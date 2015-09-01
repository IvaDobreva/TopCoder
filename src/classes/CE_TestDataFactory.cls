/**************************************************
* Test Data Factory
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
*             and Sandip Dhara (sdhara@salesforce.com)
* Last Modified: 7/10/2015
* -------------------------------------------------
* An apex class which provides functionality for 
* easily creating mock data to be used only with 
* test classes.
**************************************************/

@isTest
public with sharing class CE_TestDataFactory {
    public static User setupNewUser(String firstName, String lastName) {
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
        
        // return list
        return testUser;
    }
    
    public static User createNewUser(String firstName, String lastName) {
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
    
    public static List<User> createNewUsers(Integer numUsers) { 
        List<User> testUsers = new List<User>();
        
        // loop over number of desired users and create each user object and add to list
        for (Integer i = 0; i < numUsers; i++) {
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
    
    public static CE_Skills__c createSkill(String skillName) {
        CE_Skills__c s = new CE_Skills__c();
        s.Name = skillName;
        insert s;
        return s;
    }
    
    public static CE_UserSkill__c createUserSkill(Id userId, Id skillId) {
        CE_UserSkill__c us = new CE_UserSkill__c();
        us.Member__c = userId;
        us.Skill__c = skillId;
        insert us;
        return us;
    }
    
    public static List<CE_UserSkill__c> createUserSkills(Id userId, Integer numSkills) {
        // create lists to hold picklist entries and test user skills
        List<CE_Skills__c> skillList = getAvailableSkills();
        List<CE_UserSkill__c> testUserSkills = new List<CE_UserSkill__c>();
        
        // If number of skills requested is larger than available picklist entries,
        // set the number of skills to the total size of the picklist entries.
        if (numSkills > skillList.size()) {
            numSkills = skillList.size();
        }
        
        // loop over number of desired skills and create each skill object and add to list
        for (Integer i = 0; i < numSkills; i++) {
            CE_Skills__c skill = new CE_Skills__c();
            CE_UserSkill__c testUserSkill = new CE_UserSkill__c();
            
            // set test user skill variables
            // skill.User__c = userId;
            // skill.Name = skillList[i].Name;
            testUserSkill.Skill__c = skillList[i].ID;
            testUserSkill.Member__c = userId;
            
            // add user skill to list
            testUserSkills.add(testUserSkill);
        }
        
        return null;
    }
    
    private static List<CE_Skills__c> getAvailableSkills() {
        List<CE_Skills__c> skillList = new List<CE_Skills__c>();
        skillList = [SELECT ID, Name from CE_Skills__c LIMIT 20];
        return skillList;
    }
    
    public static CE_Internal_Project__c createInternalProject(String projectName, Id userId) {
        CE_Internal_Project__c iProject = new CE_Internal_Project__c();
        iProject.Name = projectName;
        iProject.Description__c = projectName;
        iProject.Member__c = userId;
        insert iProject;
        return iProject;
    }
    
    public static CE_InternalProjectSkill__c createInternalProjectSkill(Id internalProjectId, Id skillId) {
        CE_InternalProjectSkill__c iProjectSkill = new CE_InternalProjectSkill__c();
        iProjectSkill.CE_Internal_Project__c = internalProjectId;
        iProjectSkill.Skill__c = skillId;
        insert iProjectSkill;
        return iProjectSkill;
    }
}