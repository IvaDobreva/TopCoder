@isTest
private class CrowdExchangeRemoteControllerTest {

    private static WebAppModels.StoryRequest createStoryRequest(){
        WebAppModels.StoryRequest request = new WebAppModels.StoryRequest();
        request.filter = new WebAppModels.StoryFilter();
        request.page = 1;
        request.pageSize = 10;
        return request;
    }
    /**
     * get stories with 'positive' filter
     */
	@isTest static void getStories_positive() {
		WebAppModels.StoryRequest request = createStoryRequest();
        request.filter.storyTitle = 'Test';
        Story__c story = TestFactory.createFullStory();
        story.Status__c = Constants.STATUS_IN_REGISTRATION;
        update story;
        List<Activity__c> activities = [SELECT Status__c FROM Activity__c];
        activities[0].Status__c = Constants.STATUS_PUBLIC;
        update activities;
        Test.startTest();
            WebAppModels.StoryResponse response = CrowdExchangeRemoteController.getStories(request);
            System.assertEquals(1,response.stories.size());
            System.assertEquals(1,response.totalItems);
            System.assertEquals(1,response.totalPages);
        Test.stopTest();
	}
    /**
     * fetch stories with unreal filter
     */
    @isTest static void getStories_negative() {
        WebAppModels.StoryRequest request = createStoryRequest();
        request.filter.storyTitle = 'unknown';
        request.filter.activityTitle = 'unknown';
        request.filter.serviceOffering = 'unknown';
        request.filter.activityPhase = 'unknown';
        request.filter.showOnlyCompleted = true;
        Story__c story = TestFactory.createFullStory();
        update story;
        Test.startTest();
            WebAppModels.StoryResponse response = CrowdExchangeRemoteController.getStories(request);
            System.assertEquals(0,response.stories.size());
            System.assertEquals(0,response.totalItems);
            System.assertEquals(1,response.totalPages);
        Test.stopTest();
    }
	/**
     * fetch story by id
     */
    @isTest static void getStory_positive() {
        Story__c story = TestFactory.createFullStory();
        Test.startTest();
            WebAppModels.Story response = CrowdExchangeRemoteController.getStory(story.Id,true);
            System.assertNotEquals(null,response);
            System.assertEquals(story.Id,response.id);
        Test.stopTest();
    }
    /**
     * fetch story by id = null
     */
    @isTest static void getStory_negative() {
        Story__c story = TestFactory.createFullStory();
        Test.startTest();
            WebAppModels.Story response = CrowdExchangeRemoteController.getStory(null,true);
            System.assertEquals(null,response);
            response = CrowdExchangeRemoteController.getStory('',true);
            System.assertEquals(null,response);
        Test.stopTest();
    }
    /**
     * fetch activity by id
     */
    @isTest static void getActivity_positive() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Test.startTest();
            WebAppModels.Activity response = CrowdExchangeRemoteController.getActivity(activity.Id);
            System.assertNotEquals(null,response);
            System.assertEquals(activity.Id,response.id);
        Test.stopTest();
    }
    /**
     * delete document(Attachment)
     */
    @isTest static void deleteDocument_positive() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        insert activity;
        Attachment att = TestFactory.createAttachment();
        att.ParentId = activity.Id;
        insert att;
        Test.startTest();
            CrowdExchangeRemoteController.deleteDocument(att.Id);
            List<Attachment> atts = [SELECT Id FROM Attachment];
            System.assertEquals(0,atts.size());
        Test.stopTest();
    }
    /**
     * upserting story
     */
    @isTest static void upsertStory_positive() {
        Story__c story = TestFactory.createStory();
        insert story;
        WebAppModels.Story dto = new WebAppModels.Story(story);
        dto.description = 'descr';
        Test.startTest();
            //test updata
            CrowdExchangeRemoteController.upsertStory(dto);
            List<Story__c> stories = [SELECT Id,Description__c FROM Story__c];
            System.assertEquals(1,stories.size());
            System.assertEquals('descr',stories[0].Description__c);
            //test insert
            dto.id = null;
            CrowdExchangeRemoteController.upsertStory(dto);
            stories = [SELECT Id,Description__c FROM Story__c];
            System.assertEquals(2,stories.size());
        Test.stopTest();
    }
    /**
     * upsert activity - update
     */
    @isTest static void upsertActivity_positive() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Attachment att = TestFactory.createAttachment();
        att.ParentId = activity.Id;
        insert att;
        activity = Database.query('SELECT '+CrowdExchangeRemoteController.ACTIVITY_FULL_FIELDS+' FROM Activity__c');
        WebAppModels.Activity dto = new WebAppModels.Activity(activity);
        dto.description = 'descr';
        Test.startTest();
            //test updata
            CrowdExchangeRemoteController.upsertActivity(dto);
        Test.stopTest();
        activity = [SELECT Description__c FROM Activity__c WHERE Id = :activity.Id];
        System.assertEquals('descr',activity.Description__c);
    }
    /**
     * upsert activity - insert
     */
    @isTest static void upsertActivity_positive_insert() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Attachment att = TestFactory.createAttachment();
        att.ParentId = activity.Id;
        insert att;
        activity = Database.query('SELECT '+CrowdExchangeRemoteController.ACTIVITY_FULL_FIELDS+' FROM Activity__c');
        WebAppModels.Activity dto = new WebAppModels.Activity(activity);
        //cleaning old values
        dto.id = null;
        for(WebAppModels.CodeType codeType : dto.codeTypes)
            codeType.id = null;
        for(WebAppModels.ActivityRequirement req : dto.requirements)
            req.id = null;
        dto.requirements[0].childRequirements.add(dto.requirements[1]);
        dto.requirements.remove(1);
        dto.noPrizes = false;
        dto.prizes.add(new WebAppModels.Prize(new Award__c(Place__c = 1, Payment__c = 500)));
        dto.storyId = story.Id;
        Test.startTest();
            //test updata
            CrowdExchangeRemoteController.upsertActivity(dto);
            //Ensure that activity was created, otherwise throws the exception
            activity = [SELECT Id FROM Activity__c WHERE Id != :activity.Id LIMIT 1];

        Test.stopTest();
    }
    /**
     * register to activity
     */
    @isTest static void registerToActivity() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        activity.Status__c = Constants.STATUS_IN_REGISTRATION;
        update activity;
        Test.startTest();
            CrowdExchangeRemoteController.registerToActivity(activity.Id);
            try{
                CrowdExchangeRemoteController.registerToActivity(null);
                System.assert(false); // Never reached
            }catch(CrowdExchangeRemoteController.WebAppException ex){
                System.assert(true);
            }
            //No need in assertions due to thelogic is in ActivityService
        Test.stopTest();
    }
    /**
     * cancel activity
     */
    @isTest static void cancelActivity() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Test.startTest();
            CrowdExchangeRemoteController.cancelActivity(activity.Id);
            try{
                CrowdExchangeRemoteController.cancelActivity(null);
                System.assert(false); // Never reached
            }catch(CrowdExchangeRemoteController.WebAppException ex){
                System.assert(true);
            }
            //No need in assertions due to thelogic is in ActivityService
        Test.stopTest();
    }
    /**
     * delete activity
     */
    @isTest static void deleteActivity() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Test.startTest();
            CrowdExchangeRemoteController.deleteActivity(activity.Id);
            //No need in assertions due to thelogic is in ActivityService
        Test.stopTest();
        System.assertEquals(0,([SELECT Id FROM Activity__c]).size());
    }
    /**
     * complete activity
     */
    @isTest static void completeActivity() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Test.startTest();
            CrowdExchangeRemoteController.completeActivity(activity.Id);
            activity = [SELECT Status__c FROM Activity__c];
            System.assertEquals(Constants.STATUS_COMPLETE,activity.Status__c);
            try{
                CrowdExchangeRemoteController.completeActivity(null);
                System.assert(false); // Never reached
            }catch(CrowdExchangeRemoteController.WebAppException ex){
                System.assert(true);
            }
        Test.stopTest();
    }
    /**
     * complete activity
     */
    @isTest static void cancelStory() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Test.startTest();
            CrowdExchangeRemoteController.cancelStory(story.Id);
            story = [SELECT Status__c FROM Story__c];
            System.assertEquals(Constants.STATUS_CANCELED,story.Status__c);
            try{
                CrowdExchangeRemoteController.cancelStory(null);
                System.assert(false); // Never reached
            }catch(CrowdExchangeRemoteController.WebAppException ex){
                System.assert(true);
            }
        Test.stopTest();
    }
    /**
     * sending email. w/ and w/o null input
     */
    @isTest static void emailToMember() {

        Test.startTest();
            CrowdExchangeRemoteController.emailToMember(new List<Id>{UserInfo.getUserId()});
            try{
                CrowdExchangeRemoteController.emailToMember(null);
                System.assert(false); // Never reached
            }catch(CrowdExchangeRemoteController.WebAppException ex){
                System.assert(true);
            }
            try{
                CrowdExchangeRemoteController.emailToMember(new List<String>());
                System.assert(false); // Never reached
            }catch(CrowdExchangeRemoteController.WebAppException ex){
                System.assert(true);
            }
        Test.stopTest();
    }
    /**
     * assagning member to activity
     */
    @isTest static void assignMember() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        Test.startTest();
            WebAppModels.ActivityRegitration result = CrowdExchangeRemoteController.assignMember(activity.Id,UserInfo.getUserId());
        Test.stopTest();
        activity = [SELECT Assigned_Member__c FROM Activity__c];
        System.assertEquals(UserInfo.getUserId(), activity.Assigned_Member__c);
        System.assertEquals(UserInfo.getUserId(), result.user.id);
    }
    /**
     * unassagning member to activity
     */
    @isTest static void unassignMember() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        activity.Assigned_Member__c = UserInfo.getUserId();
        update activity;
        Test.startTest();
            CrowdExchangeRemoteController.unassignMember(activity.Id);
        Test.stopTest();
        activity = [SELECT Assigned_Member__c FROM Activity__c];
        System.assertEquals(null, activity.Assigned_Member__c);
    }
    /**
     * Fetch assign member registration
     */
    @isTest static void getAssignedMember() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        activity.Assigned_Member__c = UserInfo.getUserId();
        update activity;
        Test.startTest();
            WebAppModels.ActivityRegitration result = CrowdExchangeRemoteController.getAssignedMember(activity.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.user);
        System.assertEquals(UserInfo.getUserId(), result.user.id);
    }
    /**
     * getting default skills
     */
    @isTest static void getDefaultSkills() {
        Skills__c skill = TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        Test.startTest();
             List<WebAppModels.CodeType> result = CrowdExchangeRemoteController.getDefaultSkills();
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(skill.Id, result[0].skillId);
    }
    /**
     * getting recommended members for Activity
     */
    @isTest static void getRecommendedMembers() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Skills__c skill = [SELECT Id FROM Skills__c LIMIT 1];
        insert new UserSkill__c(Skill__c = skill.Id, Member__c = UserInfo.getUserId());
        Test.startTest();
            List<WebAppModels.UserModel> result = CrowdExchangeRemoteController.getRecommendedMembers(activity.Id);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(UserInfo.getUserId(), result[0].id);
    }
    /**
     * getting registered members for Activity
     */
    @isTest static void getRegistrants() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        Test.startTest();
            List<WebAppModels.ActivityRegitration>  result = CrowdExchangeRemoteController.getRegistrants(activity.Id,1,10);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(registration.id, result[0].id);
        System.assertEquals(UserInfo.getUserId(), result[0].user.id);
    }
    /**
     * creates basic activity;
     */
    @isTest static void createActivity() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createActivity(story);
        activity.Publisher__c = null;
        WebAppModels.Activity dto = new WebAppModels.Activity(activity);
        dto.storyId = story.Id;
        Test.startTest();
            WebAppModels.Activity result = CrowdExchangeRemoteController.createActivity(dto);
        Test.stopTest();
        activity = [SELECT Id FROM Activity__c];
        System.assertEquals(activity.Id, result.id);
    }
}