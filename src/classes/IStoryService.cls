public interface IStoryService {
	////////////////////////////////////////// Story manipulation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * creates stories
	 * @param  stories List of stories to insert
	 * @return         List<Story__c>
	 */
	List<Story__c> createStories(List<Story__c> stories);
	/**
	 * updates stories
	 * @param  stories List of stories to update
	 * @return         List<Story__c>
	 */
	List<Story__c> updateStories(List<Story__c> stories);
	////////////////////////////////////////// END Story manipulation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	/**
	 * returns a list of 10 most recently entered/modified stories
	 * @return List<Story__c>
	 */
	List<Story__c> getMostRecentlyCreatedStories();
	/**
	 *  returns a list of the most recently created stories
	 * @param  count Stories count to return
	 * @return       List<Story__c>
	 */
	List<Story__c> getMostRecentlyCreatedStories(Integer count);
	/**
	 * returns a list of activities for a particular story
	 * @param  story Story object for which activities will be returned
	 * @return       List<Activity__c>
	 */
	List<Activity__c> getActivities(Story__c story);
	/**
	 * returns a list of stories based on the skills of the associated activities
	 * @param  skills List of skills for which stories will be searched
	 * @return        List<Story__c>
	 */
	List<Story__c> search(List<Skills__c> skills);
	/**
	 * returns list of stories associated with a particular user (member or publisher)
	 * @param  user User record for who stories will be returned
	 * @return      List<Story__c>
	 */
	List<Story__c> getStoriesForUser(User user);
	
}