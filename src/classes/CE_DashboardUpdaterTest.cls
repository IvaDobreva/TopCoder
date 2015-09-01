/**************************************************
* Dashboard Updater Test
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/16/2015
* Modified By: Gaurav Kheterpal (gaurav.kheterpal@appirio.com)
* Modified On: 8/25/2015
* Modification done: Corrected the syntax to execute batch
* -------------------------------------------------
* Test methods for the Dashboard Updater.
**************************************************/ 

@isTest(SeeAllData=false)
private class CE_DashboardUpdaterTest {
    static testMethod void updateDashboardTest() {
        // create test user object
        User userToCreate = CE_TestDataFactory.createNewUsers(1)[0];
                                    
        // invoke User Service
        CE_UserService userService = new CE_UserService();
        
        // create users
        Id userId = userService.createUser(userToCreate); 
        
        // invoke Activity Service
        CE_ActivityService activityService = new CE_ActivityService();
        
        // create stories and activities
        CE_Story__c story1 = CE_TestFactory.createStory();
        CE_Story__c story2 = CE_TestFactory.createStory();
        story2.Status__c = 'Completed';
        CE_Story__c story3 = CE_TestFactory.createStory();
        insert story1;
        insert story2;
        insert story3;
        
        CE_Activity__c activity1 = CE_TestFactory.createActivity(story1);
        activity1.Assigned_Member__c = userId;
        CE_Activity__c activity2 = CE_TestFactory.createActivity(story2);
        activity2.Assigned_Member__c = userId;
        activity2.Status__c = 'Completed';
        CE_Activity__c activity3 = CE_TestFactory.createActivity(story3);
        activity3.Assigned_Member__c = userId;
        activity3.Status__c = 'Public';
        insert activity1;
        insert activity2;
        insert activity3;
        
        // create registration
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(userId, activity1);
        insert registration;
        
        // create submissions
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity1);
        CE_Submission__c submission2 = CE_TestFactory.createSubmission(activity1);
        submission2.Status__c = 'Review Complete';
        insert submission1;
        insert submission2;
        
        // create skills
        CE_Skills__c skill1 = CE_TestDataFactory.createSkill('C++');
        CE_Skills__c skill2 = CE_TestDataFactory.createSkill('Java');
        CE_Skills__c skill3 = CE_TestDataFactory.createSkill('JavaScript');
        CE_Skills__c skill4 = CE_TestDataFactory.createSkill('Python');
        CE_Skills__c skill5 = CE_TestDataFactory.createSkill('Ruby');
        CE_Skills__c skill6 = CE_TestDataFactory.createSkill('C#');
        
        // create user skills
        CE_UserSkill__c userSkill1 = CE_TestDataFactory.createUserSkill(userId, skill1.Id);
        CE_UserSkill__c userSkill2 = CE_TestDataFactory.createUserSkill(userId, skill2.Id);
        CE_UserSkill__c userSkill3 = CE_TestDataFactory.createUserSkill(userId, skill3.Id);
        CE_UserSkill__c userSkill4 = CE_TestDataFactory.createUserSkill(userId, skill4.Id);
        CE_UserSkill__c userSkill5 = CE_TestDataFactory.createUserSkill(userId, skill5.Id);
        CE_UserSkill__c userSkill6 = CE_TestDataFactory.createUserSkill(userId, skill6.Id);
        
        // add user skills to list
        List<CE_UserSkill__c> userSkills = new List<CE_UserSkill__c>();
        userSkills.add(userSkill1);
        userSkills.add(userSkill2);
        userSkills.add(userSkill3);
        userSkills.add(userSkill4);
        userSkills.add(userSkill5);
        
        // begin test
        Test.startTest();
        CE_DashboardUpdater dashboardUpdater = new CE_DashboardUpdater();
        database.executeBatch(dashboardUpdater);
        Test.stopTest();
        
        // verify results
        System.assertEquals(2, [SELECT count() FROM CE_Story__c WHERE Status__c != 'Completed' 
        		AND Status__c != 'Canceled' AND IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM CE_Activity__c WHERE Status__c != 'Completed' 
        		AND Status__c != 'Draft' AND IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM CE_Activity__c WHERE Status__c = 'Completed' 
        		AND IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM CE_Story__c WHERE Status__c = 'Completed' 
        		AND IsDeleted = false]);
        System.assertEquals(3, [SELECT count() FROM CE_Activity__c WHERE IsDeleted = false]);
        System.assertEquals(3, [SELECT count() FROM CE_Story__c WHERE IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM CE_Registration__c]);
        System.assertEquals(1, [SELECT count() FROM CE_Submission__c WHERE Status__c = 'Review Complete']);
        System.assertEquals(2, [SELECT count() FROM CE_Submission__c]);
        System.assertEquals(6, [SELECT count() FROM CE_Member_Skill_Snapshot__c]);
    }
}
