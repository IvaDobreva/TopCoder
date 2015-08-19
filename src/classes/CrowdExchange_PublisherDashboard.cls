/*
Class       : CrowdExchange_PublisherDashboard
Description : This class is controller for Publisher Dashboard Page
*/

public class CrowdExchange_PublisherDashboard {
    
    //Current logged-in Publisher
    public User currentUser  {get;set;}
    
    // Summary Data records populated using batch
    public Summary_Data__c summaryData {get;set;}
    public Boolean isSummaryDataPresent {get;set;}
    
    // Members Skill Snapshot records populated using batch
    public List<Member_Skill_Snapshot__c> listMemberSkillSnapshot {get;set;}
    public Boolean isMemberSkillSnapshotPresent {get;set;}

    // List of Story Wrapper holds active stories
    public List<StoryWrapper> listActiveStoryWrapper {get;set;}
    public Boolean isActiveStoryWrapperPresent {get;set;}
    
    // List of Completed Wrapper holds active stories
    public List<StoryWrapper> listCompletedStoryWrapper {get;set;}
    public Boolean isCompletedStoryWrapperPresent {get;set;}
    
    // List of developers
    public List<User> listDeveloper {get;set;}
    public Boolean isDeveloperPresent {get;set;}
    
    //total member count
    public Integer totalMembers {get;set;}
    
