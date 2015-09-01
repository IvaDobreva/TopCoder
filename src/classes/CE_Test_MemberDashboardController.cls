@isTest
private class CE_Test_MemberDashboardController {

	private static testMethod void testCrowdExchangeMemberDashboard() {
	    
    	//create test data
    	CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
    	CE_TestFactory.createSummaryData();
    	
    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance with standard controller
		CE_MemberDashboardController crowdExchangeMemberDashboard = new CE_MemberDashboardController();
    	//System.assert(aaController.account!=null, 'Fail to create Account Record');
    	
    	// Stop Test
    	Test.stopTest();
	}

}