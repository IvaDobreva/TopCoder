@isTest
private class NotificationEmailHandlerTest {

    /*
		test handleInboundEmail
	*/
    static testMethod void handleInboundEmail_Test() {
        NotificationEmailHandler handler = new NotificationEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        User fromUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
        User toUser = TestFactory.createUser();
        insert toUser;
        
        email.fromAddress = fromUser.Email;
        email.toAddresses = new String[]{toUser.Email};
        email.plainTextBody = 'Plain Text';
        email.subject = 'Subject';
        Messaging.InboundEmail.Header emailTemplate = new Messaging.InboundEmail.Header();
        email.headers = new Messaging.InboundEmail.Header[]{emailTemplate};
        
        Test.startTest();
            

        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);
        
        List<Notification__c> notifications = [
            SELECT Id, Date_Sent__c, FromUser__c, Notification_Text__c, Subject__c, Type__c,
            (SELECT Id, Notification__c, Recipient__c FROM NotificationRecipients__r) FROM Notification__c];
        
        System.assertEquals(1, notifications.size(), 'Inserted 1 Notification');

        Notification__c notification = notifications[0];

        System.assertEquals(1, notification.NotificationRecipients__r.size(), 'Inserted 1 User Notification');
        
        System.assertEquals(Date.today(), notification.Date_Sent__c, 'Date_Sent__c');
        System.assertEquals(fromUser.Id, notification.FromUser__c, 'FromUser__c');
		    System.assertEquals(email.plainTextBody, notification.Notification_Text__c, 'Notification_Text__c');
		    System.assertEquals(email.subject, notification.Subject__c, 'Subject__c');
		    System.assertEquals('Alert', notification.Type__c, 'Type__c');
        User_Notification__c userNotification = notification.NotificationRecipients__r[0];
        System.assertEquals(notification.id, userNotification.Notification__c, 'Notification__c');
        System.assertEquals(toUser.id, userNotification.Recipient__c, 'Recipient__c');
        
        Test.stopTest();
    }
}