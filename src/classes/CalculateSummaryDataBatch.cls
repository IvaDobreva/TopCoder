global class CalculateSummaryDataBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id Name FROM User WHERE Active=True';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<User> scope) {
         /*
         for(Account a : scope)
         {
             a.Name = a.Name + 'Updated';            
         }
         update scope;
         */
         
    }   
    
    global void finish(Database.BatchableContext BC) {
    
        //Send an email to the User after your batch completes  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {'sdhara@salesforce.com'};  
        mail.setToAddresses(toAddresses);  
        mail.setSubject('CalculateSummaryBatchData Batch Job is done');  
        mail.setPlainTextBody('The batch Apex job processed ');  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
    }
}