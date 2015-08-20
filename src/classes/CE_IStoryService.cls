public interface CE_IStoryService {
	////////////////////////////////////////// Story manipulation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * creates stories
	 * @param  stories List of stories to insert
	 * @return         List<CE_Story__c>
	 */
	List<CE_Story__c> createStories(List<CE_Story__c> stories);
	/**
	 * updates stories
	 * @param  stories List of stories to update
	 * @return         List<CE_Story__c>
	 */
	List<CE_Story__c> updateStories(List<CE_Story__c> stories);
	////////////////////////////////////////// END Story manipulation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	/**
	 * returns a list of 10 most recently entered/modified stories
	 * @return List<CE_Story__c>
	 */
	List<CE_Story__c> getMostRecentlyCreatedStories();
	/**
	 *  returns a list of the most recently created stories
	 * @param  count Stories count to return
	 * @return       List<CE_Story__c>
	 */
	List<CE_Story__c> getMostRecentlyCreatedStories(Integer count);
	/**
	 * returns a list of activities for a particular story
	 * @param  story Story object for which activities will be returned
	 * @return       List<CE_Activity__c>
	 */
	List<CE_Activity__c> getActivities(CE_Story__c story);
	/**
	 * returns a list of stories based on the skills of the associated activities
	 * @param  skills List of skills for which stories will be searched
	 * @return        List<CE_Story__c>
	 */
	List<CE_Story__c> search(List<CE_Skills__c> skills);
	/**
	 * returns list of stories associated with a particular user (member or publisher)
	 * @param  user User record for who stories will be returned
	 * @return      List<CE_Story__c>
	 */
	List<CE_Story__c> getStoriesForUser(User user);
	
}