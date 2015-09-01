/**
 * Test Class for CE_WorkflowManager class and CE_ActivityMonitoringBatch
 * Added against TC30050600
 */
@isTest
private class CE_WorkflowManagerTest {
	static CE_Activity__c activity;
	
	// Creating test data
    static void createTestData(){

        //Creating the user for Publisher field for Activity and Story objects
        User user = CE_TestFactory.createUser();
        insert user;
        
        CE_Story__c story = CE_TestFactory.createStory();
        story.Publisher__c = user.Id;
        insert story;
        
        activity = CE_TestFactory.createActivity(story);
        activity.Publisher__c = user.Id;
        insert activity;
        
        //Creating milestones
        CE_Milestone__c publishDateMilestone = new CE_Milestone__c(Name = CE_Constants.PUBLISH_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 1, Type__c = 'Software Development', Step_Number__c = 1);
		CE_Milestone__c startDateMilestone = new CE_Milestone__c(Name = CE_Constants.START_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 2);
		CE_Milestone__c registrationDateMilestone = new CE_Milestone__c(Name = CE_Constants.REGISTRATION_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 3);
		CE_Milestone__c assignmentDateMilestone = new CE_Milestone__c(Name = CE_Constants.ASSIGNMENT_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 1, Type__c = 'Software Development', Step_Number__c = 4);
		CE_Milestone__c submissionDateMilestone = new CE_Milestone__c(Name = CE_Constants.SUBMISSION_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 7, Type__c = 'Software Development', Step_Number__c = 5);
		CE_Milestone__c reviewDateMilestone = new CE_Milestone__c(Name = CE_Constants.REVIEW_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 6);
		CE_Milestone__c acceptanceDateMilestone = new CE_Milestone__c(Name = CE_Constants.ACCEPTANCE_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = false, Type__c = 'Software Development', Step_Number__c = 7);
		CE_Milestone__c endDateMilestone = new CE_Milestone__c(Name = CE_Constants.END_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = false, Type__c = 'Software Development', Step_Number__c = 8);

		insert new List<CE_Milestone__c> { 
					publishDateMilestone,
				    startDateMilestone,
				    registrationDateMilestone,
				    assignmentDateMilestone,
				    submissionDateMilestone,
				    reviewDateMilestone,
				    acceptanceDateMilestone,
				    endDateMilestone
				};
        
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, startDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, publishDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, registrationDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, assignmentDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, submissionDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, reviewDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, acceptanceDateMilestone, Date.today().addDays(-1)));
        activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, endDateMilestone, Date.today().addDays(-1)));
        
        insert activityMilestones;
    }

	/*
		test processActivities method called from CE_ActivityMonitoringBatch
	*/
    static testMethod void processActivities_BatchCall_Test() {
        createTestData();
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        CE_ActivityMonitoringBatch amb = new CE_ActivityMonitoringBatch();
		database.executeBatch(amb);
        Test.stopTest();
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        System.assert(updatedActivity != null);
        System.assertEquals(CE_Constants.STATUS_IN_REGISTRATION, updatedActivity.Status__c, 'Updated status as In Registration');
    }
	
	/*
		test processActivities method setting activity status as In Registration
	*/
    static testMethod void processActivities_Status_In_Registration_Test() {
        createTestData();
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        
        System.assertEquals(CE_Constants.STATUS_IN_REGISTRATION, updatedActivity.Status__c, 'Updated status as In Registration');
        
        Test.stopTest();
    }
    
    /*
		test processActivities method setting activity status as In Assignment
	*/
    static testMethod void processActivities_Status_In_Assignment_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        
        System.assertEquals(CE_Constants.STATUS_IN_ASSIGNMENT, updatedActivity.Status__c, 'Updated status as In Assignment');
        
        Test.stopTest();
    }
    
    /*
		test processActivities method setting activity status as In Review
	*/
    static testMethod void processActivities_Status_In_Review_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        update activity;
        
        CE_Submission__c submission = CE_TestFactory.createSubmission(activity);
        submission.Submitting_Member__c = user.Id;
        submission.Submission_Timestamp__c = DateTime.now().addHours(-48);
        insert submission;
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        
        System.assertEquals(CE_Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');

        // Test isAnySubmissionReview()
        CE_Submission__c submission2 = CE_TestFactory.createSubmission(activity);
        submission2.Submitting_Member__c = user.Id;
        submission2.Submission_Timestamp__c = DateTime.now().addHours(-48);
		submission2.Status__c = CE_Constants.REVIEW_COMPLETE_STATUS;
        insert submission2;
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        Test.stopTest();
    }
    
    /*
		test processSubmissionReview method will all activity Summissions marked as Review Complete
	*/
    static testMethod void processSubmissionReview_AllStatus_ReviewComplete_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        activity.hasAwards__c = true;
        update activity;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);
        CE_Submission__c submission2 = CE_TestFactory.createSubmission(activity);
        submission2.Submitting_Member__c = user.Id;
        submission2.Submission_Timestamp__c = DateTime.now().addHours(-48);
        insert new List<CE_Submission__c>{submission1, submission2};
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        // Calling processActivities process initail status 
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        System.assertEquals(CE_Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        // Setting submission1 status as Review Complete 
        submission1.Status__c = CE_Constants.REVIEW_COMPLETE_STATUS;
        // Setting submission2 status as Review Complete 
        submission2.Status__c = CE_Constants.REVIEW_COMPLETE_STATUS;
        
        update new List<CE_Submission__c>{submission1, submission2};
        
        updatedActivity = [Select Status__c, Notification_Code__c from CE_Activity__c where id =: activity.Id];
        
        // Activity will be marked as complete as all submission are review complete, which further update
        // activity status as Accept and finaly as complete. 
        System.assertEquals(CE_Constants.STATUS_COMPLETED, updatedActivity.Status__c, 'Updated status as Complete');
        
        submission1 = [SELECT Notification_Code__c FROM CE_Submission__c WHERE Id = :submission1.Id];
        
		// Notification Code as Submission Review Complete
        System.assertEquals(CE_Constants.NOTIFICATION_SUBMISSION_REVIEW_COMPLETE, 
                            submission1.Notification_Code__c, 'Updated Notification Code as Submission Review Complete');
        
        Test.stopTest();
    }
    
    /*
		test processSubmissionReview method will one of the activity Summissions not Review Complete
	*/
    static testMethod void processSubmissionReview_NotAllStatus_ReviewComplete_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        update activity;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);
        
        CE_Submission__c submission2 = CE_TestFactory.createSubmission(activity);
        submission2.Submitting_Member__c = user.Id;
        submission2.Submission_Timestamp__c = DateTime.now().addHours(-48);
        insert new List<CE_Submission__c>{submission1, submission2};
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        // Calling processActivities process initail status 
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        System.assertEquals(CE_Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        // Setting submission1 status as Review Complete 
        submission1.Status__c = CE_Constants.REVIEW_COMPLETE_STATUS;
        // Setting submission2 status as Ready To Review 
        submission2.Status__c = CE_Constants.READY_TO_REVIEW_STATUS;
        
        update new List<CE_Submission__c>{submission1, submission2};
        
        updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        
        // There will be no update to activity status as there is on submission not review 
        System.assertEquals(CE_Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        
        
        Test.stopTest();
    }

    /*
		test processActivities method setting notification "No Registered Users" "No Submissions" "No Review Received"
	*/
    static testMethod void processActivities_No_Reg_Sub_Review_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Activity__c updatedActivity = [Select Status__c, Notification_Code__c from CE_Activity__c where id =: activity.Id];
        
        System.assertEquals(CE_Constants.STATUS_IN_REGISTRATION, updatedActivity.Status__c, 'Updated status as In Registration');
        System.assertEquals(CE_Constants.NOTIFICATION_NO_REGISTERED_USERS, updatedActivity.Notification_Code__c, 'Updated Notification Code as No Registered Users');

        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        update activity;

        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        updatedActivity = [Select Status__c, Notification_Code__c from CE_Activity__c where id =: activity.Id];
        
        System.assertEquals(CE_Constants.STATUS_IN_SUBMISSION, updatedActivity.Status__c, 'Updated status as In Submission');
        System.assertEquals(CE_Constants.NOTIFICATION_NO_SUBMISSIONS, updatedActivity.Notification_Code__c, 'Updated Notification Code as No Submissions');

        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);
		insert submission1;

        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        updatedActivity = [Select Status__c, Notification_Code__c from CE_Activity__c where id =: activity.Id];
        
        System.assertEquals(CE_Constants.STATUS_IN_REVIEW, updatedActivity.Status__c, 'Updated status as In Review');
        System.assertEquals(CE_Constants.NOTIFICATION_NO_REVIEWS_RECEIVED, updatedActivity.Notification_Code__c, 'Updated Notification Code as No Review Received');        

        Test.stopTest();
    }

    /*
		test processActivityCancel method 
	*/
    static testMethod void processActivityCancel_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        activity.hasAwards__c = true;
        update activity;

        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);        
        insert submission1;

        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        // Calling processActivities process initail status 
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        activity.Status__c = CE_Constants.STATUS_CANCELED;
        update activity;
        
        CE_Registration__c updatedRegistration = [Select Notification_Code__c from CE_Registration__c where id =: registration.Id];
        System.assertEquals(CE_Constants.NOTIFICATION_ACTIVITY_CANCELLED, updatedRegistration.Notification_Code__c, 'Updated notification code as Activity Canceled');

        Test.stopTest();
    }

    /*
		test processStoryCancel method 
	*/
    static testMethod void processStoryCancel_Test() {
        createTestData();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // adding a registration record.
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        activity.Assigned_Member__c = user.Id;
        activity.hasAwards__c = true;
        update activity;

        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        submission1.Submitting_Member__c = user.Id;
        submission1.Submission_Timestamp__c = DateTime.now().addHours(-48);        
        insert submission1;

        Test.startTest();
        
        System.assertEquals(CE_Constants.STATUS_DRAFT, activity.Status__c, 'Initail status as Draft');
        
        // Calling processActivities process initail status 
        CE_WorkflowManager.processActivities(new List<CE_Activity__c> {activity} );
        
        CE_Story__c story = [SELECT Status__c FROM CE_Story__c WHERE Id = :activity.CE_Story__c];
        story.Status__c = CE_Constants.STATUS_STORY_CANCELLED;
        update story;
        
        CE_Activity__c updatedActivity = [Select Status__c from CE_Activity__c where id =: activity.Id];
        CE_Registration__c updatedRegistration = [Select Notification_Code__c from CE_Registration__c where id =: registration.Id];
        System.assertEquals(CE_Constants.STATUS_CANCELED, updatedActivity.Status__c, 'Updated status as Canceled');
        System.assertEquals(CE_Constants.NOTIFICATION_STORY_CANCELLED, updatedRegistration.Notification_Code__c, 'Updated notification code as Activity Canceled');

        Test.stopTest();
    }
}