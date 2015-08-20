/*
Class       : CE_MemberDashboardController
Description : This class is controller for Member-Dashboard Page
*/

public class CE_MemberDashboardController{
    
    //Current logged-in member
    public User currentUser  {get;set;}
    
    //Summary Data populated from batch
    public CE_Summary_Data__c summaryData {get;set;}
    public Boolean isSummaryDataPresent {get;set;}
    
    //Current Active Activity related to member
    public List<CE_Activity__c> listActiveActivity {get;set;}
    public List<ActivityWrapper> listActiveActivityWrapper {get;set;}
    public Boolean isActiveActivityPresent {get;set;}
    public Integer activeActility {get;set;}
    
    //Completed Activity related to member
    public List<CE_Activity__c> listCompletedActivity {get;set;}
    public List<ActivityWrapper> listCompletedActivityWrapper {get;set;}
    public Boolean isCompletedActivityPresent {get;set;}
    public Integer completedActility {get;set;}
    
    //List Publisher
    public List<User> listPublisher {get;set;}
    public Boolean isPublisherPresent {get;set;}
    
    //Boolean variables to check if records are present or not
    public Integer totalActility {get;set;}
    public Integer myResgistrations {get;set;}
    public Integer mySubmissions {get;set;}
    public Integer myReviews {get;set;}
        
