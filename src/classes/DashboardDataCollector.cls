/**************************************************
* Dashboard Data Collector
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/9/2015
* -------------------------------------------------
* Collects summary data for the dashboard.
**************************************************/

public with sharing class DashboardDataCollector {
	public DashboardDataCollector() {}
	
	// custom exceptions
	public class NullArgumentException extends Exception {}
	
	/**************************************************
	* Get Activity Total Method
	* -------------------------------------------------
	* Gets the total activities which aren't deleted,
	* regardless of status.
	* -------------------------------------------------
	* @return Integer - total activities
	* @throws DMLException
	**************************************************/
	public Integer getActivityTotal() {
		return [SELECT count() FROM Activity__c WHERE IsDeleted = false];
	}
	
	/**************************************************
	* Get Active Activity Total Method
	* -------------------------------------------------
	* Gets the total active activities which aren't
	* deleted, marked completed, or in draft.
	* -------------------------------------------------
	* @return Integer - total active activities
	* @throws DMLException
	**************************************************/
	public Integer getActiveActivityTotal() {
		return [SELECT count() FROM Activity__c WHERE Status__c != 'Completed' AND Status__c != 'Draft' AND IsDeleted = false];
	}
	
	/**************************************************
	* Get Completed Activity Total Method
	* -------------------------------------------------
	* Gets the total completed activities which aren't
	* deleted.
	* -------------------------------------------------
	* @return Integer - total completed activities
	* @throws DMLException
	**************************************************/
	public Integer getCompletedActivityTotal() {
		return [SELECT count() FROM Activity__c WHERE Status__c = 'Completed' AND IsDeleted = false];
	}
	
	/**************************************************
	* Get Active Story Total Method
	* -------------------------------------------------
	* Gets the total active stories which aren't
	* deleted, canceled, or marked completed.
	* -------------------------------------------------
	* @return Integer - total active stories
	* @throws DMLException
	**************************************************/
	public Integer getActiveStoryTotal() {
		return [SELECT count() FROM Story__c WHERE Status__c != 'Completed' AND Status__c != 'Canceled' AND IsDeleted = false];
	}
	
	/**************************************************
	* Get Completed Story Total Method
	* -------------------------------------------------
	* Gets the total completed stories which aren't
	* deleted.
	* -------------------------------------------------
	* @return Integer - total completed stories
	* @throws DMLException
	**************************************************/
	public Integer getCompletedStoryTotal() {
		return [SELECT count() FROM Story__c WHERE Status__c = 'Completed' AND IsDeleted = false];
	}
	
	/**************************************************
	* Get Member Total Method
	* -------------------------------------------------
	* Gets the total number of members which are active.
	* -------------------------------------------------
	* @return Integer - total active members
	* @throws DMLException
	**************************************************/
	public Integer getMemberTotal() {
		return [SELECT count() FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name ='Member')];
	}
	
	/**************************************************
	* Get Publisher Total Method
	* -------------------------------------------------
	* Gets the total number of publishers which are active.
	* -------------------------------------------------
	* @return Integer - total active publishers
	* @throws DMLException
	**************************************************/
	public Integer getPublisherTotal() {
		return [SELECT count() FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name ='Publisher')];
	}
	
	/**************************************************
	* Get Registration Total Method
	* -------------------------------------------------
	* Gets the total registrations.
	* -------------------------------------------------
	* @return Integer - total registrations
	* @throws DMLException
	**************************************************/
	public Integer getRegistrationTotal() {
		return [SELECT count() FROM Registration__c];
	}
	
	/**************************************************
	* Get Review Total Method
	* -------------------------------------------------
	* Gets the total reviews.
	* -------------------------------------------------
	* @return Integer - total reviews
	* @throws DMLException
	**************************************************/
	public Integer getReviewTotal() {
		return [SELECT count() FROM Submission__c WHERE Status__c = 'Review Complete'];
	}
	
	/**************************************************
	* Get Submission Total Method
	* -------------------------------------------------
	* Gets the total submissions.
	* -------------------------------------------------
	* @return Integer - total submissions
	* @throws DMLException
	**************************************************/
	public Integer getSubmissionTotal() {
		return [SELECT count() FROM Submission__c];
	}
	
	/**************************************************
	* Get All Active User Activities Method
	* -------------------------------------------------
	* Gets the total active activities assigned to each 
	* user.
	* -------------------------------------------------
	* @param userIds - list of user IDs
	* @return Map<Id, Integer> - map of user IDs and
	*                            active activity totals
	* @throws DMLException, NullArgumentException
	**************************************************/
	/*public Map<Id, Integer> getAllActiveUsrActivities(List<Id> userIds) {
		if (userIds == null) {
			throw new NullArgumentException('Get All Active User Acitivites: Unable to get total activities because null list argument was used.');
		}

		// query database for activity counts for each user
		AggregateResult[] activityResults = [SELECT Assigned_Member__c, count(Id) NumActivities FROM Activity__c 
											WHERE Assigned_Member__c IN :userIds AND IsDeleted = false AND  GROUP BY Assigned_Member__c];
		
		// map to store activity counts for each user
		Map<Id, Integer> activityMap = new Map<Id, Integer>();
		
		// loop through query results and add to map
		for (AggregateResult ar : activityResults) 
		{	
			activityMap.put((Id)ar.get('Assigned_Member__c'), (Integer)ar.get('NumActivities'));
		}
		
		return activityMap;
	}*/
}