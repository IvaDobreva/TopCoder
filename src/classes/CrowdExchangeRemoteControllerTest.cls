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
        story.Status__c = 'In Progress';
        update story;
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
    
        /**
     * gets current user's unread notifications count
     */
    @isTest static void getUnreadNotificationsCount() {
        User usr = TestFactory.createUser();
        insert usr;
        Notification__c notification = TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            Integer result = CrowdExchangeRemoteController.getUnreadNotificationsCount();
            System.assertEquals(1, result);
            User_Notification__c userNotification = [SELECT Status__c FROM User_Notification__c LIMIT 1];
            userNotification.Status__c = Constants.NOTIFICATION_READ;
            update userNotification;
            result = CrowdExchangeRemoteController.getUnreadNotificationsCount();
            System.assertEquals(0, result);
        Test.stopTest();
    }
    /**
     * gets current user's inbox notifications
     */
    @isTest static void getInboxNotifications() {
        User usr = TestFactory.createUser();
        insert usr;
        Notification__c notification = TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            WebAppModels.NotificationsResponse result = CrowdExchangeRemoteController.getInboxNotifications(1, 10);
            System.assertEquals(1, result.totalItems);
            System.assertEquals(1, result.notifications.size());
            System.assertEquals(notification.Id, result.notifications[0].id);
        Test.stopTest();
    }
    /**
     * gets notifications sent by current user
     */
    @isTest static void getOutboxNotifications() {
        User usr = TestFactory.createUser();
        insert usr;
        Notification__c notification = TestFactory.createOutboundNotification(usr.id);
        Test.startTest();
            WebAppModels.NotificationsResponse result = CrowdExchangeRemoteController.getOutboxNotifications(1, 10);
            System.assertEquals(1, result.totalItems);
            System.assertEquals(1, result.notifications.size());
            System.assertEquals(notification.Id, result.notifications[0].id);
        Test.stopTest();
    }
    /**
     * mark inbox notification as Read
     */
    @isTest static void markNotificationAsRead() {
        User usr = TestFactory.createUser();
        insert usr;
        Notification__c notification = TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            Boolean result = CrowdExchangeRemoteController.markNotificationAsRead(notification.Id);
        Test.stopTest();
        System.assert(result);
        User_Notification__c userNotification = [SELECT Status__c FROM User_Notification__c LIMIT 1];
        System.assertEquals(Constants.NOTIFICATION_READ, userNotification.Status__c);
    }
    /**
     * archives inbox notification
     */
    @isTest static void archiveNotification_recipient() {
        User usr = TestFactory.createUser();
        insert usr;
        Notification__c notification = TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            CrowdExchangeRemoteController.archiveNotification(notification.Id);
        Test.stopTest();
        User_Notification__c userNotification = [SELECT IsArchived__c FROM User_Notification__c LIMIT 1];
        System.assert(userNotification.IsArchived__c,'Seems like notification wasn\'t archived');
    }
    /**
     * archives sent notification
     */
    @isTest static void archiveNotification_sender() {
        User usr = TestFactory.createUser();
        insert usr;
        Notification__c notification = TestFactory.createOutboundNotification(usr.id);
        Test.startTest();
            CrowdExchangeRemoteController.archiveNotification(notification.Id);
        Test.stopTest();
        notification = [SELECT IsArchivedBySender__c FROM Notification__c LIMIT 1];
        System.assert(notification.IsArchivedBySender__c,'Seems like notification wasn\'t archived');
    }
    /**
     * searches stories
     */
    @isTest static void searchStories() {
        //Creating stories request
        WebAppModels.StoriesSeachRequest request = new WebAppModels.StoriesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        Story__c story = TestFactory.createFullStory();
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        update story;

        Test.startTest();
            WebAppModels.StoriesSearchResponse result = CrowdExchangeRemoteController.searchStories(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.stories.size());
        System.assertEquals(story.Id, result.stories[0].id);
    }
    /**
     * searches stories with filter
     */
    @isTest static void searchStories_filtered() {
        Story__c story = TestFactory.createFullStory();
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        update story;
        //Creating stories request
        WebAppModels.StoriesSeachFilter filter = new WebAppModels.StoriesSeachFilter();
        filter.title = story.Name;
        filter.serviceOffering = story.Service_Offering__c;
        filter.status = story.Status__c;
        //Creating stories filter
        WebAppModels.StoriesSeachRequest request = new WebAppModels.StoriesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        request.filter = filter;
        
        Test.startTest();
            WebAppModels.StoriesSearchResponse result = CrowdExchangeRemoteController.searchStories(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.stories.size());
        System.assertEquals(story.Id, result.stories[0].id);
    }
    /**
     * searches activities
     */
    @isTest static void searchActivities() {
        //Creating activities request
        WebAppModels.ActivitiesSeachRequest request = new WebAppModels.ActivitiesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        Story__c story = TestFactory.createStory();
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        activity.Status__c = Constants.STATUS_PUBLIC;
        update activity;
        Test.startTest();
            WebAppModels.ActivitiesSearchResponse result = CrowdExchangeRemoteController.searchActivities(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.activities.size());
        System.assertEquals(activity.Id, result.activities[0].id);
    }
    /**
     * searches activities with filter
     */
    @isTest static void searchActivities_filtered() {
        Story__c story = TestFactory.createStory();
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        activity.Status__c = Constants.STATUS_PUBLIC;
        update activity;
        //Creating activities filter
        WebAppModels.ActivitiesSeachFilter filter = new WebAppModels.ActivitiesSeachFilter();
        filter.title = activity.Name;
        filter.challengeType = activity.Challenge_Type__c;
        filter.phase = activity.Status__c;
        //Creating activities request
        WebAppModels.ActivitiesSeachRequest request = new WebAppModels.ActivitiesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        request.filter = filter;
        
        Test.startTest();
            WebAppModels.ActivitiesSearchResponse result = CrowdExchangeRemoteController.searchActivities(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.activities.size());
        System.assertEquals(activity.Id, result.activities[0].id);
    }
    /**
     * searches members
     */
    @isTest static void searchMembers() {
        User member = TestFactory.createMember();
        member.FirstName = 'UnbelievablyCreatedFirstName';
        update member;
        //Creating members request
        WebAppModels.MembersSearchRequest request = new WebAppModels.MembersSearchRequest();
        // need to do this hack because users with name "test" can be in the system
        request.query = member.FirstName; 
        request.page = 1;
        request.pageSize = 10;

        Test.startTest();
            WebAppModels.MembersSearchResponse result = CrowdExchangeRemoteController.searchMembers(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.members.size());
        System.assertEquals(member.Id, result.members[0].id);
    }
    /**
     * searches activities with filter
     */
    @isTest static void searchMembers_filtered() {
        User member = TestFactory.createMember();
        member.FirstName = 'UnbelievablyCreatedFirstName';
        update member;
        //Creating members request
        WebAppModels.MembersSearchRequest request = new WebAppModels.MembersSearchRequest();
        // need to do this hack because users with name "test" can be in the system
        request.query = 'unbelievablyCrea';
        request.page = 1;
        request.pageSize = 10;
        //Creating members filter
        WebAppModels.MembersSearchFilter filter = new WebAppModels.MembersSearchFilter();
        filter.firstName = member.FirstName;
        filter.lastName = member.LastName;
        filter.role = member.Crowd_Exchange_User_Type__c;
        filter.organization = member.Crowd_Exchange_Organization__c;
        request.filter = filter;
        
        Test.startTest();
            WebAppModels.MembersSearchResponse result = CrowdExchangeRemoteController.searchMembers(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.members.size());
        System.assertEquals(member.Id, result.members[0].id);
    }
    /**
     * searches "All Records" as a publisher
     */
    @isTest static void searchMembers_publisher() {
        String name = 'UnbelievablyCreatedFirstName';//Just some not existing name
        //Creating all records request
        WebAppModels.PaginatedSearchRequest request = new WebAppModels.PaginatedSearchRequest();
        request.query = 'elievablyCreatedFir';
        request.page = 1;
        request.pageSize = 10;
        //Creating initial records
        User member = TestFactory.createMember();
        member.FirstName = name;
        Story__c story = TestFactory.createStory();
        story.Name = name;
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        activity.Name = name;
        activity.Status__c = Constants.STATUS_PUBLIC;
        update new List<sObject>{member, activity};
        Test.startTest();
            WebAppModels.AllRecordsSearchResponse result = CrowdExchangeRemoteController.search(request);
        Test.stopTest();
        System.assertEquals(3, result.totalItems,'Not all records were fetched in count query');
        System.assertEquals(3, result.records.size(),'Not all records were returned');
        System.assertEquals(story.Id, ((WebAppModels.Story)result.records[2].item).id);
        System.assertEquals(activity.Id, ((WebAppModels.Activity)result.records[1].item).id);
        System.assertEquals(member.Id, ((WebAppModels.UserModel)result.records[0].item).id);
    }
    /**
     * searches "All Records" as a member
     */
    @isTest static void searchMembers_member() {
        String name = 'UnbelievablyCreatedFirstName';//Just some not existing name
        //Creating all records request
        WebAppModels.PaginatedSearchRequest request = new WebAppModels.PaginatedSearchRequest();
        request.query = 'elievablyCreatedFir';
        request.page = 1;
        request.pageSize = 10;
        //Creating initial records
        User member = TestFactory.createMember();
        member.FirstName = name;
        Story__c story = TestFactory.createStory();
        story.Name = name;
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        activity.Name = name;
        activity.Status__c = Constants.STATUS_PUBLIC;
        update new List<sObject>{member, activity};

        System.runAs(member) {
            Test.startTest();
                WebAppModels.AllRecordsSearchResponse result = CrowdExchangeRemoteController.search(request);
            Test.stopTest();
            System.assertEquals(3, result.totalItems,'Not all records were fetched in count query');
            System.assertEquals(3, result.records.size(),'Not all records were returned');
            System.assertEquals(story.Id, ((WebAppModels.Story)result.records[1].item).id);
            System.assertEquals(activity.Id, ((WebAppModels.Activity)result.records[0].item).id);
            System.assertEquals(member.Id, ((WebAppModels.UserModel)result.records[2].item).id);
        }  
    }
    /**
     * gets publisher's activities available for registration
     */
    @isTest static void getPublisherActivities() {
        Story__c story = TestFactory.createStory();
        story.Status__c = Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        activity.Status__c = Constants.STATUS_PUBLIC;
        update activity;

        Test.startTest();
            List<WebAppModels.Activity> result = CrowdExchangeRemoteController.getPublisherActivities();
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(activity.Id, result[0].id);
    }
    
    /**
     * addSubmission to activity
     */
    @isTest static void addSubmissionTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        Test.startTest();
        
        List<Submission__c> submissions = [Select id from Submission__c where Activity__c =: activity.Id];
        System.assert(submissions.isEmpty());
        
        WebAppModels.ActivitySubmission  activitySubmission = CrowdExchangeRemoteController.addSubmission(activity.Id, 'TestProject.Zip');
        
        Test.stopTest();
        
        submissions = [Select id, Name, Submission_Timestamp__c, Submitting_Member__c from Submission__c where Activity__c =: activity.Id];
        System.assert(!submissions.isEmpty());
        
        System.assertEquals(1, submissions.size());
        System.assertEquals('TestProject.Zip', submissions[0].Name);
        System.assertEquals(UserInfo.getUserId(), submissions[0].Submitting_Member__c);
        
        // Submission_Requirements added for above submission
        List<Submission_Requirement__c> submissionRequirement = [select id from Submission_Requirement__c where Submission__c =: submissions[0].id];
        System.assert(!submissions.isEmpty());
    }
    
    
    /**
     * getSubmissions for activity for member user.
     */
    @isTest static void getSubmissions_MemberUserTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        
        User memberUser = TestFactory.createUser();
        memberUser.Crowd_Exchange_User_Type__c = Constants.MEMBER;
        insert memberUser;
        
        Submission__c submission2 = new Submission__c(
            Name = 'TestSubmission2',
            Activity__c = activity.Id,
            Evaluation_Percentage__c = 90,
            Submission_Score__c = 10,
            Submission_Timestamp__c = DateTime.now(),
            Submitting_Member__c = memberUser.id
            );
        insert submission2;
        
        Test.startTest();
        
        // running in member user context.
        system.runAs(memberUser) {
        
        	List<WebAppModels.ActivitySubmission> activitySubmissionList = CrowdExchangeRemoteController.getSubmissions(activity.id);
        	
        	System.assert(!activitySubmissionList.isEmpty());
        	// will load only submission for current member user
	        System.assertEquals(1, activitySubmissionList.size());
	        System.assertEquals('TestSubmission2', activitySubmissionList[0].name);
        }
        Test.stopTest();
    }
    
    /**
     * getSubmissions for activity for Publisher user.
     */
    @isTest static void getSubmissions_PublisherUserTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        
        User publisherUser = TestFactory.createUser();
        publisherUser.Crowd_Exchange_User_Type__c = Constants.PUBLISHER;
        insert publisherUser;
        
        Submission__c submission2 = new Submission__c(
            Name = 'TestSubmission2',
            Activity__c = activity.Id,
            Evaluation_Percentage__c = 90,
            Submission_Score__c = 10,
            Submission_Timestamp__c = DateTime.now(),
            Submitting_Member__c = publisherUser.id
            );
        insert new List<Submission__c>{submission1, submission2};
        
        Test.startTest();
        
        // running in publisher user context.
        system.runAs(publisherUser) {
        
        	List<WebAppModels.ActivitySubmission> activitySubmissionList = CrowdExchangeRemoteController.getSubmissions(activity.id);
        	
        	System.assert(!activitySubmissionList.isEmpty());
        	// will load all submissions
	        System.assertEquals(2, activitySubmissionList.size());
        }
        Test.stopTest();
    }
    
    /**
     * getSubmissionRequirements for activity submission.
     */
    @isTest static void getSubmissionRequirementsTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        insert submission1;
        
        List<Requirement__c> requirements = [select id from Requirement__c where Activity__c=: activity.id];
        
        List<Submission_Requirement__c> submissionRequirements = new List<Submission_Requirement__c>();
        for(Requirement__c req:requirements) {
        	submissionRequirements.add(TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        // getting Submission Requirements for submission1
    	List<WebAppModels.SubmissionRequirement> submissionRequirementList = CrowdExchangeRemoteController.getSubmissionRequirements(submission1.id);
    	
    	System.assert(!submissionRequirementList.isEmpty());
        System.assertEquals(submissionRequirements.size(), submissionRequirementList.size());
        
        Test.stopTest();
    }
    
    /**
     * saveSubmissionReview for activity submission.
     */
    @isTest static void saveSubmissionReviewTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        insert submission1;
        
        List<Requirement__c> requirements = [select id from Requirement__c where Activity__c=: activity.id];
        
        List<Submission_Requirement__c> submissionRequirements = new List<Submission_Requirement__c>();
        for(Requirement__c req:requirements) {
        	submissionRequirements.add(TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        submission1.Overall_Comment__c = 'Test averall review comments';
        WebAppModels.ActivitySubmission submissionModel = new WebAppModels.ActivitySubmission(submission1);
        
        List<WebAppModels.SubmissionRequirement> submissionRequirementModelList = new List<WebAppModels.SubmissionRequirement>();
        for(Submission_Requirement__c sr: submissionRequirements) {
        	submissionRequirementModelList.add(new WebAppModels.SubmissionRequirement(sr));
        }
        
        try {
	        // calling saveSubmissionReview with false 
	    	CrowdExchangeRemoteController.saveSubmissionReview(submissionModel, submissionRequirementModelList, false);
	    	
	    	Submission__c updatedSubmission = [select Overall_Comment__c, Reviewed_By__c, Review_Date__c, Status__c from Submission__c where id=: submission1.Id];
	    	
	    	System.assert(true, 'successfully done with saving the review');
	    	System.assertEquals('Test averall review comments', updatedSubmission.Overall_Comment__c);
	    	System.assertEquals(Userinfo.getUserId(), updatedSubmission.Reviewed_By__c);
	    	System.assert(updatedSubmission.Status__c != Constants.REVIEW_COMPLETE_STATUS);
	    	System.assert(updatedSubmission.Review_Date__c == null);
	    	
        } catch (Exception e) {
        	System.assert(false, 'Exception while saving the review');
        }
        Test.stopTest();
    }
    
    
    /**
     * markReviewComplete for activity submission.
     */
    @isTest static void markReviewCompleteTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        insert submission1;
        
        List<Requirement__c> requirements = [select id from Requirement__c where Activity__c=: activity.id];
        
        List<Submission_Requirement__c> submissionRequirements = new List<Submission_Requirement__c>();
        for(Requirement__c req:requirements) {
        	submissionRequirements.add(TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        submission1.Overall_Comment__c = 'Test averall review comments';
        WebAppModels.ActivitySubmission submissionModel = new WebAppModels.ActivitySubmission(submission1);
        
        List<WebAppModels.SubmissionRequirement> submissionRequirementModelList = new List<WebAppModels.SubmissionRequirement>();
        for(Submission_Requirement__c sr: submissionRequirements) {
        	submissionRequirementModelList.add(new WebAppModels.SubmissionRequirement(sr));
        }
        
        try {
	        // calling saveSubmissionReview with true to mark review complete
	    	CrowdExchangeRemoteController.saveSubmissionReview(submissionModel, submissionRequirementModelList, true);
	    	
	    	Submission__c updatedSubmission = [select Reviewed_By__c, Review_Date__c, Status__c from Submission__c where id=: submission1.Id];
	    	
	    	System.assert(true, 'successfully done with marking the review as complete');
	    	System.assertEquals(Userinfo.getUserId(), updatedSubmission.Reviewed_By__c);
	    	System.assert(updatedSubmission.Review_Date__c != null);
	    	
	    	// status will be set as Review Complete 
	    	System.assertEquals(Constants.REVIEW_COMPLETE_STATUS, updatedSubmission.Status__c);
	    	
        } catch (Exception e) {
        	System.assert(false, 'Exception while marking the review as complete');
        }
        Test.stopTest();
    }
    
    /**
     * deleteSubmission for activity submission.
     */
    @isTest static void deleteSubmissionTest() {
        Story__c story = TestFactory.createStory();
        insert story;
        Activity__c activity = TestFactory.createFullActivity(story);
        Registration__c registration = TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        Submission__c submission1 = TestFactory.createSubmission(activity);
        insert submission1;
        
        List<Requirement__c> requirements = [select id from Requirement__c where Activity__c=: activity.id];
        
        List<Submission_Requirement__c> submissionRequirements = new List<Submission_Requirement__c>();
        for(Requirement__c req:requirements) {
        	submissionRequirements.add(TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        WebAppModels.ActivitySubmission submissionModel = new WebAppModels.ActivitySubmission(submission1);
        
        List<WebAppModels.SubmissionRequirement> submissionRequirementModelList = new List<WebAppModels.SubmissionRequirement>();
        for(Submission_Requirement__c sr: submissionRequirements) {
        	submissionRequirementModelList.add(new WebAppModels.SubmissionRequirement(sr));
        }
        
        try {
        	List<Submission__c> submissions = [select Reviewed_By__c, Review_Date__c, Status__c from Submission__c where Activity__c=: activity.Id];
        	System.assert(!submissions.isEmpty());
        	
	        // calling deleteSubmission
	    	CrowdExchangeRemoteController.deleteSubmission(submission1.Id);
	    	
	    	submissions = [select Reviewed_By__c, Review_Date__c, Status__c from Submission__c where Activity__c=: activity.Id];
	    	
	    	System.assert(true, 'successfully done with deleting the submission');
	    	System.assert(submissions.isEmpty());
	    	
        } catch (Exception e) {
        	System.assert(false, 'Exception while deleting the submission');
        }
        Test.stopTest();
    }
    
}