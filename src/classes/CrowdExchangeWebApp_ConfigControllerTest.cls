@isTest
private class CrowdExchangeWebApp_ConfigControllerTest {
	
	@isTest static void mainAndTheOnly() {
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;

        Test.startTest();
		  CrowdExchangeWebApp_ConfigController cntr = new CrowdExchangeWebApp_ConfigController();
        Test.stopTest();
	}
}