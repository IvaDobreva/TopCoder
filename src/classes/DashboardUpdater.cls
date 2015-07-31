/************************************************** 
* Dashboard Updater
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/16/2015
* -------------------------------------------------
* Updates the dashboard data.
**************************************************/

global class DashboardUpdater
{
    global void execute() { 
        // variables to hold summary data
        Summary_Data__c summaryData;
        List<Summary_Data__c> summaryDataList = [SELECT Id FROM Summary_Data__c LIMIT 1];
        
        // If summary data exists, assign object in list to summary data object otherwise
        // create new object.
        if (!summaryDataList.isEmpty())
            summaryData = summaryDataList.get(0);
        else
            summaryData = new Summary_Data__c();
        
        // invoke Dashboard Data Collector
        DashboardDataCollector dashboardDataCollector = new DashboardDataCollector(); 
        
        // populate summary data object
        summaryData.Total_Users__c = dashboardDataCollector.getActiveUserTotal();
        summaryData.Total_Activities__c = dashboardDataCollector.getActivityTotal();
        summaryData.Active_Activities__c = dashboardDataCollector.getActiveActivityTotal();
        summaryData.Completed_Activities__c = dashboardDataCollector.getCompletedActivityTotal();
        summaryData.Total_Stories__c = dashboardDataCollector.getStoryTotal();
        summaryData.Active_Stories__c = dashboardDataCollector.getActiveStoryTotal();
        summaryData.Completed_Stories__c = dashboardDataCollector.getCompletedStoryTotal();
        summaryData.Number_of_Members__c = dashboardDataCollector.getMemberTotal();
        summaryData.Number_of_Publishers__c = dashboardDataCollector.getPublisherTotal();
        summaryData.Total_Registrations__c = dashboardDataCollector.getRegistrationTotal();
        summaryData.Total_Reviews__c = dashboardDataCollector.getReviewTotal();
        summaryData.Total_Submissions__c = dashboardDataCollector.getSubmissionTotal();
        summaryData.Timestamp__c = DateTime.now();
        
        // insert into or update database
        upsert summaryData;
        
        // map to hold top skills
        Map<String, Integer> topSkills = dashboardDataCollector.getTopUserSkills();
        
        // list to hold member skill snapshot data
        List<Member_Skill_Snapshot__c> memberSkillSnapshots = [SELECT Id FROM Member_Skill_Snapshot__C];
        
        if (!memberSkillSnapshots.isEmpty()) {
        	// delete existing member skill snapshot data
        	delete memberSkillSnapshots;
        	
        	// clear member skill snapshot list
        	memberSkillSnapshots.clear();
        }
        
        // loop through map and build list
        for (String skillName : topSkills.keySet()) {
        	Member_Skill_Snapshot__c memberSkillSnapshot = new Member_Skill_Snapshot__c();
        	memberSkillSnapshot.Skill_Name__c = skillName;
        	memberSkillSnapshot.Member_Count__c = topSkills.get(skillName);
        	memberSkillSnapshot.Timestamp__c = DateTime.now();
        	memberSkillSnapshots.add(memberSkillSnapshot);
        }
        
        // insert into database
        insert memberSkillSnapshots;
    }
}