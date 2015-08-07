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
private class UserServiceTest 
{
    static testMethod void createUserTest() 
    {
    	// create test user object
    	User userToCreate = TestDataFactory.createNewUsers(1)[0];
			                        
		// invoke User Service
		UserService userService = new UserService();
		
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
			UserService userService = new UserService();
		
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
    	User userToUpdate = TestDataFactory.createNewUsers(1)[0];
    	
    	// invoke User Service
		UserService userService = new UserService();
		
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
			UserService userService = new UserService();
		
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
    	User userToDisable = TestDataFactory.createNewUsers(1)[0];
    	
    	// invoke User Service
		UserService userService = new UserService();
		
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
			UserService userService = new UserService();
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
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// 2. Execute
    	UserService userService = new UserService();
    	List<UserSkill__c> userSkills = userService.getUserSkills(u1.Id);

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Userskill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, userSkills.size());  	
    }
    
    static testmethod void getUserSkillsNegativeTest()
    {
    	// 1. Create Test Data
		Id userId = null;	
  		
  		try {		                        
			// invoke User Service
			UserService userService = new UserService();
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
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	s1.OwnerId = u1.Id; // assign user ID to skill
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	s2.OwnerId = u1.Id; // assign user ID to skill
    	
    	/*
    	// Create User Skill
    	Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// Skills to Add
    	List<UserSkill__c> skillsToAdd = new List<UserSkill__c>();
    	skillsToAdd.add(us1);
    	skillsToAdd.add(us2);
    	*/
    	// List of User Skills
    	List<UserSkill__c> skillsToAdd = new List<UserSkill__c>();
    	
    	Userskill__c us1 = new Userskill__c();
    	us1.Member__c = u1.Id;
    	us1.Skill__c = s1.Id;
    	skillsToAdd.add(us1);
    	
    	Userskill__c us2 = new Userskill__c();
    	us2.Member__c = u1.Id;
    	us2.Skill__c = s2.Id;
    	skillsToAdd.add(us2);
    	
    	// 2. Execute
		Test.startTest();
    	UserService userService = new UserService();
		userService.addUserSkills(skillsToAdd);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Userskill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	 	
    }
    
    static testmethod void updateUserSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	s1.OwnerId = u1.Id; // assign user ID to skill
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	s2.OwnerId = u1.Id; // assign user ID to skill
    	
    	// Create User Skill
    	Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// Skills to Add
    	List<UserSkill__c> skillsToUpdate = new List<UserSkill__c>();
    	skillsToUpdate.add(us1);
    	skillsToUpdate.add(us2);
    	
    	// 2. Execute
		Test.startTest();
    	UserService userService = new UserService();
		userService.updateUserSkills(skillsToUpdate);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Userskill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);
    }
    
    static testmethod void removeUserSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	s1.OwnerId = u1.Id; // assign user ID to skill
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	s2.OwnerId = u1.Id; // assign user ID to skill
    	
    	// Create User Skill
    	Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// SkillToDelete
    	List<UserSkill__c> listToDelete = new List<UserSkill__c>();
    	listToDelete.add(us1);
    	
    	// 2. Execute
		Test.startTest();
    	UserService userService = new UserService();
		userService.removeUserSkills(listToDelete);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Userskill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testmethod void getIntProjSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create Internal Project Skill
    	InternalProjectSkill__c ps1 = TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	InternalProjectSkill__c ps2 = TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	List<InternalProjectSkill__c> internalProjectSkills = userService.getIntProjSkills(u1.Id);
    	Test.stopTest();

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void addIntProjSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	//s1.Internal_Project__c = iProject.Id; // assign internal project ID
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	//s2.Internal_Project__c = iProject.Id; // assign internal project ID
    	
    	/*
    	// Create Internal Project Skills
    	InternalProjectSkill__c intProjSkill1 = TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	InternalProjectSkill__c intProjSkill2 = TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Create List of Internal Project Skills
    	List<InternalProjectSkill__c> skillsList = new List<InternalProjectSkill__c>();
    	skillsList.add(intProjSkill1);
    	skillsList.add(intProjSkill2);
    	*/
    	
    	List<InternalProjectSkill__c> skillsList = new List<InternalProjectSkill__c>();
    	
    	InternalProjectSkill__c intProjSkill1 = new InternalProjectSkill__c();
    	intProjSkill1.Internal_Project__c = iProject.Id;
    	intProjSkill1.Skill__c = s1.Id;
    	skillsList.add(intProjSkill1);
    	
    	InternalProjectSkill__c intProjSkill2 = new InternalProjectSkill__c();
    	intProjSkill2.Internal_Project__c = iProject.Id;
    	intProjSkill2.Skill__c = s2.Id;
    	skillsList.add(intProjSkill2);
    	
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.addIntProjSkills(skillsList);
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void updateIntProjSkillsTest()
    {
		// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	s1.Internal_Project__c = iProject.Id; // assign internal project ID
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	s2.Internal_Project__c = iProject.Id; // assign internal project ID
    	
    	// Create Internal Project Skills
    	InternalProjectSkill__c intProjSkill1 = TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	InternalProjectSkill__c intProjSkill2 = TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Create List of Internal Project Skills
    	List<InternalProjectSkill__c> skillsList = new List<InternalProjectSkill__c>();
    	skillsList.add(intProjSkill1);
    	skillsList.add(intProjSkill2);
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.updateIntProjSkills(skillsList); 
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	  	
    }
    
    static testmethod void removeIntProjSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	s1.Internal_Project__c = iProject.Id; // assign internal project ID
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	s2.Internal_Project__c = iProject.Id; // assign internal project ID
    	
    	// Create User Skill
    	InternalProjectSkill__c us1 = TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	InternalProjectSkill__c us2 = TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Skills To Remove
    	List<InternalProjectSkill__c> skillsList = new List<InternalProjectSkill__c>();
    	skillsList.add(us1);
    	
    	// 2. Execute
		Test.startTest();
    	UserService userService = new UserService();
    	userService.removeIntProjSkills(skillsList);
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testmethod void getInternalProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	User u2 = TestDataFactory.createNewUser('Jason', 'Garret');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	Internal_Project__c iProject3 = TestDataFactory.createInternalProject('TestProject3', u2.Id);

    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	List<Internal_Project__c> projects = userService.getUsrIntProjects(u1.Id);
		Test.stopTest();
		
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Internal_Project__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void addUsrIntProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = new Internal_Project__c();
    	iProject1.Name = 'MyTestProject1';
    	iProject1.Description__c = 'Description for MyTestProject1';
    	iProject1.Member__c = u1.Id;
    	
    	Internal_Project__c iProject2 = new Internal_Project__c();
    	iProject2.Name = 'MyTestProject2';
    	iProject2.Description__c = 'Description for MyTestProject2';
    	iProject2.Member__c = u1.Id;
    	
    	// Add to list of projects to add
    	List<Internal_Project__c> projectList = new List<Internal_Project__c>();
    	projectList.add(iProject1);
    	projectList.add(iProject2);
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.addUsrIntProjects(projectList);
    	Test.stopTest();

    	// 3. Test Results 	
  		Internal_Project__c test1 = [SELECT Id, Name, Description__c FROM Internal_Project__c WHERE Id = :iProject1.Id LIMIT 1];
  		System.AssertEquals(test1.Name, 'MyTestProject1');
  		System.AssertEquals(test1.Description__c, 'Description for MyTestProject1');
  		
  		Internal_Project__c test2 = [SELECT Id, Name, Description__c FROM Internal_Project__c WHERE Id = :iProject2.Id LIMIT 1];
  		System.AssertEquals(test2.Name, 'MyTestProject2');  	
  		System.AssertEquals(test2.Description__c, 'Description for MyTestProject2'); 
    }
    
    static testmethod void updateUsrIntProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	iProject1.Member__c = u1.Id;
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	iProject2.Member__c = u1.Id;
    	
    	// Update Projects
    	iProject1.Description__c = 'Updated description for project1';
    	iProject2.Description__c = 'Updated description for project2';
    	
    	// Add projects to update to list
    	List<Internal_Project__c> listProjects = new List<Internal_Project__c>();
    	listProjects.add(iProject1);
    	listProjects.add(iProject2);
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.updateUsrIntProjects(listProjects);
    	Test.stopTest();

    	// 3. Test Results
    	Internal_Project__c test1 = [SELECT Id, Description__c FROM Internal_Project__c WHERE Id = :iProject1.Id LIMIT 1];
  		System.AssertEquals(test1.Description__c, 'Updated description for project1');
  		
  		Internal_Project__c test2 = [SELECT Id, Description__c FROM Internal_Project__c WHERE Id = :iProject2.Id LIMIT 1];
  		System.AssertEquals(test2.Description__c, 'Updated description for project2');  	
    }
    
    static testMethod void updateUsrIntProjectsNegativeTest1() 
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);

    	
    	// Create List of Projects to Remove
    	List<Internal_Project__c> listProjects = new List<Internal_Project__c>();
    	listProjects.add(iProject1);
			                        
		try {		                        
			// Invoke Service
			UserService userService = new UserService();
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
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	User u2 = TestDataFactory.createNewUser('Jason', 'Garret');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	iProject1.Member__c = u1.Id;
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	iProject2.Member__c = u1.Id;
    	Internal_Project__c iProject3 = TestDataFactory.createInternalProject('TestProject3', u2.Id);
    	iProject3.Member__c = u1.Id;
    	
    	// Create List of Projects to Remove
    	List<Internal_Project__c> listProjects = new List<Internal_Project__c>();
    	listProjects.add(iProject1);
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.removeUsrIntProjects(listProjects); 
    	Test.stopTest();

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Internal_Project__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testMethod void removeUsrIntProjectsNegativeTest1() 
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	
    	// Create List of Projects to Remove
    	List<Internal_Project__c> listProjects = new List<Internal_Project__c>();
    	listProjects.add(iProject1);
			                        
		try {		                        
			// Invoke Service
			UserService userService = new UserService();
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
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);

    	
    	// Create List of Projects to Remove
    	List<Internal_Project__c> listProjects = new List<Internal_Project__c>();
    	listProjects.add(iProject1);
			                        
		try {		                        
			// Invoke Service
			UserService userService = new UserService();
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