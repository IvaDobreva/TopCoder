/**************************************************
* User Service Test
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
*             and Sandip Dhara (sdhara@salesforce.com)
* Last Modified: 7/10/2015
* -------------------------------------------------
* Test methods for User Service.
**************************************************/

@isTest
private class CE_UserServiceTest 
{
    static testMethod void createUserTest() 
    {
    	// create test user object
    	User userToCreate = CE_TestDataFactory.createNewUsers(1)[0];
			                        
		// invoke User Service
		CE_UserService userService = new CE_UserService();
		
		// create user
		Test.startTest();
		Id userId = userService.createUser(userToCreate); 
		System.debug('Create User Test: Created new user with ID ' + userId + '.');
		Test.stopTest();
		
		// verify results
		List<User> userList = [SELECT Id, Username, FirstName, LastName FROM User where Id = :userId LIMIT 1];
        System.Debug('Create User Test: ' + userList[0]);
        System.assertEquals(userList[0].Username, 'test-user0@test-user.com');
    }
    
    static testMethod void createUserNegativeTest() 
    {
    	// Set User to null to invoke error
    	User userToCreate = null;
			                        
		try{		                        
			// invoke User Service
			CE_UserService userService = new CE_UserService();
		
			// create user
			Id userId = userService.createUser(userToCreate); 
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('createUserNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Create User: Unable to create user because null user argument was used.');	
		}
    }
    
    static testMethod void updateUserTest()
    {
    	// create test user object
    	User userToUpdate = CE_TestDataFactory.createNewUsers(1)[0];
    	
    	// invoke User Service
		CE_UserService userService = new CE_UserService();
		
		// create user
		Id userId = userService.createUser(userToUpdate); 
		System.debug('Create User Test: Created new user with ID ' + userId + '.');
		
		// update user
		Test.startTest();
		userToUpdate.LastName = 'User-Update';
		userService.updateUser(userToUpdate); 
		Test.stopTest();
		
		// verify user updated
        List<User> userList = [SELECT Id, IsActive, Username, FirstName, LastName FROM User where Id = :userId LIMIT 1];
        System.assertEquals(userList[0].LastName, 'User-Update');
    }
    
    static testMethod void updateUserNegativeTest() 
    {
    	// Set User to null to invoke error
    	User userToCreate = null;
			                        
		try {		                        
			// invoke User Service
			CE_UserService userService = new CE_UserService();
		
			// create user
			userService.updateUser(userToCreate); 
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('createUserNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Update User: Unable to update user because null user argument was used.');	
		}
    }
    
    static testMethod void disableUserTest()
    {
    	// create test user object
    	User userToDisable = CE_TestDataFactory.createNewUsers(1)[0];
    	
    	// invoke User Service
		CE_UserService userService = new CE_UserService();
		
		// create user
		Id userId = userService.createUser(userToDisable); 
		System.debug('Create User Test: Created new user with ID ' + userId + '.');
        
        // disable user
        Test.startTest();
        userService.disableUser(userId);
        Test.stopTest();
        
        // verify user disabled
        List<User> userList = [SELECT Id, IsActive, Username, FirstName, LastName FROM User where Id = :userId LIMIT 1];
        System.assertEquals(userList[0].IsActive, false);
    }
    
    static testMethod void disableUserNegativeTest() 
    {
    	// Set User to null to invoke error
    	Id userId = null;
			                        
		try {		                        
			// invoke User Service
			CE_UserService userService = new CE_UserService();
			userService.disableUser(userId); 
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('createUserNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Disable User: Unable to disable user because null user ID argument was used.');	
		}	
    }
    
