/************************************************** 
* Dashboard Updater
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/15/2015
* -------------------------------------------------
* Updates the dashboard data.
**************************************************/

global class DashboardUpdaterScheduler implements Schedulable
{
    global void execute(SchedulableContext scheduleableContext) { 
        DashboardUpdater d = new DashboardUpdater();
        d.execute();
    }
}