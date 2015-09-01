@isTest
private class CE_Test_MemberMyProfileController{
    
    // Creat Test Data
    public static void createTestData(){

        // Create Publisher user
    	User user = CE_TestFactory.createUser();
    	user.Crowd_Exchange_User_Type__c = 'Publisher';
        insert user;
        
        //Create Story record
    	CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        
        //Create Activities 
        List<CE_Activity__c> listActivity = new List<CE_Activity__c>();
        CE_Activity__c activity1 = CE_TestFactory.createActivity(story);
        activity1.Status__c = 'Completed';
        activity1.Publisher__c = user.Id;
        activity1.Assigned_Member__c = userinfo.getuserId();
        listActivity.add(activity1);
        
        CE_Activity__c activity2 = CE_TestFactory.createActivity(story);
        activity2.Status__c = 'In Submission';
        activity2.Assigned_Member__c = userinfo.getuserId();
        activity2.Publisher__c = user.Id;
        listActivity.add(activity2);
        insert listActivity;
        
        //Create Header Picture
        CE_User_Header_Picture__c userHeaderPicture = new CE_User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        
        //Create Skill and Use Skill
        CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        CE_UserSkill__c userSkill = new CE_UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        insert userSkill;
         
        //Create Summary Data
    	CE_TestFactory.createSummaryData();
    }
    
    /*
        Test method with Test Data
    */
	private static testMethod void testCrowdExchangeMemberMyProfileController(){
	    
        //Create test Data
        createTestData();
        
    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CE_MemberMyProfileController crowdExchangeMemberMyProfileController = new CE_MemberMyProfileController();
		
		// System Asserts
    	System.assert(crowdExchangeMemberMyProfileController.isCurrentActivityPresent == true,'Active Activities not present');
    	System.assert(crowdExchangeMemberMyProfileController.isCompletedActivityPresent == true,'Completed Activities not present');

    	// Stop Test
    	Test.stopTest();
	}
	
	/*
        Test methods without Test Data
    */
	private static testMethod void testCrowdExchangeMemberMyProfile_NoData(){

    	// Start Test  
    	Test.startTest();
    	
    	//Controller instance
		CE_MemberMyProfileController crowdExchangeMemberMyProfileController = new CE_MemberMyProfileController();
		
		// System Asserts
    	System.assert(crowdExchangeMemberMyProfileController.isCurrentActivityPresent == false,'Active Activities present');
    	System.assert(crowdExchangeMemberMyProfileController.isCompletedActivityPresent == false,'Completed Activities present');

    	// Stop Test
    	Test.stopTest();
	}

	/*
        Test Remote Action Method to update/insert Skills
    */
	private static testMethod void testSkillUpsertRemoteAction(){

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
		Boolean result = CE_MemberMyProfileController.upsertSkills(listUserSkill,userinfo.getuserId());
		
        // System Asserts
    	System.assert(result == false,'Skill Upsert not Successful');
    	
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
		Boolean result = CE_MemberMyProfileController.uploadProfilePicture(userinfo.getuserId(),false,'','',true,'test.jpg','aaa','fName','lName','email','role','organization','123456','aboutMe');
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
		Boolean result = CE_MemberMyProfileController.uploadProfilePicture(userinfo.getuserId(),false,'test.jpg','test',true,'test.jpg','test','fName','lName','email','role','organization','123456','aboutMe');
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
		Boolean result = CE_MemberMyProfileController.uploadProfilePicture(userinfo.getuserId(),true,'test.jpg','test',true,'test.jpg','test','fName','lName','email','role','organization','123456','aboutMe');
        // System Asserts
    	System.assert(result == false,'User Information update not Successful');
    	
    	// Stop Test
    	Test.stopTest();
	}
	
}