@isTest
private class ActivityServiceTest {
    static IActivityService mService = null;
    static IActivityService getService() {
        if (mService == null)
            mService = new ActivityService();
        return mService;
    }

    static Activity__c createActivity(){
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        insert activity;
        return activity;
    }
    /**
     * Just simple insert test.
     */
    @isTest static void createActivities_positive() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        Test.startTest();

        List<Activity__c> result = getService().createActivities(new List<Activity__c> {activity});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertNotEquals(null, result[0].Id, 'Activity was returned with no Id. Guess insertion failed');
    }
    /**
     * Creation fails because Activity has no story reference
     */
    @isTest static void createActivities_negative_noStoryReference() {
        Activity__c activity = TestFactory.createActivity(TestFactory.createStory());
        Test.startTest();
        Boolean operationFailed = false;
        try {
            getService().createActivities(new List<Activity__c> {activity});
            
        } catch (Exception ex) {
            operationFailed = true;
        }

        Test.stopTest();
        System.assert(operationFailed, 'Operation allows to insert Activity without story reference');
    }
    /**
     * Just simple update test.
     */
    @isTest static void updateActivities_positive() {
        Activity__c activity = createActivity();
        activity.Description__c = 'NewTestDescription';

        Test.startTest();

        List<Activity__c> result = getService().updateActivities(new List<Activity__c> {activity});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertEquals(activity.Description__c, result[0].Description__c, 'Activity was returned with wrong description');
        Activity__c updatedActivity = [SELECT Description__c FROM Activity__c WHERE Id = :activity.Id LIMIT 1];
        System.assertEquals(activity.Description__c, updatedActivity.Description__c, 'Activity\'s field was not updated');

    }

    /**
     * Just simple delete test
     */
    @isTest static void deleteActivities_positive() {
        Activity__c activity = createActivity();
        Test.startTest();

        getService().deleteActivities(new List<Activity__c> {activity});

        Test.stopTest();
        List<Activity__c> activitiesFromDB = [SELECT Id FROM Activity__c WHERE Id = :activity.Id];
        System.assertEquals(0, activitiesFromDB.size(), 'Activity was not deleted');

    }
    /**
     * Searches for Activities for the member user
     */
    @isTest static void getActivitiesForUser_positive_member() {
        //Creating the user for Publisher field for Activity and Story objects
        User user = TestFactory.createUser();
        insert user;
        Story__c story = TestFactory.createStory();
        story.Publisher__c = user.Id;
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        activity.Publisher__c = user.Id;
        insert activity;
        //Creating milestones, we need them to create MemberActivityMilestone for the user(member)
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        //Take Submission Date milestone and create MemberActivityMilestone
        insert TestFactory.createMemberActivityMilestone(UserInfo.getUserId(), activity, activityMilestones[3]);
        Test.startTest();

        List<Activity__c> result = getService().getActivitiesForUser(new User(Id = UserInfo.getUserId()));

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Activity was not found');
    }
    /**
     * Searches for Activities for the member user with no activities
     */
    @isTest static void getActivitiesForUser_negative_member() {
        //Creating the user for Publisher field for Activity and Story objects
        User user = TestFactory.createUser();
        Story__c story = TestFactory.createStory();
        story.Publisher__c = user.Id;
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        activity.Publisher__c = user.Id;
        insert activity;
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;

        Test.startTest();

        List<Activity__c> result = getService().getActivitiesForUser(new User(Id = UserInfo.getUserId()));

        Test.stopTest();
        System.assertEquals(0, result.size(), 'Search must return no activities');

    }
    /**
     * Searches for Activities for the publisher user
     */
    @isTest static void getActivitiesForUser_positive_publisher() {
        Activity__c activity = createActivity();

        Test.startTest();

        List<Activity__c> result = getService().getActivitiesForUser(new User(Id = UserInfo.getUserId()));

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Activity was not found');
    }
    /**
     * Searches for Activities for the publisher user with no activities
     */
    @isTest static void getActivitiesForUser_negative_publisher() {
        User user = TestFactory.createUser();
        insert user;
        Activity__c activity = createActivity();

        Test.startTest();

        List<Activity__c> result = getService().getActivitiesForUser(user);

        Test.stopTest();
        System.assertEquals(0, result.size(), 'Search must return no activities');


    }
    /**
     * Tests search by 2 Skills
     */
    @isTest static void search_positive() {
        Activity__c activity = createActivity();
        Skills__c dotNetSkill = TestFactory.createSkill('.net');
        Skills__c androidSkill = TestFactory.createSkill('android');

        insert new List<Skills__c> { dotNetSkill, androidSkill };

        insert new List<ActivitySkills__c> { TestFactory.createActivitySkill(activity, dotNetSkill), TestFactory.createActivitySkill(activity, androidSkill)};

        Test.startTest();

        List<Activity__c> result = getService().search(new List<Skills__c> {dotNetSkill});
        System.assertEquals(1, result.size(), 'Search must return 1 activity for the .Net skill.');
        System.assertEquals(activity.Id, result[0].Id, 'Wrong activity was returned by search');

        result = getService().search(new List<Skills__c> {androidSkill});
        System.assertEquals(1, result.size(), 'Search must return 1 activity for the Android skill.');
        System.assertEquals(activity.Id, result[0].Id, 'Wrong activity was returned by search');

        result = getService().search(new List<Skills__c> {dotNetSkill, androidSkill});
        System.assertEquals(1, result.size(), 'Search must return 1 activity for Android and .Net skills.');
        System.assertEquals(activity.Id, result[0].Id, 'Wrong activity was returned by search');

        Test.stopTest();
    }
    /**
     * Tests search non existed skill
     */
    @isTest static void search_negative() {
        Activity__c activity = createActivity();
        Skills__c dotNetSkill = TestFactory.createSkill('.net');
        Skills__c androidSkill = TestFactory.createSkill('android');
        insert new List<Skills__c> {dotNetSkill, androidSkill};

        insert new List<ActivitySkills__c> {TestFactory.createActivitySkill(activity, dotNetSkill)};

        Test.startTest();

        List<Activity__c>result = getService().search(new List<Skills__c> {androidSkill});

        Test.stopTest();
        System.assertEquals(0, result.size(), 'Search must return no activities for the Android skill.');

    }
    /**
     * Just simple create test.
     */
    @isTest static void addAwards_positive() {
        Activity__c activity = createActivity();
        Award__c award = TestFactory.createAward(activity);

        Test.startTest();

        List<Award__c> result = getService().addAwards(new List<Award__c> {award});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertNotEquals(null, result[0].Id, 'Seems like award was not created');
        System.assertEquals(award.Activity__c, result[0].Activity__c, 'Seems like wrong Award was returned');
        System.assertEquals(award.Payment__c, result[0].Payment__c, 'Seems like wrong Award was returned');

    }
    /**
     * Just simple update test.
     */
    @isTest static void updateAwards_positive() {
        Activity__c activity = createActivity();
        Award__c award = TestFactory.createAward(activity);
        insert award;
        award.Payment__c = 333;
        Test.startTest();
        
        List<Award__c> result = getService().updateAwards(new List<Award__c> {award});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertEquals(award.Activity__c, result[0].Activity__c, 'Seems like wrong Award was returned');
        System.assertEquals(award.Payment__c, result[0].Payment__c, 'Seems like Award was not updated');
        Award__c awardFromDB = [SELECT Payment__c FROM Award__c WHERE Id = :award.Id LIMIT 1];
        System.assertEquals(award.Payment__c, awardFromDB.Payment__c, 'Seems like Award was not updated');

    }
    /**
     * Just simple delete test.
     */
    @isTest static void deleteAwards_positive() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        insert activity;
        Award__c award = TestFactory.createAward(activity);
        insert award;
        Test.startTest();

        getService().deleteAwards(new List<Award__c> {award});

        Test.stopTest();
        List<Award__c> awardsFromDB = [SELECT Payment__c FROM Award__c WHERE Id = :award.Id];
        System.assertEquals(0, awardsFromDB.size(), 'Seems like Award was not deleted');

    }
    /**
     * Testing creating ActivityMilestones
     */
    @isTest static void setMilestones_positive() {
        Activity__c activity = createActivity();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;

        Test.startTest();

        getService().setMilestones(milestones, activity);

        Test.stopTest();
        List<ActivityMilestones__c> activityMilestonesFromDB = [SELECT Milestone__c, Activity__c FROM ActivityMilestones__c];

        System.assertEquals(milestones.size(), activityMilestonesFromDB.size(), 'Seems like wrong number of ActivityMilestones were inserted');

        for (ActivityMilestones__c activityMilestoneFromDB : activityMilestonesFromDB) {
            System.assertEquals(activity.Id, activityMilestoneFromDB.Activity__c, 'ActivityMilestone has wrong Activity reference');

            Boolean milestoneWasFound = false;
            for (Milestone__c milestone : milestones)
                if (milestone.Id == activityMilestoneFromDB.Milestone__c) {
                    milestoneWasFound = true;
                }
            System.assert(milestoneWasFound, 'ActivityMilestone reference was not found in milestones');
        }
    }

    /**
     * Testing getting ActivityMilestones
     */
    @isTest static void getMilestones_positive() {
        Activity__c activity = createActivity();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;

        Test.startTest();

        List<Milestone__c> result = getService().getMilestones(activity);

        Test.stopTest();
        System.assertEquals(milestones.size(), result.size(), 'Seems like wrong number of ActivityMilestones were returned');
        Map<Id, Milestone__c> milestonesMap = new Map<Id, Milestone__c>(milestones);
        //Making sure that all needed milestones were found
        for (Milestone__c milestone : result)
            milestonesMap.remove(milestone.Id);
        System.assertEquals(0, milestonesMap.size(), 'Returned milestones are different from initial data.');

    }
    /**
     * Tests inserting skills for an activity
     */
    @isTest static void addSkills_positive() {
        Activity__c activity = createActivity();
        Skills__c dotNetSkill = TestFactory.createSkill('.net');
        Skills__c androidSkill = TestFactory.createSkill('android');

        insert new List<Skills__c> { dotNetSkill, androidSkill };


        Test.startTest();

        getService().addSkills(new List<Skills__c> {dotNetSkill, androidSkill}, activity);

        Test.stopTest();
        List<ActivitySkills__c> skillsFromDB = [SELECT Skill__c FROM ActivitySkills__c WHERE Activity__c = :activity.Id];
        System.assertEquals(2, skillsFromDB.size(), 'There must be 2 skills for the activity in DB');

        Boolean dotNetSkillFound = skillsFromDB[0].Skill__c == dotNetSkill.Id || skillsFromDB[1].Skill__c == dotNetSkill.Id;
        System.assert(dotNetSkillFound, 'Cannot find .Net skill');
        Boolean androidSkillFound = skillsFromDB[0].Skill__c == androidSkill.Id || skillsFromDB[1].Skill__c == androidSkill.Id;
        System.assert(androidSkillFound, 'Cannot find Android skill');
    }
    /**
     * Tests deleting skills for an activity
     */
    @isTest static void deleteSkills_positive() {
        Activity__c activity = createActivity();
        Skills__c dotNetSkill = TestFactory.createSkill('.net');
        Skills__c androidSkill = TestFactory.createSkill('android');

        insert new List<Skills__c> { dotNetSkill, androidSkill };
        insert new List<ActivitySkills__c> {TestFactory.createActivitySkill(activity, dotNetSkill)};

        Test.startTest();

        getService().deleteSkills(new List<Skills__c> {dotNetSkill, androidSkill}, activity);

        Test.stopTest();
        List<ActivitySkills__c> skillsFromDB = [SELECT Skill__c FROM ActivitySkills__c WHERE Activity__c = :activity.Id];
        System.assertEquals(0, skillsFromDB.size(), 'There must be no skills for the activity in DB');

    }
    /**
     * Tests getting skills for an activity
     */
    @isTest static void getSkills_positive() {
        Activity__c activity = createActivity();
        Skills__c dotNetSkill = TestFactory.createSkill('.net');
        Skills__c androidSkill = TestFactory.createSkill('android');

        insert new List<Skills__c> { dotNetSkill, androidSkill };
        insert new List<ActivitySkills__c> { TestFactory.createActivitySkill(activity, dotNetSkill), TestFactory.createActivitySkill(activity, androidSkill)};

        Test.startTest();

        List<Skills__c> result = getService().getSkills(activity);

        Test.stopTest();
        System.assertEquals(2, result.size(), 'Seems like wrong number of skills was returned');
        Map<Id, Skills__c> resultMap = new Map<Id, Skills__c>(result);
        resultMap.remove(dotNetSkill.Id);
        System.assertEquals(1, resultMap.size(), 'Seems like result does not contain .Net skill');
        resultMap.remove(androidSkill.Id);
        System.assertEquals(0, resultMap.size(), 'Seems like result does not contain Android skill');

    }
    /**
     * Getting requirements test
     */
    @isTest static void getRequirements_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        Test.startTest();

        List<Requirement__c> result = getService().getRequirements(activity);

        Test.stopTest();
        System.assertEquals(requirements.size(), result.size(), 'Seems like wrong number of requirements was returned');
        Map<Id, Requirement__c> resultMap = new Map<Id, Requirement__c>(result);
        for (Requirement__c requirement : requirements)
            resultMap.remove(requirement.Id);
        System.assertEquals(0, resultMap.size(), 'Seems like different collection of requirements was returned');
    }
    /**
     * Adding requirements test
     */
    @isTest static void addRequirements_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        //Creating default requirements
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(TestFactory.createRequirement(activity, defaultRequirement));

        Test.startTest();

        List<Requirement__c> result = getService().addRequirements(requirements);

        Test.stopTest();
        System.assertEquals(requirements.size(), result.size(), 'Seems like wrong number of requirements was returned');
        for (Requirement__c requirement : result) {
            System.assertNotEquals(null, requirement.Id, 'Requirements was not inserted');
        }
    }
    /**
     * Adding requirements test with fail because Submission is closed
     */
    @isTest static void addRequirements_negative() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        
        insert milestones;

        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        //Creating default requirements
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(TestFactory.createRequirement(activity, defaultRequirement));
        Boolean operationFailed = false;
        Test.startTest();
        
        try {
            List<Requirement__c> result = getService().addRequirements(requirements);
        } catch (Exception ex) {
            operationFailed = true;
        }

        Test.stopTest();
        System.assert(operationFailed, 'Operation was successful. It must fail due to expired submission due date ');

    }
    /**
     * Updating requirements test
     */
    @isTest static void updateRequirement_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        //Creating default requirements
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        for (Requirement__c requirement : requirements)
            requirement.Requirement_Weight__c = 'Low';
        Test.startTest();

        Map<Id, Requirement__c> resultMap = new Map<Id, Requirement__c>(getService().updateRequirement(requirements));
    
        Test.stopTest();
        System.assertEquals(requirements.size(), resultMap.size(), 'Seems like wrong number of requirements was returned');
        List<Requirement__c> resultFromDB = [SELECT Requirement_Weight__c FROM Requirement__c WHERe Id IN :resultMap.keySet()];
        for (Requirement__c requirement : resultFromDB)
            System.assertEquals('Low', requirement.Requirement_Weight__c, 'Seems like Requirements was not updated');

    }
    /**
     * Deleting requirements test
     */
    @isTest static void deleteRequirements_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        //Creating default requirements
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        Map<Id, Requirement__c> requirementsMap = new Map<Id, Requirement__c>(requirements);
        Test.startTest();

        getService().deleteRequirements(requirements);

        Test.stopTest();
        List<Requirement__c> resultFromDB = [SELECT Id FROM Requirement__c WHERe Id IN :requirementsMap.keySet()];
        System.assertEquals(0, resultFromDB.size(), 'Must be no Requirements in DB');
    }
    /**
     * Getting default requirements test
     */
    @isTest static void getDefaultRequirements_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        Test.startTest();

        List<Default_Requirement__c> result = getService().getDefaultRequirements();

        Test.stopTest();

        System.assertEquals(defaultRequirements.size(), result.size(), 'Seems like wrong number of default requirements was returned');
        Map<Id, Default_Requirement__c> resultMap = new Map<Id, Default_Requirement__c>(result);
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            resultMap.remove(defaultRequirement.Id);
        System.assertEquals(0, resultMap.size(), 'Seems like different collection of Default Requirements was returned');
    }
    /**
     * Checking that activity is unlocked
     */
    @isTest static void isLocked_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        Test.startTest();

        System.assertEquals(false, getService().isLocked(activity), 'Activity must be unlocked');

        Test.stopTest();
    }
    /**
     * Checking that activity is locked
     */
    @isTest static void isLocked_negative() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
       
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        Test.startTest();

        System.assertEquals(true, getService().isLocked(activity), 'Activity must be locked');

        Test.stopTest();
    }
    /**
     * Checking that activity is unlocked. Fails because there is no Milestones in DB
     */
    @isTest static void isLocked_negative_noMilestones() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        Test.startTest();
        Boolean operationFailed = false;
        try {
            getService().isLocked(activity);
        } catch (Exception ex) {
            operationFailed = true;
        }
        System.assert(operationFailed, 'Operation must fail, because there are no milestones for the activity');
        Test.stopTest();
    }
    /**
     * Cloning activity test
     */
    @isTest static void cloneActivity_positive() {
        Activity__c activity = createActivity();
        List<Default_Requirement__c> defaultRequirements = TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<Requirement__c> requirements = new List<Requirement__c>();
        for (Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        //Creating milestones
        List<Milestone__c> milestones = TestFactory.createDefaultMilestones();
        insert milestones;
        List<ActivityMilestones__c> activityMilestones = new List<ActivityMilestones__c>();
        for (Milestone__c milestone : milestones)
            activityMilestones.add(TestFactory.createActivityMilestone(activity, milestone));
        insert activityMilestones;
        Award__c award = TestFactory.createAward(activity);
        insert award;
        Test.startTest();

            Activity__c newActivity = getService().cloneActivity(activity);

        Test.stopTest();
        System.assertNotEquals(activity.Id, newActivity.Id,'Seems like activity was not cloned');
        System.assertNotEquals(null, newActivity.Id,'Seems like cloned activity was not inserted');
        List<ActivityMilestones__c> newActivityMilestones = [SELECT Id FROM ActivityMilestones__c WHERE Activity__c = :newActivity.Id];
        System.assertEquals(activityMilestones.size(), newActivityMilestones.size(), 'Seems like not all Activity Milestones were cloned');
        List<Requirement__c> newActivityRequirements = [SELECT Id FROM Requirement__c WHERE Activity__c = :newActivity.Id];
        System.assertEquals(newActivityRequirements.size(), newActivityRequirements.size(), 'Seems like not all Activity Requirements were cloned');
        List<Award__c> newActivityAwards = [SELECT Id FROM Award__c WHERE Activity__c = :newActivity.Id];
        System.assertEquals(newActivityAwards.size(), newActivityAwards.size(), 'Seems like not all Activity Awards were cloned');
    }
}