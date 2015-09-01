/**
  InboundEmailHandler class to receive notification emails and to store them in objects. 
 */
global class CE_NotificationEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        // Result object
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        // Prepare for Email - User mapping
        List<String> emails = new List<String>();
        emails.add(email.fromAddress);
        emails.addAll(email.toAddresses);
        Map<String, User> emailMap = getEmailMap(emails);
        
        // Insert Notification
        CE_Notification__c notification = new CE_Notification__c();
        List<CE_User_Notification__c> userNotifications = new List<CE_User_Notification__c>();
        notification.Date_Sent__c = Date.today();
        notification.FromUser__c = emailMap.get(email.fromAddress).Id;
        notification.Notification_Text__c = email.plainTextBody;
        notification.Subject__c = email.subject;
        notification.Type__c = 'Alert';  
        insert notification; 
        
        // Insert User Notifications
        for(string toAddress : email.toAddresses){
            User toUser = emailMap.get(toAddress);
            if(toUser == null) continue;
            CE_User_Notification__c userNotification = new CE_User_Notification__c();
            userNotification.CE_Notification__c = notification.id;
            userNotification.Recipient__c = toUser.id;
            userNotifications.add(userNotification);
        }
        if(!userNotifications.isEmpty()) insert userNotifications;
        result.success = true;
        return result;
    }
    
    /**
      Gets Email-User map based on given list of emails
      @param List<string> a list of emails to include 
      @return the map with Email key and User value including given emails
     */
    private Map<String, User> getEmailMap(List<String> emails){
        Map<String, User> emailMap = new Map<String, User>();
        for(User u : [SELECT Id, Email FROM User WHERE Email in :emails]){
            emailMap.put(u.Email, u);
        }   
        return emailMap;        
    }
}