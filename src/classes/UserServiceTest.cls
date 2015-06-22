@isTest
private class UserServiceTest 
{
    static testMethod void createUserTest() 
    {
    	// create test user object
    	User userToCreate = TestDataFactory.createNewUsers(1)[0];
    	// SD: Modified above statement
    	//User userToCreate = TestDataFactory.setupNewUser('Tomo', ' Romo');
			                        
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
			                        
		try{		                        
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
			                        
		try{		                        
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
    
    /*
    // Replaced by method below
    static testMethod void addUserSkillsTest()
    {
    	// create test user object
    	User userToDisable = TestDataFactory.createNewUsers(1)[0];
    	
    	// invoke User Service
		UserService userService = new UserService();
		
		// create user
		Id userId = userService.createUser(userToDisable); 
		System.debug('Create User Test: Created new user with ID ' + userId + '.');
		
		// add user skills
		
    }
    */
    
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
  		
  		try{		                        
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
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	//Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	//Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	List<Skills__c> skillsList = new List<Skills__c>();
    	skillsList.add(s1);
    	skillsList.add(s2);
    	
    	// 2. Execute
    	// SD: This should be a list of skills, instead of UserSkill
    	//public void addUserSkills(Id userId, List<UserSkill__c> skills)
    	UserService userService = new UserService();
    	userService.addUserSkills(u1.Id, skillsList);
    	//userService.addUserSkills(u1.Id, skillsList);
    	
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
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	//Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	//Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	List<Skills__c> skillsList = new List<Skills__c>();
    	skillsList.add(s1);
    	skillsList.add(s2);
    	
    	// 2. Execute
		Test.startTest();
    	UserService userService = new UserService();
    	userService.updateUserSkills(u1.Id, skillsList);
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
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	
    	// SkillToDelete
    	List<UserSkill__c> listToDelete = new List<UserSkill__c>();
    	listToDelete.add(us1);
    	
    	// 2. Execute
    	// SD: This should be a list of skills, instead of UserSkill
    	//public void addUserSkills(Id userId, List<UserSkill__c> skills)
		Test.startTest();
    	UserService userService = new UserService();
		userService.removeUserSkills(u1.Id, listToDelete);
		Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Userskill__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testmethod void getInternalProjectSkillsTest()
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
    	List<InternalProjectSkill__c> internalProjectSkills = userService.getInternalProjectSkills(u1.Id);
    	Test.stopTest();

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void addInternalProjectSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create List of Skills
    	List<Skills__c> skillsList = new List<Skills__c>();
    	skillsList.add(s1);
    	skillsList.add(s2);
    	
    	// 2. Execute
    	// SD: This should be a list of skills, instead of UserSkill
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.addInternalProjectSkills(iProject.Id, skillsList);
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void updateInternalProjectSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	//Userskill__c us1 = TestDataFactory.createUserSkill(u1.Id, s1.Id);
    	//Userskill__c us2 = TestDataFactory.createUserSkill(u1.Id, s2.Id);
    	List<Skills__c> skillsList = new List<Skills__c>();
    	skillsList.add(s1);
    	skillsList.add(s2);
    	
    	// 2. Execute
    	// SD: This should be a list of skills, instead of UserSkill
    	//public void addUserSkills(Id userId, List<UserSkill__c> skills)
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.updateInternalProjectSkills(iProject.Id, skillsList);
    	Test.stopTest();
    	
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM InternalProjectSkill__c WHERE Internal_Project__r.Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  		
    }
    
    static testmethod void removeInternalProjectSkillsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	
    	// Create Skills
    	Skills__c s1 = TestDataFactory.createSkill('Football');
    	Skills__c s2 = TestDataFactory.createSkill('Golf');
    	
    	// Create User Skill
    	InternalProjectSkill__c us1 = TestDataFactory.createInternalProjectSkill(iProject.Id, s1.Id);
    	InternalProjectSkill__c us2 = TestDataFactory.createInternalProjectSkill(iProject.Id, s2.Id);
    	
    	// Skills To Remove
    	List<InternalProjectSkill__c> skillsList = new List<InternalProjectSkill__c>();
    	skillsList.add(us1);
    	//skillsList.add(us2);
    	
    	// 2. Execute
		Test.startTest();
    	UserService userService = new UserService();
    	userService.removeInternalProjectSkills(iProject.Id,skillsList);
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
    	List<Internal_Project__c> projects = userService.getInternalProjects(u1.Id);
		Test.stopTest();
		
    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Internal_Project__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 2);  	
    }
    
    static testmethod void addInternalProjectsTest()
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
    	userService.addInternalProjects(u1.Id, projectList);
    	Test.stopTest();

    	// 3. Test Results
    	//Integer usTest1 = [SELECT count() FROM Internal_Project__c WHERE Member__c = :u1.Id];
  		//System.AssertEquals(2, usTest1);  	
  		
  		Internal_Project__c test1 = [SELECT Id, Name, Description__c FROM Internal_Project__c WHERE Id = :iProject1.Id LIMIT 1];
  		System.AssertEquals(test1.Name, 'MyTestProject1');
  		System.AssertEquals(test1.Description__c, 'Description for MyTestProject1');
  		
  		Internal_Project__c test2 = [SELECT Id, Name, Description__c FROM Internal_Project__c WHERE Id = :iProject2.Id LIMIT 1];
  		System.AssertEquals(test2.Name, 'MyTestProject2');  	
  		System.AssertEquals(test2.Description__c, 'Description for MyTestProject2'); 
    }
    
