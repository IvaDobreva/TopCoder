/**************************************************
* Dashboard Updater
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/14/2015
* -------------------------------------------------
* Updates dashboard data for each active user in
* the database in batches.
**************************************************/

global class CE_DashboardUpdater implements Database.Batchable<SObject>, Database.Stateful {
	
	global CE_DashboardUpdater() {}
	
	/**************************************************
	* Start Method
	* -------------------------------------------------
	* Starts the batch job by getting all active users.
	* -------------------------------------------------
	* @param ctx - batchable database context
	* @throws DMLException
	**************************************************/
	global Database.queryLocator start(Database.BatchableContext ctx) {
   		return Database.getQueryLocator([SELECT Id FROM User WHERE IsActive = true]);
	}
	
	/**************************************************
	* Execute Method
	* -------------------------------------------------
	* Executes the batch job by querying the database
	* for relevant dashboard data and then saving or
	* updating these results to the proper database
	* tables used to store the results.
	* -------------------------------------------------
	* @param ctx - batchable database context
	* @param scope - list which holds results from Start method
	* @throws DMLException
	**************************************************/
	 global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
		// lists to store user information
	    List<User> users = (List<User>)scope;
	    List<Id> userIds = new List<Id>();
	    
	    // loop through user list and populate userIDs list
	    for (User user : users) {
	    	userIds.add(user.Id);
	    }
	    
	    // get current summary data
	    List<CE_Summary_Data__c> summaryDataList = [SELECT Id FROM CE_Summary_Data__c LIMIT 1];
	    
		CE_Summary_Data__c summaryData = new CE_Summary_Data__c(); // object to hold summary data
		
		// assign ID if it exists
		if (!summaryDataList.isEmpty()) {
			summaryData.Id = summaryDataList.get(0).Id;
		}
		
		// invoke dashboard data collector
		CE_DashboardDataCollector dashboardDataCollector = new CE_DashboardDataCollector(); 
		
		// populate summary data object
		summaryData.Total_Users__c = userIds.size();
		summaryData.Total_Activities__c = dashboardDataCollector.getActivityTotal();
		summaryData.Active_Activities__c = dashboardDataCollector.getActiveActivityTotal();
		summaryData.Completed_Activities__c = dashboardDataCollector.getCompletedActivityTotal();
		summaryData.Active_Stories__c = dashboardDataCollector.getActiveStoryTotal();
		summaryData.Completed_Stories__c = dashboardDataCollector.getCompletedStoryTotal();
		summaryData.Number_of_Members__c = dashboardDataCollector.getMemberTotal();
		summaryData.Number_of_Publishers__c = dashboardDataCollector.getPublisherTotal();
		summaryData.Total_Registrations__c = dashboardDataCollector.getRegistrationTotal();
		summaryData.Total_Reviews__c = dashboardDataCollector.getReviewTotal();
		summaryData.Total_Submissions__c = dashboardDataCollector.getSubmissionTotal();
		
		// insert into or update database
		upsert summaryData;
	    
	    
		
		
		
		// lists to store user information
	    /*List<User> users = (List<User>)scope;
	    List<Id> userIds = new List<Id>();
	    
	    // loop through user list and populate userIDs list
	    for (User user : users) {
	    	userIds.add(user.Id);
	    }
	    
		if (!userIds.isEmpty()) {
			CE_DashboardDataCollector dashboardDataCollector = new CE_DashboardDataCollector(); 
			
			// get total activities for each user and store in map
			Map<Id, Integer> userActivityMap = new Map<Id, Integer>();
			userActivityMap = dashboardDataCollector.getAllUserActivities(userIds);
			
			List<CE_Summary_Data__c> summaryDataList = new List<CE_Summary_Data__c>();
			
			// loop through all active users
			for (Id userId : userIds) {
				CE_Summary_Data__c summaryData = new CE_Summary_Data__c();
				
				if (!userActivityMap.isEmpty()) {
					// loop through map and update summary data list
					for (Id id : userActivityMap.keySet()) {
						// assign values to summary data object
						summaryData.OwnerId = Id;
						summaryData.Total_Activities__c = userActivityMap.get(id);
						summaryData.Total_Users__c = userActivityMap.size();
	    			}
				}
				
				// additional if statement and for loop goes here
				
				// add to list
				summaryDataList.add(summaryData);
			}
			
			// update database
			upsert summaryDataList;
		}*/
	}
	
	/**************************************************
	* Finish Method
	* -------------------------------------------------
	* Immediately runs after Execute method and writes
	* to log file if error has occured.
	* -------------------------------------------------
	* @param ctx - batchable database context
	**************************************************/
	global void finish(Database.BatchableContext ctx) {
		// TODO: write to log if failure
	}
}