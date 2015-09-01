@isTest
private class CE_ActivityServiceTest {
    static CE_IActivityService mService = null;
    static CE_IActivityService getService() {
        if (mService == null)
            mService = new CE_ActivityService(); 
        return mService;
    }

    static CE_Activity__c createActivity(){
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        return activity;
    }
    /**
     * Just simple insert test.
     */
    @isTest static void createActivities_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        Test.startTest();

        List<CE_Activity__c> result = getService().createActivities(new List<CE_Activity__c> {activity});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertNotEquals(null, result[0].Id, 'Activity was returned with no Id. Guess insertion failed');
    }
    
     /**
     * Just simple insert single activity test.
     */
    @isTest static void createActivity_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        
        Test.startTest();

        CE_Activity__c result = getService().createActivity(activity);

        Test.stopTest();
        System.assertNotEquals(null, result.Id, 'Activity was returned with no Id. Guess insertion failed');
    }
    
    /**
     * Creation fails because Activity has no story reference
     */
    @isTest static void createActivities_negative_noStoryReference() {
        CE_Activity__c activity = CE_TestFactory.createActivity(CE_TestFactory.createStory());
        Test.startTest();
        Boolean operationFailed = false;
        try {
            getService().createActivities(new List<CE_Activity__c> {activity});
            
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
        CE_Activity__c activity = createActivity();
        activity.Description__c = 'NewTestDescription';

        Test.startTest();

        List<CE_Activity__c> result = getService().updateActivities(new List<CE_Activity__c> {activity});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertEquals(activity.Description__c, result[0].Description__c, 'Activity was returned with wrong description');
        CE_Activity__c updatedActivity = [SELECT Description__c FROM CE_Activity__c WHERE Id = :activity.Id LIMIT 1];
        System.assertEquals(activity.Description__c, updatedActivity.Description__c, 'Activity\'s field was not updated');

    }
    
    /**
     * Just simple single activity update test.
     */
    @isTest static void updateActivity_positive() {
    	User user = CE_TestFactory.createUser();
        insert user;
        
        CE_Activity__c activity = createActivity();
        activity.Description__c = 'NewTestDescription';
		    activity.Assigned_Member__c = user.Id;
		    	activity.Date_Member_Assigned__c = DateTime.now();
		
        Test.startTest();

        CE_Activity__c result = getService().updateActivity(activity);

        Test.stopTest();
        
        CE_Activity__c updatedActivity = [SELECT Description__c, Assigned_Member__c, Date_Member_Assigned__c FROM CE_Activity__c WHERE Id = :activity.Id LIMIT 1];
        System.assertEquals(activity.Description__c, updatedActivity.Description__c, 'Activity\'s field was not updated');
        System.assertEquals(activity.Assigned_Member__c, user.Id, 'Activity\'s field Assigned Member was not updated');
    }
    
    /**
     * Just assign Member To Activity test.
     */
    @isTest static void assignMemberToActivity_positive() {
    	User user = CE_TestFactory.createUser();
        insert user;
        
        CE_Activity__c activity = createActivity();
        activity.Description__c = 'NewTestDescription';
		
        Test.startTest();

        getService().assignMemberToActivity(user, activity);

        Test.stopTest();
        
        CE_Activity__c updatedActivity = [SELECT Description__c, Assigned_Member__c, Date_Member_Assigned__c FROM CE_Activity__c WHERE Id = :activity.Id LIMIT 1];
        System.assertEquals(activity.Description__c, updatedActivity.Description__c, 'Activity\'s field was not updated');
        System.assertEquals(activity.Assigned_Member__c, user.Id, 'Activity\'s field Assigned Member was not updated');
    }

    /**
     * Just simple delete test
     */
    @isTest static void deleteActivities_positive() {
        CE_Activity__c activity = createActivity();
        Test.startTest();

        getService().deleteActivities(new List<CE_Activity__c> {activity});

        Test.stopTest();
        List<CE_Activity__c> activitiesFromDB = [SELECT Id FROM CE_Activity__c WHERE Id = :activity.Id];
        System.assertEquals(0, activitiesFromDB.size(), 'Activity was not deleted');

    }
    /**
     * Searches for Activities for the member user
     */
    @isTest static void getActivitiesForUser_positive_member() {
        //Creating the user for Publisher field for Activity and Story objects
        User user = CE_TestFactory.createUser();
        insert user;
        CE_Story__c story = CE_TestFactory.createStory();
        story.Publisher__c = user.Id;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        activity.Publisher__c = user.Id;
        insert activity;
        //Creating milestones, we need them to create MemberActivityMilestone for the user(member)
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        
        Test.startTest();

        List<CE_Activity__c> result = getService().getActivitiesForUser(new User(Id = user.Id));

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Activity was not found');
    }
    /**
     * Searches for Activities for the member user with no activities
     */
    @isTest static void getActivitiesForUser_negative_member() {
        //Creating the user for Publisher field for Activity and Story objects
        User user = CE_TestFactory.createUser();
        CE_Story__c story = CE_TestFactory.createStory();
        story.Publisher__c = user.Id;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        activity.Publisher__c = user.Id;
        insert activity;
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;

        Test.startTest();

        List<CE_Activity__c> result = getService().getActivitiesForUser(new User(Id = UserInfo.getUserId()));

        Test.stopTest();
        System.assertEquals(0, result.size(), 'Search must return no activities');

    }
    /**
     * Searches for Activities for the publisher user
     */
    @isTest static void getActivitiesForUser_positive_publisher() {
        CE_Activity__c activity = createActivity();

        Test.startTest();

        List<CE_Activity__c> result = getService().getActivitiesForUser(new User(Id = UserInfo.getUserId()));

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Activity was not found');
    }
    /**
     * Searches for Activities for the publisher user with no activities
     */
    @isTest static void getActivitiesForUser_negative_publisher() {
        User user = CE_TestFactory.createUser();
        insert user;
        CE_Activity__c activity = createActivity();

        Test.startTest();

        List<CE_Activity__c> result = getService().getActivitiesForUser(user);

        Test.stopTest();
        System.assertEquals(0, result.size(), 'Search must return no activities');


    }
    /**
     * Tests search by 2 Skills
     */
    @isTest static void search_positive() {
        CE_Activity__c activity = createActivity();
        CE_Skills__c dotNetSkill = CE_TestFactory.createSkill('.net');
        CE_Skills__c androidSkill = CE_TestFactory.createSkill('android');

        insert new List<CE_Skills__c> { dotNetSkill, androidSkill };

        insert new List<CE_ActivitySkills__c> { CE_TestFactory.createActivitySkill(activity, dotNetSkill), CE_TestFactory.createActivitySkill(activity, androidSkill)};

        Test.startTest();

        List<CE_Activity__c> result = getService().search(new List<CE_Skills__c> {dotNetSkill});
        System.assertEquals(1, result.size(), 'Search must return 1 activity for the .Net skill.');
        System.assertEquals(activity.Id, result[0].Id, 'Wrong activity was returned by search');

        result = getService().search(new List<CE_Skills__c> {androidSkill});
        System.assertEquals(1, result.size(), 'Search must return 1 activity for the Android skill.');
        System.assertEquals(activity.Id, result[0].Id, 'Wrong activity was returned by search');

        result = getService().search(new List<CE_Skills__c> {dotNetSkill, androidSkill});
        System.assertEquals(1, result.size(), 'Search must return 1 activity for Android and .Net skills.');
        System.assertEquals(activity.Id, result[0].Id, 'Wrong activity was returned by search');

        Test.stopTest();
    }
    /**
     * Tests search non existed skill
     */
    @isTest static void search_negative() {
        CE_Activity__c activity = createActivity();
        CE_Skills__c dotNetSkill = CE_TestFactory.createSkill('.net');
        CE_Skills__c androidSkill = CE_TestFactory.createSkill('android');
        insert new List<CE_Skills__c> {dotNetSkill, androidSkill};

        insert new List<CE_ActivitySkills__c> {CE_TestFactory.createActivitySkill(activity, dotNetSkill)};

        Test.startTest();

        List<CE_Activity__c>result = getService().search(new List<CE_Skills__c> {androidSkill});

        Test.stopTest();
        System.assertEquals(0, result.size(), 'Search must return no activities for the Android skill.');

    }
    
    /*
    	Test getActivity with activity assigned to as user
    */
    @isTest static void getActivitiesByActivityId() {
    	User user = CE_TestFactory.createUser();
        insert user;
        
        CE_Activity__c activity = createActivity();
		activity.Assigned_Member__c = user.Id;
		update activity;
		
        Test.startTest();

        CE_Activity__c result = getService().getActivity(activity.Id);

        Test.stopTest();
        System.assertEquals(user.Id, result.Assigned_Member__c);
    }
    
    /**
     * Just simple create test.
     */
    @isTest static void addAwards_positive() {
        CE_Activity__c activity = createActivity();
        CE_Award__c award = CE_TestFactory.createAward(activity);

        Test.startTest();

        List<CE_Award__c> result = getService().addAwards(new List<CE_Award__c> {award});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertNotEquals(null, result[0].Id, 'Seems like award was not created');
        System.assertEquals(award.CE_Activity__c, result[0].CE_Activity__c, 'Seems like wrong Award was returned');
        System.assertEquals(award.Payment__c, result[0].Payment__c, 'Seems like wrong Award was returned');

    }
    /**
     * Just simple update test.
     */
    @isTest static void updateAwards_positive() {
        CE_Activity__c activity = createActivity();
        CE_Award__c award = CE_TestFactory.createAward(activity);
        insert award;
        award.Payment__c = 333;
        Test.startTest();
        
        List<CE_Award__c> result = getService().updateAwards(new List<CE_Award__c> {award});

        Test.stopTest();
        System.assertEquals(1, result.size(), 'Size of the returned collection must be 1');
        System.assertEquals(award.CE_Activity__c, result[0].CE_Activity__c, 'Seems like wrong Award was returned');
        System.assertEquals(award.Payment__c, result[0].Payment__c, 'Seems like Award was not updated');
        CE_Award__c awardFromDB = [SELECT Payment__c FROM CE_Award__c WHERE Id = :award.Id LIMIT 1];
        System.assertEquals(award.Payment__c, awardFromDB.Payment__c, 'Seems like Award was not updated');

    }
    /**
     * Just simple delete test.
     */
    @isTest static void deleteAwards_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        CE_Award__c award = CE_TestFactory.createAward(activity);
        insert award;
        Test.startTest();

        getService().deleteAwards(new List<CE_Award__c> {award});

        Test.stopTest();
        List<CE_Award__c> awardsFromDB = [SELECT Payment__c FROM CE_Award__c WHERE Id = :award.Id];
        System.assertEquals(0, awardsFromDB.size(), 'Seems like Award was not deleted');

    }
    /**
     * Testing creating ActivityMilestones
     */
    @isTest static void setMilestones_positive() {
        CE_Activity__c activity = createActivity();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;

        Test.startTest();

        getService().setMilestones(milestones, activity);

        Test.stopTest();
        List<CE_ActivityMilestones__c> activityMilestonesFromDB = [SELECT CE_Milestone__c, CE_Activity__c FROM CE_ActivityMilestones__c];

        System.assertEquals(milestones.size(), activityMilestonesFromDB.size(), 'Seems like wrong number of ActivityMilestones were inserted');

        for (CE_ActivityMilestones__c activityMilestoneFromDB : activityMilestonesFromDB) {
            System.assertEquals(activity.Id, activityMilestoneFromDB.CE_Activity__c, 'ActivityMilestone has wrong Activity reference');

            Boolean milestoneWasFound = false;
            for (CE_Milestone__c milestone : milestones)
                if (milestone.Id == activityMilestoneFromDB.CE_Milestone__c) {
                    milestoneWasFound = true;
                }
            System.assert(milestoneWasFound, 'ActivityMilestone reference was not found in milestones');
        }
    }

    /**
     * Testing getting ActivityMilestones
     */
    @isTest static void getMilestones_positive() {
        CE_Activity__c activity = createActivity();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;

        Test.startTest();

        List<CE_Milestone__c> result = getService().getMilestones(activity);

        Test.stopTest();
        System.assertEquals(milestones.size(), result.size(), 'Seems like wrong number of ActivityMilestones were returned');
        Map<Id, CE_Milestone__c> milestonesMap = new Map<Id, CE_Milestone__c>(milestones);
        //Making sure that all needed milestones were found
        for (CE_Milestone__c milestone : result)
            milestonesMap.remove(milestone.Id);
        System.assertEquals(0, milestonesMap.size(), 'Returned milestones are different from initial data.');

    }
    /**
     * Tests inserting skills for an activity
     */
    @isTest static void addSkills_positive() {
        CE_Activity__c activity = createActivity();
        CE_Skills__c dotNetSkill = CE_TestFactory.createSkill('.net');
        CE_Skills__c androidSkill = CE_TestFactory.createSkill('android');

        insert new List<CE_Skills__c> { dotNetSkill, androidSkill };


        Test.startTest();

        getService().addSkills(new List<CE_Skills__c> {dotNetSkill, androidSkill}, activity);

        Test.stopTest();
        List<CE_ActivitySkills__c> skillsFromDB = [SELECT Skill__c FROM CE_ActivitySkills__c WHERE CE_Activity__c = :activity.Id];
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
        CE_Activity__c activity = createActivity();
        CE_Skills__c dotNetSkill = CE_TestFactory.createSkill('.net');
        CE_Skills__c androidSkill = CE_TestFactory.createSkill('android');

        insert new List<CE_Skills__c> { dotNetSkill, androidSkill };
        insert new List<CE_ActivitySkills__c> {CE_TestFactory.createActivitySkill(activity, dotNetSkill)};

        Test.startTest();

        getService().deleteSkills(new List<CE_Skills__c> {dotNetSkill, androidSkill}, activity);

        Test.stopTest();
        List<CE_ActivitySkills__c> skillsFromDB = [SELECT Skill__c FROM CE_ActivitySkills__c WHERE CE_Activity__c = :activity.Id];
        System.assertEquals(0, skillsFromDB.size(), 'There must be no skills for the activity in DB');

    }
    /**
     * Tests getting skills for an activity
     */
    @isTest static void getSkills_positive() {
        CE_Activity__c activity = createActivity();
        CE_Skills__c dotNetSkill = CE_TestFactory.createSkill('.net');
        CE_Skills__c androidSkill = CE_TestFactory.createSkill('android');

        insert new List<CE_Skills__c> { dotNetSkill, androidSkill };
        insert new List<CE_ActivitySkills__c> { CE_TestFactory.createActivitySkill(activity, dotNetSkill), CE_TestFactory.createActivitySkill(activity, androidSkill)};

        Test.startTest();

        List<CE_Skills__c> result = getService().getSkills(activity);

        Test.stopTest();
        System.assertEquals(2, result.size(), 'Seems like wrong number of skills was returned');
        Map<Id, CE_Skills__c> resultMap = new Map<Id, CE_Skills__c>(result);
        resultMap.remove(dotNetSkill.Id);
        System.assertEquals(1, resultMap.size(), 'Seems like result does not contain .Net skill');
        resultMap.remove(androidSkill.Id);
        System.assertEquals(0, resultMap.size(), 'Seems like result does not contain Android skill');

    }
    /**
     * Getting requirements test
     */
    @isTest static void getRequirements_positive() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        Test.startTest();

        List<CE_Requirement__c> result = getService().getRequirements(activity);

        Test.stopTest();
        System.assertEquals(requirements.size(), result.size(), 'Seems like wrong number of requirements was returned');
        Map<Id, CE_Requirement__c> resultMap = new Map<Id, CE_Requirement__c>(result);
        for (CE_Requirement__c requirement : requirements)
            resultMap.remove(requirement.Id);
        System.assertEquals(0, resultMap.size(), 'Seems like different collection of requirements was returned');
    }
    /**
     * Adding requirements test
     */
    @isTest static void addRequirements_positive() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        Integer dayIndex = 0;
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today().addDays(dayIndex++)));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));

        Test.startTest();

        List<CE_Requirement__c> result = getService().addRequirements(requirements);

        Test.stopTest();
        System.assertEquals(requirements.size(), result.size(), 'Seems like wrong number of requirements was returned');
        for (CE_Requirement__c requirement : result) {
            System.assertNotEquals(null, requirement.Id, 'Requirements was not inserted');
        }
    }
    /**
     * Adding requirements test with fail because Submission is closed
     */
    @isTest static void addRequirements_negative() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        
        insert milestones;

        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        Boolean operationFailed = false;
        Test.startTest();
        
        try {
            List<CE_Requirement__c> result = getService().addRequirements(requirements);
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
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        Integer dayIndex = 0;
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today().addDays(dayIndex++)));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        for (CE_Requirement__c requirement : requirements)
            requirement.Requirement_Weight__c = 'Low';
        Test.startTest();

        Map<Id, CE_Requirement__c> resultMap = new Map<Id, CE_Requirement__c>(getService().updateRequirement(requirements));
    
        Test.stopTest();
        System.assertEquals(requirements.size(), resultMap.size(), 'Seems like wrong number of requirements was returned');
        List<CE_Requirement__c> resultFromDB = [SELECT Requirement_Weight__c FROM CE_Requirement__c WHERe Id IN :resultMap.keySet()];
        for (CE_Requirement__c requirement : resultFromDB)
            System.assertEquals('Low', requirement.Requirement_Weight__c, 'Seems like Requirements was not updated');

    }
    /**
     * Deleting requirements test
     */
    @isTest static void deleteRequirements_positive() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        Integer dayIndex = 0;
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today().addDays(dayIndex++)));
        insert activityMilestones;
        //Creating default requirements
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        Map<Id, CE_Requirement__c> requirementsMap = new Map<Id, CE_Requirement__c>(requirements);
        Test.startTest();

        getService().deleteRequirements(requirements);

        Test.stopTest();
        List<CE_Requirement__c> resultFromDB = [SELECT Id FROM CE_Requirement__c WHERe Id IN :requirementsMap.keySet()];
        System.assertEquals(0, resultFromDB.size(), 'Must be no Requirements in DB');
    }
    /**
     * Getting default requirements test
     */
    @isTest static void getDefaultRequirements_positive() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        Test.startTest();

        List<CE_Default_Requirement__c> result = getService().getDefaultRequirements();

        Test.stopTest();

        System.assertEquals(defaultRequirements.size(), result.size(), 'Seems like wrong number of default requirements was returned');
        Map<Id, CE_Default_Requirement__c> resultMap = new Map<Id, CE_Default_Requirement__c>(result);
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            resultMap.remove(defaultRequirement.Id);
        System.assertEquals(0, resultMap.size(), 'Seems like different collection of Default Requirements was returned');
    }
    /**
     * Checking that activity is unlocked
     */
    @isTest static void isLocked_positive() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        Integer dayIndex = 0;
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today().addDays(dayIndex++)));
        insert activityMilestones;
        Test.startTest();

        System.assertEquals(false, getService().isLocked(activity), 'Activity must be unlocked');

        Test.stopTest();
    }
    /**
     * Checking that activity is locked
     */
    @isTest static void isLocked_negative() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
       
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        Test.startTest();

        System.assertEquals(true, getService().isLocked(activity), 'Activity must be locked');

        Test.stopTest();
    }
    /**
     * Checking that activity is unlocked. Fails because there is no Milestones in DB
     */
    @isTest static void isLocked_negative_noMilestones() {
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
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
        CE_Activity__c activity = createActivity();
        List<CE_Default_Requirement__c> defaultRequirements = CE_TestFactory.createDefaultRequirements();
        insert defaultRequirements;
        List<CE_Requirement__c> requirements = new List<CE_Requirement__c>();
        for (CE_Default_Requirement__c defaultRequirement : defaultRequirements)
            requirements.add(CE_TestFactory.createRequirement(activity, defaultRequirement));
        insert requirements;
        //Creating milestones
        List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
        insert milestones;
        List<CE_ActivityMilestones__c> activityMilestones = new List<CE_ActivityMilestones__c>();
        for (CE_Milestone__c milestone : milestones)
            activityMilestones.add(CE_TestFactory.createActivityMilestone(activity, milestone, Date.today()));
        insert activityMilestones;
        CE_Award__c award = CE_TestFactory.createAward(activity);
        insert award;
        Test.startTest();

            CE_Activity__c newActivity = getService().cloneActivity(activity);

        Test.stopTest();
        System.assertNotEquals(activity.Id, newActivity.Id,'Seems like activity was not cloned');
        System.assertNotEquals(null, newActivity.Id,'Seems like cloned activity was not inserted');
        List<CE_ActivityMilestones__c> newActivityMilestones = [SELECT Id FROM CE_ActivityMilestones__c WHERE CE_Activity__c = :newActivity.Id];
        System.assertEquals(activityMilestones.size(), newActivityMilestones.size(), 'Seems like not all Activity Milestones were cloned');
        List<CE_Requirement__c> newActivityRequirements = [SELECT Id FROM CE_Requirement__c WHERE CE_Activity__c = :newActivity.Id];
        System.assertEquals(newActivityRequirements.size(), newActivityRequirements.size(), 'Seems like not all Activity Requirements were cloned');
        List<CE_Award__c> newActivityAwards = [SELECT Id FROM CE_Award__c WHERE CE_Activity__c = :newActivity.Id];
        System.assertEquals(newActivityAwards.size(), newActivityAwards.size(), 'Seems like not all Activity Awards were cloned');
    }
    
    /**
     * Test registering a member to an activity.
     * Added against TC30050600 
     */
    @isTest static void registerMember_positive() {
        CE_Activity__c activity = createActivity();
        User user = CE_TestFactory.createUser();
        insert user;
        Test.startTest();

        getService().registerMember(user.Id, activity);
    
        Test.stopTest();

        List<CE_Registration__c> results = [SELECT  Name, CE_Activity__c, Registration_Date__c, User__c FROM CE_Registration__c WHERE CE_Activity__c = :activity.Id];
        
        System.assertEquals(1, results.size(), 'There one Registration corresponding to given activity');
		System.assertEquals(user.Id, results[0].User__c);
    }
    
    /**
     * Test getRegistrations method.
     * Added against TC30050600 
     */
    @isTest static void getRegistrations_positive() {
        CE_Activity__c activity = createActivity();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // Creating a register member record 
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        Test.startTest();

        List<CE_Registration__c> results = getService().getRegistrations(activity);
    
        Test.stopTest();
        System.assertEquals(1, results.size(), 'There one Registration corresponding to given activity');
    }
    
    /**
     * Test deregisterMember method.
     * Added against TC30050600 
     */
    @isTest static void deregisterMemberTest() {
        CE_Activity__c activity = createActivity();
        User user = CE_TestFactory.createUser();
        insert user;
        
        // Creating a register member record 
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(user.Id, activity);
        insert registration;
        
        Test.startTest();
		
        getService().deregisterMember(registration.Id);
    
        Test.stopTest();
        List<CE_Registration__c> results = [SELECT  Name FROM CE_Registration__c WHERE CE_Activity__c = :activity.Id];
        System.assertEquals(0, results.size(), 'There should be no Registrations corresponding to given activity');
        
    }
}