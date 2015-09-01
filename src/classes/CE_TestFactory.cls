@isTest
public class CE_TestFactory {
    public static CE_Story__c createStory() {
        return new CE_Story__c(
                   Name = 'TestStory',
                   Budget__c = 5000,
                   Description__c = 'Description',
                   Project_Start_Date__c = Date.today(),
                   Publisher__c = UserInfo.getUserId(),
                   Status__c = CE_Constants.STORY_PLANNING_STATUS,
                   Service_Offering__c = 'Applications Services',
                   Remaining_Budget__c = 5000
               );
    }
    public static CE_Activity__c createActivity(CE_Story__c story) {
        return new CE_Activity__c(
                   Name = 'TestActivity',
                   Challenge_Type__c = 'Competition',
                   Budget_Authorized__c = true,
                   Cost__c = 1000,
                   Description__c = 'Description',
                   Minimum_Viable_Score__c = 75,
                   Possible_Score__c = 25,
                   Publisher__c = UserInfo.getUserId(),
                   CE_Story__c = story.Id,
                   Status__c = CE_Constants.STATUS_DRAFT
               );
    }
    public static CE_Skills__c createSkill(String skill) {
        return new CE_Skills__c(
                   Name = skill
               );
    }
    public static CE_ActivitySkills__c createActivitySkill(CE_Activity__c activity, CE_Skills__c skill) {
        return new CE_ActivitySkills__c(
                   CE_Activity__c = activity.Id,
                   Skill__c = skill.Id
               );
    }
    
    /*
        Updated below method as per TC30050600
    */
    public static List<CE_Milestone__c> createDefaultMilestones() {
        CE_Milestone__c publishDateMilestone = new CE_Milestone__c(Name = CE_Constants.PUBLISH_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 1, Type__c = 'Software Development', Step_Number__c = 1);
        CE_Milestone__c startDateMilestone = new CE_Milestone__c(Name = CE_Constants.START_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 2);
        CE_Milestone__c registrationDateMilestone = new CE_Milestone__c(Name = CE_Constants.REGISTRATION_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 3);
        CE_Milestone__c assignmentDateMilestone = new CE_Milestone__c(Name = CE_Constants.ASSIGNMENT_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 1, Type__c = 'Software Development', Step_Number__c = 4);
        CE_Milestone__c submissionDateMilestone = new CE_Milestone__c(Name = CE_Constants.SUBMISSION_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 7, Type__c = 'Software Development', Step_Number__c = 5);
        CE_Milestone__c reviewDateMilestone = new CE_Milestone__c(Name = CE_Constants.REVIEW_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = true, Default_Time_Period__c = 2, Type__c = 'Software Development', Step_Number__c = 6);
        CE_Milestone__c acceptanceDateMilestone = new CE_Milestone__c(Name = CE_Constants.ACCEPTANCE_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = false, Type__c = 'Software Development', Step_Number__c = 7);
        CE_Milestone__c endDateMilestone = new CE_Milestone__c(Name = CE_Constants.END_DATE_MILESTONE_NAME, Display_In_Initial_Setup__c = false, Type__c = 'Software Development', Step_Number__c = 8);

        return new List<CE_Milestone__c> { 
                    publishDateMilestone,
                    startDateMilestone,
                    registrationDateMilestone,
                    assignmentDateMilestone,
                    submissionDateMilestone,
                    reviewDateMilestone,
                    acceptanceDateMilestone,
                    endDateMilestone
                };
    }
    
    // Updated against TC30050600 
    public static CE_ActivityMilestones__c createActivityMilestone(CE_Activity__c activity, CE_Milestone__c milestone, Date scheduleDate) {
        return new CE_ActivityMilestones__c(CE_Activity__c = activity.Id, 
                                        CE_Milestone__c = milestone.Id, 
                                        Scheduled_Date__c = scheduleDate
                                        );
    }

