/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SD_UserServiceTest {

    static testMethod void addSkillsToUser() {
        // TO DO: implement unit test
        //createTestData();
        // Create Test Data 
        // 1. Create User
        User u = createUser('TestFirstName', 'TestLastName');
        
        // 2. Create Skills
        List<String> skills = new List<String>();
        skills.add('Skill1');
        skills.add('Skill2');
        skills.add('Skill3');
        System.Debug('*************Skills: ' + skills);
        
        // 3. Add Skills to User
        SD_UserService s = new SD_UserService();
        s.insertSkills(skills, u);
        
        // 4. Test that skills have been added correctly
        List<Skills__c> userSkill = [SELECT Id, Skill__c FROM Skills__c where User__c = :u.Id LIMIT 1];
        System.Debug('**************UserSkill: ' + userSkill[0]);
        System.assertEquals(userSkill[0].Skill__c.contains('Skill1'), true);
        //System.assertEquals(userSkill[0].Skill__c.contains('Skill2'), true);
        //System.assertEquals(userSkill[0].Skill__c.contains('Skill3'), true);
    }
    
    // Test
    
    static testMethod void findSkillsForuser()
    {
    	 // 1. Create User
        User u = createUser('TestFirstName', 'TestLastName');
        
        // 2. Add Skills To User
    	Id s1 = addSkill('Skill1',u);
    	Id s2 = addSkill('Skill2',u);
    	Id s3 = addSkill('Skill3',u);
    	
    	// 3. Retrieve skills
    	SD_UserService s = new SD_UserService();
        List<Skills__c> skillsList = s.getUserSkills(u);
        
        // 4. Test that skills have been added
    	System.assertEquals(skillsList.size(), 3);
    	
    }
    
    
    private static User createUser(String firstName, String lastName)
    {
    	User UserSetting = [select TimeZoneSidKey, 
                            LocaleSidKey, 
                            EmailEncodingKey, 
                            ProfileId, 
                            LanguageLocaleKey
                        from User LIMIT 1];
                        
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        // Create New Users
        User user1 = new User (FirstName = firstName, 
                                LastName = lastName, 
                                Username = firstName + '.' + lastName + '@apttus.com',
                                Email =  firstName + '.' + lastName + '@apttus.com',
                                Alias = lastName.left(8),
                                TimeZoneSidKey = UserSetting.TimeZoneSidKey, 
                                LocaleSidKey = UserSetting.LocaleSidKey, 
                                EmailEncodingKey = UserSetting.EmailEncodingKey, 
                                ProfileId = UserSetting.ProfileId, 
                                LanguageLocaleKey = UserSetting.LanguageLocaleKey);
        insert user1; // Create Test User 1
    	return user1;
    }
    
    private static Id addSkill(String skillName, User u)
    {
    	Skills__c s1 = new Skills__c();
    	s1.User__c = u.Id;
    	s1.Skill__c = skillName;
    	insert s1;
    	return s1.Id;
    }
    
    
}