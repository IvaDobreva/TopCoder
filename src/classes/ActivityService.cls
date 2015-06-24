public with sharing class ActivityService implements IActivityService {

    ////////////////////////////////////////// Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    /**
     * creates activities
     * @param  activities list of activities to insert
     * @return            created list of activies with ids
     */
    public List<Activity__c> createActivities(List<Activity__c> activities) {
        insert activities;
        return activities;
    }
    /**
     * updates activities
     * @param  activities list of activities to insert
     * @return            updated list of activies
     */
    public List<Activity__c> updateActivities(List<Activity__c> activities) {
        update activities;
        return activities;
    }
    /**
     * deletes activities
     * @param activities list of activities to delete
     */
    public void deleteActivities(List<Activity__c> activities) {
        delete activities;
    }
    /**
     * searches for activities based on a list of skills
     * @param  skills list of skills for Activities' filter
     * @return        List<Activity__c> 
     */
    public List<Activity__c> search(List<Skills__c> skills) {
        Set<Id> skillsIds = new Map<Id,Skills__c>(skills).keySet();
        return [SELECT Name,
                        Activity_Type__c,
                        Budget_Authorized__c,
                        Cost__c,
                        Description__c,
                        Minimum_Viable_Score__c,
                        Possible_Score__c,
                        Publisher__c,
                        Resource_Commitment__c,
                        Status__c,
                        Total_Awards__c,
                        Story__c
                FROM Activity__c 
                WHERE Id IN (SELECT Activity__c FROM ActivitySkills__c WHERE Skill__c IN :skillsIds)];
    }
    /**
     * gets a collections of activities associated with a particular user.  The user might be a publisher or a member.
     * @param  user User record(member or publisher)
     * @return      List<Activity__c>
     */
    public List<Activity__c> getActivitiesForUser(User user) {

        Map<Id, Activity__c> activitiesMap = new Map<Id, Activity__c>();
        //Getting ACtivities where user is Member
        activitiesMap.putAll([SELECT Name,
                                    Activity_Type__c,
                                    Budget_Authorized__c,
                                    Cost__c,
                                    Description__c,
                                    Minimum_Viable_Score__c,
                                    Possible_Score__c,
                                    Publisher__c,
                                    Resource_Commitment__c,
                                    Status__c,
                                    Total_Awards__c,
                                    Story__c
                            FROM Activity__c 
                            WHERE Id IN (SELECT Activity__c FROM UserActivityMilestone__c WHERE User__c = :user.Id)]);
        //Getting ACtivities where user is Publisher
        activitiesMap.putAll([SELECT Name,
                                    Activity_Type__c,
                                    Budget_Authorized__c,
                                    Cost__c,
                                    Description__c,
                                    Minimum_Viable_Score__c,
                                    Possible_Score__c,
                                    Publisher__c,
                                    Resource_Commitment__c,
                                    Status__c,
                                    Total_Awards__c,
                                    Story__c
                            FROM Activity__c 
                            WHERE Publisher__c = :user.Id]);
        return activitiesMap.values();

    }
    ////////////////////////////////////////// END Activity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    
    ////////////////////////////////////////// Milestone \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    /**
     * determines the list of milestones for a particular activity
     * @param milestones List of milestones for athe activity
     * @param activity   Activity for which mislestones will be set
     */
    public void setMilestones(List<Milestone__c> milestones, Activity__c activity) {
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for(Milestone__c milestone : milestones)
            activityMilestones.add(new ActivityMilestones__c(Milestone__c = milestone.Id, Activity__c = activity.Id));
        insert activityMilestones;
    }
    /**
     * gets the list of milestones for an activity
     * @param  activity Activity for which mislestones will be returned
     * @return          List<Milestone__c>
     */
    public List<Milestone__c> getMilestones(Activity__c activity) {
        List<ActivityMilestones__c> activityMilestones = [SELECT Milestone__c,
                                                                Milestone__r.Step_Number__c,
                                                                Milestone__r.Name
                                                          FROM ActivityMilestones__c WHERE Activity__c = :activity.Id];
        List<Milestone__c> result = new List<Milestone__c>();
        for(ActivityMilestones__c activityMilestone : activityMilestones)
            result.add(activityMilestone.Milestone__r);
        return result;
    }
    ////////////////////////////////////////// END Milestone \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    ////////////////////////////////////////// ActivitySkill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    /**
     * adds requested skills to an activity
     * @param skills   List of milestones for the activity
     * @param activity Activity for which Skills will be set
     */
    public void addSkills(List<Skills__c> skills, Activity__c activity) {
        List<ActivitySkills__c> activitySkills = new List<ActivitySkills__c>();
        for (Skills__c skill : skills)
            activitySkills.add(new ActivitySkills__c(Skill__c = skill.Id, Activity__c = activity.Id));
        insert activitySkills;
    }
    /**
     * deletes skills from an activity
     * @param skills   List of milestones for the activity
     * @param activity Activity for which Skills will be deleted
     */
    public void deleteSkills(List<Skills__c> skills, Activity__c activity) {
        Set<Id> skillsIds = new Map<Id, SKills__c>(skills).keySet();
        delete [SELECT Id FROM ActivitySkills__c WHERE Skill__c IN :skillsIds AND Activity__c = :activity.Id];
    }
    /**
     * gets the skills for an activity
     * @param  activity Activity for which Skills will be returned
     * @return          List<Skills__c>
     */
    public List<Skills__c> getSkills(Activity__c activity) {
        
        return [SELECT Id,
                       Name,
                       Experience_Level__c,
                       Internal_Project__c,
                       User__c,
                       Skill__c
                FROM Skills__c WHERE Id IN (SELECT Skill__c FROM ActivitySkills__c WHERE Activity__c = :activity.Id)];
    }
    ////////////////////////////////////////// END ActivitySkill \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    

    ////////////////////////////////////////// Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /**
     * get a collection of requirements for an activity
     * @param  activity Activity for which Requirements will be returned
     * @return          List<Requirement__c>
     */
    public List<Requirement__c> getRequirements(Activity__c activity) {
        return [SELECT  Name,
                        Activity__c,
                        Description__c,
                        Requirement_Evaluation__c,
                        Requirement_Weight__c,
                        Type__c
                FROM Requirement__c WHERE Activity__c = :activity.Id];
    }
    /**
     * adds a list of requirements related to a particular activity
     * @param requirements List of Requirements that will be added
     */
    public List<Requirement__c> addRequirements(List<Requirement__c> requirements) {
        //NOTE: Take Activity's Id only from first requirement. We sure that users pass only those requirements that belong to only one activity
        if(isLocked(new Activity__c(Id = requirements[0].Activity__c)))
            throw new ActivityServiceException('Cannot add requirements when activity is locked.');
        insert requirements;
        return requirements;
    }
    /**
     * allows editing of a particular requirements related to an activity
     * @param  requirements List of Requirements that will be updated
     */
    public List<Requirement__c> updateRequirement(List<Requirement__c> requirements) {
        //NOTE: Take Activity's Id only from first requirement. We sure that users pass only those requirements that belong to only one activity
        if(isLocked(new Activity__c(Id = requirements[0].Activity__c)))
            throw new ActivityServiceException('Cannot update requirements when activity is locked.');
        update requirements;
        return requirements;
    }
    /**
     * deletes a list of requirements related to a particular activity
     * @param requirement List of Requirements that will be deleted
     */
    public void deleteRequirements(List<Requirement__c> requirements) {
        //NOTE: Take Activity's Id only from first requirement. We sure that users pass only those requirements that belong to only one activity
        if(isLocked(new Activity__c(Id = requirements[0].Activity__c)))
            throw new ActivityServiceException('Cannot delete requirements when activity is locked.');
        delete requirements;
    }
    ////////////////////////////////////////// END Requirement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    ////////////////////////////////////////// Award \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /**
     * adds an award to an activity
     * @param awards List of Awards that will be inserted
     */
    public List<Award__c> addAwards(List<Award__c> awards) {
        insert awards;
        return awards;
    }
    /**
     * updates an award related to an activity
     * @param awards List of Awards that will be updated
     */
    public List<Award__c> updateAwards(List<Award__c> awards) {
        update awards;
        return awards;
    }
    /**
     * deletes an award related to an activity
     * @param awards List of Awards that will be deleted
     */
    public void deleteAwards(List<Award__c> awards) {
        delete awards;
    }
    ////////////////////////////////////////// END Award \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /**
     * gets the list of default requirements associated with the activity.  Actually to start with, all activities will have the same set of default requirements.
     * @return List<Default_Requirement__c>
     */
    public List<Default_Requirement__c> getDefaultRequirements() {
        return [SELECT Name, Description__c, Requirement_Weight__c, Type__c FROM Default_Requirement__c];
    }
    /**
     * after submission due date we should prevent publishers from adding requirements and members from making submissions.
     * @param  activity Activity to check of lock
     * @return          TRUE if Activity is locked
     */
     
     
    public Boolean isLocked(Activity__c activity) {
    
        /*
        List<ActivityMilestones__c> milestones = [SELECT Milestone__r.Step_Number__c
                FROM ActivityMilestones__c
                WHERE Activity__c = :activity.Id AND Milestone__r.Name LIKE :Constants.SUBMISSION_DATE_MILESTONE_NAME];
        if (milestones.size() == 0)
            throw new ActivityServiceException('Cannot find Submission Date milestone for the provided activity.');
        return milestones[0].Milestone__r.Step_Number__c < Datetime.now();
        */
        
        return false;
    }
    /**
     * deep copy of an Activity along with Awards, Requirements, Skills. After insert all object into database
     * @param  activity Activity to clone
     * @return          New cloned activity
     */
    public Activity__c cloneActivity(Activity__c activity) {
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        Activity__c newActivity = null;
        try{
            //Querying old activity with all needed related collections
            Activity__c oldActivity = [SELECT   Name,
                                                Activity_Type__c,
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
                                                (SELECT Activity__c, Milestone__c FROM ActivityMilestones__r),
                                                (SELECT Name, Activity__c, Description__c, Requirement_Evaluation__c, Requirement_Weight__c, Type__c FROM Requirements__r),
                                                (SELECT Activity__c, Payment__c FROM Awards__r)
                                        FROM Activity__c 
                                        WHERE Id = :activity.Id];

            newActivity = oldActivity.clone(false, false, false, false);
            insert newActivity;
            List<sObject> newChildObjects = new List<sObject>();
            //Copying ActivityMilestone objects
            for(ActivityMilestones__c oldActivityMilestone : oldActivity.ActivityMilestones__r){
                ActivityMilestones__c newActivityMilestone = oldActivityMilestone.clone(false, false, false, false);
                newActivityMilestone.Activity__c = newActivity.Id;
                newChildObjects.add(newActivityMilestone);
            }
            //Copying Requirement objects
            for(Requirement__c oldRequirement : oldActivity.Requirements__r){
                Requirement__c newRequirement = oldRequirement.clone(false, false, false, false);
                newRequirement.Activity__c = newActivity.Id;
                newChildObjects.add(newRequirement);
            }
            //Copying Award objects
            for(Award__c oldAward : oldActivity.Awards__r){
                Award__c newAward = oldAward.clone(false, false, false, false);
                newAward.Activity__c = newActivity.Id;
                newChildObjects.add(newAward);
            }
            insert newChildObjects;
        }catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
        return newActivity;
    }
    /**
     * Custom Activity Service exception
     */
    public class ActivityServiceException extends ServiceException {

    }
}