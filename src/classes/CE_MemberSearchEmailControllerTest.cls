@isTest
private class CE_MemberSearchEmailControllerTest {
	//Just testing funtionality without templte rendering
	@isTest static void main() {
		CE_MemberSearchEmailController controller = new CE_MemberSearchEmailController();
        Test.startTest();
            controller.getEmailTemplate();
        Test.stopTest();
        System.assertNotEquals(null, controller.emailSubject);
        System.assertNotEquals(null, controller.emailTemplate);
	}
	
	
}