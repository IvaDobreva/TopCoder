@isTest
private class Test_CrowdExchange_MemberDashboard {

	private static testMethod void testCrowdExchangeMemberDashboard() {
	    
    	//create test data
    	Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
    	TestFactory.createSummaryData();
    	
    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance with standard controller
		CrowdExchange_MemberDashboard crowdExchangeMemberDashboard = new CrowdExchange_MemberDashboard();
    	//System.assert(aaController.account!=null, 'Fail to create Account Record');
    	
    	// Stop Test
    	Test.stopTest();
	}

}