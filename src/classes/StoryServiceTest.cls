@isTest
private class StoryServiceTest {
	static IStoryService mService = null;
	static IStoryService getService() {
		if (mService == null)
			mService = new StoryService();
		return mService;
	}

	@isTest static void createStories_positive() {
		//Init data
		Story__c story = TestFactory.createStory();
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().createStories(new List<Story__c> {story});

		Test.stopTest();
		//Start assertion
		System.assertEquals(1, result.size(), 'Seems like method returned wrond collection size');
		System.assertNotEquals(null, result[0].Id, 'Seems like Story was not inserted');
	}
	@isTest static void updateStories_positive() {
		//Init data
		Story__c story = TestFactory.createStory();
		insert story;
		story.Description__c = 'TestDesctiption';
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().updateStories(new List<Story__c> {story});

		Test.stopTest();
		//Start assertion
		System.assertEquals(1, result.size(), 'Seems like method returned wrond collection size');
		Story__c updatedStoryFromDB = [SELECT Description__c FROM Story__c WHERE Id = :story.Id];
		System.assertEquals(story.Description__c, updatedStoryFromDB.Description__c, 'Seems like story was not updated');
	}

	@isTest static void getMostRecentlyCreatedStories_positive() {
		//Init data
		List<Story__c> stories = new List<Story__c>();
		for (Integer i = 0 ; i < 20; i++)
			stories.add(TestFactory.createStory());
		insert stories;
		//Start testing
		Test.startTest();
		List<Story__c> result = getService().getMostRecentlyCreatedStories();
		Test.stopTest();
		//Start assertion
		System.assertEquals(StoryService.DEFAULT_RECENT_STORIES_COUNT, result.size(), 'Seems like method returned wrong collection(size)');

	}
	@isTest static void getActivities_positive() {
		//Init data
		Story__c story = TestFactory.createStory();
		insert story;
		Activity__c activity = TestFactory.createActivity(story);
		insert activity;
		//Start testing
		Test.startTest();

		List<Activity__c> result = getService().getActivities(story);

		Test.stopTest();
		System.assertEquals(1, result.size(), 'Seems like method returned wrond collection size');
		System.assertEquals(result[0].Id, activity.Id, 'Seems like method returned wron activity');
	}
	@isTest static void getActivities_negative() {
		//Init data
		Story__c story = TestFactory.createStory();
		Story__c story2 = TestFactory.createStory();
		insert new List<Story__c> {story, story2};
		Activity__c activity2 = TestFactory.createActivity(story2);
		insert activity2;
		//Start testing
		Test.startTest();

		List<Activity__c> result = getService().getActivities(story);

		Test.stopTest();
		//Start assertion
		System.assertEquals(0, result.size(), 'Method must return no Activities');
	}
	/**
	 * Tests search by 2 Skills
	 */
	@isTest static void search_positive() {
		//Init data
		Story__c story = TestFactory.createStory();
		insert story;
		Activity__c activity = TestFactory.createActivity(story);
		insert activity;
		Skills__c dotNetSkill = TestFactory.createSkill('.net');
		Skills__c androidSkill = TestFactory.createSkill('android');

		insert new List<Skills__c> { dotNetSkill, androidSkill };

		insert new List<ActivitySkills__c> { TestFactory.createActivitySkill(activity, dotNetSkill), TestFactory.createActivitySkill(activity, androidSkill)};
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().search(new List<Skills__c> {dotNetSkill});
		System.assertEquals(1, result.size(), 'Search must return 1 activity for the .Net skill.');
		System.assertEquals(story.Id, result[0].Id, 'Wrong story was returned by search');

		result = getService().search(new List<Skills__c> {androidSkill});
		System.assertEquals(1, result.size(), 'Search must return 1 story for the Android skill.');
		System.assertEquals(story.Id, result[0].Id, 'Wrong story was returned by search');

		result = getService().search(new List<Skills__c> {dotNetSkill, androidSkill});
		System.assertEquals(1, result.size(), 'Search must return 1 story for Android and .Net skills.');
		System.assertEquals(story.Id, result[0].Id, 'Wrong story was returned by search');

		Test.stopTest();
	}
	/**
	 * Tests search non existed skill
	 */
	@isTest static void search_negative() {
		//Init data
		Story__c story = TestFactory.createStory();
		insert story;
		Activity__c activity = TestFactory.createActivity(story);
		insert activity;
		Skills__c dotNetSkill = TestFactory.createSkill('.net');
		Skills__c androidSkill = TestFactory.createSkill('android');
		insert new List<Skills__c> {dotNetSkill, androidSkill};

		insert new List<ActivitySkills__c> {TestFactory.createActivitySkill(activity, dotNetSkill)};
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().search(new List<Skills__c> {androidSkill});

		Test.stopTest();
		//Start assertion
		System.assertEquals(0, result.size(), 'Search must return no stiries for the Android skill.');

	}
	/**
	 * Searches for Stories for the member user
	 */
	@isTest static void getActivitiesForUser_positive_member() {
		//Init data
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
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().getStoriesForUser(new User(Id = UserInfo.getUserId()));

		Test.stopTest();
		//Start assertion
		System.assertEquals(1, result.size(), 'Story was not found');
	}
	/**
	 * Searches for Stories for the member user with no activities
	 */
	@isTest static void getActivitiesForUser_negative_member() {
		//Init data
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
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().getStoriesForUser(new User(Id = UserInfo.getUserId()));

		Test.stopTest();
		//Start assertion
		System.assertEquals(0, result.size(), 'Search must return no stories');

	}
	/**
	 * Searches for Stories for the publisher user
	 */
	@isTest static void getActivitiesForUser_positive_publisher() {
		//Init data
		Story__c story = TestFactory.createStory();
		insert story;
		Activity__c activity = TestFactory.createActivity(story);
		insert activity;
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().getStoriesForUser(new User(Id = UserInfo.getUserId()));

		Test.stopTest();
		//Start assertion
		System.assertEquals(1, result.size(), 'Story was not found');
	}
	/**
	 * Searches for Stories for the publisher user with no Stories
	 */
	@isTest static void getActivitiesForUser_negative_publisher() {
		//Init data
		User user = TestFactory.createUser();
		insert user;
		Story__c story = TestFactory.createStory();
		insert story;
		Activity__c activity = TestFactory.createActivity(story);
		insert activity;
		//Start testing
		Test.startTest();

		List<Story__c> result = getService().getStoriesForUser(user);

		Test.stopTest();
		//Start assertion
		System.assertEquals(0, result.size(), 'Search must return no stories');


	}
}