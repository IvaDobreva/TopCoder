public with sharing class CE_SubmissionService implements CE_ISubmissionService {
    @TestVisible private static final Decimal MAX_SCORE_PER_REQUIREMENT = 40;
    @TestVisible private static final Decimal MIN_SCORE_PER_REQUIREMENT = 10;
    /**
     * copies requirements to Submission Requirement table.
     * @param  activity    parent activity of the submissions
     * @param  submissions list of submission for which we initialize scorecards
     * @return             List<CE_Submission_Requirement__c>
     */
    public List<CE_Submission_Requirement__c> initializeScorecard(CE_Activity__c activity, List<CE_Submission__c> submissions) {
        List<CE_Requirement__c> requirementsForActivity = [SELECT Id FROM CE_Requirement__c WHERE CE_Activity__c = :activity.Id];
        List<CE_Submission_Requirement__c> submissionsRequirements = new List<CE_Submission_Requirement__c>();

        for (CE_Submission__c submission : submissions) {
            for (CE_Requirement__c requirementForActivity : requirementsForActivity) {
                CE_Submission_Requirement__c newRequirement = new CE_Submission_Requirement__c(CE_Submission__c = submission.Id, CE_Requirement__c = requirementForActivity.Id, Evaluation_Score__c = 0);
                submissionsRequirements.add(newRequirement);
            }
        }
        insert submissionsRequirements;
        return submissionsRequirements;
    }
    /**
     * only allow users to create submission before submission due date or review date.
     * Updated against TC30050600 
     * @param  submission submission record to create
     * @param  activity   submission's parent activity
     * @param  attachment submission's attachment
     * @return            CE_Submission__c
     */
    public CE_Submission__c createSubmission(CE_Submission__c submission, CE_Activity__c activity, Attachment attachment) {
        List<sObject> objectsToInsert = new List<sObject>();
        
         List<CE_ActivityMilestones__c> milestones = [SELECT CE_Milestone__c, Scheduled_Date__c
                FROM CE_ActivityMilestones__c
                WHERE CE_Activity__c = :activity.Id AND CE_Milestone__r.Name LIKE :CE_Constants.SUBMISSION_DATE_MILESTONE_NAME];
        if (milestones.size() == 0)
            throw new SubmissionServiceException('Cannot find Submission Date milestone for the provided activity.');
        
        if (milestones[0].Scheduled_Date__c < Datetime.now())
             throw new SubmissionServiceException('Cannot create submission after due date.');
        
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        try {
            submission.Submission_Timestamp__c = DateTime.now();
            insert submission;
            
            if(attachment != null) {
                attachment.ParentId = submission.Id;
                insert attachment;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            throw ex;
        }
        return submission;
    }
    
    /**
     * Gets the list of submissions for each user submitted before the review date
     * @param  activity activity for which we need to return submissions
     * @return          List<CE_Submission__c>
     */
    public List<CE_Submission__c> getValidSubmissions(CE_Activity__c activity) {
        // Bug fix : http://community.topcoder.com/tc?module=ProjectDetail&pj=30051251
        List<CE_ActivityMilestones__c> submitMilestoneList = [SELECT Id, Scheduled_Date__c FROM CE_ActivityMilestones__c WHERE CE_Activity__c = :activity.Id AND CE_Milestone__r.Name = :CE_Constants.SUBMISSION_DATE_MILESTONE_NAME LIMIT 1];
        
        // If we dont have setup the Submission Milestone, Just return the empty list.
        if(submitMilestoneList == null || submitMilestoneList.size() != 1){
            return new List<CE_Submission__c>();
        }
        
        Id currentUserId = UserInfo.getUserId();
        // Query Crowd_Exchange_User_Type__c for current logged in user
        User usr = [SELECT Crowd_Exchange_User_Type__c FROM User WHERE Id = :currentUserId];
        
        Id activityId = activity.Id;
            
        String selectQuery = 'SELECT   Name, CE_Activity__c, Evaluation_Percentage__c,  Submission_Score__c,  Overall_Comment__c, '+
                              ' Status__c,  Submission_Timestamp__c, Submitting_Member__c,  Submitting_Member__r.FirstName, '+
                              ' Submitting_Member__r.LastName,  Submitting_Member__r.SmallPhotoUrl, '+
                                // we will load only on submission i.e latest.
                              ' (SELECT Name, Description, ContentType, BodyLength, CreatedDate  FROM Attachments order by CreatedDate asc limit 1), '+
                              ' (Select Evaluation_Score__c From Submission_Requirements__r) '+
                              ' FROM CE_Submission__c WHERE CE_Activity__c = :activityId AND Submission_Timestamp__c != null ';
        
        if(usr.Crowd_Exchange_User_Type__c == CE_Constants.PUBLISHER){
            selectQuery += ' AND Submitting_Member__c != null ';
        } else if(usr.Crowd_Exchange_User_Type__c == CE_Constants.MEMBER) {
            selectQuery += ' AND Submitting_Member__c = :currentUserId ';
        }                
        
        selectQuery += ' ORDER BY Submission_Timestamp__c DESC ';
        
        //Querying submissions for the activity. Filtering all broken submissions without timestamp and Submitting member reference
        List<CE_Submission__c> submissions = Database.query(selectQuery);
        
        // Added check for submission Timestamp to be less then or equal to Activity Milestones Schedule Date
        List<CE_Submission__c> validSubmissions = new List<CE_Submission__c>();
            for(CE_Submission__c submission : submissions) {
                if(submission.Submission_Timestamp__c.date() <= submitMilestoneList[0].Scheduled_Date__c){
                    validSubmissions.add(submission);
                }
            }
        return validSubmissions;
    }
    
    /**
     * update score for a lists of requirements
     * @param submissionRequirements [description]
     */
    public void evaluateRequirement(List<CE_Submission_Requirement__c> submissionRequirements) {
        update submissionRequirements;
    }
    
    /**
     * updates scoring in parent Submission object
     * Updated against TC30050600 
     * @param  submission submission for which we need to calculate score
     * @return            Integer - Summary score
     */
    public Integer calculateSubmissionScore(CE_Submission__c submission) {
        
        List<CE_Submission_Requirement__c> submissionRequirements = [SELECT Evaluation_Score__c, CE_Requirement__r.Requirement_Weight__c 
                        FROM CE_Submission_Requirement__c WHERE CE_Submission__c = :submission.Id];

        Decimal evaluationScoreSum = 0;
        Decimal maximumScore = 0;
        for (CE_Submission_Requirement__c submissionRequirement : submissionRequirements) {
            maximumScore += (MAX_SCORE_PER_REQUIREMENT * CE_Constants.REQUIRMENT_SCORE_BY_WEIGHT.get(submissionRequirement.CE_Requirement__r.Requirement_Weight__c));
            
            Integer weightScore = 0;
            if(String.isNotBlank(submissionRequirement.CE_Requirement__r.Requirement_Weight__c)) {
                weightScore = CE_Constants.REQUIRMENT_SCORE_BY_WEIGHT.get(submissionRequirement.CE_Requirement__r.Requirement_Weight__c);
            }
            
            if (submissionRequirement.Evaluation_Score__c != null) {
                evaluationScoreSum += (weightScore * submissionRequirement.Evaluation_Score__c);
            } else {
                evaluationScoreSum += (weightScore * MIN_SCORE_PER_REQUIREMENT); //We think that if Evaluation_Score__c is null then Requirement didn't met
            }
        }
        submission.Submission_Score__c = evaluationScoreSum;
        submission.Evaluation_Percentage__c = (evaluationScoreSum / maximumScore) * 100; //Calculate percentage of current total score
        update submission;
        return (Integer)evaluationScoreSum;
    }
    /**
     * change status of Activity and Submissions to Ready to Review, Review Complete
     * @param  submissions Submissions to update
     * @return         List<CE_Submission__c>    
     */
    public List<CE_Submission__c> updateStatus(List<CE_Submission__c> submissions) {
        for(CE_Submission__c submission : submissions){
            if(submission.Status__c == null)
                submission.Status__c = CE_Constants.READY_TO_REVIEW_STATUS;
            else if(submission.Status__c == CE_Constants.READY_TO_REVIEW_STATUS)
                submission.Status__c = CE_Constants.REVIEW_COMPLETE_STATUS;
        }
        update submissions;
        return submissions;
    }
    /**
     * returns a collections of submissions for a particular member
     * @param  user user for who we need to return submissions
     * @return      List<CE_Submission__c>
     */
    public List<CE_Submission__c> getSubmissionsForUser(User user) {
        return [SELECT  Name,
                        CE_Activity__c,
                        Evaluation_Percentage__c,
                        Submission_Score__c,
                        Submission_Timestamp__c,
                        Submitting_Member__c
                FROM CE_Submission__c
                WHERE Submitting_Member__c = :user.Id];
    }
    /**
     * handles file upload process to SFDC
     * Updated against TC30050600 
     * @param  attachment new attachment for submission
     * @param  submission Attachment's parent submission
     * @return            Attachment - inserted attachment
     */
    public Attachment uploadFile(Attachment attachment, CE_Submission__c submission) {
        attachment.ParentId = submission.Id;
        insert attachment;
        return attachment;
    }


    /**
     * Custom Submission Service Exception
     */
    public class SubmissionServiceException extends CE_ServiceException {

    }
}