    static testmethod void updateInternalProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	
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
    	userService.updateInternalProjects(u1.Id, listProjects);
    	Test.stopTest();

    	// 3. Test Results
    	Internal_Project__c test1 = [SELECT Id, Description__c FROM Internal_Project__c WHERE Id = :iProject1.Id LIMIT 1];
  		System.AssertEquals(test1.Description__c, 'Updated description for project1');
  		
  		Internal_Project__c test2 = [SELECT Id, Description__c FROM Internal_Project__c WHERE Id = :iProject2.Id LIMIT 1];
  		System.AssertEquals(test2.Description__c, 'Updated description for project2');  	
    }
    
    static testMethod void updateInternalProjectNegativeTest1() 
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
			                        
		try{		                        
			// Invoke Service
			UserService userService = new UserService();
    		userService.updateInternalProjects(null, null);
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('removeInternalProjectNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Update Internal Projects: Unable to update internal projects because null user ID or internal projects list argument was used.');	
		}
		
    }
    
    static testmethod void removeInternalProjectsTest()
    {
    	// 1. Create Test Data
    	// Create User
    	User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
    	User u2 = TestDataFactory.createNewUser('Jason', 'Garret');
    	
    	// Create Internal Project
    	Internal_Project__c iProject1 = TestDataFactory.createInternalProject('TestProject1', u1.Id);
    	Internal_Project__c iProject2 = TestDataFactory.createInternalProject('TestProject2', u1.Id);
    	Internal_Project__c iProject3 = TestDataFactory.createInternalProject('TestProject3', u2.Id);
    	
    	// Create List of Projects to Remove
    	List<Internal_Project__c> listProjects = new List<Internal_Project__c>();
    	listProjects.add(iProject1);
    	
    	// 2. Execute
    	Test.startTest();
    	UserService userService = new UserService();
    	userService.removeInternalProjects(u1.Id, listProjects);
    	Test.stopTest();

    	// 3. Test Results
    	Integer usTest1 = [SELECT count() FROM Internal_Project__c WHERE Member__c = :u1.Id];
  		System.AssertEquals(usTest1, 1);  	
    }
    
    static testMethod void removeInternalProjectNegativeTest1() 
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
			                        
		try{		                        
			// Invoke Service
			UserService userService = new UserService();
    		userService.removeInternalProjects(null, listProjects);
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('removeInternalProjectNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Remove Internal Projects: Unable to remove internal projects because null user ID or internal projects list argument was used.');	
		}
		
    }
    
    static testMethod void removeInternalProjectNegativeTest2() 
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
			                        
		try{		                        
			// Invoke Service
			UserService userService = new UserService();
    		userService.removeInternalProjects(u1.Id, null);
		}
		catch(Exception e)
		{
			// verify results
			System.Debug('removeInternalProjectNegativeTest: ' + e.getMessage());
        	System.assertEquals(e.getMessage(), 'Remove Internal Projects: Unable to remove internal projects because null user ID or internal projects list argument was used.');	
		}
		
    }
}