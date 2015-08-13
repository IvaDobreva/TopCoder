@isTest
private class CrowdExchange_MemberSearchEmailCntrTest {
	//Just testing funtionality without templte rendering
	@isTest static void main() {
		CrowdExchange_MemberSearchEmailCntr controller = new CrowdExchange_MemberSearchEmailCntr();
        Test.startTest();
            controller.getEmailTemplate();
        Test.stopTest();
        System.assertNotEquals(null, controller.emailSubject);
        System.assertNotEquals(null, controller.emailTemplate);
	}
	
	
}