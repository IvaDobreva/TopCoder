/*
Class       : CrowdExchangeMemberMyProfileController
Description : This class is controller for Member-My-Profile Page and Publisher-Member-Profile page
              which shows details of member to himself and publisher.
*/

public class CrowdExchangeMemberMyProfileController {     
    
    //Current logged-in member
    public User currentMember {get;set;}  
    
    
    //User SKills related to member
    public List<UserSkill__c> listMemberSkills {get;set;}
    public Boolean isMemberSkillPresent {get;set;}

    //Internal Project related to member
    public List<Internal_Project__c> listInternalProjects {get;set;}
    public Boolean isInternalProjectsPresent {get;set;}
    
    //Current Activity related to member
    public List<Activity__c> listCurrentActivity {get;set;}      
    public Boolean isCurrentActivityPresent {get;set;}
    
    //All skills present in org for showing in page                 
    public List<Skills__c> listSkills {get;set;}  
    public Map<Id,UserSkill__c> mapSkill {get;set;} 
    public String skillMapping {get;set;}
    public String mapSkillString {get;set;} 
    public List<SelectOption> skillOptions {get;set;}
    public List<SelectOption> skillLevel {get;set;}
    
    //Completed Activity related to member
    public List<CompletedActivityWrapper> listCompletedActivityWrapper {get;set;}
    public List<Activity__c> listCompletedActivity {get;set;}
    public Boolean isCompletedActivityPresent {get;set;}    
    
    //Boolean variables to check if records are present or not
    public Integer currentActivity {get;set;}
    public Integer completedActivityCount {get;set;}
    public Integer totalActivity {get;set;}
    public Integer totalMemberSkill {get;set;}  
    
    // Store page parameter for
    public String userId {get;set;}
    
    //Holds Banner image of user
    public Attachment headerImageAttachment {get;set;}
    
