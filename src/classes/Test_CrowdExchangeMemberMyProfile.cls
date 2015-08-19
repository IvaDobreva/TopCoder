@isTest
private class Test_CrowdExchangeMemberMyProfile{
    
    // Creat Test Data
    public static void createTestData(){

        // Create Publisher user
    	User user = TestFactory.createUser();
    	user.Crowd_Exchange_User_Type__c = 'Publisher';
        insert user;
        
        //Create Story record
    	Story__c story = TestFactory.createStory();
        insert story;
        
        //Create Activities 
        List<Activity__c> listActivity = new List<Activity__c>();
        Activity__c activity1 = TestFactory.createActivity(story);
        activity1.Status__c = 'Completed';
        activity1.Publisher__c = user.Id;
        activity1.Assigned_Member__c = userinfo.getuserId();
        listActivity.add(activity1);
        
        Activity__c activity2 = TestFactory.createActivity(story);
        activity2.Status__c = 'In Submission';
        activity2.Assigned_Member__c = userinfo.getuserId();
        activity2.Publisher__c = user.Id;
        listActivity.add(activity2);
        insert listActivity;
        
        //Create Header Picture
        User_Header_Picture__c userHeaderPicture = new User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        
        //Create Skill and Use Skill
        Skills__c skill = TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        UserSkill__c userSkill = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        insert userSkill;
         
        //Create Summary Data
    	TestFactory.createSummaryData();
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
		CrowdExchangeMemberMyProfileController crowdExchangeMemberMyProfileController = new CrowdExchangeMemberMyProfileController();
		
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
		CrowdExchangeMemberMyProfileController crowdExchangeMemberMyProfileController = new CrowdExchangeMemberMyProfileController();
		
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
        Skills__c skill = TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<UserSkill__c> listUserSkill = new List<UserSkill__c>();
        UserSkill__c userSkill = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        UserSkill__c userSkill1 = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
    	
    	//Controller instance
		Boolean result = CrowdExchangeMemberMyProfileController.upsertSkills(listUserSkill,userinfo.getuserId());
		
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
        Skills__c skill = TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<UserSkill__c> listUserSkill = new List<UserSkill__c>();
        UserSkill__c userSkill = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        UserSkill__c userSkill1 = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
    	
    	//Controller instance
		Boolean result = CrowdExchangeMemberMyProfileController.uploadProfilePicture(userinfo.getuserId(),false,'','',true,'test.jpg','aaa','fName','lName','email','role','organization','123456','aboutMe');
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
        Skills__c skill = TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<UserSkill__c> listUserSkill = new List<UserSkill__c>();
        UserSkill__c userSkill = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        UserSkill__c userSkill1 = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
        
        //Create Header Picture
        User_Header_Picture__c userHeaderPicture = new User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        

    	//Controller instance
		Boolean result = CrowdExchangeMemberMyProfileController.uploadProfilePicture(userinfo.getuserId(),false,'test.jpg','test',true,'test.jpg','test','fName','lName','email','role','organization','123456','aboutMe');
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
        Skills__c skill = TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        List<UserSkill__c> listUserSkill = new List<UserSkill__c>();
        UserSkill__c userSkill = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill);
        
        UserSkill__c userSkill1 = new UserSkill__c(Member__c = userinfo.getuserId(), Skill__c = skill.Id);
        listUserSkill.add(userSkill1);
        insert listUserSkill;
    	
    	//Create Header Picture
        User_Header_Picture__c userHeaderPicture = new User_Header_Picture__c();
        userHeaderPicture.User__c = userinfo.getuserId();
        insert userHeaderPicture;
        
        //Controller instance
		Boolean result = CrowdExchangeMemberMyProfileController.uploadProfilePicture(userinfo.getuserId(),true,'test.jpg','test',true,'test.jpg','test','fName','lName','email','role','organization','123456','aboutMe');
        // System Asserts
    	System.assert(result == false,'User Information update not Successful');
    	
    	// Stop Test
    	Test.stopTest();
	}
	
}