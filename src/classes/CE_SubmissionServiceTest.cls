@isTest
private class CE_SubmissionServiceTest {
    static CE_ISubmissionService mService = null;
    static CE_ISubmissionService getService() {
        if (mService == null)
            mService = new CE_SubmissionService();
        return mService;
    }

    @isTest static void initializeScorecard_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        Integer dayIndex = 0;
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today().addDays(dayIndex++)));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        insert submission;

        //Start testing
        Test.startTest();
        List<CE_Submission_Requirement__c> result = getService().initializeScorecard(activity, new List<CE_Submission__c> {submission});
        Test.stopTest();

        System.assertEquals(requirements.size(), result.size(), 'Seems like method created wrong number of submission requirements');
        Map<Id, CE_Requirement__c> requirementsMap = new Map<Id, CE_Requirement__c>(requirements);
        for (CE_Submission_Requirement__c submissionRequirement : result) {
            System.assertNotEquals(null, submissionRequirement.Id, 'Seems like requirement was not inserted');
            System.assertEquals(submission.Id, submissionRequirement.CE_Submission__c, 'Requirement has wrong submission reference');
            requirementsMap.remove(submissionRequirement.CE_Requirement__c);
        }
        System.assertEquals(0, requirementsMap.size(), 'Seems like not all requirements were created');
    }

    @isTest static void createSubmission_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today().addDays(1)));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        Attachment attachment = CE_TestFactory.createAttachment();

        //Start testing
        Test.startTest();
        getService().createSubmission(submission, activity, attachment);
        Test.stopTest();
        //Start assertion
        System.assertNotEquals(null, submission.Id, 'Seems like submission was not inserted');
        System.assertNotEquals(null, attachment.Id, 'Seems like attachment was not inserted');
        System.assertEquals(submission.Id, attachment.ParentId, 'Attachment has wrong ParentId. ParentId must equals Submission.Id');
        //List<UserActivityMilestone__c> userActivityMilestones = [SELECT Id FROM UserActivityMilestone__c WHERE CE_Activity__c = :activity.Id AND User__c = :UserInfo.getUserId() AND Attachment_ID__c = :attachment.Id];
        //System.assertEquals(1, userActivityMilestones.size(), 'Cannot find UserActivityMilestone for the submission');
    }
    
    @isTest 
    static void createSubmission_negative_submitAfterDueDate() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        Attachment attachment = CE_TestFactory.createAttachment();
        Boolean operationFailed = false;

        //Start testing
        Test.startTest();
        try {
            getService().createSubmission(submission, activity, attachment);
        } catch (Exception ex) {
            operationFailed = true;
        }
        Test.stopTest();
        //Start assertion
        System.assert(operationFailed, 'Operation must fail. Cannot create submission after Due Date');

    }
    @isTest static void createSubmission_negative_noMilestones() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        Attachment attachment = CE_TestFactory.createAttachment();
        Boolean operationFailed = false;

        //Start testing
        Test.startTest();
        try {
            getService().createSubmission(submission, activity, attachment);
        } catch (Exception ex) {
            operationFailed = true;
        }
        Test.stopTest();
        //Start assertion
        System.assert(operationFailed, 'Operation must fail. Because Due Date cannot be verified, because there are no ActivityMilestones');

    }
    @isTest static void getValidSubmissions_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        //VAlid submsiion
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        //Overwritten submission
        CE_Submission__c submission2 = CE_TestFactory.createSubmission(activity);
        submission2.Submission_Timestamp__c = submission2.Submission_Timestamp__c.addMinutes(5);
        //Submission after due date
        CE_Submission__c submission3 = CE_TestFactory.createSubmission(activity);
        submission3.Submission_Timestamp__c = submission3.Submission_Timestamp__c.addDays(20);
        insert new List<CE_Submission__c> {submission, submission2, submission3};

        Test.startTest();
        List<CE_Submission__c> result = getService().getValidSubmissions(activity);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Seems like method returned wrong number of submissions');
        // TODO: need to fix this figure out why it isn't working....
        System.debug('+++Result[0].Date:' + result[0].Submission_Timestamp__c );
        System.assertEquals(submission2.Id, result[0].Id, 'Seems like method returned wrong submission');
    }

    @isTest static void evaluateRequirement_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        insert submission;
        CE_Submission_Requirement__c submissionRequirement = CE_TestFactory.createSubmissionRequirement(submission, requirements[0]);
        insert submissionRequirement;
        submissionRequirement.Evaluation_Score__c = 5;

        //Start testing
        Test.startTest();
        getService().evaluateRequirement(new List<CE_Submission_Requirement__c> {submissionRequirement});
        Test.stopTest();

        submissionRequirement = [SELECT Evaluation_Score__c FROM CE_Submission_Requirement__c WHERE Id = :submissionRequirement.Id];
        System.assertEquals(5, submissionRequirement.Evaluation_Score__c, 'Seems like submission requirement was not updated');
    }
    
    // Update test method as per change to calculateSubmissionScore 
    // Updated against TC30050600 
    @isTest static void calculateSubmissionScore_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        insert submission;
        List<CE_Submission_Requirement__c> submissionRequirements = new List<CE_Submission_Requirement__c>();
        for (Integer i = 0 ; i < requirements.size(); i++) {

            CE_Submission_Requirement__c submissionRequirement = CE_TestFactory.createSubmissionRequirement(submission, requirements[i]);
            submissionRequirement.Evaluation_Score__c = CE_SubmissionService.MAX_SCORE_PER_REQUIREMENT;
            submissionRequirements.add(submissionRequirement);
        }
        //Making one submission requirement unfiled, so score will be MIN
        submissionRequirements[0].Evaluation_Score__c = null;
        insert submissionRequirements;

        //Start testing
        Test.startTest();
        Integer result = getService().calculateSubmissionScore(submission);
        Test.stopTest();
        
        // There are total 12 requirments with Requirement Weight as medium i.e 2 multiple maximum score
        Decimal maxScore = 12 * (CE_SubmissionService.MAX_SCORE_PER_REQUIREMENT * 2);
        
        // There are total 11 CE_Submission_Requirement__c with Evaluation_Score__c as maximum i.e 4 and corresponding requirment 
        // weight as medium i.e 2 Plus one CE_Submission_Requirement__c with minimum score as it Evaluation_Score__c is set to null.
        Decimal evaluationScore = 11 * (CE_SubmissionService.MAX_SCORE_PER_REQUIREMENT * 2) + (CE_SubmissionService.MIN_SCORE_PER_REQUIREMENT * 2);
        
        //Start assertion
        System.assertEquals(evaluationScore, result, 'Method returned wrong points sum');
        submission = [SELECT Submission_Score__c, Evaluation_Percentage__c FROM CE_Submission__c WHERE Id = :submission.Id];
        System.assertEquals(evaluationScore, submission.Submission_Score__c, 'Submition has wrong score');
        System.assertEquals(evaluationScore / (maxScore) * 100, submission.Evaluation_Percentage__c, 'Submition has wrong percentage');
    }

    @isTest static void updateStatus_positive_goToReadyToTest() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        insert submission;

        //Start testing
        Test.startTest();
        List<CE_Submission__c> result = getService().updateStatus(new List<CE_Submission__c> {submission});
        Test.stopTest();
        //Start assertion
        System.assertEquals(1, result.size(), 'Method returned wrong number of submissions');
        System.assertEquals(Submission.Id, result[0].Id, 'Method returned wrong submission');
        System.assertEquals(CE_Constants.READY_TO_REVIEW_STATUS, result[0].Status__c, 'Method did not changed submission status');
    }
    @isTest static void updateStatus_positive_goToReviewComplete() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        submission.Status__c = CE_Constants.READY_TO_REVIEW_STATUS;
        insert submission;

        //Start testing
        Test.startTest();
        List<CE_Submission__c> result = getService().updateStatus(new List<CE_Submission__c> {submission});
        Test.stopTest();
        //Start assertion
        System.assertEquals(1, result.size(), 'Method returned wrong number of submissions');
        System.assertEquals(submission.Id, result[0].Id, 'Method returned wrong submission');
        System.assertEquals(CE_Constants.REVIEW_COMPLETE_STATUS, result[0].Status__c, 'Method did not changed submission status');
    }
    @isTest static void getSubmissionsForUser_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        insert submission;

        //Start testing
        Test.startTest();
        List<CE_Submission__c> result = getService().getSubmissionsForUser(new User(Id = UserInfo.getUserId()));
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Method returned wrong number of submissions');
        System.assertEquals(submission.Id, result[0].Id, 'Method returned wrong submission');
    }

    @isTest static void uploadFile_positive() {
        //Init test data
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
       
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        insert submission;
        Attachment attachment = CE_TestFactory.createAttachment();

        //Start testing
        Test.startTest();
        Attachment result = getService().uploadFile(attachment, submission);
        Test.stopTest();
        //Start assertion
        System.assertNotEquals(null, attachment.Id, 'Seems like attacment was not inserted');
        System.assertEquals(submission.Id, attachment.ParentId, 'Attachment must belong to the passed submission.');
        
      
    }

}