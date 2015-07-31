@isTest
private class DashboardUpdaterSchedulerTest
{
    static testmethod void  testschedule()
    {
        Test.StartTest();

        DashboardUpdaterScheduler sh1 = new DashboardUpdaterScheduler();
        /*
         Datetime futureTime = Datetime.now().addHours(1).addMinutes(1);
         String futureTimeCronString = '0 ' + futureTime.minute() + ' ' + futureTime.day() + ' ' + futureTime.month() + ' * ' + futureTime.year();
         System.schedule('OrderApprovalDeadlineScheduler', futureTimeCronString, new OrderApprovalDeadlineScheduler());
        */
        Datetime futureTime = Datetime.now().addMinutes(1);
        String cron_exp = futureTime.second() + ' ' + futureTime.minute() + ' ' + futureTime.hour() + ' * * ?';
        String jobId = system.schedule('Test', cron_exp, sh1);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                 FROM CronTrigger WHERE id = :jobId];
                 
        // Verify the expressions are the same
        System.assertEquals(cron_exp,ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals(String.valueOf(futureTime), String.valueOf(ct.NextFireTime));

        Test.stopTest();
        
        //List<Times_of_Account_Transction__c> objectList = new List<Times_of_Account_Transction__c>(); 
    }
    
   
}