    public static List<CE_Default_Requirement__c> createDefaultRequirements() {
        List<CE_Default_Requirement__c> result = new List<CE_Default_Requirement__c>();
        for (Integer i = 0; i < 3; i++)
            result.add(new CE_Default_Requirement__c(
                           Name = 'Application Functionality ' + 1,
                           Description__c = 'Application Functionality ' + 1,
                           Requirement_Weight__c = 'Normal',
                           Type__c = 'Application Functionality'
                       ));
        for (Integer i = 0; i < 3; i++)
            result.add(new CE_Default_Requirement__c(
                           Name = 'Code Standard ' + 1,
                           Description__c = 'Code Standard ' + 1,
                           Requirement_Weight__c = 'Normal',
                           Type__c = 'Code Standard'
                       ));
        for (Integer i = 0; i < 3; i++)
            result.add(new CE_Default_Requirement__c(
                           Name = 'Deployment ' + 1,
                           Description__c = 'Deployment ' + 1,
                           Requirement_Weight__c = 'Normal',
                           Type__c = 'Deployment'
                       ));
        for (Integer i = 0; i < 3; i++)
            result.add(new CE_Default_Requirement__c(
                           Name = 'Documentation ' + 1,
                           Description__c = 'Documentation ' + 1,
                           Requirement_Weight__c = 'Normal',
                           Type__c = 'Documentation'
                       ));
        return result;
    }

    public static CE_Requirement__c createRequirement(CE_Activity__c activity, CE_Default_Requirement__c requirement) {
        return new CE_Requirement__c(
                   CE_Activity__c = activity.Id,
                   Description__c = 'Description',
                   Requirement_Evaluation__c = 'Meets requirement',
                   Requirement_Weight__c = 'Normal',
                   Type__c = requirement.Type__c,
                   Requirement_Number__c = '1'
               );
    }

    public static CE_Award__c createAward(CE_Activity__c activity) {
        return new CE_Award__c(
                   CE_Activity__c = activity.Id,
                   Payment__c = 500,
                   Place__c = 1
               );
    }


    public static User createUser() {
        // Setup test data
        // This code runs as the system user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        String email = 'awesometestuser' + Crypto.getRandomInteger() + '@testorg.com';
        User user = new User(Alias = 'standt', Email = email, FirstName = 'Named',
                             EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US', ProfileId = profile.Id,
                             TimeZoneSidKey = 'America/Los_Angeles', UserName = email);

        return user;
    }
    
    public static CE_Submission__c createSubmission(CE_Activity__c activity){
        return new CE_Submission__c(
            Name = 'TestSubmission',
            CE_Activity__c = activity.Id,
            Evaluation_Percentage__c = 100,
            Submission_Score__c = 10,
            Submission_Timestamp__c = DateTime.now(),
            Submitting_Member__c = UserInfo.getUserId()
            );
    }
    public static Attachment createAttachment(){
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf('TestBodyContent');
        attachment.Name = 'test.txt';

        return attachment;
    }
    
    public static CE_Submission_Requirement__c createSubmissionRequirement(CE_Submission__c submission, CE_Requirement__c requirement){
        return new CE_Submission_Requirement__c(CE_Submission__c = submission.Id, CE_Requirement__c = requirement.Id, Evaluation_Score__c = 0);
    }
    
    
    // Added against TC30050600 
    public static CE_Registration__c createRegisterMember(Id userId, CE_Activity__c activity) {
        return new CE_Registration__c(
                CE_Activity__c = activity.Id, 
                User__c = userId, 
                Registration_Date__c = DateTime.now());
    }

    /**
     * Creates full story with all child objects
     * @return story object with all related fields and collections
     */
    public static CE_Story__c createFullStory(){
        

        String userId = UserInfo.getUserId();
        User usr = [SELECT FirstName,LastName,SmallPhotoUrl,Crowd_Exchange_User_Type__c,Crowd_Exchange_Organization__c FROM User WHERE Id = :userId];
        CE_Story__c story = CE_TestFactory.createStory();
        story.Publisher__c = userId;
        insert story;
        createFullActivity(story);

        return story;
    }

