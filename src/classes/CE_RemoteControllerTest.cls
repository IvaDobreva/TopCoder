@isTest
private class CE_RemoteControllerTest {

    private static CE_WebAppModels.StoryRequest createStoryRequest(){
        CE_WebAppModels.StoryRequest request = new CE_WebAppModels.StoryRequest();
        request.filter = new CE_WebAppModels.StoryFilter();
        request.page = 1;
        request.pageSize = 10;
        return request;
    }
    /**
     * get stories with 'positive' filter
     */
	@isTest static void getStories_positive() {
		CE_WebAppModels.StoryRequest request = createStoryRequest();
        request.filter.storyTitle = 'Test';
        CE_Story__c story = CE_TestFactory.createFullStory();
        story.Status__c = CE_Constants.STATUS_IN_REGISTRATION;
        update story;
        List<CE_Activity__c> activities = [SELECT Status__c FROM CE_Activity__c];
        activities[0].Status__c = CE_Constants.STATUS_PUBLIC;
        update activities;
        Test.startTest();
            CE_WebAppModels.StoryResponse response = CE_RemoteController.getStories(request);
            System.assertEquals(1,response.stories.size());
            System.assertEquals(1,response.totalItems);
            System.assertEquals(1,response.totalPages);
        Test.stopTest();
	}
    /**
     * fetch stories with unreal filter
     */
    @isTest static void getStories_negative() {
        CE_WebAppModels.StoryRequest request = createStoryRequest();
        request.filter.storyTitle = 'unknown';
        request.filter.activityTitle = 'unknown';
        request.filter.serviceOffering = 'unknown';
        request.filter.activityPhase = 'unknown';
        request.filter.showOnlyCompleted = true;
        CE_Story__c story = CE_TestFactory.createFullStory();
        update story;
        Test.startTest();
            CE_WebAppModels.StoryResponse response = CE_RemoteController.getStories(request);
            System.assertEquals(0,response.stories.size());
            System.assertEquals(0,response.totalItems);
            System.assertEquals(1,response.totalPages);
        Test.stopTest();
    }
	/**
     * fetch story by id
     */
    @isTest static void getStory_positive() {
        CE_Story__c story = CE_TestFactory.createFullStory();
        story.Status__c = 'In Progress';
        update story;
        Test.startTest();
            CE_WebAppModels.Story response = CE_RemoteController.getStory(story.Id,true);
            System.assertNotEquals(null,response);
            System.assertEquals(story.Id,response.id);
        Test.stopTest();
    }
    /**
     * fetch story by id = null
     */
    @isTest static void getStory_negative() {
        CE_Story__c story = CE_TestFactory.createFullStory();
        Test.startTest();
            CE_WebAppModels.Story response = CE_RemoteController.getStory(null,true);
            System.assertEquals(null,response);
            response = CE_RemoteController.getStory('',true);
            System.assertEquals(null,response);
        Test.stopTest();
    }
    /**
     * fetch activity by id
     */
    @isTest static void getActivity_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Test.startTest();
            CE_WebAppModels.Activity response = CE_RemoteController.getActivity(activity.Id);
            System.assertNotEquals(null,response);
            System.assertEquals(activity.Id,response.id);
        Test.stopTest();
    }
    /**
     * delete document(Attachment)
     */
    @isTest static void deleteDocument_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        insert activity;
        Attachment att = CE_TestFactory.createAttachment();
        att.ParentId = activity.Id;
        insert att;
        Test.startTest();
            CE_RemoteController.deleteDocument(att.Id);
            List<Attachment> atts = [SELECT Id FROM Attachment];
            System.assertEquals(0,atts.size());
        Test.stopTest();
    }
    /**
     * upserting story
     */
    @isTest static void upsertStory_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_WebAppModels.Story dto = new CE_WebAppModels.Story(story);
        dto.description = 'descr';
        Test.startTest();
            //test updata
            CE_RemoteController.upsertStory(dto);
            List<CE_Story__c> stories = [SELECT Id,Description__c FROM CE_Story__c];
            System.assertEquals(1,stories.size());
            System.assertEquals('descr',stories[0].Description__c);
            //test insert
            dto.id = null;
            CE_RemoteController.upsertStory(dto);
            stories = [SELECT Id,Description__c FROM CE_Story__c];
            System.assertEquals(2,stories.size());
        Test.stopTest();
    }
    /**
     * upsert activity - update
     */
    @isTest static void upsertActivity_positive() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Attachment att = CE_TestFactory.createAttachment();
        att.ParentId = activity.Id;
        insert att;
        activity = Database.query('SELECT '+CE_RemoteController.ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c');
        CE_WebAppModels.Activity dto = new CE_WebAppModels.Activity(activity);
        dto.description = 'descr';
        Test.startTest();
            //test updata
            CE_RemoteController.upsertActivity(dto);
        Test.stopTest();
        activity = [SELECT Description__c FROM CE_Activity__c WHERE Id = :activity.Id];
        System.assertEquals('descr',activity.Description__c);
    }
    /**
     * upsert activity - insert
     */
    @isTest static void upsertActivity_positive_insert() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Attachment att = CE_TestFactory.createAttachment();
        att.ParentId = activity.Id;
        insert att;
        activity = Database.query('SELECT '+CE_RemoteController.ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c');
        CE_WebAppModels.Activity dto = new CE_WebAppModels.Activity(activity);
        //cleaning old values
        dto.id = null;
        for(CE_WebAppModels.CodeType codeType : dto.codeTypes)
            codeType.id = null;
        for(CE_WebAppModels.ActivityRequirement req : dto.requirements)
            req.id = null;
        dto.requirements[0].childRequirements.add(dto.requirements[1]);
        dto.requirements.remove(1);
        dto.noPrizes = false;
        dto.prizes.add(new CE_WebAppModels.Prize(new CE_Award__c(Place__c = 1, Payment__c = 500)));
        dto.storyId = story.Id;
        Test.startTest();
            //test updata
            CE_RemoteController.upsertActivity(dto);
            //Ensure that activity was created, otherwise throws the exception
            activity = [SELECT Id FROM CE_Activity__c WHERE Id != :activity.Id LIMIT 1];

        Test.stopTest();
    }
    /**
     * register to activity
     */
    @isTest static void registerToActivity() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        activity.Status__c = CE_Constants.STATUS_IN_REGISTRATION;
        update activity;
        Test.startTest();
            CE_RemoteController.registerToActivity(activity.Id);
            try{
                CE_RemoteController.registerToActivity(null);
                System.assert(false); // Never reached
            }catch(CE_RemoteController.WebAppException ex){
                System.assert(true);
            }
            //No need in assertions due to thelogic is in CE_ActivityService
        Test.stopTest();
    }
    /**
     * cancel activity
     */
    @isTest static void cancelActivity() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Test.startTest();
            CE_RemoteController.cancelActivity(activity.Id);
            try{
                CE_RemoteController.cancelActivity(null);
                System.assert(false); // Never reached
            }catch(CE_RemoteController.WebAppException ex){
                System.assert(true);
            }
            //No need in assertions due to thelogic is in CE_ActivityService
        Test.stopTest();
    }
    /**
     * delete activity
     */
    @isTest static void deleteActivity() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Test.startTest();
            CE_RemoteController.deleteActivity(activity.Id);
            //No need in assertions due to thelogic is in CE_ActivityService
        Test.stopTest();
        System.assertEquals(0,([SELECT Id FROM CE_Activity__c]).size());
    }
    /**
     * complete activity
     */
    @isTest static void completeActivity() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Test.startTest();
            CE_RemoteController.completeActivity(activity.Id);
            activity = [SELECT Status__c FROM CE_Activity__c];
            System.assertEquals(CE_Constants.STATUS_COMPLETED,activity.Status__c);
            try{
                CE_RemoteController.completeActivity(null);
                System.assert(false); // Never reached
            }catch(CE_RemoteController.WebAppException ex){
                System.assert(true);
            }
        Test.stopTest();
    }
    /**
     * complete activity
     */
    @isTest static void cancelStory() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        Test.startTest();
            CE_RemoteController.cancelStory(story.Id);
            story = [SELECT Status__c FROM CE_Story__c];
            System.assertEquals(CE_Constants.STATUS_CANCELED,story.Status__c);
            try{
                CE_RemoteController.cancelStory(null);
                System.assert(false); // Never reached
            }catch(CE_RemoteController.WebAppException ex){
                System.assert(true);
            }
        Test.stopTest();
    }
    /**
     * sending email. w/ and w/o null input
     */
    @isTest static void emailToMember() {

        Test.startTest();
            CE_RemoteController.emailToMember(new List<Id>{UserInfo.getUserId()});
            try{
                CE_RemoteController.emailToMember(null);
                System.assert(false); // Never reached
            }catch(CE_RemoteController.WebAppException ex){
                System.assert(true);
            }
            try{
                CE_RemoteController.emailToMember(new List<String>());
                System.assert(false); // Never reached
            }catch(CE_RemoteController.WebAppException ex){
                System.assert(true);
            }
        Test.stopTest();
    }
    /**
     * assagning member to activity
     */
    @isTest static void assignMember() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        Test.startTest();
            CE_WebAppModels.ActivityRegitration result = CE_RemoteController.assignMember(activity.Id,UserInfo.getUserId());
        Test.stopTest();
        activity = [SELECT Assigned_Member__c FROM CE_Activity__c];
        System.assertEquals(UserInfo.getUserId(), activity.Assigned_Member__c);
        System.assertEquals(UserInfo.getUserId(), result.user.id);
    }
    /**
     * unassagning member to activity
     */
    @isTest static void unassignMember() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        activity.Assigned_Member__c = UserInfo.getUserId();
        update activity;
        Test.startTest();
            CE_RemoteController.unassignMember(activity.Id);
        Test.stopTest();
        activity = [SELECT Assigned_Member__c FROM CE_Activity__c];
        System.assertEquals(null, activity.Assigned_Member__c);
    }
    /**
     * Fetch assign member registration
     */
    @isTest static void getAssignedMember() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        activity.Assigned_Member__c = UserInfo.getUserId();
        update activity;
        Test.startTest();
            CE_WebAppModels.ActivityRegitration result = CE_RemoteController.getAssignedMember(activity.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.user);
        System.assertEquals(UserInfo.getUserId(), result.user.id);
    }
    /**
     * getting default skills
     */
    @isTest static void getDefaultSkills() {
        CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
        insert skill;
        Test.startTest();
             List<CE_WebAppModels.CodeType> result = CE_RemoteController.getDefaultSkills();
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(skill.Id, result[0].skillId);
    }
    /**
     * getting recommended members for Activity
     */
    @isTest static void getRecommendedMembers() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Skills__c skill = [SELECT Id FROM CE_Skills__c LIMIT 1];
        insert new CE_UserSkill__c(Skill__c = skill.Id, Member__c = UserInfo.getUserId());
        Test.startTest();
            List<CE_WebAppModels.UserModel> result = CE_RemoteController.getRecommendedMembers(activity.Id);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(UserInfo.getUserId(), result[0].id);
    }
    /**
     * getting registered members for Activity
     */
    @isTest static void getRegistrants() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        Test.startTest();
            List<CE_WebAppModels.ActivityRegitration>  result = CE_RemoteController.getRegistrants(activity.Id,1,10);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(registration.id, result[0].id);
        System.assertEquals(UserInfo.getUserId(), result[0].user.id);
    }
    /**
     * creates basic activity;
     */
    @isTest static void createActivity() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createActivity(story);
        activity.Publisher__c = null;
        CE_WebAppModels.Activity dto = new CE_WebAppModels.Activity(activity);
        dto.storyId = story.Id;
        Test.startTest();
            CE_WebAppModels.Activity result = CE_RemoteController.createActivity(dto);
        Test.stopTest();
        activity = [SELECT Id FROM CE_Activity__c];
        System.assertEquals(activity.Id, result.id);
    }
    
        /**
     * gets current user's unread notifications count
     */
    @isTest static void getUnreadNotificationsCount() {
        User usr = CE_TestFactory.createUser();
        insert usr;
        CE_Notification__c notification = CE_TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            Integer result = CE_RemoteController.getUnreadNotificationsCount();
            System.assertEquals(1, result);
            CE_User_Notification__c userNotification = [SELECT Status__c FROM CE_User_Notification__c LIMIT 1];
            userNotification.Status__c = CE_Constants.NOTIFICATION_READ;
            update userNotification;
            result = CE_RemoteController.getUnreadNotificationsCount();
            System.assertEquals(0, result);
        Test.stopTest();
    }
    /**
     * gets current user's inbox notifications
     */
    @isTest static void getInboxNotifications() {
        User usr = CE_TestFactory.createUser();
        insert usr;
        CE_Notification__c notification = CE_TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            CE_WebAppModels.NotificationsResponse result = CE_RemoteController.getInboxNotifications(1, 10);
            System.assertEquals(1, result.totalItems);
            System.assertEquals(1, result.notifications.size());
            System.assertEquals(notification.Id, result.notifications[0].id);
        Test.stopTest();
    }
    /**
     * gets notifications sent by current user
     */
    @isTest static void getOutboxNotifications() {
        User usr = CE_TestFactory.createUser();
        insert usr;
        CE_Notification__c notification = CE_TestFactory.createOutboundNotification(usr.id);
        Test.startTest();
            CE_WebAppModels.NotificationsResponse result = CE_RemoteController.getOutboxNotifications(1, 10);
            System.assertEquals(1, result.totalItems);
            System.assertEquals(1, result.notifications.size());
            System.assertEquals(notification.Id, result.notifications[0].id);
        Test.stopTest();
    }
    /**
     * mark inbox notification as Read
     */
    @isTest static void markNotificationAsRead() {
        User usr = CE_TestFactory.createUser();
        insert usr;
        CE_Notification__c notification = CE_TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            Boolean result = CE_RemoteController.markNotificationAsRead(notification.Id);
        Test.stopTest();
        System.assert(result);
        CE_User_Notification__c userNotification = [SELECT Status__c FROM CE_User_Notification__c LIMIT 1];
        System.assertEquals(CE_Constants.NOTIFICATION_READ, userNotification.Status__c);
    }
    /**
     * archives inbox notification
     */
    @isTest static void archiveNotification_recipient() {
        User usr = CE_TestFactory.createUser();
        insert usr;
        CE_Notification__c notification = CE_TestFactory.createInboundNotification(usr.id);
        Test.startTest();
            CE_RemoteController.archiveNotification(notification.Id);
        Test.stopTest();
        CE_User_Notification__c userNotification = [SELECT IsArchived__c FROM CE_User_Notification__c LIMIT 1];
        System.assert(userNotification.IsArchived__c,'Seems like notification wasn\'t archived');
    }
    /**
     * archives sent notification
     */
    @isTest static void archiveNotification_sender() {
        User usr = CE_TestFactory.createUser();
        insert usr;
        CE_Notification__c notification = CE_TestFactory.createOutboundNotification(usr.id);
        Test.startTest();
            CE_RemoteController.archiveNotification(notification.Id);
        Test.stopTest();
        notification = [SELECT IsArchivedBySender__c FROM CE_Notification__c LIMIT 1];
        System.assert(notification.IsArchivedBySender__c,'Seems like notification wasn\'t archived');
    }
    /**
     * searches stories
     */
    @isTest static void searchStories() {
        //Creating stories request
        CE_WebAppModels.StoriesSeachRequest request = new CE_WebAppModels.StoriesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        CE_Story__c story = CE_TestFactory.createFullStory();
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        update story;

        Test.startTest();
            CE_WebAppModels.StoriesSearchResponse result = CE_RemoteController.searchStories(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.stories.size());
        System.assertEquals(story.Id, result.stories[0].id);
    }
    /**
     * searches stories with filter
     */
    @isTest static void searchStories_filtered() {
        CE_Story__c story = CE_TestFactory.createFullStory();
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        update story;
        //Creating stories request
        CE_WebAppModels.StoriesSeachFilter filter = new CE_WebAppModels.StoriesSeachFilter();
        filter.title = story.Name;
        filter.serviceOffering = story.Service_Offering__c;
        filter.status = story.Status__c;
        //Creating stories filter
        CE_WebAppModels.StoriesSeachRequest request = new CE_WebAppModels.StoriesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        request.filter = filter;
        
        Test.startTest();
            CE_WebAppModels.StoriesSearchResponse result = CE_RemoteController.searchStories(request);
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
        CE_WebAppModels.ActivitiesSeachRequest request = new CE_WebAppModels.ActivitiesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        CE_Story__c story = CE_TestFactory.createStory();
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        activity.Status__c = CE_Constants.STATUS_PUBLIC;
        update activity;
        Test.startTest();
            CE_WebAppModels.ActivitiesSearchResponse result = CE_RemoteController.searchActivities(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.activities.size());
        System.assertEquals(activity.Id, result.activities[0].id);
    }
    /**
     * searches activities with filter
     */
    @isTest static void searchActivities_filtered() {
        CE_Story__c story = CE_TestFactory.createStory();
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        activity.Status__c = CE_Constants.STATUS_PUBLIC;
        update activity;
        //Creating activities filter
        CE_WebAppModels.ActivitiesSeachFilter filter = new CE_WebAppModels.ActivitiesSeachFilter();
        filter.title = activity.Name;
        filter.challengeType = activity.Challenge_Type__c;
        filter.phase = activity.Status__c;
        //Creating activities request
        CE_WebAppModels.ActivitiesSeachRequest request = new CE_WebAppModels.ActivitiesSeachRequest();
        request.query = 'test';
        request.page = 1;
        request.pageSize = 10;
        request.filter = filter;
        
        Test.startTest();
            CE_WebAppModels.ActivitiesSearchResponse result = CE_RemoteController.searchActivities(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.activities.size());
        System.assertEquals(activity.Id, result.activities[0].id);
    }
    /**
     * searches members
     */
    @isTest static void searchMembers() {
        User member = CE_TestFactory.createMember();
        member.FirstName = 'UnbelievablyCreatedFirstName';
        update member;
        //Creating members request
        CE_WebAppModels.MembersSearchRequest request = new CE_WebAppModels.MembersSearchRequest();
        // need to do this hack because users with name "test" can be in the system
        request.query = member.FirstName; 
        request.page = 1;
        request.pageSize = 10;

        Test.startTest();
            CE_WebAppModels.MembersSearchResponse result = CE_RemoteController.searchMembers(request);
        Test.stopTest();
        System.assertEquals(1, result.totalItems);
        System.assertEquals(1, result.members.size());
        System.assertEquals(member.Id, result.members[0].id);
    }
    /**
     * searches activities with filter
     */
    @isTest static void searchMembers_filtered() {
        User member = CE_TestFactory.createMember();
        member.FirstName = 'UnbelievablyCreatedFirstName';
        update member;
        //Creating members request
        CE_WebAppModels.MembersSearchRequest request = new CE_WebAppModels.MembersSearchRequest();
        // need to do this hack because users with name "test" can be in the system
        request.query = 'unbelievablyCrea';
        request.page = 1;
        request.pageSize = 10;
        //Creating members filter
        CE_WebAppModels.MembersSearchFilter filter = new CE_WebAppModels.MembersSearchFilter();
        filter.firstName = member.FirstName;
        filter.lastName = member.LastName;
        filter.role = member.Crowd_Exchange_User_Type__c;
        filter.organization = member.Crowd_Exchange_Organization__c;
        request.filter = filter;
        
        Test.startTest();
            CE_WebAppModels.MembersSearchResponse result = CE_RemoteController.searchMembers(request);
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
        CE_WebAppModels.PaginatedSearchRequest request = new CE_WebAppModels.PaginatedSearchRequest();
        request.query = 'elievablyCreatedFir';
        request.page = 1;
        request.pageSize = 10;
        //Creating initial records
        User member = CE_TestFactory.createMember();
        member.FirstName = name;
        CE_Story__c story = CE_TestFactory.createStory();
        story.Name = name;
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        activity.Name = name;
        activity.Status__c = CE_Constants.STATUS_PUBLIC;
        update new List<sObject>{member, activity};
        Test.startTest();
            CE_WebAppModels.AllRecordsSearchResponse result = CE_RemoteController.search(request);
        Test.stopTest();
        System.assertEquals(3, result.totalItems,'Not all records were fetched in count query');
        System.assertEquals(3, result.records.size(),'Not all records were returned');
        System.assertEquals(story.Id, ((CE_WebAppModels.Story)result.records[2].item).id);
        System.assertEquals(activity.Id, ((CE_WebAppModels.Activity)result.records[1].item).id);
        System.assertEquals(member.Id, ((CE_WebAppModels.UserModel)result.records[0].item).id);
    }
    /**
     * searches "All Records" as a member
     */
    @isTest static void searchMembers_member() {
        String name = 'UnbelievablyCreatedFirstName';//Just some not existing name
        //Creating all records request
        CE_WebAppModels.PaginatedSearchRequest request = new CE_WebAppModels.PaginatedSearchRequest();
        request.query = 'elievablyCreatedFir';
        request.page = 1;
        request.pageSize = 10;
        //Creating initial records
        User member = CE_TestFactory.createMember();
        member.FirstName = name;
        CE_Story__c story = CE_TestFactory.createStory();
        story.Name = name;
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        activity.Name = name;
        activity.Status__c = CE_Constants.STATUS_PUBLIC;
        update new List<sObject>{member, activity};

        System.runAs(member) {
            Test.startTest();
                CE_WebAppModels.AllRecordsSearchResponse result = CE_RemoteController.search(request);
            Test.stopTest();
            System.assertEquals(3, result.totalItems,'Not all records were fetched in count query');
            System.assertEquals(3, result.records.size(),'Not all records were returned');
            System.assertEquals(story.Id, ((CE_WebAppModels.Story)result.records[1].item).id);
            System.assertEquals(activity.Id, ((CE_WebAppModels.Activity)result.records[0].item).id);
            System.assertEquals(member.Id, ((CE_WebAppModels.UserModel)result.records[2].item).id);
        }  
    }
    /**
     * gets publisher's activities available for registration
     */
    @isTest static void getPublisherActivities() {
        CE_Story__c story = CE_TestFactory.createStory();
        story.Status__c = CE_Constants.STORY_IN_PROGRESS_STATUS;
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        activity.Status__c = CE_Constants.STATUS_PUBLIC;
        update activity;

        Test.startTest();
            List<CE_WebAppModels.Activity> result = CE_RemoteController.getPublisherActivities();
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(activity.Id, result[0].id);
    }
    
    /**
     * addSubmission to activity
     */
    @isTest static void addSubmissionTest() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        Test.startTest();
        
        List<CE_Submission__c> submissions = [Select id from CE_Submission__c where CE_Activity__c =: activity.Id];
        System.assert(submissions.isEmpty());
        
        CE_WebAppModels.ActivitySubmission  activitySubmission = CE_RemoteController.addSubmission(activity.Id, 'TestProject.Zip');
        
        Test.stopTest();
        
        submissions = [Select id, Name, Submission_Timestamp__c, Submitting_Member__c from CE_Submission__c where CE_Activity__c =: activity.Id];
        System.assert(!submissions.isEmpty());
        
        System.assertEquals(1, submissions.size());
        System.assertEquals('TestProject.Zip', submissions[0].Name);
        System.assertEquals(UserInfo.getUserId(), submissions[0].Submitting_Member__c);
        
        // Submission_Requirements added for above submission
        List<CE_Submission_Requirement__c> submissionRequirement = [select id from CE_Submission_Requirement__c where CE_Submission__c =: submissions[0].id];
        System.assert(!submissions.isEmpty());
    }
    
    
    /**
     * getSubmissions for activity for member user.
     */
    @isTest static void getSubmissions_MemberUserTest() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        
        User memberUser = CE_TestFactory.createUser();
        memberUser.Crowd_Exchange_User_Type__c = CE_Constants.MEMBER;
        insert memberUser;
        
        CE_Submission__c submission2 = new CE_Submission__c(
            Name = 'TestSubmission2',
            CE_Activity__c = activity.Id,
            Evaluation_Percentage__c = 90,
            Submission_Score__c = 10,
            Submission_Timestamp__c = DateTime.now(),
            Submitting_Member__c = memberUser.id
            );
        insert submission2;
        
        Test.startTest();
        
        // running in member user context.
        system.runAs(memberUser) {
        
        	List<CE_WebAppModels.ActivitySubmission> activitySubmissionList = CE_RemoteController.getSubmissions(activity.id);
        	
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
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        
        User publisherUser = CE_TestFactory.createUser();
        publisherUser.Crowd_Exchange_User_Type__c = CE_Constants.PUBLISHER;
        insert publisherUser;
        
        CE_Submission__c submission2 = new CE_Submission__c(
            Name = 'TestSubmission2',
            CE_Activity__c = activity.Id,
            Evaluation_Percentage__c = 90,
            Submission_Score__c = 10,
            Submission_Timestamp__c = DateTime.now(),
            Submitting_Member__c = publisherUser.id
            );
        insert new List<CE_Submission__c>{submission1, submission2};
        
        Test.startTest();
        
        // running in publisher user context.
        system.runAs(publisherUser) {
        
        	List<CE_WebAppModels.ActivitySubmission> activitySubmissionList = CE_RemoteController.getSubmissions(activity.id);
        	
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
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        insert submission1;
        
        List<CE_Requirement__c> requirements = [select id from CE_Requirement__c where CE_Activity__c=: activity.id];
        
        List<CE_Submission_Requirement__c> submissionRequirements = new List<CE_Submission_Requirement__c>();
        for(CE_Requirement__c req:requirements) {
        	submissionRequirements.add(CE_TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        // getting Submission Requirements for submission1
    	List<CE_WebAppModels.SubmissionRequirement> submissionRequirementList = CE_RemoteController.getSubmissionRequirements(submission1.id);
    	
    	System.assert(!submissionRequirementList.isEmpty());
        System.assertEquals(submissionRequirements.size(), submissionRequirementList.size());
        
        Test.stopTest();
    }
    
    /**
     * saveSubmissionReview for activity submission.
     */
    @isTest static void saveSubmissionReviewTest() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        insert submission1;
        
        List<CE_Requirement__c> requirements = [select id from CE_Requirement__c where CE_Activity__c=: activity.id];
        
        List<CE_Submission_Requirement__c> submissionRequirements = new List<CE_Submission_Requirement__c>();
        for(CE_Requirement__c req:requirements) {
        	submissionRequirements.add(CE_TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        submission1.Overall_Comment__c = 'Test averall review comments';
        CE_WebAppModels.ActivitySubmission submissionModel = new CE_WebAppModels.ActivitySubmission(submission1);
        
        List<CE_WebAppModels.SubmissionRequirement> submissionRequirementModelList = new List<CE_WebAppModels.SubmissionRequirement>();
        for(CE_Submission_Requirement__c sr: submissionRequirements) {
        	submissionRequirementModelList.add(new CE_WebAppModels.SubmissionRequirement(sr));
        }
        
        try {
	        // calling saveSubmissionReview with false 
	    	CE_RemoteController.saveSubmissionReview(submissionModel, submissionRequirementModelList, false);
	    	
	    	CE_Submission__c updatedSubmission = [select Overall_Comment__c, Reviewed_By__c, Review_Date__c, Status__c from CE_Submission__c where id=: submission1.Id];
	    	
	    	System.assert(true, 'successfully done with saving the review');
	    	System.assertEquals('Test averall review comments', updatedSubmission.Overall_Comment__c);
	    	System.assertEquals(Userinfo.getUserId(), updatedSubmission.Reviewed_By__c);
	    	System.assert(updatedSubmission.Status__c != CE_Constants.REVIEW_COMPLETE_STATUS);
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
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        insert submission1;
        
        List<CE_Requirement__c> requirements = [select id from CE_Requirement__c where CE_Activity__c=: activity.id];
        
        List<CE_Submission_Requirement__c> submissionRequirements = new List<CE_Submission_Requirement__c>();
        for(CE_Requirement__c req:requirements) {
        	submissionRequirements.add(CE_TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        submission1.Overall_Comment__c = 'Test averall review comments';
        CE_WebAppModels.ActivitySubmission submissionModel = new CE_WebAppModels.ActivitySubmission(submission1);
        
        List<CE_WebAppModels.SubmissionRequirement> submissionRequirementModelList = new List<CE_WebAppModels.SubmissionRequirement>();
        for(CE_Submission_Requirement__c sr: submissionRequirements) {
        	submissionRequirementModelList.add(new CE_WebAppModels.SubmissionRequirement(sr));
        }
        
        try {
	        // calling saveSubmissionReview with true to mark review complete
	    	CE_RemoteController.saveSubmissionReview(submissionModel, submissionRequirementModelList, true);
	    	
	    	CE_Submission__c updatedSubmission = [select Reviewed_By__c, Review_Date__c, Status__c from CE_Submission__c where id=: submission1.Id];
	    	
	    	System.assert(true, 'successfully done with marking the review as complete');
	    	System.assertEquals(Userinfo.getUserId(), updatedSubmission.Reviewed_By__c);
	    	System.assert(updatedSubmission.Review_Date__c != null);
	    	
	    	// status will be set as Review Complete 
	    	System.assertEquals(CE_Constants.REVIEW_COMPLETE_STATUS, updatedSubmission.Status__c);
	    	
        } catch (Exception e) {
        	System.assert(false, 'Exception while marking the review as complete');
        }
        Test.stopTest();
    }
    
    /**
     * deleteSubmission for activity submission.
     */
    @isTest static void deleteSubmissionTest() {
        CE_Story__c story = CE_TestFactory.createStory();
        insert story;
        CE_Activity__c activity = CE_TestFactory.createFullActivity(story);
        CE_Registration__c registration = CE_TestFactory.createRegisterMember(UserInfo.getUserId(), activity);
        insert registration;
        
        CE_Submission__c submission1 = CE_TestFactory.createSubmission(activity);
        insert submission1;
        
        List<CE_Requirement__c> requirements = [select id from CE_Requirement__c where CE_Activity__c=: activity.id];
        
        List<CE_Submission_Requirement__c> submissionRequirements = new List<CE_Submission_Requirement__c>();
        for(CE_Requirement__c req:requirements) {
        	submissionRequirements.add(CE_TestFactory.createSubmissionRequirement(submission1, req));
        }
        insert submissionRequirements;
        
        Test.startTest();
        
        CE_WebAppModels.ActivitySubmission submissionModel = new CE_WebAppModels.ActivitySubmission(submission1);
        
        List<CE_WebAppModels.SubmissionRequirement> submissionRequirementModelList = new List<CE_WebAppModels.SubmissionRequirement>();
        for(CE_Submission_Requirement__c sr: submissionRequirements) {
        	submissionRequirementModelList.add(new CE_WebAppModels.SubmissionRequirement(sr));
        }
        
        try {
        	List<CE_Submission__c> submissions = [select Reviewed_By__c, Review_Date__c, Status__c from CE_Submission__c where CE_Activity__c=: activity.Id];
        	System.assert(!submissions.isEmpty());
        	
	        // calling deleteSubmission
	    	CE_RemoteController.deleteSubmission(submission1.Id);
	    	
	    	submissions = [select Reviewed_By__c, Review_Date__c, Status__c from CE_Submission__c where CE_Activity__c=: activity.Id];
	    	
	    	System.assert(true, 'successfully done with deleting the submission');
	    	System.assert(submissions.isEmpty());
	    	
        } catch (Exception e) {
        	System.assert(false, 'Exception while deleting the submission');
        }
        Test.stopTest();
    }
    
     /**
     * login for portal or community user
     */
    @isTest static void portalLogin() {
        Account account = CE_TestFactory.createAccount('Test Acc - 001');
        insert account;
        Contact contact = CE_TestFactory.createContact(account.Id, 'PortalUser - 001');
        insert contact;

        User portalUser = CE_TestFactory.createPortalUser(contact.Id);

        Test.startTest(); 
            String result = CE_RemoteController.portalLogin(
                new CE_WebAppModels.LoginInformation('portaluser@cp.com', '12345'));
        Test.stopTest();
        
        system.assertEquals(true, String.isEmpty(result));
    }
    /**
     *  reset portal or community user's passwords
     */
    @isTest static void resetPassword() {
        Account account = CE_TestFactory.createAccount('Test Acc - 001');
        insert account;
        Contact contact = CE_TestFactory.createContact(account.Id, 'PortalUser - 001');
        insert contact;

        User portalUser = CE_TestFactory.createPortalUser(contact.Id);

        Test.startTest(); 
            Boolean result = CE_RemoteController.resetPassword(
                'portaluser@cp.com'
            );
        Test.stopTest();
        
        system.assertEquals(false, result);
    }
    /**
     *  check page navigation for internal users
     */
    @isTest static void checkNavigationForInternalUser() {

        Test.startTest(); 
        
            CE_RemoteController objController = new CE_RemoteController();
            PageReference redirectedUrl = objController.redirectIfLoggedIn();
            system.assertEquals(null, redirectedUrl);
            
        Test.stopTest();
    }
    
}