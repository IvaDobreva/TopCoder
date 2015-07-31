public with sharing class StoryService implements IStoryService {

	@TestVisible private static final Integer DEFAULT_RECENT_STORIES_COUNT = 10;

	////////////////////////////////////////// Story manipulation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * creates stories
	 * @param  stories List of stories to insert
	 * @return         List<Story__c>
	 */
	public List<Story__c> createStories(List<Story__c> stories) {
		insert stories;
		return stories;
	}
	/**
	 * updates stories
	 * @param  stories List of stories to update
	 * @return         List<Story__c>
	 */
	public List<Story__c> updateStories(List<Story__c> stories) {
		update stories;
		return stories;
	}
	////////////////////////////////////////// END Story manipulation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * returns a list of 10 most recently created stories
	 * @return List<Story__c>
	 */
	public List<Story__c> getMostRecentlyCreatedStories() {
		return getMostRecentlyCreatedStories(DEFAULT_RECENT_STORIES_COUNT);
	}
	/**
	 *  returns a list of the most recently created stories
	 * @param  count Stories count to return
	 * @return       List<Story__c>
	 */
	public List<Story__c> getMostRecentlyCreatedStories(Integer count) {
		return [SELECT  Id,
						Name,
						Budget__c,
						Description__c,
						Service_Offering__c,
						Project_Duration__c,
						Project_Start_Date__c,
						Publisher__c,
						Remaining_Budget__c,
						Status__c  
				FROM Story__c 
				ORDER BY CreatedDate DESC 
				LIMIT :count];
	}
	/**
	 * returns a list of activities for a particular story
	 * @param  story Story object for which activities will be returned
	 * @return       List<Activity__c>
	 */
	public List<Activity__c> getActivities(Story__c story) {
		String storyId = story.Id;
		return [SELECT  Id,
						Name,
						Challenge_Type__c,
						Budget_Authorized__c,
						Cost__c,
						Description__c,
						Minimum_Viable_Score__c,
						Possible_Score__c,
						Publisher__c,
						Resource_Commitment__c,
						Status__c,
						Total_Awards__c,
						Story__c,
						hasAwards__c
				FROM Activity__c WHERE Story__c = :storyId];
	}
	/**
	 * returns a list of stories based on the skills of the associated activities
	 * @param  skills List of skills for which stories will be searched
	 * @return        List<Story__c>
	 */
	public List<Story__c> search(List<Skills__c> skills) {
		Set<Id> skillsIds = new Map<Id, Skills__c>(skills).keySet();

		List<Activity__c> activities = [SELECT Story__c FROM Activity__c WHERE Id IN (SELECT Activity__c FROM ActivitySkills__c WHERE Skill__c IN :skillsIds)];
		Set<Id> storiesIds = new Set<Id>();
		for(Activity__c activity : activities)
			storiesIds.add(activity.Story__c);
		return [SELECT  Id,
						Name,
						Budget__c,
						Description__c,
						Service_Offering__c,
						Project_Duration__c,
						Project_Start_Date__c,
						Publisher__c,
						Remaining_Budget__c,
						Status__c  
				FROM Story__c WHERE Id IN :storiesIds];
	}
	/**
	 * returns list of stories associated with a particular user (member or publisher)
	 * @param  user User record for who stories will be returned
	 * @return      List<Story__c>
	 */
	public List<Story__c> getStoriesForUser(User user){
		// //Updated against TC30050600 
		//Collect Stories' IDs for member. NOTE: we can skip submissions, because if User has Submission for an activity he definetly has MemberActivityMilestone
		List<Activity__c> activities = [SELECT Story__c FROM Activity__c WHERE Assigned_Member__c = :user.Id OR Publisher__c = :user.Id];
		Set<Id> storiesIds = new Set<Id>();
		for(Activity__c activity : activities)
			storiesIds.add(activity.Story__c);
		return [SELECT  Id,
						Name,
						Budget__c,
						Description__c,
						Service_Offering__c,
						Project_Duration__c,
						Project_Start_Date__c,
						Publisher__c,
						Remaining_Budget__c,
						Status__c  
				FROM Story__c 
				WHERE Publisher__c = :user.Id OR Id IN :storiesIds];//Filtering stories where User is a publisher or a member
	}
}