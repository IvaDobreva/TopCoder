/*
Class       : CE_MemPubProfileController
Description : This class is controller for Publisher-My-Profile and Member-Publisher-Profile page
              which shows details of Publisher to member and himself
*/
public class CE_MemPubProfileController {
    
    //Current logged-in Publisher
	public User currentPublisher {get;set;}
	
	//Active Stories related to Publisher
	public List<CE_Story__c> listActiveStories {get;set;}
	public Boolean isActiveStoriesPresent {get;set;}
	
	//Completed Stories related to Publisher
	public List<CE_Story__c> listCompletedStories {get;set;}
	public Boolean isCompletedStoriesPresent {get;set;}  
	
	//Hols Developers related to Publisher Activities  
	public List<User> listMembers {get;set;}
	public List<List<User>> listDevelopers {get;set;}
	public Boolean isMembersPresent	{get;set;}
	
	// Set of developer Id
	public set<Id> setMemberId {get;set;}
	
	//Boolean variables to check if records are present or not
	public integer completedActivityCount {get;set;}
	public integer activeActivityCount {get;set;}
	public integer completedStoryCount {get;set;}
	public integer activeStoryCount	{get;set;}
	
	// Member Skill Snapshot records created today
	public List<CE_Member_Skill_Snapshot__c> listMemberSkillSnapshot {get;set;}
  public Boolean isMemberSkillSnapshotPresent {get;set;}
	
	//User Banner image
	public Attachment headerImageAttachment {get;set;}
	public Integer totalMembers {get;set;}
	
	public CE_MemPubProfileController(){
	    
	    //Initialization of Variables and List.
		String publisherId 		= '';
		currentPublisher 		= new User();
		completedActivityCount 	= 0;
		activeActivityCount		= 0;
		completedStoryCount 	= 0;
		activeStoryCount 		= 0;
		totalMembers 			= 0;
		isActiveStoriesPresent = false;
		isCompletedStoriesPresent = false;
		isMembersPresent = false;
		
		listCompletedStories	= new List<CE_Story__c>();
		listMembers				= new list<User>();
		setMemberId				= new set<Id>();
		listMemberSkillSnapshot = new List<CE_Member_Skill_Snapshot__c>();
		listDevelopers          = new List<List<User>>();
		
		try{

    		//Get User if from page parameter and fetching user fields, 
            //If parameter is not present fetch information of current user
    		publisherId = apexpages.currentPage().getParameters().get('id');		
    		if(publisherId == null || publisherId==''){
    			publisherId = userinfo.getuserId();
    		}
            if(publisherId!=null && publisherId!=''){
                
                currentPublisher = [Select Id,Title,Name,Email,Crowd_Exchange_Organization__c,AboutMe,Phone,SmallPhotoUrl,
                                    FullPhotoUrl,FirstName,LastName,Crowd_Exchange_About_Me__c,Crowd_Exchange_User_Type__c 
                                    from User where Id =: publisherId limit 1];
                                    
                //Fetch Completed Stories to show on page                    
                listCompletedStories = CE_Utils.filterCompletedStories(publisherId);
                if(listCompletedStories!=null && listCompletedStories.size()>0){
                	isCompletedStoriesPresent = true;
                	completedStoryCount += listCompletedStories.size();
                	for(CE_Story__c story : listCompletedStories){
                		if(story.Activities__r!=null && story.Activities__r.size()>0){
    	            		completedActivityCount += CE_Utils.getCompletedActivityCount(story.Activities__r);
    	            		setMemberId.addAll(CE_Utils.getAssignedMemberList(story.Activities__r));
                		}
                	} 
                }
                
                //Fetch Active Stories to show on page  
                listActiveStories = CE_Utils.filterActiveStories(publisherId);
                if(listActiveStories!=null && listActiveStories.size()>0){
                	isActiveStoriesPresent = true;
                	for(CE_Story__c story : listActiveStories){
                		activeStoryCount++; 
                		if(story.Activities__r!=null && story.Activities__r.size()>0){            			 
                			activeActivityCount += CE_Utils.getActiveActivityCount(story.Activities__r);
                			completedActivityCount += CE_Utils.getCompletedActivityCount(story.Activities__r);
                			setMemberId.addAll(CE_Utils.getAssignedMemberList(story.Activities__r));
                		}
                	}
                }
            }
            
            //Fetch User banner image from custom object
            List<CE_User_Header_Picture__c> listUserHeaderPicture = [Select Id,(Select Id, ParentId From Attachments) from CE_User_Header_Picture__c 
                                                                  where User__c =: publisherId limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
            if(listUserHeaderPicture!=null && listUserHeaderPicture.size()>0){
                CE_User_Header_Picture__c userHeaderPicture = listUserHeaderPicture[0];
                if(userHeaderPicture.Attachments!=null && userHeaderPicture.Attachments.size()>0){
                    headerImageAttachment = userHeaderPicture.Attachments[0];
                }
            }
            
            //Fetch Member SKill Snapshot records
            listMemberSkillSnapshot = [Select Id,Member_Count__c,Skill_Name__c
                                       from CE_Member_Skill_Snapshot__c where Skill_Name__c!='' and Skill_Name__c!=null and CreatedDate = TODAY  limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
            if(listMemberSkillSnapshot!=null && listMemberSkillSnapshot.size()>0){
                isMemberSkillSnapshotPresent = true;
            }
            
            //Fetch all members
            List<User> memberList = [Select Id,Name,Crowd_Exchange_User_Type__c,Email from User where Crowd_Exchange_User_Type__c = :CE_Constants.MEMBER limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];  
            if(memberList!=null && memberList.size()>0){
                totalMembers = memberList.size();
            }
            
            //Fetch all developers related to Publisher activities
            listMembers = CE_Utils.fetchDevelopers(setMemberId);
            if(listMembers!=null && listMembers.size()>0){
            	isMembersPresent = true;
            	List<User> tempmemberList = new List<User>();
            	Integer tempCount = 1;
    			for(User member: listMembers){
    				if(tempCount == 3){
    					tempmemberList.add(member);
    					listDevelopers.add(tempmemberList);
    					tempmemberList = new List<User>();
    					tempCount = 1;
    				}else{
    					tempmemberList.add(member);
    					if(listMembers.size() == tempCount){
    					  listDevelopers.add(tempmemberList);
    					}
    					tempCount++;  
    				}
    			}
            }
            
        // Catch if exception caused	
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
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
                	isSuccess = true;
                }
                
                // Boolean which shows if Banner Picture is changed
                if(isBannerPicChanged){
                    
                    //Get current User Header Picture record
                    List<CE_User_Header_Picture__c> listUserHeaderPicture = [Select Id,(Select Id, ParentId From Attachments) from CE_User_Header_Picture__c 
                                                                          where User__c =: muser.Id limit:Limits.getLimitQueryRows()- Limits.getQueryRows() ];
                    CE_User_Header_Picture__c userHeaderPicture = new CE_User_Header_Picture__c();
                    if(listUserHeaderPicture!=null && listUserHeaderPicture.size()>0){
                        
                        userHeaderPicture = listUserHeaderPicture[0];
                        if(userHeaderPicture.Attachments!=null && userHeaderPicture.Attachments.size()>0){
                            Attachment hImageAttachment = userHeaderPicture.Attachments[0];
                            delete hImageAttachment;
                        }
                        
                    }else{
                        
                       userHeaderPicture = new  CE_User_Header_Picture__c();
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
            
            }
            

        }//Exception caused
    	catch(Exception e){  
    		isSuccess = false;
    	}  
        return isSuccess;
    }
	
	
}