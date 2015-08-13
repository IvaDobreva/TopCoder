/**
 * Test Class for WorkflowManager class and ActivityMonitoringBatch
 * Added against TC30050600
 */
@isTest
private class WorkflowManagerTest {
	static Activity__c activity;
	
	// Creating test data
    static void createTestData(){

        //Creating the user for Publisher field for Activity and Story objects
        User user = TestFactory.createUser();
        insert user;
        
        Story__c story = TestFactory.createStory();
        story.Publisher__c = user.Id;
        insert story;
        
        activity = TestFactory.createActivity(story);
        activity.Publisher__c = user.Id;
        insert activity;
        
        //Creating milestones
        Milestone__c publishDateMilestone = new Milestone__c(Name = Constants.PUBLISH_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 1, Type__c = 'Software Development', Step_Number__c = 1);
		Milestone__c startDateMilestone = new Milestone__c(Name = Constants.START_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 2);
		Milestone__c registrationDateMilestone = new Milestone__c(Name = Constants.REGISTRATION_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 3);
		Milestone__c assignmentDateMilestone = new Milestone__c(Name = Constants.ASSIGNMENT_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 1, Type__c = 'Software Development', Step_Number__c = 4);
		Milestone__c submissionDateMilestone = new Milestone__c(Name = Constants.SUBMISSION_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 7, Type__c = 'Software Development', Step_Number__c = 5);
		Milestone__c reviewDateMilestone = new Milestone__c(Name = Constants.REVIEW_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 6);
		Milestone__c acceptanceDateMilestone = new Milestone__c(Name = Constants.ACCEPTANCE_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = false, Type__c = 'Software Development', Step_Number__c = 7);
		Milestone__c endDateMilestone = new Milestone__c(Name = Constants.END_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = false, Type__c = 'Software Development', Step_Number__c = 8);

		insert new List<Milestone__c> { 
					publishDateMilestone,
				    startDateMilestone,
				    registrationDateMilestone,
				    assignmentDateMilestone,
				    submissionDateMilestone,
				    reviewDateMilestone,
				    acceptanceDateMilestone,
				    endDateMilestone
				};
        
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        activityMilestones.add(TestFactory.createActivityMilestone(activity, startDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, publishDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, registrationDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, assignmentDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, submissionDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, reviewDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, acceptanceDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(TestFactory.createActivityMilestone(activity, endDateMilestone, Date.today().addDays(-1)));
        
        insert activityMilestones;
    }

	/*
		test processActivities method called from ActivityMonitoringBatch
	*/
    static testMethod void processActivities_BatchCall_Test() {
        createTestData();
        
        Test.startTest();
        
        System.assertEquals(Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        ActivityMonitoringBatch amb = new ActivityMonitoringBatch();
		database.executeBatch(amb);
        Test.stopTest();
        
        Activity__c updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        System.assert(updatedActivity != null);
        System.assertEquals(Constants.STATUS_IN_REGISTRATION, updatedActivity.Status__c, 'Updated status as In Registration');
    }
	
	/*
		test processActivities method setting activity status as In Registration
	*/
    static testMethod void processActivities_Status_In_Registration_Test() {
        createTestData();
        
        Test.startTest();
        
        System.assertEquals(Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        WorkflowManager.processActivities(new List<Activity__c> {activity} );
        
        Activity__c updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        
        System.assertEquals(Constants.STATUS_IN_REGISTRATION, updatedActivity.Status__c, 'Updated status as In Registration');
        
        Test.stopTest();
    }
    
    /*
		test processActivities method setting activity status as In Assignment
	*/
    static testMethod void processActivities_Status_In_Assignment_Test() {
        createTestData();
        User user = TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        Registration__c registration = TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        Test.startTest();
        
        System.assertEquals(Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        WorkflowManager.processActivities(new List<Activity__c> {activity} );
        
        Activity__c updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        
        System.assertEquals(Constants.STATUS_IN_ASSIGNMENT, updatedActivity.Status__c, 'Updated status as In Assignment');
        
        Test.stopTest();
    }
    
    /*
		test processActivities method setting activity status as In Review
	*/
    static testMethod void processActivities_Status_In_Review_Test() {
        createTestData();
        User user = TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        Registration__c registration = TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        update activity;
        
        Submission__c submission = TestFactory.createSubmission(activity);
        submission.Submitting_Member__c = user.Id;
        submission.Submission_Timestamp__c = DateTime.now().addHours(-48);
        insert submission;
        
        Test.startTest();
        
        System.assertEquals(Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        WorkflowManager.processActivities(new List<Activity__c> {activity} );
        
        Activity__c updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        
        System.assertEquals(Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        Test.stopTest();
    }
    
    /*
		test processSubmissionReview method will all activity Summissions marked as Review Complete
	*/
    static testMethod void processSubmissionReview_AllStatus_ReviewComplete_Test() {
        createTestData();
        User user = TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        Registration__c registration = TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        update activity;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);
        Submission__c submission2 = TestFactory.createSubmission(activity);
        submission2.Submitting_Member__c = user.Id;
        submission2.Submission_Timestamp__c = DateTime.now().addHours(-48);
        insert new List<Submission__c>{submission1, submission2};
        
        Test.startTest();
        
        System.assertEquals(Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        // Calling processActivities process initail status 
        WorkflowManager.processActivities(new List<Activity__c> {activity} );
        
        Activity__c updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        System.assertEquals(Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        // Setting submission1 status as Review Complete 
        submission1.Status__c = Constants.REVIEW_COMPLETE_STATUS;
        // Setting submission2 status as Review Complete 
        submission2.Status__c = Constants.REVIEW_COMPLETE_STATUS;
        
        update new List<Submission__c>{submission1, submission2};
        
        updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        
        // Activity will be marked as complete as all submission are review complete, which further update
        // activity status as Accept and finaly as complete. 
        System.assertEquals(Constants.STATUS_COMPLETE, updatedActivity.Status__c, 'Updated status as Complete');
        
        Test.stopTest();
    }
    
    /*
		test processSubmissionReview method will one of the activity Summissions not Review Complete
	*/
    static testMethod void processSubmissionReview_NotAllStatus_ReviewComplete_Test() {
        createTestData();
        User user = TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        Registration__c registration = TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        update activity;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);
        
        Submission__c submission2 = TestFactory.createSubmission(activity);
        submission2.Submitting_Member__c = user.Id;
        submission2.Submission_Timestamp__c = DateTime.now().addHours(-48);
        insert new List<Submission__c>{submission1, submission2};
        
        Test.startTest();
        
        System.assertEquals(Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        // Calling processActivities process initail status 
        WorkflowManager.processActivities(new List<Activity__c> {activity} );
        
        Activity__c updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        System.assertEquals(Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        // Setting submission1 status as Review Complete 
        submission1.Status__c = Constants.REVIEW_COMPLETE_STATUS;
        // Setting submission2 status as Ready To Review 
        submission2.Status__c = Constants.READY_TO_REVIEW_STATUS;
        
        update new List<Submission__c>{submission1, submission2};
        
        updatedActivity = [Select Status__c from Activity__c where id =: activity.Id];
        
        // There will be no update to activity status as there is on submission not review 
        System.assertEquals(Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        Test.stopTest();
    }
}