/*
Class       : CE_MemberMemberProfileController
Description : This class is controller for Member-Member profile page
*/

public class CE_MemberMemberProfileController {
    
    //Current logged-in member
    public User currentMember {get;set;}
    
    //User SKills related to member
    public List<CE_UserSkill__c> listMemberSkills {get;set;}
    public Boolean isMemberSkillPresent {get;set;}

    //Internal Project related to member
    public List<CE_Internal_Project__c> listInternalProjects {get;set;}
    public Boolean isInternalProjectsPresent {get;set;}
    
    //Current Activity related to member
    public List<CE_Activity__c> listCurrentActivity {get;set;}
    public List<ActiveActivityWrapper> listCurrentActivityWrapper {get;set;}
    public Boolean isCurrentActivityPresent {get;set;}
    
    //Completed Activity related to member
    public List<CompletedActivityWrapper> listCompletedActivityWrapper {get;set;}
    public List<CE_Activity__c> listCompletedActivity {get;set;}
    public Boolean isCompletedActivityPresent {get;set;}    
    
    //Boolean variables to check if records are present or not
    public Integer currentActivity {get;set;}
    public Integer completedActivityCount {get;set;}
    public Integer totalActivity {get;set;}
    public Integer totalMemberSkill {get;set;}
    public String userId {get;set;}
    
    //email template record amd email related information
    public EmailTemplate emailTemplate {get;set;}
    public List<ActivityWrapper> listActivityWrapper{get;set;}
    public String subject {get;set;}
    public String body {get;set;}
    public String bodyAll {get;set;}
    public String email {get;set;}
    public String selectedUser {get;set;}
    public Boolean isPublisherActivityPresent {get;set;}
    
    //Holds Banner image of user
    public Attachment headerImageAttachment {get;set;}
    
