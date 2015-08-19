public with sharing class CrowdExchange_Utils {
	public CrowdExchange_Utils() {
		
	}
	public static final String SITE_PREFIX = Site.getPathPrefix();
    /**
     * Gets communities avaliable for current user
     * @return ConnectApi.CommunityPage
     */
    public static ConnectApi.CommunityPage getCommunities() {
        return ConnectApi.Communities.getCommunities();
    }
    /**
     * Gets current community Id
     * @return Community Id ot null for internal
     */
    public static String getCurrentCommunityId() {
        ConnectApi.CommunityPage cp = null;
        if (!Test.isRunningTest())
            cp = getCommunities();
        else {
            //Test hack
            cp = new ConnectApi.CommunityPage();
            ConnectApi.Community com = new ConnectApi.Community();
            com.urlPathPrefix = '/';
            cp.communities = new List<ConnectApi.Community> {
                com
            };
        }
        String sitePath = SITE_PREFIX;

        if (!cp.communities.isEmpty()) {
            for (ConnectApi.Community community : cp.communities) {
                if (sitePath.contains(community.urlPathPrefix))
                    return community.id;
            }
        }
        return null;
    }
    /**
     * Escapes SOSL special characters
     * @param  term string to escape
     * @return      string with escaped SOSL special characters
     */
    public static String escapeSOSLTerm(String term){
        system.debug(term);
        term = term.replace('\'', '');
        system.debug(term);
        Pattern reservedPattern = pattern.compile('[\\?&\\|!{}\\[\\]\\(\\)\\^~\\*:\\\"\\+-]');
        Matcher myMatcher = reservedPattern.matcher(term);
        List<Integer> escapeIndexs = new List<Integer>();
        while(true){
            if(myMatcher.find()){
                escapeIndexs.add(myMatcher.start());
            }else{
                break;
            }
        }
        escapeIndexs.sort();
        for(Integer i = escapeIndexs.size()-1; i>=0; i--){
            Integer escapeIndex = escapeIndexs[i];
            term = term.substring(0, escapeIndex) + '\\\\' + term.substring(escapeIndex);
        }
        return term; 
    }
    
    /*
        Method to fetch Stories related to publisher which are active
    */
    public static List < Story__c > filterActiveStories(string Id) {
     	List < Story__c > listStory = [Select Id, Name, (Select Id, Story__r.Name, Status__c, Registrants__c, Submissions__c, Story__c,
     	                                Name, Assigned_Member__c, Publisher__c from Activities__r)
     	                                from Story__c where Publisher__c = : Id and Status__c != : Constants.STATUS_CANCELED and Status__c != : Constants.STORY_COMPLETED_STATUS];
     	
     	
     	return listStory;
     	
    }
    
    /* Attempt to add milestones to story output.  
     	
    public static List<Story__c> addMilestonesToStoryList(List <Story__c> listStory){
	    
	
     	Map<ID, Activity__c> activityMap = new Map<ID, Activity__c>();
     	for(Story__c story : listStory){
     		for(Activity__c activity : story.Activities__r){
     			activityMap.put(activity.Id, activity);
     		}
     	}
     	
     	List<Activity__c> listActivity = [Select Id, (Select Id, Name, Activity__c, Milestone__c, Completed_Date__c, Scheduled_Date__c From ActivityMilestones__r) 
     	                                from Activity__c where Id in :activityMap.keySet()];
     	                                
     	for(Activity__c activity : listActivity){
     		if(activityMap.contains(activity.ID)){
     			Activity__c mapActivity = activityMap.get(activity.ID);
     			if(activity.ActivityMilestones__r != null){
     				List<ActivityMilestones> activityMilestoneList = new List<ActivityMilestones>();
	     			for(ActivityMilestone am : activity.ActivityMilestones__r){
	     				ActivityMilestone amToAdd = new ActivityMilestone();
	     				amToAdd = am;
	     				activityMilestoneList(amToAdd);
	     			}
     			}
     		}
     	}
     	
     	
     	return listStory;
     }
     
     */
    
    /*
        Method to fetch Stories related to publisher which are Completed
    */
     public static List < Story__c > filterCompletedStories(string Id) {
     	List < Story__c > listStory = [Select Id, Name, (Select Id, Story__r.Name, Status__c, Registrants__c, Submissions__c, Story__c,
                                     	Name, Assigned_Member__c, Publisher__c from Activities__r)
                                     	from Story__c where Publisher__c = : Id and Status__c = : Constants.STORY_COMPLETED_STATUS];
                                     	
     	return listStory;
     }
     
     
    
     
     /*
        Method to fetch Stories related to publisher which are active
    */
     public static List < User > fetchDevelopers(Set < Id > setUserId) {
     	if (setUserId != null && setUserId.size() > 0) {
     		List < User > listUsers = [Select Id, Name, Crowd_Exchange_User_Type__c, SmallPhotoUrl
                                 		from User where Crowd_Exchange_User_Type__c = 'Member'
                                 		and Id IN: setUserId];
    
     		return listUsers;
     	}
     	return null;
     }
     
     /*
        Method to fetch Active Activities count
    */
     public static integer getActiveActivityCount(list < Activity__c > listActivity) {
     	if (listActivity != null && listActivity.size() > 0) {
     		integer activeActivityCounter = 0;
     		for (Activity__c activity: listActivity) {
     			if (activity.status__c != Constants.STATUS_CANCELED && activity.status__c != Constants.STATUS_COMPLETED && activity.status__c != Constants.STATUS_DRAFT) {
     				activeActivityCounter++;
     			}
     		}
     		return activeActivityCounter;
     	} else {
     		return 0;
     	}
     }
     
     /*
        Method to fetch Completed Activities count
    */
     public static integer getCompletedActivityCount(list < Activity__c > listActivity) {
     	if (listActivity != null && listActivity.size() > 0) {
     		integer completedActivityCounter = 0;
     		for (Activity__c activity: listActivity) {
     			if (activity.status__c == Constants.STATUS_COMPLETED) {
     				completedActivityCounter++;
     			}
     		}
     		return completedActivityCounter;
     	} else {
     		return 0;
     	}
     }
     
     /*
        Method to fetch members that has been assigned to Activities.
    */
     public static set < id > getAssignedMemberList(list < Activity__c > listActivity) {
     	if (listActivity != null && listActivity.size() > 0) {
     		set < Id > memberIdSet = new set < Id > ();
     		for (Activity__c activity: listActivity) {
     			if (activity.status__c != Constants.STATUS_CANCELED && activity.status__c != Constants.STATUS_COMPLETED && activity.status__c != Constants.STATUS_DRAFT && activity.Assigned_Member__c != null) {
     				memberIdSet.add(activity.Assigned_Member__c);
     			}
     		}
     		if (memberIdSet != null && memberIdSet.size() > 0) return memberIdSet;
     		else return null;
     	} else {
     		return null;
     	}
     }
        


}