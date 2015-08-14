/*
	Static class holding workflow process related methods for monitering activities and updating 
	status as per process.
	Added against TC30050600
*/
public with sharing class WorkflowManager {
	
	/*
		Method for processing activities, updating status to next level depending on activity current status.
		The method is mainly called from batch
	*/
	public static void processActivities(List<Activity__c> activities) {
		// Return if activities is null or empty
		if(activities == null || activities.isEmpty()) return;
		
		set<Id> activityIdSet = new Map<Id, Activity__c>(activities).keySet();
		
		// Getting list of all activity Milestones for given set of activity ids 
		List<ActivityMilestones__c> activityMilestones = loadActivityMilestonesByActivityIdSet(activityIdSet);
        
        // Getting activity details        
        Map<Id, Activity__c> activityByIdMap = getActivitiesByIdSet(activityIdSet);         
        
        Map<Id, Activity__c> activitiesToUpdateMap = new Map<Id, Activity__c>();
        List<ActivityMilestones__c> activityMilestonesToUpdate = new List<ActivityMilestones__c>();
        
        for(ActivityMilestones__c am : activityMilestones) {
            Activity__c activity = activityByIdMap.get(am.Activity__c);
            
            // Flag to check if activity and ActivityMilestones need to be added to list 
            // for update or not. 
            boolean addForUpdate = false;
            // Flag to check if (only) activity needs to be added to list for update for notification or not
            // If it is only for notification, ActivityMilestones should not be closed
            boolean addForUpdateForNotification = false;
            
            if(am.Milestone__r.Name == Constants.PUBLISH_DATE_MILESTONE_NAME 
                && activity.Status__c == Constants.STATUS_DRAFT && am.Scheduled_Date__c <= Date.today()) {
                
                // setting the activity status as Public. 
                activity.Status__c = Constants.STATUS_PUBLIC;
                addForUpdate = true;
            
            } else if(am.Milestone__r.Name == Constants.START_DATE_MILESTONE_NAME 
                    && activity.Status__c == Constants.STATUS_PUBLIC && am.Scheduled_Date__c <= Date.today()) {
                
                // setting the activity status as In Registration. 
                activity.Status__c = Constants.STATUS_IN_REGISTRATION;
                addForUpdate = true;
                
            } else if(am.Milestone__r.Name == Constants.REGISTRATION_DATE_MILESTONE_NAME 
                    && activity.Status__c == Constants.STATUS_IN_REGISTRATION
                    && am.Scheduled_Date__c <= Date.today()){
                    
                if(activityByIdMap.get(activity.Id).Registrations__r != null 
                    && !activityByIdMap.get(activity.Id).Registrations__r.isEmpty()) {
                
                    // setting the activity status as In Assignment. 
                    activity.Status__c = Constants.STATUS_IN_ASSIGNMENT;
                    addForUpdate = true;
                    // sending notification email "Activity Registration Complete"
                    activity.Notification_Code__c = Constants.NOTIFICATION_ACTIVITY_REGISTRATION_COMPLETE;
                    addForUpdateForNotification = true;
                
                }else{
                
                    // sending notification email "No Registered Users"
                    activity.Notification_Code__c = Constants.NOTIFICATION_NO_REGISTERED_USERS;
                    addForUpdateForNotification = true;

                }
                
            } else if(am.Milestone__r.Name == Constants.ASSIGNMENT_DATE_MILESTONE_NAME 
                    && activity.Status__c == Constants.STATUS_IN_ASSIGNMENT 
                    && am.Scheduled_Date__c <= Date.today()
                    && activity.Assigned_Member__c != null) {
                
                // setting the activity status as In Submission. 
                activity.Status__c = Constants.STATUS_IN_SUBMISSION;
                addForUpdate = true;
                
            } else if(am.Milestone__r.Name == Constants.SUBMISSION_DATE_MILESTONE_NAME 
                    && activity.Status__c == Constants.STATUS_IN_SUBMISSION
                    && am.Scheduled_Date__c <= Date.today()){
                                
                if(hasValidSubmissions(activity.Id, activityByIdMap.get(activity.Id).Submissions__r, am.Scheduled_Date__c)) { 
                
                    // setting the activity status as In Review. 
                    activity.Status__c = Constants.STATUS_IN_REVIEW;
                    addForUpdate = true;
                
                }else { 

                    // sending notification email "No Submissions"
                    activity.Notification_Code__c = Constants.NOTIFICATION_NO_SUBMISSIONS;
                    addForUpdateForNotification = true;

                }
                
            } else if(am.Milestone__r.Name == Constants.REVIEW_DATE_MILESTONE_NAME
                    && activity.Status__c == Constants.STATUS_IN_REVIEW
                    && am.Scheduled_Date__c <= Date.today().addDays(2)
                    && !isAnySubmissionsReview(activity.Submissions__r)){

                // sending notification email "No Reviews Received"
                activity.Notification_Code__c = Constants.NOTIFICATION_NO_REVIEWS_RECEIVED;
                addForUpdateForNotification = true;
                
            } 
            
            // Will only update if there any change in status or notification code. 
            if(addForUpdate || addForUpdateForNotification) {
                activitiesToUpdateMap.put(activity.Id, activity);
                
                // Will only update if there any change in status 
                if(addForUpdate){
                    // setting the activity Milestone Completed date
                    am.Completed_Date__c = Date.today();
                    activityMilestonesToUpdate.add(am);
                }
            }
            
        } 
        
        // Update acticity Status 
        if(!activitiesToUpdateMap.isEmpty()) update activitiesToUpdateMap.values();
        
        // Update the set Completed date
        if(!activityMilestonesToUpdate.isEmpty()) update activityMilestonesToUpdate;
            
    }
    
    /*
        Method for getting list of all activity Milestones for given set of activity ids order by 
        milestone Step Number asc
    */
    public static List<ActivityMilestones__c> loadActivityMilestonesByActivityIdSet(set<Id> activityIdSet) {
        
        List<ActivityMilestones__c> activityMilestones = [SELECT Scheduled_Date__c, Milestone__r.Name,
                    Activity__c FROM ActivityMilestones__c
                    WHERE Activity__c IN :activityIdSet AND Milestone__c != null order by Milestone__r.Step_Number__c asc];
                    
        return activityMilestones;                  
    }
    
    /*
        Method to get activities for set activity ids passed as argument. Activities are loaded along with 
        related registration and submissions.
    */
    public static Map<Id, Activity__c> getActivitiesByIdSet(set<Id> activityIdSet) {
        Map<Id, Activity__c> activityByIdMap = new Map<Id, Activity__c>([Select Id, Status__c, Assigned_Member__c, 
                    Story__c, Notification_Code__c, hasAwards__c, 
                    (Select Id, Notification_Code__c From Registrations__r),
                    (SELECT Name, Activity__c, Submitting_Member__c, Submission_Timestamp__c, Status__c 
                        FROM Submissions__r WHERE Submission_Timestamp__c != null 
                        AND Submitting_Member__c != null) 
                    from Activity__c where id IN: activityIdSet]); 
                      
        return activityByIdMap;                 
    }
    
    /*
        Method for getting list of valid submissions for a specific activity. The list of submission passed as argument belong to 
        single activity and are checked against the activityScheduledDate passed as argument.
    */
    public static boolean hasValidSubmissions(Id activityId, List<Submission__c> submissions, Date activityScheduledDate) {
        
        //Creating Subbmiting_Member -> Submission map to ensure that for each user there's will be only one submission
        Map<Id, Submission__c> submissionMap = new Map<Id, Submission__c>();
        
        // Added check for submission Timestamp to be less then or equal to Activity Schedule Date and 
        // submission activity id should match activityId passed as argument as we need to check submission 
        // for specific activity only.
        
		for(Submission__c submission : submissions) {
			System.debug('++++ActivityScheduledDate: ' + activityScheduledDate);
		    System.debug('++++SubmissionTimestamp: ' + submission.Submission_Timestamp__c);
            if(activityId == submission.Activity__c && submission.Submission_Timestamp__c.date() <= activityScheduledDate){
            	System.debug('++++Valid Submission Found');
                submissionMap.put(submission.Submitting_Member__c, submission);
            }
        }
		return !submissionMap.IsEmpty();
	}
	
	/*
		Method to process submissions. As part of this method it will check weather all submission 
		corresponding to updated submission activity are reviewed or not. If all are review the 
		activity status will be marked as review complete.
	*/
	public static void processSubmissionReview(List<Submission__c> submissions) {
		
		// Return if submissions is null or empty
		if(submissions == null || submissions.isEmpty()) return;
		
		set<Id> activityIdSet = new Set<Id>();
		
		for(Submission__c submission  : submissions) {
			activityIdSet.add(submission.Activity__c);
		}
		
		// Getting list of all activity Milestones for given set of activity ids 
		List<ActivityMilestones__c> activityMilestones = loadActivityMilestonesByActivityIdSet(activityIdSet);
		
		Map<Id, Activity__c> activityByIdMap = getActivitiesByIdSet(activityIdSet);
		
		List<Activity__c> activitiesToUpdate = new List<Activity__c>();
        List<ActivityMilestones__c> activityMilestonesToUpdate = new List<ActivityMilestones__c>();
        List<Submission__c> submissionsToUpdate = new List<Submission__c>();
        
        for(ActivityMilestones__c am : activityMilestones) {
            Activity__c activity = activityByIdMap.get(am.Activity__c);
            
            if(am.Milestone__r.Name == Constants.REVIEW_DATE_MILESTONE_NAME 
                    && activity.Status__c == Constants.STATUS_IN_REVIEW 
                    && am.Scheduled_Date__c <= Date.today()
                    && isAllSubmissionsReview(activityByIdMap.get(activity.Id).Submissions__r)) {
                
                // setting the activity status as Review Complete. 
                activity.Status__c = Constants.REVIEW_COMPLETE_STATUS;
                // setting the activity Milestone Completed date
                am.Completed_Date__c = Date.today();
                
                activitiesToUpdate.add(activity);
                activityMilestonesToUpdate.add(am);
                
                // setting the submission notification "Submission Review Complete"
                for(Submission__c s : activityByIdMap.get(activity.Id).Submissions__r){
                    s.Notification_Code__c = Constants.NOTIFICATION_SUBMISSION_REVIEW_COMPLETE;
                    submissionsToUpdate.add(s);
                }
                
            } 
        }
        
        // Update acticity Status 
        if(!activitiesToUpdate.isEmpty()) update activitiesToUpdate;
        
        // Update the set Completed date
        if(!activityMilestonesToUpdate.isEmpty()) update activityMilestonesToUpdate;
        
        // Update the submissions
        if(!submissionsToUpdate.isEmpty()) update submissionsToUpdate;
	}
	
	/*
		Check if all submissions are reviewed or not i.e submission status equals to Review Complete
	*/
	public static boolean isAllSubmissionsReview(List<Submission__c> submissions) {
		
		boolean allSubmissionReviewed = true;
		for(Submission__c submission : submissions) {
			// check if any of the submission is not yet marked as review complete.
			if(submission.Status__c != Constants.REVIEW_COMPLETE_STATUS) {
				allSubmissionReviewed = false;
				break;
			}
		}
		return allSubmissionReviewed;
	}
	
	
	/*
        Check if any submission is reviewed or not i.e submission status equals to Review Complete
    */
    public static boolean isAnySubmissionsReview(List<Submission__c> submissions) {
        
        for(Submission__c submission : submissions) {
            // check if any of the submission is not yet marked as review complete.
            if(submission.Status__c == Constants.REVIEW_COMPLETE_STATUS) {
                return true;
            }
        }
        return false;
    }
	
	/*
		method for processing activities after submission review to update activity as Accepted and Complete
		Method will be call from activity trigger. 
	*/
	public static void processActivitiesAfterReview(List<Activity__c> activities) {
		// Return if activities is null or empty
		if(activities == null || activities.isEmpty()) return;
		
		set<Id> activityIdSet = new Map<Id, Activity__c>(activities).keySet();
		
		// Getting list of all activity Milestones for given set of activity ids 
		List<ActivityMilestones__c> activityMilestones = loadActivityMilestonesByActivityIdSet(activityIdSet);
        
        // Getting activity details        
        Map<Id, Activity__c> activityByIdMap = getActivitiesByIdSet(activityIdSet);         
        
        Map<Id, Activity__c> activitiesToUpdateMap = new Map<Id, Activity__c>();
        List<ActivityMilestones__c> activityMilestonesToUpdate = new List<ActivityMilestones__c>();
        
        // To find out Stories to Complete
        Set<Id> storyIdSet = new Set<Id>();
        
        // Registrations to Update
        List<Registration__c> registrationsToUpdate = new List<Registration__c>();

        // Submissionsto Update
        List<Submission__c> submissionsToUpdate = new List<Submission__c>();
        
        for(ActivityMilestones__c am : activityMilestones) {
            Activity__c activity = activityByIdMap.get(am.Activity__c);
            
            // Flag to check if activity and ActivityMilestones need to be added to list 
            // for update or not. 
            boolean addForUpdate = false;
            
            if(am.Milestone__r.Name == Constants.ACCEPTANCE_DATE_MILESTONE_NAME 
                    && activity.Status__c == Constants.REVIEW_COMPLETE_STATUS 
                    && am.Scheduled_Date__c <= Date.today()) {
                
                // setting the activity status as Accepted. 
                activity.Status__c = Constants.STATUS_ACCEPTED;
                addForUpdate = true;
                
            } else if(am.Milestone__r.Name == Constants.END_DATE_MILESTONE_NAME 
                    && am.Scheduled_Date__c <= Date.today()) {
                
                if(activity.Status__c == Constants.STATUS_ACCEPTED){ 

                    // setting the activity status as Complete. 
                    activity.Status__c = Constants.STATUS_COMPLETE;
                    addForUpdate = true;
                    // setting notification "Activity Awarded"
                    if(activity.hasAwards__c){
                        for(Submission__c submission : activity.Submissions__r){
                            submission.Notification_Code__c = Constants.NOTIFICATION_ACTIVITY_AWARDED;
                            submissionsToUpdate.add(submission);
                        }
                    }
                }
                
                storyIdSet.add(activity.Story__c);
            }
            
            // Will only update if there any change in status. 
            if(addForUpdate) {
                activitiesToUpdateMap.put(activity.id, activity);
                
                // setting the activity Milestone Completed date
                am.Completed_Date__c = Date.today();
                activityMilestonesToUpdate.add(am);
            }
        }
        // Update acticity Status 
        if(!activitiesToUpdateMap.isEmpty()) update activitiesToUpdateMap.values();
        
        // Update the set Completed date
        if(!activityMilestonesToUpdate.isEmpty()) update activityMilestonesToUpdate;
        
        // Update Registrations
        if(!registrationsToUpdate.isEmpty()) update registrationsToUpdate;
        
        // Update Submissions
        if(!submissionsToUpdate.isEmpty()) update submissionsToUpdate;
        
        // Update Stories to complete
        if(!storyIdSet.isEmpty()) checkAndCompleteStories(storyIdSet);

    }
    
    /*
        method for checking open activities for stories and changing status to complete if no open activities.
    */
    public static void checkAndCompleteStories(Set<Id> storyIdSet){
        List<Story__c> storiesToUpate = new List<Story__c>();
        for(Story__c story : [
            SELECT 
                Id, (
                    SELECT 
                        Id 
                    FROM 
                        Activities__r 
                    WHERE 
                        Status__c != :Constants.STATUS_COMPLETE AND
                        Status__c != :Constants.STATUS_CANCELED
                    LIMIT 1
                ) 
            FROM
                Story__c
            WHERE
                Id in :storyIdSet
        ]){
            if(story.Activities__r.isEmpty()){
                story.Status__c = Constants.STATUS_STORY_COMPLETED;
                storiesToUpate.add(story);
            }
        }
        
        if(!storiesToUpate.isEmpty()) update storiesToUpate;
                    
    }
    
    
    /*
        method for processing stories after cancellation to cancel all related activities and set notifications.
        Method will be call from story trigger. 
    */
    public static void processStoryCancel(Map<Id, Story__c> oldStoryMap, Map<Id, Story__c> newStoryMap){
        Set<Id> storyIdSet = new Set<Id>();
        List<Registration__c> registrationsToUpdate = new List<Registration__c>();
        
        for(Story__c oldStory : oldStoryMap.values()){
            Story__c newStory = newStoryMap.get(oldStory.id);
            if(newStory.Status__c != oldStory.Status__c && newStory.Status__c == Constants.STATUS_STORY_CANCELLED){
                storyIdSet.add(oldStory.id);
            }
        }
        
        if(storyIdSet.isEmpty()) return;
        
        List<Activity__c> activitiesToUpdate = [
            SELECT Id, Notification_Code__c, Status__c, (SELECT Id, Notification_Code__c FROM Registrations__r) 
             FROM Activity__c WHERE Story__c in :storyIdSet
        ];
        
        for(Activity__c activity : activitiesToUpdate){
            activity.Status__c = Constants.STATUS_CANCELED;
        }
        
        if(!activitiesToUpdate.isEmpty()) update activitiesToUpdate;
    }

    /*
        method for processing activities after cancellation to set notifications.
        Method will be call from activitytrigger. 
    */
    public static void processActivityCancel(Map<Id, Activity__c> oldActivityMap, Map<Id, Activity__c> newActivityMap){
        Set<Id> ActivityIdSet = new Set<Id>();
        
        for(Activity__c oldActivity : oldActivityMap.values()){
            Activity__c newActivity = newActivityMap.get(oldActivity.id);
            if(newActivity .Status__c != oldActivity .Status__c && newActivity.Status__c == Constants.STATUS_CANCELED){
                ActivityIdSet.add(oldActivity.id);
            }
        }
        
        if(ActivityIdSet.isEmpty()) return;
        
        List<Registration__c> registrationsToUpdate = [
            SELECT Id, Notification_Code__c, Activity__r.Story__r.Status__c FROM Registration__c WHERE Activity__c in :ActivityIdSet
        ];
        
        for(Registration__c reg : registrationsToUpdate){
            reg.NotificatioN_Code__c = reg.Activity__r.Story__r.Status__c == Constants.STATUS_STORY_CANCELLED 
                ? Constants.NOTIFICATION_STORY_CANCELLED : Constants.NOTIFICATION_ACTIVITY_CANCELLED;
        }
        
        if(!registrationsToUpdate.isEmpty()) update registrationsToUpdate;
    }
}