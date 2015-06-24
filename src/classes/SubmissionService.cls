public with sharing class SubmissionService implements ISubmissionService {
    @TestVisible private static final Decimal MAX_SCORE_PER_REQUIREMENT = 4;
    @TestVisible private static final Decimal MIN_SCORE_PER_REQUIREMENT = 1;
    /**
     * copies requirements to Submission Requirement table.
     * @param  activity    parent activity of the submissions
     * @param  submissions list of submission for which we initialize scorecards
     * @return             List<Submission_Requirement__c>
     */
    public List<Submission_Requirement__c> initializeScorecard(Activity__c activity, List<Submission__c> submissions) {
        List<Requirement__c> requirementsForActivity = [SELECT Id FROM Requirement__c WHERE Activity__c = :activity.Id];
        List<Submission_Requirement__c> submissionsRequirements = new List<Submission_Requirement__c>();

        for (Submission__c submission : submissions) {
            for (Requirement__c requirementForActivity : requirementsForActivity) {
                Submission_Requirement__c newRequirement = new Submission_Requirement__c(Submission__c = submission.Id, Requirement__c = requirementForActivity.Id, Evaluation_Score__c = 0);
                submissionsRequirements.add(newRequirement);
            }
        }
        insert submissionsRequirements;
        return submissionsRequirements;
    }
    /**
     * only allow users to create submission before submission due date or review date.
     * @param  submission submission record to create
     * @param  activity   submission's parent activity
     * @param  attachment submission's attachment
     * @return            Submission__c
     * TODO:  remove Due_Date__c
     */
    public Submission__c createSubmission(Submission__c submission, Activity__c activity, Attachment attachment) {
        List<sObject> objectsToInsert = new List<sObject>();
        List<ActivityMilestones__c> milestones = [SELECT Milestone__c
                FROM ActivityMilestones__c
                WHERE Activity__c = :activity.Id AND Milestone__r.Name LIKE :Constants.SUBMISSION_DATE_MILESTONE_NAME];
        if (milestones.size() == 0)
            throw new SubmissionServiceException('Cannot find Submission Date milestone for the provided activity.');
        // if (milestones[0].Milestone__r.Due_Date__c < Datetime.now())
        //    throw new SubmissionServiceException('Cannot create submission after due date.');
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        try {
            submission.Submission_Timestamp__c = DateTime.now();
            insert submission;
            attachment.ParentId = submission.Id;
            insert attachment;
            insert new UserActivityMilestone__c(
                Activity__c = activity.Id,
                ActivityMilestones__c = milestones[0].Id,
                Attachment_ID__c = attachment.Id,
                User__c = submission.Submitting_Member__c,
                Activity_Milestone_Timestamp__c = DateTime.now());
        } catch (Exception ex) {
            Database.rollback(sp);
            throw ex;
        }
        return submission;
    }
    /**
     * Gets the list of submissions is the last submitted (most recent) submission for each user submitted before the review date
     * @param  activity activity for which we need to return submissions
     * @return          List<Submission__c>
     */
     
    /**
    *  @TODO needs to be fixed to use Activity Milestone timestamps
    * 
    */  
    public List<Submission__c> getValidSubmissions(Activity__c activity) {
        ActivityMilestones__c submitMilestone = [SELECT Id FROM ActivityMilestones__c WHERE Activity__c = :activity.Id AND Milestone__r.Name = :Constants.SUBMISSION_DATE_MILESTONE_NAME LIMIT 1];
        //Querying all submissions for the activity. Filtering all broken submissions without timestamp and Submitting member reference
        List<Submission__c> submissions = [SELECT   Name,
                                                    Activity__c,
                                                    Evaluation_Percentage__c,
                                                    Submission_Score__c,
                                                    Submission_Timestamp__c,
                                                    Submitting_Member__c
                                            FROM Submission__c
                                            WHERE Activity__c = :activity.Id AND Submission_Timestamp__c != null AND Submitting_Member__c != null
                                            ORDER BY Submission_Timestamp__c ASC];
        //Creating Subbmiting_Member -> Submission map to ensure that for each user there's will be only one submission
        Map<Id, Submission__c> submissionMap = new Map<Id, Submission__c>();
        /*
        for(Submission__c submission : submissions){
            if(submission.Submission_Timestamp__c <= submitMilestone.Milestone__r.Due_Date__c){
                submissionMap.put(submission.Submitting_Member__c, submission);
            }
        }
        */
        return submissionMap.values();
    }
    /**
     * update score for a lists of requirements
     * @param submissionRequirements [description]
     */
    public void evaluateRequirement(List<Submission_Requirement__c> submissionRequirements) {
        update submissionRequirements;
    }
    /**
     * updates scoring in parent Submission object
     * @param  submission submission for which we need to calculate score
     * @return            Integer - Summary score
     */
    public Integer calculateSubmissionScore(Submission__c submission) {
        List<Submission_Requirement__c> submissionRequirements = [SELECT Evaluation_Score__c FROM Submission_Requirement__c WHERE Submission__c = :submission.Id];

        Decimal scoreSum = 0;
        for (Submission_Requirement__c submissionRequirement : submissionRequirements)
            if (submissionRequirement.Evaluation_Score__c != null)
                scoreSum += submissionRequirement.Evaluation_Score__c;
            else scoreSum += MIN_SCORE_PER_REQUIREMENT; //We think that if Evaluation_Score__c is null then Requirement didn't met
        submission.Submission_Score__c = scoreSum;
        submission.Evaluation_Percentage__c = scoreSum / (submissionRequirements.size() * MAX_SCORE_PER_REQUIREMENT) * 100; //Calculate percentage of current total score
        update submission;
        return (Integer)scoreSum;
    }
    /**
     * change status of Activity and Submissions to Ready to Review, Review Complete
     * @param  submissions Submissions to update
     * @return         List<Submission__c>    
     */
    public List<Submission__c> updateStatus(List<Submission__c> submissions) {
        for(Submission__c submission : submissions){
            if(submission.Status__c == null)
                submission.Status__c = Constants.READY_TO_REVIEW_STATUS;
            else if(submission.Status__c == Constants.READY_TO_REVIEW_STATUS)
                submission.Status__c = Constants.REVIEW_COMPLETE_STATUS;
        }
        update submissions;
        return submissions;
    }
    /**
     * returns a collections of submissions for a particular member
     * @param  user user for who we need to return submissions
     * @return      List<Submission__c>
     */
    public List<Submission__c> getSubmissionsForUser(User user) {
        return [SELECT  Name,
                        Activity__c,
                        Evaluation_Percentage__c,
                        Submission_Score__c,
                        Submission_Timestamp__c,
                        Submitting_Member__c
                FROM Submission__c
                WHERE Submitting_Member__c = :user.Id];
    }
    /**
     * handles file upload process to SFDC
     * @param  attachment new attachment for submission
     * @param  submission Attachment's parent submission
     * @return            Attachment - inserted attachment
     */
    public Attachment uploadFile(Attachment attachment, Submission__c submission) {
        attachment.ParentId = submission.Id;
        //Also updating attacment ID on UserActivityMilestone object
        UserActivityMilestone__c milestone = [SELECT Attachment_ID__c
                FROM UserActivityMilestone__c
                WHERE ActivityMilestones__c IN (SELECT Id FROM ActivityMilestones__c WHERE Activity__c = :submission.Activity__c AND Milestone__r.Name LIKE :Constants.SUBMISSION_DATE_MILESTONE_NAME)
                  AND User__c = :submission.Submitting_Member__c LIMIT 1];

        insert attachment;
        milestone.Attachment_ID__c = attachment.Id;
        update milestone;
        return attachment;
    }


    /**
     * Custom Submission Service Exception
     */
    public class SubmissionServiceException extends ServiceException {

    }
}