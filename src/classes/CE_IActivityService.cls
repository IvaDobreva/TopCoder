public interface CE_IActivityService {

	////////////////////////////////////////// Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * creates activities
	 * @param  activities list of activities to insert
	 * @return            created list of activies with ids
	 */
	List<CE_Activity__c> createActivities(List<CE_Activity__c> activities);
	/**
	 * updates activities
	 * @param  activities list of activities to insert
	 * @return            updated list of activies
	 */
	List<CE_Activity__c> updateActivities(List<CE_Activity__c> activities);
	
	/**
     * create single activity
     * @param  activity 	activity record to insert
     * @return            created activity record with id
     */
    CE_Activity__c createActivity(CE_Activity__c activity);
    
    /**
     * update single activity
     * @param  activity activity record to update
     * @return      updated activity
     */
    CE_Activity__c updateActivity(CE_Activity__c activity);
    
	/**
	 * deletes activities
	 * @param activities list of activities to delete
	 */
	void deleteActivities(List<CE_Activity__c> activities);
	/**
	 * searches for activities based on a list of skills
	 * @param  skills list of skills for Activities' filter
	 * @return        List<CE_Activity__c> 
	 */
	List<CE_Activity__c> search(List<CE_Skills__c> skills);
	
	/**
     * method to assign member to activity  
     * @param user User to be assigned to activity
     * @param activity   Activity to which member will be assigned.
     */
    void assignMemberToActivity(User user, CE_Activity__c activity);
    
	/**
	 * gets a collections of activities associated with a particular user.  The user might be a publisher or a member.
	 * @param  user User record(member or publisher)
	 * @return      List<CE_Activity__c>
	 */
	List<CE_Activity__c> getActivitiesForUser(User user);
	
	/**
     * get activity associated with assigned member and Date Member Assigned.
     * Updated against TC30050600	#7
     * @param  activityId Activity Id
     * @return      CE_Activity__c
     */
    CE_Activity__c getActivity(Id activityId);
	////////////////////////////////////////// END Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	////////////////////////////////////////// Milestone \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * determines the list of milestones for a particular activity
	 * @param milestones List of milestones for the activity
	 * @param activity   Activity for which mislestones will be set
	 */
	void setMilestones(List<CE_Milestone__c> milestones, CE_Activity__c activity);
	/**
	 * gets the list of milestones for an activity
	 * @param  activity Activity for which mislestones will be returned
	 * @return          List<CE_Milestone__c>
	 */
	List<CE_Milestone__c> getMilestones(CE_Activity__c activity);
	////////////////////////////////////////// Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	////////////////////////////////////////// END Milestone \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	////////////////////////////////////////// ActivitySkill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	/**
	 * adds requested skills to an activity
	 * @param skills   List of milestones for the activity
	 * @param activity Activity for which Skills will be set
	 */
	void addSkills(List<CE_Skills__c> skills, CE_Activity__c activity);
	/**
	 * deletes skills from an activity
	 * @param skills   List of milestones for the activity
	 * @param activity Activity for which Skills will be deleted
	 */
	void deleteSkills(List<CE_Skills__c> skills, CE_Activity__c activity);
	/**
	 * gets the skills for an activity
	 * @param  activity Activity for which Skills will be returned
	 * @return          List<CE_Skills__c>
	 */
	List<CE_Skills__c> getSkills(CE_Activity__c activity);
	////////////////////////////////////////// END ActivitySkill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	////////////////////////////////////////// Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	/**
	 * get a collection of requirements for an activity
	 * @param  activity Activity for which Requirements will be returned
	 * @return          List<CE_Requirement__c>
	 */
	List<CE_Requirement__c> getRequirements(CE_Activity__c activity);
	/**
	 * adds a list of requirements related to a particular activity
	 * @param requirements List of Requirements that will be added
	 */
	List<CE_Requirement__c> addRequirements(List<CE_Requirement__c> requirements);
	/**
	 * allows editing of a particular requirements related to an activity
	 * @param  requirements List of Requirements that will be updated
	 */
	List<CE_Requirement__c>  updateRequirement(List<CE_Requirement__c> requirements);
	/**
	 * deletes a list of requirements related to a particular activity
	 * @param requirement List of Requirements that will be deleted
	 */
	void deleteRequirements(List<CE_Requirement__c> requirement);
	////////////////////////////////////////// END Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	////////////////////////////////////////// Award \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	/**
	 * adds an award to an activity
	 * @param awards List of Awards that will be inserted
	 */
	List<CE_Award__c> addAwards(List<CE_Award__c> awards);
	/**
	 * updates an award related to an activity
	 * @param awards List of Awards that will be updated
	 */
	List<CE_Award__c> updateAwards(List<CE_Award__c> awards);
	/**
	 * deletes an award related to an activity
	 * @param awards List of Awards that will be deleted
	 */
	void deleteAwards(List<CE_Award__c> awards);
	////////////////////////////////////////// END Award \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	/**
	 * gets the list of default requirements associated with the activity.  Actually to start with, all activities will have the same set of default requirements.
	 * @return List<CE_Default_Requirement__c>
	 */
	List<CE_Default_Requirement__c> getDefaultRequirements();
	/**
	 * after submission due date we should prevent publishers from adding requirements and members from making submissions.
	 * @param  activity Activity to check of lock
	 * @return          TRUE if Activity is locked
	 */
	Boolean isLocked(CE_Activity__c activity);
	/**
	 * deep copy of an Activity along with Awards, Requirements, Skills. After insert all object into database
	 * @param  activity Activity to clone
	 * @return          New cloned activity
	 */
	CE_Activity__c cloneActivity(CE_Activity__c activity);
	
	/*
    * Method for regesting a member to an activity.
    * Added against TC30050600 
    * @param  userId User Id
    * @param  activity Activity for which Registration will be inserted
    * @return          List<CE_Registration__c>
    */
    void registerMember(Id userId, CE_Activity__c activity);
    
    /*
    *	Get list of the members that are registered to a particular activity.
    *	Added against TC30050600 
    * @param  activity Activity for which Registration will be returned
    * @return          List<CE_Registration__c>
    */
    List<CE_Registration__c> getRegistrations(CE_Activity__c activity);
    
    /*
    * Deregistering a member by deleting the related registration record.
    * Added against TC30050600
    * @Param  registrationId	registeration record id
    */
    void deregisterMember(Id registrationId);
}