    public CrowdExchange_PublisherDashboard(){
        
        //Initialization of Variables and List.
        isSummaryDataPresent = false;
        isMemberSkillSnapshotPresent = false;
        listMemberSkillSnapshot = new List<Member_Skill_Snapshot__c>();
        currentuser = new User();
        
        listActiveStoryWrapper = new List<StoryWrapper>(); 
        isActiveStoryWrapperPresent = false;
        
        listCompletedStoryWrapper = new List<StoryWrapper>(); 
        isCompletedStoryWrapperPresent = false;
        
        isDeveloperPresent = false;
        totalMembers = 0;
        
        try{
            
            // Fetch current user information
            currentuser = [Select Id,Name,Crowd_Exchange_User_Type__c,Email from User where Id=:userinfo.getuserId()]; 
            
            
            // Fetch Summary Data records populated using batch
            list<Summary_Data__c> listSummaryData = [SELECT Active_Stories__c,Completed_Activities__c,Completed_Stories__c,Total_Users__c,
                                                     Id,Name,Number_of_Members__c,Number_of_Publishers__c,Timestamp__c,Total_Activities__c,
                                                     Total_Registrations__c,Total_Reviews__c,Total_Stories__c,Total_Submissions__c,Active_Activities__c 
                                                     FROM Summary_Data__c where CreatedDate = TODAY limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
            List<User> listMembers = [Select Id,Name,Crowd_Exchange_User_Type__c,Email from User where Crowd_Exchange_User_Type__c = :Constants.MEMBER limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];  
            if(listMembers!=null && listMembers.size()>0){
                totalMembers = listMembers.size();
            }
            if(listSummaryData!=null && listSummaryData.size()>0){
                summaryData = listSummaryData[0];
                isSummaryDataPresent = true;
            }
            
            // Fetch Members Skill Snapshot records populated using batch
            listMemberSkillSnapshot = [Select Id,Member_Count__c,Skill_Name__c
                                       from Member_Skill_Snapshot__c where Skill_Name__c!='' and Skill_Name__c!=null and CreatedDate = TODAY limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
            if(listMemberSkillSnapshot!=null && listMemberSkillSnapshot.size()>0){
                isMemberSkillSnapshotPresent = true;
            }
            
            //Fetch Active Stories to show on page  
            Set<Id> setDeveloperId = new Set<Id>();
            List<Story__c> listActiveStory = filterActiveStories();
            if(listActiveStory!=null && listActiveStory.size()>0){
                for(Story__c story: listActiveStory){
                    
                    // Adding Story and its related Activities to Wrapper
                    StoryWrapper storyWrap = new StoryWrapper();
                    if(story.Activities__r!=null && story.Activities__r.size()>0){
                        List<Activity__c> listActivity = new List<Activity__c>();
                        for(Activity__c activity: story.Activities__r){
                            if(activity.Publisher__c!=null && activity.Publisher__c == userinfo.getuserId()){
                                listActivity.add(activity);
                            }
                            if(activity.Assigned_Member__c!=null){
                                setDeveloperId.add(activity.Assigned_Member__c);
                            }
                        }
                        if(listActivity.size()>0){
                            storyWrap.listActivity = listActivity;
                            storyWrap.isActivityPresent = true;
                        }
                    }
                    storyWrap.story = story;
                    listActiveStoryWrapper.add(storyWrap);
                }
            }
            if(listActiveStoryWrapper!=null && listActiveStoryWrapper.size()>0){
                isActiveStoryWrapperPresent = true;
            }
            
            //Fetch Completed Stories to show on page  
            List<Story__c> listCompletedStory = filterCompletedStories();
            if(listCompletedStory!=null && listCompletedStory.size()>0){
                for(Story__c story: listCompletedStory){
                    // Adding Story and its related Activities to Wrapper
                    StoryWrapper storyWrap = new StoryWrapper();
                    if(story.Activities__r!=null && story.Activities__r.size()>0){
                        List<Activity__c> listActivity = new List<Activity__c>();
                        for(Activity__c activity: story.Activities__r){
                            if(activity.Publisher__c!=null && activity.Publisher__c == userinfo.getuserId()){
                                listActivity.add(activity);   
                            }
                            if(activity.Assigned_Member__c!=null){
                                setDeveloperId.add(activity.Assigned_Member__c);
                            }
                        }
                        if(listActivity.size()>0){
                            storyWrap.listActivity = listActivity;
                            storyWrap.isActivityPresent = true;
                        }  
                    }
                    storyWrap.story = story;
                    listCompletedStoryWrapper.add(storyWrap);
                }  
            }
            if(listCompletedStoryWrapper!=null && listCompletedStoryWrapper.size()>0){
                isCompletedStoryWrapperPresent = true;
            } 
            
            //Fetch list of developers
            listDeveloper = fetchDevelopers(setDeveloperId);
            if(listDeveloper!=null && listDeveloper.size()>0){
                isDeveloperPresent = true;           
            }
            
        // Catch if exception caused	
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
		} 
    }
    
     /*
        Method to fetch Stories related to publisher which are active
    */
    public List<Story__c> filterActiveStories(){
        List<Story__c> listStory = [Select Id,Name,(Select Id,Story__r.Name,Status__c,Registrants__c,Submissions__c,Story__c,
                            Name,Assigned_Member__c,Publisher__c from Activities__r)
                            from Story__c where Publisher__c = :userinfo.getuserId() and Status__c!= :Constants.STATUS_CANCELED  and Status__c!= :Constants.STATUS_COMPLETED 
                            limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
        return listStory;
    }

    /*
        Method to fetch Stories related to publisher which are Completed
    */
    public List<Story__c> filterCompletedStories(){
        List<Story__c> listStory = [Select Id,Name,(Select Id,Story__r.Name,Status__c,Registrants__c,Submissions__c,Story__c,
                            Name,Assigned_Member__c,Publisher__c from Activities__r)
                            from Story__c where Publisher__c = :userinfo.getuserId() and Status__c= :Constants.STATUS_COMPLETED 
                            limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
        return listStory;
    }
    
    /*
        Method to fetch Developers who have worked with publisher
    */
    public List<User> fetchDevelopers(Set<Id> setUserId){
        if(setUserId!=null && setUserId.size()>0){
            List<User> listUsers = [Select Id,Name,Crowd_Exchange_User_Type__c,SmallPhotoUrl  
                                       from User where Crowd_Exchange_User_Type__c = :Constants.MEMBER and Id IN :setUserId 
                                       limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
                                      
            return listUsers;
        }
        return null;
    }
    
    /*
        Wrapper class to hold Story and its related Activities information
    */
    public class StoryWrapper{
        
        public Story__c story {get;set;}
        public List<Activity__c> listActivity {get;set;}
        public Boolean isActivityPresent {get;set;}
        
        public StoryWrapper(){
            listActivity = new List<Activity__c>();
            isActivityPresent = false;
        }
    }

}