/**************************************************
* Dashboard Updater Test
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/16/2015
* -------------------------------------------------
* Test methods for the Dashboard Updater.
**************************************************/ 

@isTest(SeeAllData=false)
private class DashboardUpdaterTest {
    static testMethod void updateDashboardTest() {
        // create test user object
        User userToCreate = TestDataFactory.createNewUsers(1)[0];
                                    
        // invoke User Service
        UserService userService = new UserService();
        
        // create users
        Id userId = userService.createUser(userToCreate); 
        
        // invoke Activity Service
        ActivityService activityService = new ActivityService();
        
        // create stories and activities
        Story__c story1 = TestFactory.createStory();
        Story__c story2 = TestFactory.createStory();
        story2.Status__c = 'Completed';
        Story__c story3 = TestFactory.createStory();
        insert story1;
        insert story2;
        insert story3;
        
        Activity__c activity1 = TestFactory.createActivity(story1);
        activity1.Assigned_Member__c = userId;
        Activity__c activity2 = TestFactory.createActivity(story2);
        activity2.Assigned_Member__c = userId;
        activity2.Status__c = 'Completed';
        Activity__c activity3 = TestFactory.createActivity(story3);
        activity3.Assigned_Member__c = userId;
        activity3.Status__c = 'Public';
        insert activity1;
        insert activity2;
        insert activity3;
        
        // create registration
        Registration__c registration = TestFactory.createRegisterMember(userId, activity1);
        insert registration;
        
        // create submissions
        Submission__c submission1 = TestFactory.createSubmission(activity1);
        Submission__c submission2 = TestFactory.createSubmission(activity1);
        submission2.Status__c = 'Review Complete';
        insert submission1;
        insert submission2;
        
        // create skills
        Skills__c skill1 = TestDataFactory.createSkill('C++');
        Skills__c skill2 = TestDataFactory.createSkill('Java');
        Skills__c skill3 = TestDataFactory.createSkill('JavaScript');
        Skills__c skill4 = TestDataFactory.createSkill('Python');
        Skills__c skill5 = TestDataFactory.createSkill('Ruby');
        Skills__c skill6 = TestDataFactory.createSkill('C#');
        
        // create user skills
        UserSkill__c userSkill1 = TestDataFactory.createUserSkill(userId, skill1.Id);
        UserSkill__c userSkill2 = TestDataFactory.createUserSkill(userId, skill2.Id);
        UserSkill__c userSkill3 = TestDataFactory.createUserSkill(userId, skill3.Id);
        UserSkill__c userSkill4 = TestDataFactory.createUserSkill(userId, skill4.Id);
        UserSkill__c userSkill5 = TestDataFactory.createUserSkill(userId, skill5.Id);
        UserSkill__c userSkill6 = TestDataFactory.createUserSkill(userId, skill6.Id);
        
        // add user skills to list
        List<UserSkill__c> userSkills = new List<UserSkill__c>();
        userSkills.add(userSkill1);
        userSkills.add(userSkill2);
        userSkills.add(userSkill3);
        userSkills.add(userSkill4);
        userSkills.add(userSkill5);
        
        // begin test
        Test.startTest();
        DashboardUpdater dashboardUpdater = new DashboardUpdater();
        dashboardUpdater.execute();
        Test.stopTest();
        
        // verify results
        System.assertEquals(2, [SELECT count() FROM Story__c WHERE Status__c != 'Completed' 
        		AND Status__c != 'Canceled' AND IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM Activity__c WHERE Status__c != 'Completed' 
        		AND Status__c != 'Draft' AND IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM Activity__c WHERE Status__c = 'Completed' 
        		AND IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM Story__c WHERE Status__c = 'Completed' 
        		AND IsDeleted = false]);
        System.assertEquals(3, [SELECT count() FROM Activity__c WHERE IsDeleted = false]);
        System.assertEquals(3, [SELECT count() FROM Story__c WHERE IsDeleted = false]);
        System.assertEquals(1, [SELECT count() FROM Registration__c]);
        System.assertEquals(1, [SELECT count() FROM Submission__c WHERE Status__c = 'Review Complete']);
        System.assertEquals(2, [SELECT count() FROM Submission__c]);
        System.assertEquals(6, [SELECT count() FROM Member_Skill_Snapshot__c]);
    }
}