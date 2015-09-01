@isTest
private class CE_Test_MemPubProfileController {
    
    // Creat Test Data
    public static void createTestData(){

        // Create Publisher user
    	  User user = CE_TestFactory.createUser();
    	  user.Crowd_Exchange_User_Type__c = 'Publisher';
        insert user;
        
        //Create Story record
        List<CE_Story__c> listStory = new List<CE_Story__c>();
    	  CE_Story__c story = CE_TestFactory.createStory();
    	  story.Publisher__c = userinfo.getuserId();
        listStory.add(story);
        
        //Create Story record
    	  CE_Story__c story1 = CE_TestFactory.createStory();
     	  story.Publisher__c = userinfo.getuserId();
    	  story.Status__c = 'Completed';
        listStory.add(story1);
        insert listStory;
        
        //Create Activities 
        List<CE_Activity__c> listActivity = new List<CE_Activity__c>();
        CE_Activity__c activity1 = CE_TestFactory.createActivity(story);
        activity1.Status__c = 'Completed';
        activity1.Publisher__c = userinfo.getuserId();
        activity1.Assigned_Member__c = userinfo.getuserId();
        listActivity.add(activity1);
        
        CE_Activity__c activity2 = CE_TestFactory.createActivity(story);
        activity2.Status__c = 'In Submission';
        activity2.Assigned_Member__c = user.Id;
        activity2.Publisher__c = userinfo.getuserId();
        listActivity.add(activity2);
        
        CE_Activity__c activity3 = CE_TestFactory.createActivity(story1);
        activity3.Status__c = 'In Submission';
        activity3.Assigned_Member__c = user.Id;
        activity3.Publisher__c = userinfo.getuserId();
        listActivity.add(activity3);
        
        insert listActivity;
        
        //Create Header Picture
        CE_User_Header_Picture__c userHeaderPicture = new CE_User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        
         
        //Create Summary Data
    	  CE_TestFactory.createSummaryData();
    }
    
    /*
        Test method with Test Data
    */
	private static testMethod void testCrowdExchangeMemPubProfile(){
	    
        //Create test Data
        createTestData();
        
    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CE_MemPubProfileController crowdExchangeMemPubProfile = new CE_MemPubProfileController();
		
		// System Asserts
    	System.assert(crowdExchangeMemPubProfile.isActiveStoriesPresent == true,'Active Story present');
    	System.assert(crowdExchangeMemPubProfile.isCompletedStoriesPresent == true,'Completed Story present');
    	
    	// Stop Test
    	Test.stopTest();
	}
	
	/*
        Test methods without Test Data
    */
	private static testMethod void testCrowdExchangeMemPubProfile_NoData(){

    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CE_MemPubProfileController crowdExchangeMemPubProfile = new CE_MemPubProfileController();
		          
		// System Asserts
    	System.assert(crowdExchangeMemPubProfile.isActiveStoriesPresent == false,'Active Story not present');          
    	System.assert(crowdExchangeMemPubProfile.isCompletedStoriesPresent == false,'Completed Story not present');
    	
    	// Stop Test
    	Test.stopTest();
	}
	
	/*
        Test Remote Action Method to update user information
    */
	private static testMethod void testUserInformationUpdateRemoteAction(){

    	// Start Test  
    	Test.startTest();
    	
    	//Create Skill and Use Skill
        CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<CE_UserSkill__c> listUserSkill = new List<CE_UserSkill__c>();
        CE_UserSkill__c userSkill = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        CE_UserSkill__c userSkill1 = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
    	
    	//Controller instance
		Boolean result = CE_MemPubProfileController.uploadProfilePicture(userinfo.getuserId(),false,'','',true,'abc.jpg','aaa','fName','lName','email','role','organization','123456','aboutMe');
        // System Asserts
    	System.assert(result == false,'User Information update not Successful');
    	
    	// Stop Test
    	Test.stopTest();
	}

	/*   
        Test Remote Action Method to update user information with pic changed
    */
	private static testMethod void testUserInformationUpdateRemoteAction_PicChanged(){

    	// Start Test  
    	Test.startTest();
    	
    	//Create Skill and Use Skill
        CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<CE_UserSkill__c> listUserSkill = new List<CE_UserSkill__c>();
        CE_UserSkill__c userSkill = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        CE_UserSkill__c userSkill1 = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
        
        //Create Header Picture
        CE_User_Header_Picture__c userHeaderPicture = new CE_User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        

    	//Controller instance
		Boolean result = CE_MemPubProfileController.uploadProfilePicture(userinfo.getuserId(),false,'test.jpg','test',true,'test.jpg','test','fName','lName','email','role','organization','123456','aboutMe');
        // System Asserts
    	System.assert(result == false,'User Information update not Successful');
    	
    	
    	// Stop Test
    	Test.stopTest();
	}
	
	/*
        Test Remote Action Method to update user information with Picture already present and pic changed
    */
	private static testMethod void testUserInformationUpdateRemoteAction_WithPicture(){

    	// Start Test  
    	Test.startTest();
    	
    	//Create Skill and Use Skill
        CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<CE_UserSkill__c> listUserSkill = new List<CE_UserSkill__c>();
        CE_UserSkill__c userSkill = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        CE_UserSkill__c userSkill1 = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
    	
    	//Create Header Picture
        CE_User_Header_Picture__c userHeaderPicture = new CE_User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        
        //Controller instance
		Boolean result = CE_MemPubProfileController.uploadProfilePicture(userinfo.getuserId(),true,'test.jpg','test',true,'test.jpg','test','fName','lName','email','role','organization','123456','aboutMe');
        // System Asserts
    	System.assert(result == false,'User Information update not Successful');
    	
    	// Stop Test
    	Test.stopTest();
	}
	

}