    public CrowdExchangeMemberMyProfileController(){  
        
        try{
            
            //Initialization of Variables and List.
            currentMember = new User();
            userId = '';
            currentActivity = 0;    
            totalActivity = 0; 
            totalMemberSkill = 0; 
            completedActivityCount = 0;
            
            //Get User if from page parameter and fetching user fields, 
            //If parameter is not present fetch information of current user
            userId = ApexPages.currentPage().getParameters().get(Constants.ID);
            if(userId!=null && userId!=''){
                currentMember = [Select Id,Title,Name,Email,Crowd_Exchange_Organization__c,AboutMe,Phone,SmallPhotoUrl,FullPhotoUrl,FirstName,LastName,Crowd_Exchange_About_Me__c 
                                 from User where Id =: userId limit 1];
            }else{
                currentMember = [Select Id,Title,Name,Email,Crowd_Exchange_Organization__c,AboutMe,Phone,SmallPhotoUrl,FullPhotoUrl,FirstName,LastName,Crowd_Exchange_About_Me__c 
                                 from User where Id =: userinfo.getuserId() limit 1];
            }  
            userId = currentMember.Id;
    
            //Fetch Member skills to show on page
            isMemberSkillPresent = false;                 
            listMemberSkills = new List<UserSkill__c>();
            listMemberSkills = filterMemberSkills();
            mapSkill = new Map<Id,UserSkill__c>();
            if(listMemberSkills!=null && listMemberSkills.size()>0){
                isMemberSkillPresent = true;
                totalMemberSkill = listMemberSkills.size();
                for(UserSkill__c uSkill : listMemberSkills){
                   mapSkill.put(uSkill.Id,uSkill);   
                }
            }
            mapSkillString = JSON.serialize(mapSkill);
            
            //Fetch Internal Projects to show on page  
            listInternalProjects = new List<Internal_Project__c>();
            listInternalProjects = filterInternalProjects();
            if(listInternalProjects!=null && listInternalProjects.size()>0){
                isInternalProjectsPresent = true;
            }
            
            //Fetch Current Activities to show on page
            isCurrentActivityPresent = false;                 
            listCurrentActivity = new List<Activity__c>();
            listCurrentActivity = filterCurrentActivity();
            if(listCurrentActivity!=null && listCurrentActivity.size()>0){  
                isCurrentActivityPresent = true;
                currentActivity = listCurrentActivity.size();
                totalActivity += currentActivity;
            }
            
            //Fetch Completed Activities to show on page
            isCompletedActivityPresent = false;      
            listCompletedActivityWrapper = new List<CompletedActivityWrapper>();
            List<Activity__c> listCompletedActivity = new List<Activity__c>();
            listCompletedActivity = filterCompletedActivity();
            if(listCompletedActivity!=null && listCompletedActivity.size()>0){
                for(Activity__c activity : listCompletedActivity){
                    CompletedActivityWrapper cActivityWrapper = new CompletedActivityWrapper(activity);
                    for(Submission__c submission: activity.Submissions__r){
                        if(submission.Submitting_Member__c == currentMember.Id){
                            cActivityWrapper.submission = submission;
                        }
                    }
                    listCompletedActivityWrapper.add(cActivityWrapper);
                }
                isCompletedActivityPresent = true;
                completedActivityCount = listCompletedActivity.size();  
                totalActivity += listCompletedActivity.size();    
            } 
            
            //Fetch USer banner image from custom object
            List<User_Header_Picture__c> listUserHeaderPicture = [Select Id,(Select Id, ParentId From Attachments) from User_Header_Picture__c where User__c =: currentMember.Id limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
            if(listUserHeaderPicture!=null && listUserHeaderPicture.size()>0){
                User_Header_Picture__c userHeaderPicture = listUserHeaderPicture[0];
                if(userHeaderPicture.Attachments!=null && userHeaderPicture.Attachments.size()>0){
                    headerImageAttachment = userHeaderPicture.Attachments[0];
                }  
            }
            
            //Fetch Skill records to create skill picklist
            listSkills = new List<Skills__c>();
            skillOptions = new List<SelectOption>();
            Map<String,Id> mapSkillNameId = new Map<String,Id>();
            listSkills = [Select Id,Name from Skills__c];
            for(Skills__c skill : listSkills){
                skillOptions.add(new SelectOption(skill.Id,skill.Name));
                mapSkillNameId.put(skill.Name,skill.Id);
            }
            skillMapping = JSON.serialize(mapSkillNameId);
            
            //Get Skill level picklist values dynamically
            skillLevel = new List<SelectOption>();
            skillLevel = getPicklistValues(new UserSkill__c(),Constants.EXPERIENCE_LEVEL);
            
       // Catch if exception caused	
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
		}   
    }
    
    /*
        Method to fetch User skills related to current user
    */
    public List<UserSkill__c> filterMemberSkills(){  
        List<UserSkill__c> listUserSkills = [Select Id,Experience_Level__c,Member__c,Skill__r.Name,Skill__c
                                             from UserSkill__c where Member__c =: userId and Skill__c!=null 
                                             limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
        return listUserSkills;
    }

    /*
        Method to fetch Internal Projects to current user
    */
    public List<Internal_Project__c> filterInternalProjects(){
        List<Internal_Project__c> listInternalProject = [Select Id,Description__c,Name,(Select Id,Skill__r.Name from Internal_Project_Skills__r)
                                                         from Internal_Project__c where Member__c =: userId 
                                                         limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
        return listInternalProject;
    }
    
    /*
        Method to fetch Active Activities related to current user
    */  
    public List<Activity__c> filterCurrentActivity(){  
        List<Activity__c> listActivity = [Select Id,Name,Possible_Score__c,Cost__c,
                                          (Select Id,Skill__r.Name from Activity_Skills__r)
                                          from Activity__c where Status__c != :Constants.STATUS_DRAFT and Status__c != :Constants.STATUS_COMPLETED  and Status__c != :Constants.STATUS_CANCELED 
                                          and Assigned_Member__c =: userId 
                                          limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listActivity;
    }
    
    /*
        Method to fetch Completed Activities related to current user
    */ 
    public List<Activity__c> filterCompletedActivity(){
        List<Activity__c> listActivity = [Select Id,Name,Possible_Score__c,Cost__c,
                                          (Select Id,Skill__r.Name from Activity_Skills__r),
                                          (Select id,Evaluation_Percentage__c,Placement__c,Submission_Score__c,Submitting_Member__c from Submissions__r)
                                          from Activity__c where Status__c = :Constants.STATUS_COMPLETED and Assigned_Member__c =: userId 
                                          limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
        return listActivity;
    }
        

    /*
        Activity Wrapper holds activity information for sending mail
    */
    public class ActivityWrapper{
        public String activityName {get;set;}
        public String activityBody {get;set;}
        public String email {get;set;}
        public ActivityWrapper(String aName,String aBody,String userEmail){
            activityName = aName;
            activityBody = aBody;           
            email = userEmail;
        }
    }  
    
    /*
        CompletedActivityWrapper holds information of Completed Activities
    */
    public class CompletedActivityWrapper{  
        
        public Activity__c completedActivity {get;set;}
        public Submission__c submission {get;set;}
        
        public CompletedActivityWrapper(Activity__c cActivity){
            completedActivity = cActivity;
        }
        
    }
    
    /*  
        Remote action to Update Profile Picture, Banner Picture and User Information
    */
    @RemoteAction
    public static Boolean uploadProfilePicture(String userId,Boolean isProfilePicChanged,String filename, String fileData,Boolean isBannerPicChanged,String bFilename, String bFileData,String fName,String lName,String email,String role,String organization,String phoneNumber,String aboutMe){  
        Boolean isSuccess = false;
        try{
            //fetch user information using userId from parameters
            User muser = [Select Id,Title,Name,Email,Crowd_Exchange_Organization__c,AboutMe,Phone,SmallPhotoUrl,FullPhotoUrl,FirstName,LastName 
                          from User where Id =: userId limit 1];
            if(muser!=null){
                
                // Boolean which shows if Profile Picture is changed
                if(isProfilePicChanged){

        			blob imageBlob = EncodingUtil.base64Decode(fileData);  
        			
        			if(fileName == null || fileName ==''){
        				fileName = 'image';
        			}
        			String imageType = filename.substringAfterLast('.');
        			imageType = imageType.toLowerCase();
        			String contentType = 'image/'+imageType;
        			
        			//Upload image using Connect API
        			ConnectApi.BinaryInput photoFileInput = new ConnectApi.BinaryInput(imageBlob, contentType, fileName);
                    ConnectApi.ChatterUsers.setPhoto(Network.getNetworkId(), muser.Id, photoFileInput);
                	
                }
                
                // Boolean which shows if Banner Picture is changed
                if(isBannerPicChanged){
                    
                    //Get current User Header Picture record
                    List<User_Header_Picture__c> listUserHeaderPicture = [Select Id,(Select Id, ParentId From Attachments) from User_Header_Picture__c
                                                                          where User__c =: muser.Id limit:Limits.getLimitQueryRows()- Limits.getQueryRows()];
                    User_Header_Picture__c userHeaderPicture = new User_Header_Picture__c();
                    if(listUserHeaderPicture!=null && listUserHeaderPicture.size()>0){
                        
                        userHeaderPicture = listUserHeaderPicture[0];
                        if(userHeaderPicture.Attachments!=null && userHeaderPicture.Attachments.size()>0){
                            Attachment hImageAttachment = userHeaderPicture.Attachments[0];
                            delete hImageAttachment;
                        }
                        
                    }else{
                        
                       userHeaderPicture = new  User_Header_Picture__c();
                       userHeaderPicture.User__c = muser.Id;
                       insert userHeaderPicture;
                       
                    }
                    
                    //Adding image selected by user under User Header Picture record
                    Attachment attachment = new Attachment();
                    attachment.Name = bFilename;
                    blob attachmentBlob = EncodingUtil.base64Decode(bFileData);  
                    attachment.Body = attachmentBlob;
                    attachment.ParentId = userHeaderPicture.Id;
                    insert attachment;
                }
            
                //Update User Information
                muser.FirstName = fName;
                muser.LastName = lName;
                muser.Email = email;
                muser.Title = role;
                muser.Crowd_Exchange_Organization__c = organization;
                muser.Phone = phoneNumber;
                muser.AboutMe = aboutMe;
                update muser;
            
                isSuccess = true;
            }
            

        }//Exception caused
    	catch(Exception e){  
    		isSuccess = false;
    	}  
        return isSuccess;
    }  
    
    /*
        Remote action to Upsert User Skills which take List of User Skill records
    */
    @RemoteAction
    public static Boolean upsertSkills(List<UserSkill__c> listUserSkills,String userId){  
        Boolean isSuccess = false;
        system.debug('#####listUserSkills :'+listUserSkills);
        List<UserSkill__c> listUS = new List<UserSkill__c>();
        for(UserSkill__c uSkill :listUserSkills){
            if(uSkill.Skill__c!=null){
                uSkill.Member__c = userId;
                listUS.add(uSkill);
            }
        }
        if(listUS.size()>0){  
            upsert listUS;
        }
        system.debug('#####listUS :'+listUS);
        
        return isSuccess;
    }
    
    
    /*
	    Methods to that dynamically gets Picklist values using Object and Field Name
	*/
    public list<SelectOption> getPicklistValues(SObject obj, String fld){  
        list<SelectOption> options = new list<SelectOption>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry entry : values)
        { 
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }
        return options;
    }
    
    
}