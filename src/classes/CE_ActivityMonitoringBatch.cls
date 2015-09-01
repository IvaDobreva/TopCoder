/*
    Batch class for monitering and change the status of activities as they progress through the workflow.
    Logging all errors to CE_Activity_Monitoring_Batch_Error__c 
    Added against TC30050600
*/
global class CE_ActivityMonitoringBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    global List<CE_Activity_Monitoring_Batch_Error__c> errorLogs;
    
    global CE_ActivityMonitoringBatch() {
        errorLogs = new List<CE_Activity_Monitoring_Batch_Error__c>();
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        
        // Quering all activities that are not completed and canceled 
        String query = 'Select Status__c, Reviews_Completed__c, Name From CE_Activity__c where Status__c NOT IN (\'Completed\' , \'Canceled\' ) ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objectList){
        try {
            
            // Calling processActivites from with in batch execute method
            CE_WorkflowManager.processActivities(objectList);
        } 
        catch (Exception e) {errorLogs.add(new CE_Activity_Monitoring_Batch_Error__c( Name = ''+system.now().time() , Error_Message__c = e.getStackTraceString())); throw e; }
    }
    
    global void finish(Database.BatchableContext BC){
        
        // Inserting error logs for apex failure tracking.
        if(!errorLogs.isEmpty()) insert errorLogs;
        
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
       
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Monitor Activity Batch Status : ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    global void execute(SchedulableContext sc) {

      // batchable b = new batchable();
      CE_ActivityMonitoringBatch amb = new CE_ActivityMonitoringBatch();
      Database.executeBatch(amb, 1);
      // database.executebatch(b);

   }

    
}