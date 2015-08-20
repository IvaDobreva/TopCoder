/************************************************** 
* Dashboard Updater
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/15/2015
* -------------------------------------------------
* Updates the dashboard data.
**************************************************/

global class CE_DashboardUpdaterScheduler implements Schedulable
{
    global void execute(SchedulableContext scheduleableContext) { 
        CE_DashboardUpdater d = new CE_DashboardUpdater();
        // d.execute();
    }
}