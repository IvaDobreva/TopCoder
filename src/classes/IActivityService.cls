public interface IActivityService {

	////////////////////////////////////////// Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * creates activities
	 * @param  activities list of activities to insert
	 * @return            created list of activies with ids
	 */
	List<Activity__c> createActivities(List<Activity__c> activities);
	/**
	 * updates activities
	 * @param  activities list of activities to insert
	 * @return            updated list of activies
	 */
	List<Activity__c> updateActivities(List<Activity__c> activities);
	/**
	 * deletes activities
	 * @param activities list of activities to delete
	 */
	void deleteActivities(List<Activity__c> activities);
	/**
	 * searches for activities based on a list of skills
	 * @param  skills list of skills for Activities' filter
	 * @return        List<Activity__c> 
	 */
	List<Activity__c> search(List<Skills__c> skills);
	/**
	 * gets a collections of activities associated with a particular user.  The user might be a publisher or a member.
	 * @param  user User record(member or publisher)
	 * @return      List<Activity__c>
	 */
	List<Activity__c> getActivitiesForUser(User user);
	////////////////////////////////////////// END Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	////////////////////////////////////////// Milestone \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * determines the list of milestones for a particular activity
	 * @param milestones List of milestones for the activity
	 * @param activity   Activity for which mislestones will be set
	 */
	void setMilestones(List<Milestone__c> milestones, Activity__c activity);
	/**
	 * gets the list of milestones for an activity
	 * @param  activity Activity for which mislestones will be returned
	 * @return          List<Milestone__c>
	 */
	List<Milestone__c> getMilestones(Activity__c activity);
	////////////////////////////////////////// Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	////////////////////////////////////////// END Milestone \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	////////////////////////////////////////// ActivitySkill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * adds requested skills to an activity
	 * @param skills   List of milestones for the activity
	 * @param activity Activity for which Skills will be set
	 */
	void addSkills(List<Skills__c> skills, Activity__c activity);
	/**
	 * deletes skills from an activity
	 * @param skills   List of milestones for the activity
	 * @param activity Activity for which Skills will be deleted
	 */
	void deleteSkills(List<Skills__c> skills, Activity__c activity);
	/**
	 * gets the skills for an activity
	 * @param  activity Activity for which Skills will be returned
	 * @return          List<Skills__c>
	 */
	List<Skills__c> getSkills(Activity__c activity);
	////////////////////////////////////////// END ActivitySkill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	////////////////////////////////////////// Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	/**
	 * get a collection of requirements for an activity
	 * @param  activity Activity for which Requirements will be returned
	 * @return          List<Requirement__c>
	 */
	List<Requirement__c> getRequirements(Activity__c activity);
	/**
	 * adds a list of requirements related to a particular activity
	 * @param requirements List of Requirements that will be added
	 */
	List<Requirement__c> addRequirements(List<Requirement__c> requirements);
	/**
	 * allows editing of a particular requirements related to an activity
	 * @param  requirements List of Requirements that will be updated
	 */
	List<Requirement__c>  updateRequirement(List<Requirement__c> requirements);
	/**
	 * deletes a list of requirements related to a particular activity
	 * @param requirement List of Requirements that will be deleted
	 */
	void deleteRequirements(List<Requirement__c> requirement);
	////////////////////////////////////////// END Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	////////////////////////////////////////// Award \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	/**
	 * adds an award to an activity
	 * @param awards List of Awards that will be inserted
	 */
	List<Award__c> addAwards(List<Award__c> awards);
	/**
	 * updates an award related to an activity
	 * @param awards List of Awards that will be updated
	 */
	List<Award__c> updateAwards(List<Award__c> awards);
	/**
	 * deletes an award related to an activity
	 * @param awards List of Awards that will be deleted
	 */
	void deleteAwards(List<Award__c> awards);
	////////////////////////////////////////// END Award \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	/**
	 * gets the list of default requirements associated with the activity.  Actually to start with, all activities will have the same set of default requirements.
	 * @return List<Default_Requirement__c>
	 */
	List<Default_Requirement__c> getDefaultRequirements();
	/**
	 * after submission due date we should prevent publishers from adding requirements and members from making submissions.
	 * @param  activity Activity to check of lock
	 * @return          TRUE if Activity is locked
	 */
	Boolean isLocked(Activity__c activity);
	/**
	 * deep copy of an Activity along with Awards, Requirements, Skills. After insert all object into database
	 * @param  activity Activity to clone
	 * @return          New cloned activity
	 */
	Activity__c cloneActivity(Activity__c activity);
}