    static testmethod void getUserSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	CE_UserSkill__c us1 = CE_TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	CE_UserSkill__c us2 = CE_TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// 2. Execute
    	CE_UserService userService = new CE_UserService();
    	List<CE_UserSkill__c> userSkills = userService.getUserSkills(u1.Id);

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_UserSkill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, userSkills.size());  	
    }
    
    static testmethod void getUserSkillsNegativeTest()
    {
    	// 1. Create Test Data
		Id userId = null;	
  		
  		try {		                        
			// invoke User Service
			CE_UserService userService = new CE_UserService();
			userService.getUserSkills(userId); 
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('createUserNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Get User Skills: Unable to get skills because null user ID argument was used.');	
		}
    }
    
    static testmethod void addUserSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	s1.OwnerId = u1.Id; // assign user ID to skill
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	s2.OwnerId = u1.Id; // assign user ID to skill
    	
    	/*
    	// Create User Skill
    	CE_UserSkill__c us1 = CE_TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	CE_UserSkill__c us2 = CE_TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// Skills to Add
    	List<CE_UserSkill__c> skillsToAdd = new List<CE_UserSkill__c>();
    	skillsToAdd.add(us1);
    	skillsToAdd.add(us2);
    	*/
    	// List of User Skills
    	List<CE_UserSkill__c> skillsToAdd = new List<CE_UserSkill__c>();
    	
    	CE_UserSkill__c us1 = new CE_UserSkill__c();
    	us1.Member__c = u1.Id;
    	us1.Skill__c = s1.Id;
    	skillsToAdd.add(us1);
    	
    	CE_UserSkill__c us2 = new CE_UserSkill__c();
    	us2.Member__c = u1.Id;
    	us2.Skill__c = s2.Id;
    	skillsToAdd.add(us2);
    	
    	// 2. Execute
		Test.startTest();
    	CE_UserService userService = new CE_UserService();
		userService.addUserSkills(skillsToAdd);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_UserSkill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	 	
    }
    
    static testmethod void updateUserSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	s1.OwnerId = u1.Id; // assign user ID to skill
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	s2.OwnerId = u1.Id; // assign user ID to skill
    	
    	// Create User Skill
    	CE_UserSkill__c us1 = CE_TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	CE_UserSkill__c us2 = CE_TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// Skills to Add
    	List<CE_UserSkill__c> skillsToUpdate = new List<CE_UserSkill__c>();
    	skillsToUpdate.add(us1);
    	skillsToUpdate.add(us2);
    	
    	// 2. Execute
		Test.startTest();
    	CE_UserService userService = new CE_UserService();
		userService.updateUserSkills(skillsToUpdate);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_UserSkill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);
    }
    
    static testmethod void removeUserSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	s1.OwnerId = u1.Id; // assign user ID to skill
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	s2.OwnerId = u1.Id; // assign user ID to skill
    	
    	// Create User Skill
    	CE_UserSkill__c us1 = CE_TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	CE_UserSkill__c us2 = CE_TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// SkillToDelete
    	List<CE_UserSkill__c> listToDelete = new List<CE_UserSkill__c>();
    	listToDelete.add(us1);
    	
    	// 2. Execute
		Test.startTest();
    	CE_UserService userService = new CE_UserService();
		userService.removeUserSkills(listToDelete);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_UserSkill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testmethod void getIntProjSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	
    	// Create Internal Project Skill
    	CE_InternalProjectSkill__c ps1 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	CE_InternalProjectSkill__c ps2 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	List<CE_InternalProjectSkill__c> internalProjectSkills = userService.getIntProjSkills(u1.Id);
    	Test.stopTest();

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_InternalProjectSkill__c WHERE CE_Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void addIntProjSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	//s1.CE_Internal_Project__c = iProject.Id; // assign internal project ID
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	//s2.CE_Internal_Project__c = iProject.Id; // assign internal project ID
    	
    	/*
    	// Create Internal Project Skills
    	CE_InternalProjectSkill__c intProjSkill1 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	CE_InternalProjectSkill__c intProjSkill2 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Create List of Internal Project Skills
    	List<CE_InternalProjectSkill__c> skillsList = new List<CE_InternalProjectSkill__c>();
    	skillsList.add(intProjSkill1);
    	skillsList.add(intProjSkill2);
    	*/
    	
    	List<CE_InternalProjectSkill__c> skillsList = new List<CE_InternalProjectSkill__c>();
    	
    	CE_InternalProjectSkill__c intProjSkill1 = new CE_InternalProjectSkill__c();
    	intProjSkill1.CE_Internal_Project__c = iProject.Id;
    	intProjSkill1.Skill__c = s1.Id;
    	skillsList.add(intProjSkill1);
    	
    	CE_InternalProjectSkill__c intProjSkill2 = new CE_InternalProjectSkill__c();
    	intProjSkill2.CE_Internal_Project__c = iProject.Id;
    	intProjSkill2.Skill__c = s2.Id;
    	skillsList.add(intProjSkill2);
    	
    	
    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	userService.addIntProjSkills(skillsList);
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_InternalProjectSkill__c WHERE CE_Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void updateIntProjSkillsTest()
    {
		// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	s1.CE_Internal_Project__c = iProject.Id; // assign internal project ID
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	s2.CE_Internal_Project__c = iProject.Id; // assign internal project ID
    	
    	// Create Internal Project Skills
    	CE_InternalProjectSkill__c intProjSkill1 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	CE_InternalProjectSkill__c intProjSkill2 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Create List of Internal Project Skills
    	List<CE_InternalProjectSkill__c> skillsList = new List<CE_InternalProjectSkill__c>();
    	skillsList.add(intProjSkill1);
    	skillsList.add(intProjSkill2);
    	
    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	userService.updateIntProjSkills(skillsList); 
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_InternalProjectSkill__c WHERE CE_Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	  	
    }
    
    static testmethod void removeIntProjSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	CE_Skills__c s1 = CE_TestDataFactory.createSkill('Football');
    	s1.CE_Internal_Project__c = iProject.Id; // assign internal project ID
    	CE_Skills__c s2 = CE_TestDataFactory.createSkill('Golf');
    	s2.CE_Internal_Project__c = iProject.Id; // assign internal project ID
    	
    	// Create User Skill
    	CE_InternalProjectSkill__c us1 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	CE_InternalProjectSkill__c us2 = CE_TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Skills To Remove
    	List<CE_InternalProjectSkill__c> skillsList = new List<CE_InternalProjectSkill__c>();
    	skillsList.add(us1);
    	
    	// 2. Execute
		Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	userService.removeIntProjSkills(skillsList);
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_InternalProjectSkill__c WHERE CE_Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testmethod void getInternalProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	User u2 = CE_TestDataFactory.createNewUser('Jason', 'Garret');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	CE_Internal_Project__c iProject2 = CE_TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	CE_Internal_Project__c iProject3 = CE_TestDataFactory.createInternalProject('TestProject3', u2.Id);

    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	List<CE_Internal_Project__c> projects = userService.getUsrIntProjects(u1.Id);
		  Test.stopTest();
		
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_Internal_Project__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void addUsrIntProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = new CE_Internal_Project__c();
    	iProject1.Name = 'MyTestProject1';
    	iProject1.Description__c = 'Description for MyTestProject1';
    	iProject1.Member__c = u1.Id;
    	
    	CE_Internal_Project__c iProject2 = new CE_Internal_Project__c();
    	iProject2.Name = 'MyTestProject2';
    	iProject2.Description__c = 'Description for MyTestProject2';
    	iProject2.Member__c = u1.Id;
    	
    	// Add to list of projects to add
    	List<CE_Internal_Project__c> projectList = new List<CE_Internal_Project__c>();
    	projectList.add(iProject1);
    	projectList.add(iProject2);
    	
    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	userService.addUsrIntProjects(projectList);
    	Test.stopTest();

    	// 3. Test Results 	
  		CE_Internal_Project__c test1 = [SELECT Id, Name, Description__c FROM CE_Internal_Project__c WHERE Id = :iProject1.Id LIMIT 1];
  		System.AssertEquals(test1.Name, 'MyTestProject1');
  		System.AssertEquals(test1.Description__c, 'Description for MyTestProject1');
  		
  		CE_Internal_Project__c test2 = [SELECT Id, Name, Description__c FROM CE_Internal_Project__c WHERE Id = :iProject2.Id LIMIT 1];
  		System.AssertEquals(test2.Name, 'MyTestProject2');  	
  		System.AssertEquals(test2.Description__c, 'Description for MyTestProject2'); 
    }
    
    static testmethod void updateUsrIntProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	iProject1.Member__c = u1.Id;
    	CE_Internal_Project__c iProject2 = CE_TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	iProject2.Member__c = u1.Id;
    	
    	// Update Projects
    	iProject1.Description__c = 'Updated description for project1';
    	iProject2.Description__c = 'Updated description for project2';
    	
    	// Add projects to update to list
    	List<CE_Internal_Project__c> listProjects = new List<CE_Internal_Project__c>();
    	listProjects.add(iProject1);
    	listProjects.add(iProject2);
    	
    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	userService.updateUsrIntProjects(listProjects);
    	Test.stopTest();

    	// 3. Test Results
    	CE_Internal_Project__c test1 = [SELECT Id, Description__c FROM CE_Internal_Project__c WHERE Id = :iProject1.Id LIMIT 1];
  		System.AssertEquals(test1.Description__c, 'Updated description for project1');
  		
  		CE_Internal_Project__c test2 = [SELECT Id, Description__c FROM CE_Internal_Project__c WHERE Id = :iProject2.Id LIMIT 1];
  		System.AssertEquals(test2.Description__c, 'Updated description for project2');  	
    }
    
    static testMethod void updateUsrIntProjectsNegativeTest1() 
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	CE_Internal_Project__c iProject2 = CE_TestDataFactory.createInternalProject('TestProject2', u1.Id);

    	
    	// Create List of Projects to Remove
    	List<CE_Internal_Project__c> listProjects = new List<CE_Internal_Project__c>();
    	listProjects.add(iProject1);
			                        
		try {		                        
			// Invoke Service
			CE_UserService userService = new CE_UserService();
    		userService.updateUsrIntProjects(null);
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('removeInternalProjectNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Update Internal Projects: Unable to update internal projects because null internal projects list argument was used.');	
		}
    }
    
    static testmethod void removeUsrIntProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	User u2 = CE_TestDataFactory.createNewUser('Jason', 'Garret');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	iProject1.Member__c = u1.Id;
    	CE_Internal_Project__c iProject2 = CE_TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	iProject2.Member__c = u1.Id;
    	CE_Internal_Project__c iProject3 = CE_TestDataFactory.createInternalProject('TestProject3', u2.Id);
    	iProject3.Member__c = u1.Id;
    	
    	// Create List of Projects to Remove
    	List<CE_Internal_Project__c> listProjects = new List<CE_Internal_Project__c>();
    	listProjects.add(iProject1);
    	
    	// 2. Execute
    	Test.startTest();
    	CE_UserService userService = new CE_UserService();
    	userService.removeUsrIntProjects(listProjects); 
    	Test.stopTest();

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM CE_Internal_Project__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testMethod void removeUsrIntProjectsNegativeTest1() 
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	CE_Internal_Project__c iProject2 = CE_TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	
    	// Create List of Projects to Remove
    	List<CE_Internal_Project__c> listProjects = new List<CE_Internal_Project__c>();
    	listProjects.add(iProject1);
			                        
		try {		                        
			// Invoke Service
			CE_UserService userService = new CE_UserService();
    		userService.removeUsrIntProjects(listProjects);
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('removeInternalProjectNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Remove Internal Projects: Unable to remove internal projects because null internal projects list argument was used.');	
		}
    }
    
    static testMethod void removeUsrIntProjectsNegativeTest2() 
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = CE_TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	CE_Internal_Project__c iProject1 = CE_TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	CE_Internal_Project__c iProject2 = CE_TestDataFactory.createInternalProject('TestProject2', u1.Id);

    	
    	// Create List of Projects to Remove
    	List<CE_Internal_Project__c> listProjects = new List<CE_Internal_Project__c>();
    	listProjects.add(iProject1);
			                        
		try {		                        
			// Invoke Service
			CE_UserService userService = new CE_UserService();
    		userService.removeUsrIntProjects(null); 
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('removeInternalProjectNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Remove Internal Projects: Unable to remove internal projects because null internal projects list argument was used.');	
		}
    }
}