    public CE_MemberMemberProfileController(){
        
        //Initialization of Variables and List.
        currentMember = new User();
        userId = '';
        currentActivity = 0;    
        totalActivity = 0; 
        totalMemberSkill = 0; 
        completedActivityCount = 0;
        
        //Get User if from page parameter and fetching user fields, 
       //If parameter is not present fetch information of current user
        userId = ApexPages.currentPage().getParameters().get(CE_Constants.ID);
        if(userId!=null && userId!=''){
            currentMember = [Select Id,Title,Name,Email,Crowd_Exchange_Organization__c,AboutMe,Phone,SmallPhotoUrl,FullPhotoUrl,Crowd_Exchange_About_Me__c 
                             from User where Id =: userId limit 1];
        }else{
            currentMember = [Select Id,Title,Name,Email,Crowd_Exchange_Organization__c,AboutMe,Phone,SmallPhotoUrl,FullPhotoUrl,Crowd_Exchange_About_Me__c 
                             from User where Id =: userinfo.getuserId() limit 1];
        }  
        userId = currentMember.Id;
        
        //Fetch Member skills to show on page
        isMemberSkillPresent = false;                 
        listMemberSkills = new List<CE_UserSkill__c>();
        listMemberSkills = filterMemberSkills();
        if(listMemberSkills!=null && listMemberSkills.size()>0){
            isMemberSkillPresent = true;
            totalMemberSkill = listMemberSkills.size();
        }
        
        //Fetch Internal Projects to show on page    
        listInternalProjects = new List<CE_Internal_Project__c>();
        listInternalProjects = filterInternalProjects();
        if(listInternalProjects!=null && listInternalProjects.size()>0){
            isInternalProjectsPresent = true;
        }
        
         //Fetch Current Activities to show on page
        isCurrentActivityPresent = false;                 
        listCurrentActivity = new List<CE_Activity__c>();
        listCurrentActivity = filterCurrentActivity();
        listCurrentActivityWrapper = new List<ActiveActivityWrapper>();
        listCurrentActivityWrapper = populateActivityWrapperList(listCurrentActivity);
        if(listCurrentActivity!=null && listCurrentActivity.size()>0){  
            isCurrentActivityPresent = true;
            currentActivity = listCurrentActivity.size();
            totalActivity += currentActivity;
        }
        
        //Fetch Completed Activities to show on page
        isCompletedActivityPresent = false;      
        listCompletedActivityWrapper = new List<CompletedActivityWrapper>();
        List<CE_Activity__c> listCompletedActivity = new List<CE_Activity__c>();
        listCompletedActivity = filterCompletedActivity();
        if(listCompletedActivity!=null && listCompletedActivity.size()>0){
            for(CE_Activity__c activity : listCompletedActivity){
                CompletedActivityWrapper cActivityWrapper = new CompletedActivityWrapper(activity);
                for(CE_Submission__c submission: activity.Submissions__r){
                    if(submission.Submitting_Member__c == currentMember.Id){
                        cActivityWrapper.submission = submission;
                    }
                }
                if(activity.ActivityMilestones__r != null && activity.ActivityMilestones__r.size() == CE_Constants.NUMBER_OF_MILESTONES){
	    		    	cActivityWrapper.startDate = activity.ActivityMilestones__r[1].Completed_Date__c;
		    		    cActivityWrapper.endDate = activity.ActivityMilestones__r[7].Completed_Date__c;
	    		}
	    		
	    		listCompletedActivityWrapper.add(cActivityWrapper);
	    		
	         }
             isCompletedActivityPresent = true;
             completedActivityCount = listCompletedActivity.size();  
             totalActivity += listCompletedActivity.size();    
                
        }
            
        
        //Fetch USer banner image from custom object
        List<CE_User_Header_Picture__c> listUserHeaderPicture = [Select Id,(Select Id, ParentId From Attachments) from CE_User_Header_Picture__c 
                                                              where User__c =: currentMember.Id limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        if(listUserHeaderPicture!=null && listUserHeaderPicture.size()>0){
            CE_User_Header_Picture__c userHeaderPicture = listUserHeaderPicture[0];
            if(userHeaderPicture.Attachments!=null && userHeaderPicture.Attachments.size()>0){
                headerImageAttachment = userHeaderPicture.Attachments[0];
            }
        }
        
        //Fetch Activit list
        fetchActivityList();
                         
    }
    
    /*
        Method to fetch User skills related to current user
    */
    public List<CE_UserSkill__c> filterMemberSkills(){  
        List<CE_UserSkill__c> listUserSkills = [Select Id,Experience_Level__c,Member__c,Skill__r.Name
                                             from CE_UserSkill__c where Member__c =: userId and Skill__c!=null 
                                             limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listUserSkills;
    }

    /*
        Method to fetch Internal Projects to current user
    */
    public List<CE_Internal_Project__c> filterInternalProjects(){
        List<CE_Internal_Project__c> listInternalProject = [Select Id,Description__c,Name,(Select Id,Skill__r.Name from Internal_Project_Skills__r)
                                                         from CE_Internal_Project__c where Member__c =: userId 
                                                         limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listInternalProject;
    }
    
    /*
        Method to fetch Active Activities related to current user
    */
    public List<CE_Activity__c> filterCurrentActivity(){  
        List<CE_Activity__c> listActivity = [Select Id,Name,Possible_Score__c,Cost__c,
                                          (Select Id,Skill__r.Name from Activity_Skills__r),
                                          (Select Id, Name, CE_Activity__c, CE_Milestone__c, Completed_Date__c, Scheduled_Date__c From ActivityMilestones__r) 
                                          from CE_Activity__c where Status__c != :CE_Constants.STATUS_DRAFT and Status__c != :CE_Constants.STATUS_COMPLETED  and Status__c != :CE_Constants.STATUS_CANCELED 
                                          and Assigned_Member__c =: userId limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listActivity;
    }
    
    /*
        Method to fetch Completed Activities related to current user
    */ 
    public List<CE_Activity__c> filterCompletedActivity(){
        List<CE_Activity__c> listActivity = [Select Id,Name,Possible_Score__c,Cost__c,
                                          (Select Id,Skill__r.Name from Activity_Skills__r),
                                          (Select Id, Name, CE_Activity__c, CE_Milestone__c, Completed_Date__c, Scheduled_Date__c From ActivityMilestones__r),
                                          (Select id,Evaluation_Percentage__c,Placement__c,Submission_Score__c,Submitting_Member__c from Submissions__r)
                                          from CE_Activity__c where Status__c =  :CE_Constants.STATUS_COMPLETED and Assigned_Member__c =: userId 
                                          limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];  
        return listActivity;
    }
    
        
    /*
        Method to fetch Activity List to show when publisher clicks email button on member tabs 
    */    
    public void fetchActivityList(){

            try{
                User user = [Select Id,Name,Email from User where Id =:currentMember.Id];
                email = user.email;  
                
                // Fetch email template
                List<EmailTemplate> listEmailTemplate = [Select Id,Body,Subject from EmailTemplate where Name = :CE_Constants.MEMBER_SEARCH];
                if(listEmailTemplate!=null &&listEmailTemplate.size()>0){
                    emailTemplate = listEmailTemplate[0];
                    subject = emailTemplate.Subject;
                    body = emailTemplate.Body;
                }
                
                // Website url from custom setting
                CE_CrowdExchangeSettings__c ceWebsite = CE_CrowdExchangeSettings__c.getOrgDefaults();  
                String urlWebsite = ceWebsite.Site_Url__c;
                listActivityWrapper = new List<ActivityWrapper>();
                
                //List of all activities for a user
                List<CE_Activity__c> listActivities = [Select Id,Name from CE_Activity__c where Publisher__c = :userinfo.getuserId() and ( Status__c = :CE_Constants.STATUS_IN_REGISTRATION or Status__c = :CE_Constants.STATUS_PUBLIC )
                                                    limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
                if(listActivities!=null && listActivities.size()>0){
                    for(CE_Activity__c activity : listActivities){
                
                        String mergedBody = body.replace('{{userFirstName}}:', '{!User.Name}:%0A');
                        mergedBody = mergedBody.replace('{!User.Name}', user.Name);
                        if(urlWebsite!=null){
                            mergedBody = mergedBody.replace('{!$Setup.CE_CrowdExchangeSettings__c.Site_Url__c}', urlWebsite);
                        }
                        mergedBody = mergedBody.replace('{{activityName}}', activity.Name); 
                         
                        ActivityWrapper activityWrap = new ActivityWrapper(activity.Id, activity.Name,mergedBody,user.Email);
                        
                        listActivityWrapper.add(activityWrap);  
                    }
                }
                
                //form email body with activity name mentioned in body
                bodyAll = body.replace('{{userFirstName}}:', '{!User.Name}:%0A');
                bodyAll = bodyAll.replace('{!User.Name}', user.Name); 
                if(urlWebsite!=null){  
                    bodyAll = bodyAll.replace('{!$Setup.CE_CrowdExchangeSettings__c.Site_Url__c}', urlWebsite);
                }
                bodyAll = bodyAll.replace('{{activityName}}', '<enter activity name>');
                        
                if(listActivityWrapper!=null && listActivityWrapper.size()>0){
                    isPublisherActivityPresent = true;  
                }
                
            // Catch if exception caused  	
    		}catch(Exception ex){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
    		} 
    }
    
    /*
        Activity Wrapper holds activity information   
    */
    public class ActivityWrapper{
    	public String activityId {get;set;}
        public String activityName {get;set;}
        public String activityBody {get;set;}
        public String email {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public ActivityWrapper(String aId, String aName,String aBody,String userEmail){
            activityId = aId;
            activityName = aName;
            activityBody = aBody;
            email = userEmail;
        }
    }
    
    /*
        Completed Activity Wrapper holds completed activity information   
    */
    public class ActiveActivityWrapper{  
        
        public CE_Activity__c activity {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
       
    }
        
    public List<ActiveActivityWrapper> populateActivityWrapperList(List<CE_Activity__c> activityList){
    	
    	List<ActiveActivityWrapper> awl = new List<ActiveActivityWrapper>();
    	for(CE_Activity__c a: activityList){
    		ActiveActivityWrapper wrapper = new ActiveActivityWrapper();
    		wrapper.activity = a;
    		if(a.ActivityMilestones__r != null && a.ActivityMilestones__r.size() == CE_Constants.NUMBER_OF_MILESTONES){
	    		    wrapper.startDate = a.ActivityMilestones__r[1].Scheduled_Date__c;
	    		    wrapper.endDate = a.ActivityMilestones__r[7].Scheduled_Date__c;
    		}
    		awl.add(wrapper);
    		
    	}
    	return awl;
    	
    }
    
    
    
    
    /*
        Completed Activity Wrapper holds completed activity information   
    */
    public class CompletedActivityWrapper{  
        
        public CE_Activity__c completedActivity {get;set;}
        public CE_Submission__c submission {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public CompletedActivityWrapper(CE_Activity__c cActivity){
            completedActivity = cActivity;
        }
        
    }
    
}