    public static CE_Activity__c createFullActivity(CE_Story__c story){
      CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
      List<CE_Milestone__c> milestones = CE_TestFactory.createDefaultMilestones();
      List<sObject> toInsert = new List<sObject>((List<sObject>)milestones);
      toInsert.add(skill);
      insert toInsert;
      toInsert.clear();


      String userId = UserInfo.getUserId();
      CE_Activity__c activity = CE_TestFactory.createActivity(story);
      activity.Publisher__c = userId;
      insert activity;
      Date dt = Date.today();
      for(CE_Milestone__c milestone : milestones){
        toInsert.add(
          CE_TestFactory.createActivityMilestone(activity, milestone, dt ));
        if(milestone.Default_Time_Period__c!=null)
          dt = dt.addDays(milestone.Default_Time_Period__c.intValue());
      }
      toInsert.addAll((List<sObject>)activity.ActivityMilestones__r);
      List<CE_Default_Requirement__c> defRequirements = CE_TestFactory.createDefaultRequirements();
      Integer reqNumber = 1;
      for(CE_Default_Requirement__c defReq : defRequirements){
        CE_Requirement__c req = CE_TestFactory.createRequirement(activity, defReq);
        req.Requirement_Number__c = reqNumber+'';
        reqNumber++;
        toInsert.add(req);
      }
      CE_ActivitySkills__c actSkill = CE_TestFactory.createActivitySkill(activity,skill);
      toInsert.add(actSkill);
      toInsert.add(CE_TestFactory.createAward(activity));
      insert toInsert;
      toInsert.clear();
      return activity;
    }
    /**
     * Creates new member user
     * @return          created member
     */
    public static User createMember(){
      User usr = createUser();
      usr.Crowd_Exchange_User_Type__c = CE_Constants.MEMBER;
      usr.Crowd_Exchange_Organization__c = 'Awesome org';
      insert usr;
      CE_Skills__c skill = CE_TestFactory.createSkill('Test Awesome Skill');
      insert skill;
      CE_UserSkill__c userSkill = new CE_UserSkill__c(Member__c = usr.Id, Skill__c = skill.Id);
      insert userSkill;
      return usr;
    }
    /**
     * Creates inboud notification for the current user
     * @param  senderId sender(user) Id
     * @return          created notification
     */
    public static CE_Notification__c createInboundNotification(Id senderId){
      return createNotification(senderId, UserInfo.getUserId());
    }
    /**
     * Creates inboud notification for the current user
     * @param  recipientId Recipient(user) Id
     * @return          created notification
     */
    public static CE_Notification__c createOutboundNotification(Id recipientId){
      return createNotification(UserInfo.getUserId(), recipientId);
    }
    /**
     * Creates notification
     * @param  senderId    Sender(user) Id
     * @param  recipientId Recipient(user) Id
     * @return             created notification
     */
    public static CE_Notification__c createNotification(Id senderId, Id recipientId){
      CE_Notification__c notification = new CE_Notification__c(
        Date_Sent__c = Datetime.now(),
        FromUser__c = senderId,
        Notification_Text__c = 'text',
        Subject__c = 'test subject');
      insert notification;
      CE_User_Notification__c userNotification = new CE_User_Notification__c(
        Recipient__c = recipientId, CE_Notification__c = notification.Id, Status__c = CE_Constants.NOTIFICATION_UNREAD);
      insert userNotification;
      return notification;
    }
    
     public static Account createAccount(String name) {
        return new Account(
                   Name = name
               );
    }
    
    public static Contact createContact(Id accountId, String lastname) {
        return new Contact(
                   LastName = lastname,
                   AccountId = accountId
               );
    }
    
    public static User createPortalUser(Id contactId) {
        Set<String> customerUserTypes = new Set<String> {
            'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'
        };

        Profile profile = [SELECT Id, Name FROM Profile WHERE UserType IN :customerUserTypes LIMIT 1];

        User portalUser = new User(
            ProfileId = profile.Id,
            Username = 'portaluser@cp.com',
            Email = 'portaluser@cp.com',
            EmailEncodingkey = 'UTF-8',
            Localesidkey = 'en_US',
            Languagelocalekey = 'en_US',
            Timezonesidkey = 'America/Los_Angeles',
            Alias='puser',
            Lastname='PortalUser - 001',
            ContactId = contactId,
            Crowd_Exchange_User_Type__c = CE_RemoteController.USERTYPE_MEMBER
        );
        insert portalUser;
        system.assertNotEquals(null, portalUser.Id);
        return portalUser;
    }
    
     /**
     * Creates Summary Data
     */
    public static void createSummaryData(){
        CE_Summary_Data__c summaryData = new CE_Summary_Data__c();
        summaryData.Name = 'Test';
        summaryData.Timestamp__c = System.now();
        summaryData.Active_Activities__c = 250;
        summaryData.Active_Stories__c = 250;
        summaryData.Completed_Activities__c = 250;
        insert summaryData;
        
    }
}