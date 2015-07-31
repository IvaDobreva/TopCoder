/**************************************************
* Dashboard Data Collector
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/17/2015
* -------------------------------------------------
* Collects summary data for the dashboard.
**************************************************/

public with sharing class DashboardDataCollector {
	public DashboardDataCollector() {}
	
	// custom exceptions
	public class NullArgumentException extends Exception {}
	
	/**************************************************
	* Get Active User Total Method
	* -------------------------------------------------
	* Gets the total active users.
	* -------------------------------------------------
	* @return Integer - total active users
	* @throws DMLException
	**************************************************/
	public Integer getActiveUserTotal() { 
		return [SELECT count() FROM User WHERE IsActive = true];
	}
	
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
	* Get Story Total Method
	* -------------------------------------------------
	* Gets the total stories which aren't deleted,
	* regardless of status.
	* -------------------------------------------------
	* @return Integer - total stories
	* @throws DMLException
	**************************************************/
	public Integer getStoryTotal() {
		return [SELECT count() FROM Story__c WHERE IsDeleted = false];
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
	* Get Top User Skills Method
	* -------------------------------------------------
	* Gets the top 20 user skills.
	* -------------------------------------------------
	* @return Map<String, Integer> - map of skills by name
	*                                and total users for 
	*                                each skill
	* @throws DMLException
	**************************************************/
	public Map<String, Integer> getTopUserSkills() {
		// query database for top 20 skills based on number of users for each skill
		AggregateResult[] topSkillResults = [SELECT Skill__r.Name, count(Id) memberTotal FROM UserSkill__c GROUP BY Skill__r.Name LIMIT 20];
		
		// map to store skill ID and user count for each
		Map<String, Integer> topSkills = new Map<String, Integer>();
		
		// loop through query results and add to map
		for (AggregateResult ar : topSkillResults) 
		{	
			topSkills.put((String)ar.get('Name'), (Integer)ar.get('memberTotal'));
		}
		
		return topSkills;
	}
}