@isTest
private class CE_WebApp_ConfigControllerTest {
	
	@isTest static void mainAndTheOnly() {
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;

        Test.startTest();
		  CE_WebApp_ConfigController cntr = new CE_WebApp_ConfigController();
        Test.stopTest();
	}
}