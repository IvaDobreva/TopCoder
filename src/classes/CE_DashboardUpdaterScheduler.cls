/************************************************** 
* Dashboard Updater
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/15/2015
* Modified By: Gaurav Kheterpal (gaurav.kheterpal@appirio.com)
* Modified On: 8/25/2015
* Modification done: Corrected the syntax to execute batch
* -------------------------------------------------
* Updates the dashboard data.
**************************************************/

global class CE_DashboardUpdaterScheduler implements Schedulable
{
    global void execute(SchedulableContext scheduleableContext) { 
        CE_DashboardUpdater d = new CE_DashboardUpdater();
        database.executeBatch(d);
    }
}
