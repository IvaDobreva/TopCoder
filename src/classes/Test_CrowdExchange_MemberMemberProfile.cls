@isTest
private class Test_CrowdExchange_MemberMemberProfile {
    
    // Creat Test Data
    public static void createTestData(){

        // Create Publisher user
    	User user = TestFactory.createUser();
    	user.Crowd_Exchange_User_Type__c = 'Publisher';
        insert user;
        
        //Create Story record
    	Story__c story = TestFactory.createStory();
        insert story;
        
        //Create Activities 
        List<Activity__c> listActivity = new List<Activity__c>();
        Activity__c activity1 = TestFactory.createActivity(story);
        activity1.Status__c = 'Completed';
        activity1.Publisher__c = userinfo.getuserId();
        activity1.Assigned_Member__c = userinfo.getuserId();
        listActivity.add(activity1);
        
        Activity__c activity2 = TestFactory.createActivity(story);
        activity2.Status__c = 'In Registration';
        activity2.Assigned_Member__c = userinfo.getuserId();
        activity2.Publisher__c = userinfo.getuserId();
        listActivity.add(activity2);
        insert listActivity;
        
        //Create Header Picture
        User_Header_Picture__c userHeaderPicture = new User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        
        //Create Summary Data
    	TestFactory.createSummaryData();
    }
    
    /*
        Test method with Test Data
    */
	private static testMethod void testMemberMemberProfile (){
	    
        //Create test Data
        createTestData();
        
    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CrowdExchange_MemberMemberProfile crowdExchangeMemberMemberProfile = new CrowdExchange_MemberMemberProfile();

		// System Asserts
    	System.assert(crowdExchangeMemberMemberProfile.isCompletedActivityPresent == true,'Completed Activities not present');
    	System.assert(crowdExchangeMemberMemberProfile.isCurrentActivityPresent == true,'Active Activities not present');
    	
    	// Stop Test
    	Test.stopTest();
	}
	
	/*
        Test methods without Test Data
    */
	private static testMethod void testMemberMemberProfile_NoData(){

    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CrowdExchange_MemberMemberProfile crowdExchangeMemberMemberProfile = new CrowdExchange_MemberMemberProfile();
		
		// System Asserts
    	System.assert(crowdExchangeMemberMemberProfile.isCompletedActivityPresent == false,'Completed Activities present');
    	System.assert(crowdExchangeMemberMemberProfile.isCurrentActivityPresent == false,'Active Activities present');
    	
    	// Stop Test
    	Test.stopTest();
	}

}