    public CE_MemberDashboardController(){  
        
        //Initialization of Variables and List.
        listActiveActivity = new List<CE_Activity__c>();
        listActiveActivityWrapper = new List<ActivityWrapper>();
        listCompletedActivity = new List<CE_Activity__c>();
        listCompletedActivityWrapper = new List<ActivityWrapper>();
        listPublisher = new List<User>();
        currentuser = new User();
        isCompletedActivityPresent = false;
        isActiveActivityPresent = false;
        isPublisherPresent = false;
        isSummaryDataPresent = false;
        totalActility = 0;
        mySubmissions = 0;
        myReviews = 0;
        myResgistrations = 0;
        
        try{

            currentuser = [Select Id,Name,Crowd_Exchange_User_Type__c,Email from User where Id=:userinfo.getuserId() limit 1]; 
            
            // Fetch Summary Data populated using batch that runs daily
            list<CE_Summary_Data__c> listSummaryData = [SELECT Active_Stories__c,Completed_Activities__c,Completed_Stories__c,Total_Users__c,
                                                     Id,Name,Number_of_Members__c,Number_of_Publishers__c,Timestamp__c,Total_Activities__c,
                                                     Total_Registrations__c,Total_Reviews__c,Total_Stories__c,Total_Submissions__c,Active_Activities__c  
                                                     FROM CE_Summary_Data__c where CreatedDate = TODAY limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
            if(listSummaryData!=null && listSummaryData.size()>0){
                summaryData = listSummaryData[0];
                isSummaryDataPresent = true;
            }
            
            //Fetch Current Active Activities to show on page
            listActiveActivity = fetchActiveActivities();
            listActiveActivityWrapper = populateActivityWrapperList(listActiveActivity, true);
            if(listActiveActivity!=null && listActiveActivity.size()>0){
                isActiveActivityPresent = true;
                activeActility = listActiveActivity.size();
                totalActility += activeActility;
            }
            
            //Fetch Completed Activities to show on page
            Set<Id> setPublisherId = new Set<Id>();
            listCompletedActivity = fetchCompletedActivities();
            listCompletedActivityWrapper = populateActivityWrapperList(listCompletedActivity, false);
            if(listCompletedActivity!=null && listCompletedActivity.size()>0){
                for(CE_Activity__c activity : listCompletedActivity){
                    if(activity.Publisher__c!=null){
                        setPublisherId.add(activity.Publisher__c);
                    }
                }
                completedActility = listCompletedActivity.size();
                isCompletedActivityPresent = true;
                totalActility += completedActility;
            }
            
            //Fetch Publisher member has worked with
            listPublisher = fetchPublishers(setPublisherId);
            if(listPublisher!=null && listPublisher.size()>0){
                isPublisherPresent = true;  
            }
            
            //Fetch Registration records member has registered for
            List<CE_Registration__c> listRegistration = [Select Id from CE_Registration__c where User__c =: userinfo.getuserId() limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
            if(listRegistration!=null && listRegistration.size()>0){
                myResgistrations = listRegistration.size();
            }
            
            //Fetch Submission user has submitted for
            List<CE_Submission__c> listSubmission = [Select Id from CE_Submission__c where Submitting_Member__c =: userinfo.getuserId() limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
            if(listSubmission!=null && listSubmission.size()>0){
                mySubmissions = listSubmission.size();
            }
            
            //Fetch Submission user has submitted for that are in review complete phase
            List<CE_Submission__c> listReviewSubmission = [Select Id from CE_Submission__c where Submitting_Member__c =: userinfo.getuserId() and Status__c = :CE_Constants.REVIEW_COMPLETE_STATUS 
                                                        limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
            if(listReviewSubmission!=null && listReviewSubmission.size()>0){
                myReviews = listReviewSubmission.size();
            }
            
        // Catch if exception caused	
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
		} 
    }
    
    /*
        Method to fetch Active Activities related to current user
    */  
    public List<CE_Activity__c> fetchActiveActivities(){
        List<CE_Activity__c> listActivity = [Select Id,CE_Story__r.Name,Status__c,Registrants__c,Submissions__c,CE_Story__c,Name,Assigned_Member__c,Publisher__c, 
                                         (Select Id, Name, CE_Activity__c, CE_Milestone__c, Completed_Date__c, Scheduled_Date__c From ActivityMilestones__r)
                                          from CE_Activity__c where Status__c != :CE_Constants.STATUS_DRAFT and Status__c != :CE_Constants.STATUS_COMPLETED  and Status__c != :CE_Constants.STATUS_CANCELED 
                                          and Assigned_Member__c =: userinfo.getuserId() limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listActivity;
    }

    /*
        Method to fetch Completed Activities related to current user
    */ 
    public List<CE_Activity__c> fetchCompletedActivities(){
        List<CE_Activity__c> listActivity = [Select Id,CE_Story__r.Name,Status__c,Registrants__c,Submissions__c,CE_Story__c,Name,Assigned_Member__c,Publisher__c,
                                          (Select Id, Name, CE_Activity__c, CE_Milestone__c, Completed_Date__c, Scheduled_Date__c From ActivityMilestones__r)
                                          from CE_Activity__c where Status__c = :CE_Constants.STATUS_COMPLETED and Assigned_Member__c =: userinfo.getuserId() limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listActivity;
    }  
    
    /*
        Method to fetch Publishers user has worked with
    */  
    public List<User> fetchPublishers(Set<Id> setUserId){
        if(setUserId!=null && setUserId.size()>0){
            List<User> listUsers = [Select Id,Name,Crowd_Exchange_User_Type__c,SmallPhotoUrl
                                       from User where Crowd_Exchange_User_Type__c = :CE_Constants.PUBLISHER and Id IN :setUserId limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
                                      
            return listUsers;
        }
        return null;
    }
    
    public class ActivityWrapper{
    	
    	public Id activityId {get;set;}
    	public String storyName{get;set;}
    	public String status{get;set;}
    	public Decimal registrants{get;set;}
    	public Decimal submissions{get;set;}
    	public Id story{get;set;}
    	public String activityName{get;set;}
    	public Date startDate{get;set;}
    	public Date endDate{get;set;}
    	
    }
    
    public List<ActivityWrapper> populateActivityWrapperList(List<CE_Activity__c> activityList, boolean active){
    	
    	List<ActivityWrapper> awl = new List<ActivityWrapper>();
    	for(CE_Activity__c a: activityList){
    		ActivityWrapper wrapper = new ActivityWrapper();
    		wrapper.activityId = a.ID;
    		wrapper.activityName = a.Name;
    		wrapper.storyName = a.CE_Story__r.Name;
    		wrapper.status = a.Status__c;
    		wrapper.registrants = a.Registrants__c;
    		wrapper.submissions = a.Submissions__c;
    		wrapper.story = a.CE_Story__c;
    		if(a.ActivityMilestones__r != null && a.ActivityMilestones__r.size() == CE_Constants.NUMBER_OF_MILESTONES){
    		    if(active){
	    		    wrapper.startDate = a.ActivityMilestones__r[1].Scheduled_Date__c;
	    		    wrapper.endDate = a.ActivityMilestones__r[7].Scheduled_Date__c;
    		    } else {
    		    	wrapper.startDate = a.ActivityMilestones__r[1].Completed_Date__c;
	    		    wrapper.endDate = a.ActivityMilestones__r[7].Completed_Date__c;
    		    }
    		    
    		}
    		awl.add(wrapper);
    		
    	}
    	return awl;
    	
    }
    	
    
}