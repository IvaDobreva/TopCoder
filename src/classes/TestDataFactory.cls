/**************************************************
* Test Data Factory
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
*             and Sandip Dhara (sdhara@salesforce.com)
* Last Modified: 6/22/2015
* -------------------------------------------------
* An apex class which provides functionality for 
* easily creating mock data to be used only with 
* test classes.
**************************************************/

@isTest
public with sharing class TestDataFactory {
	
	public static User setupNewUser(String firstName, String lastName)
	{
		
			User testUser = new User();
			                        
			// set test user object variables
			testUser.Username = firstName + '@test-user.com';
			testUser.LastName = lastName;
			testUser.FirstName = firstName;
			testUser.Email = firstName +'.' + lastName + '@test-user.com';
			String alias = firstName + lastName;
			testUser.Alias = alias.left(8);
			testUser.CommunityNickname = firstName + lastName;
			testUser.IsActive = true;
			testUser.TimeZoneSidKey = 'America/Los_Angeles';
			testUser.LocaleSidKey = 'en_US';
			testUser.EmailEncodingKey = 'ISO-8859-1';
			testUser.LanguageLocaleKey = 'en_US';
			testUser.UserPermissionsMobileUser = false;
			testUser.UserPreferencesDisableAutoSubForFeeds = false;
			
			// get profile Id from database and assign to test user
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
			testUser.ProfileId = p.Id;
			//insert testUser;
		
		// return list
		return testUser;
	}
	
	public static User createNewUser(String firstName, String lastName)
	{
		
			User testUser = new User();
			                        
			// set test user object variables
			testUser.Username = firstName + '@test-user.com';
			testUser.LastName = lastName;
			testUser.FirstName = firstName;
			testUser.Email = firstName +'.' + lastName + '@test-user.com';
			String alias = firstName + lastName;
			testUser.Alias = alias.left(8);
			testUser.CommunityNickname = firstName + lastName;
			testUser.IsActive = true;
			testUser.TimeZoneSidKey = 'America/Los_Angeles';
			testUser.LocaleSidKey = 'en_US';
			testUser.EmailEncodingKey = 'ISO-8859-1';
			testUser.LanguageLocaleKey = 'en_US';
			testUser.UserPermissionsMobileUser = false;
			testUser.UserPreferencesDisableAutoSubForFeeds = false;
			
			// get profile Id from database and assign to test user
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
			testUser.ProfileId = p.Id;
			insert testUser;
		
		// return list
		return testUser;
	}
	
	public static List<User> createNewUsers(Integer numUsers)
	{
		
		List<User> testUsers = new List<User>();
		
		// loop over number of desired users and create each user object and add to list
		for (Integer i = 0; i < numUsers; i++)
		{
			User testUser = new User();
			                        
			// set test user object variables
			testUser.Username = 'test-user' + i + '@test-user.com';
			testUser.LastName = 'User' + i;
			testUser.FirstName = 'Test';
			testUser.Email = 'test-user' + i + '@test-user.com';
			testUser.Alias = 'jsmith' + i;
			testUser.CommunityNickname = 'jsmith' + i + 'yourorgdomain';
			testUser.IsActive = true;
			testUser.TimeZoneSidKey = 'America/Los_Angeles';
			testUser.LocaleSidKey = 'en_US';
			testUser.EmailEncodingKey = 'ISO-8859-1';
			testUser.LanguageLocaleKey = 'en_US';
			testUser.UserPermissionsMobileUser = false;
			testUser.UserPreferencesDisableAutoSubForFeeds = false;
			
			// get profile Id from database and assign to test user
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
			testUser.ProfileId = p.Id;
			
			// add to list
			testUsers.add(testUser);
		}
		
		// return list
		return testUsers;
	}
	
	public static Skills__c createSkill(String skillName)
	{
		Skills__c s = new Skills__c();
		s.Skill__c = skillName;
		insert s;
		return s;
	}
	
	public static UserSkill__c createUserSkill(Id UserId, Id skillId)
	{
		UserSkill__c us = new UserSkill__c();
		us.Member__c = userId;
		us.Skill__c = skillId;
		insert us;
		return us;
	}
	
	public static List<UserSkill__c> createUserSkills(Id userId, Integer numSkills)
	{
		// create lists to hold picklist entries and test user skills
		List<Schema.PicklistEntry> picklistEntries = getAvailableSkills();
		List<UserSkill__c> testUserSkills = new List<UserSkill__c>();
		
		// If number of skills requested is larger than available picklist entries,
		// set the number of skills to the total size of the picklist entries.
		if (numSkills > picklistEntries.size())
		{
			numSkills = picklistEntries.size();
		}
		
		// loop over number of desired skills and create each skill object and add to list
		for (Integer i = 0; i < numSkills; i++)
		{
			Skills__c skill = new Skills__c();
			UserSkill__c testUserSkill = new UserSkill__c();
			
			// set test user skill variables
			skill.User__c = userId;
			skill.Skill__c = picklistEntries[i].getValue();
			//testUserSkill.Skill__c = skill;
			
			// add user skill to list
			testUserSkills.add(testUserSkill);
		}
		
		return null;
	}
	
	private static List<Schema.PicklistEntry> getAvailableSkills()
	{
		Schema.DescribeFieldResult availableSkill = UserSkill__c.Skill__c.getDescribe();
		return availableSkill.getPicklistValues();
	}
	
	public static Internal_Project__c createInternalProject(String projectName, Id UserId)
	{
		Internal_Project__c iProject = new Internal_Project__c();
		iProject.Name = projectName;
		iProject.Description__c = projectName;
		iProject.Member__c = userId;
		insert iProject;
		return iProject;
	}
	
	public static InternalProjectSkill__c createInternalProjectSkill(Id internalProjectId, Id skillId)
	{
		InternalProjectSkill__c iProjectSkill = new InternalProjectSkill__c();
		iProjectSkill.Internal_Project__c = internalProjectId;
		iProjectSkill.Skill__c = skillId;
		insert iProjectSkill;
		return iProjectSkill;
	}
	
}