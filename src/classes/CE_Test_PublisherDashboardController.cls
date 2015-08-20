@isTest
private class CE_Test_PublisherDashboardController {
    
    // Creat Test Data
    public static void createTestData(){

        // Create Publisher user
    	User user = CE_TestFactory.createUser();
    	user.Crowd_Exchange_User_Type__c = 'Publisher';
        insert user;
        
        //Create Story record
        List<CE_Story__c> listStory = new List<CE_Story__c>();
    	CE_Story__c story = CE_TestFactory.createStory();
    	story.Publisher__c = userinfo.getuserId();
        listStory.add(story);
        
        //Create Story record
    	CE_Story__c story1 = CE_TestFactory.createStory();
    	story.Publisher__c = userinfo.getuserId();
    	story.Status__c = 'Completed';
        listStory.add(story1);
        insert listStory;
        
        //Create Activities 
        List<CE_Activity__c> listActivity = new List<CE_Activity__c>();
        CE_Activity__c activity1 = CE_TestFactory.createActivity(story);
        activity1.Status__c = 'Completed';
        activity1.Publisher__c = userinfo.getuserId();
        activity1.Assigned_Member__c = userinfo.getuserId();
        listActivity.add(activity1);
        
        CE_Activity__c activity2 = CE_TestFactory.createActivity(story);
        activity2.Status__c = 'In Submission';
        activity2.Assigned_Member__c = user.Id;
        activity2.Publisher__c = userinfo.getuserId();
        listActivity.add(activity2);
        insert listActivity;
         
        //Create Summary Data
    	CE_TestFactory.createSummaryData();
    }
    
    /*
        Test method with Test Data
    */
	private static testMethod void testCrowdExchangePublisherDashboard(){
	    
        //Create test Data
        createTestData();
        
    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CE_PublisherDashboardController crowdExchangePublisherDashboard = new CE_PublisherDashboardController();
		
		// System Asserts
    	System.assert(crowdExchangePublisherDashboard.isActiveStoryWrapperPresent == true,'Active Story not present');
    	System.assert(crowdExchangePublisherDashboard.isCompletedStoryWrapperPresent == true,'Completed Story not present');
    	
    	// Stop Test
    	Test.stopTest();
	}
	
	/*
        Test methods without Test Data
    */
	private static testMethod void testCrowdExchangePublisherDashboard_NoData(){

    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CE_PublisherDashboardController crowdExchangePublisherDashboard = new CE_PublisherDashboardController();
		          
		// System Asserts
    	System.assert(crowdExchangePublisherDashboard.isMemberSkillSnapshotPresent == false,'Member Skill Snapshot data present');
    	System.assert(crowdExchangePublisherDashboard.isActiveStoryWrapperPresent == false,'Active Story present');
    	System.assert(crowdExchangePublisherDashboard.isCompletedStoryWrapperPresent == false,'Completed Story present');
    	
    	// Stop Test
    	Test.stopTest();
	}

}