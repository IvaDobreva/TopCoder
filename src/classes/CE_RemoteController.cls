public with sharing class CE_RemoteController {
    private static CE_IActivityService mActivityService = new CE_ActivityService();
    private static CE_IStoryService mStoryService = new CE_StoryService();
    private static CE_ISubmissionService mSubmissionService = new CE_SubmissionService();
    public CE_RemoteController() {
    }
    
        // properties for holding user type
    @TestVisible private static final String USERTYPE_MEMBER = 'Member';
    @TestVisible private static final String USERTYPE_PUBLISHER = 'Publisher';
    @TestVisible private static final String GUESTUSER= 'Guest';
    @TestVisible private static final String STANDARDUSER = 'Standard';

    
    @TestVisible private final static String MEMBER_FIELDS = 'FirstName, LastName, SmallPhotoUrl, Email, Crowd_Exchange_Organization__c, Crowd_Exchange_User_Type__c,'+
                                                                    '(SELECT Skill__c, Skill__r.Name FROM Member_Skills__r), (SELECT Id FROM Submissions__r) ';

    @TestVisible private final static String ACTIVITY_LIGHT_FIELDS = 'Name, Description__c, hasAwards__c, Challenge_Type__c, CE_Story__c, Status__c, '+
                                                ' Assigned_Member__c, Assigned_Member__r.FirstName, Assigned_Member__r.LastName, Assigned_Member__r.SmallPhotoUrl, Assigned_Member__r.Crowd_Exchange_User_Type__c, Assigned_Member__r.Crowd_Exchange_Organization__c,'+
                                                'CE_Story__r.Name, CE_Story__r.Service_Offering__c, CE_Story__r.Description__c, CE_Story__r.Status__c,CE_Story__r.Publisher__r.FirstName, CE_Story__r.Publisher__r.LastName, CE_Story__r.Publisher__r.SmallPhotoUrl,'+ 
                                                'CE_Story__r.Publisher__r.Crowd_Exchange_User_Type__c,CE_Story__r.Publisher__r.Crowd_Exchange_Organization__c,CE_Story__r.Publisher__r.Email,'+
                                                ' (SELECT Id, Registration_Date__c, User__r.FirstName, User__r.LastName, User__r.SmallPhotoUrl,User__r.Email, User__r.Crowd_Exchange_User_Type__c, User__r.Crowd_Exchange_Organization__c FROM Registrations__r),'+
                                                ' (SELECT Id FROM Submissions__r) ';
    @TestVisible private final static String ACTIVITY_FULL_FIELDS = 'Name, Description__c, hasAwards__c, Challenge_Type__c, CE_Story__c, Status__c, '+
                                                ' Assigned_Member__c, Assigned_Member__r.FirstName, Assigned_Member__r.LastName, Assigned_Member__r.SmallPhotoUrl, '+
                                                'CE_Story__r.Name, CE_Story__r.Service_Offering__c,'+
                                                ' (SELECT Scheduled_Date__c, Completed_Date__c, CE_Milestone__r.Name,CE_Milestone__r.Display_In_Initial_Setup__c,CE_Milestone__r.Default_Time_Period__c,CE_Milestone__r.Step_Number__c FROM ActivityMilestones__r),'+
                                                ' (SELECT Skill__c, Skill__r.Name FROM Activity_Skills__r),'+
                                                ' (SELECT Type__c, Requirement_Weight__c, Requirement_Number__c, Description__c, Parent_Requirement__c FROM Requirements__r),'+
                                                ' (SELECT Registration_Date__c, User__r.FirstName, User__r.LastName, User__r.SmallPhotoUrl FROM Registrations__r),'+
                                                ' (SELECT Review_Date__c, Evaluation_Percentage__c, Reviewed_By__r.FirstName, Reviewed_By__r.LastName, Reviewed_By__r.SmallPhotoUrl, '+
                                                        'Status__c, Submission_Timestamp__c, Submitting_Member__r.FirstName, Submitting_Member__r.LastName, '+
                                                        'Submitting_Member__r.SmallPhotoUrl FROM Submissions__r),'+
                                                ' (SELECT Name, Description, ContentType, BodyLength, CreatedDate  FROM Attachments),'+
                                                ' (SELECT Place__c, Payment__c FROM Awards__r)';

    @TestVisible private final static String STORY_FIELDS = 'Service_Offering__c, Name, Description__c, Publisher__r.FirstName, Publisher__r.LastName, Publisher__r.SmallPhotoUrl,'+
                                                ' Publisher__r.Crowd_Exchange_Organization__c, Publisher__r.Crowd_Exchange_User_Type__c, Status__c';
    @TestVisible private final static String STORY_FIELDS_MEMBER = STORY_FIELDS + ', (SELECT Id FROM Activities__r WHERE Status__c != \''+CE_Constants.STATUS_DRAFT+'\')';
    @TestVisible private final static String STORY_FIELDS_PUBLISHER = STORY_FIELDS + ', (SELECT Id FROM Activities__r)';
    
    private final static String COUNT_FIELD = 'Count(Id) result';
    
     /**
     * redirects to login page if user is already logged in!
     * @return      PageReference
     */
    public PageReference redirectIfLoggedIn() {
        if(UserInfo.getUserType() != GUESTUSER && UserInfo.getUserType() != STANDARDUSER) {
            return new PageReference(getLandingPageUrl());
        }
        // for other type of users, do not redirect to landing page
        return null;
    }
    
    
    /**
     * Fetches a story by id
     * @param  id   Story Id
     * @param  deep defines if need to fetch all activities with all child records
     * @return      Story object DTO
     */
    @RemoteAction
    public static CE_WebAppModels.Story getStory(String id, Boolean deep) {
        try{
            if(String.isNotEmpty(id)){
                CE_WebAppModels.Story response;
                CE_Story__c story = null;
                User usr = [SELECT Crowd_Exchange_User_Type__c FROM User WHERE Id = :UserInfo.getUserId()];
                if(usr.Crowd_Exchange_User_Type__c == CE_Constants.PUBLISHER){
                    story = Database.query('SELECT '+STORY_FIELDS_PUBLISHER+' FROM CE_Story__c WHERE Id = :id LIMIT 1');
                }else {
                    String storyStatusPlanning = CE_Constants.STORY_PLANNING_STATUS;
                    List<CE_Story__c> stories = Database.query('SELECT '+STORY_FIELDS_MEMBER+' FROM CE_Story__c WHERE Id = :id AND Status__c != :storyStatusPlanning LIMIT 1');
                    if(!stories.isEmpty()) story = stories.get(0);
                }
                    
                if(story != null) {
                    response = new CE_WebAppModels.Story(story);
                    Set<Id> activitiesIds = new Set<Id>();
                    for(CE_Activity__c activity : story.Activities__r)
                        activitiesIds.add(activity.Id);
                    if(deep){
                       //Querying activities and adding them to the corresponding stories
                        List<CE_Activity__c> activities = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c WHERE Id IN :activitiesIds');
                        for(CE_Activity__c activity : activities){
                            response.activities.add(new CE_WebAppModels.Activity(activity));
                        } 
                    }
                }          
                return response;
            }else {
                return null;
            }
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches an activity by id with all child records
     * @param  id activity id
     * @return    Activity object DTO
     */
    @RemoteAction
    public static CE_WebAppModels.Activity getActivity(String id) {
        try{
            if(String.isNotEmpty(id)){
                //Querying activities and adding them to the corresponding stories
                CE_Activity__c activity = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c WHERE Id = :id');
                return new CE_WebAppModels.Activity(activity);
                        
            }else {
                return null;
            }
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Deletes Attachment object
     * @param id Attachment Id
     */
    @RemoteAction
    public static void deleteDocument(Id id) {
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            delete new Attachment(Id = id);
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches default skills collection
     * @return List of skill object DTO
     */
    @RemoteAction
    public static List<CE_WebAppModels.CodeType> getDefaultSkills(){
        List<CE_Skills__c> skills = [SELECT Name FROM CE_Skills__c];
        List<CE_WebAppModels.CodeType> codeTypes = new List<CE_WebAppModels.CodeType>();
        for(CE_Skills__c skill : skills)
            codeTypes.add(new CE_WebAppModels.CodeType(skill));
        return codeTypes;
    }
    /**
     * Upserts story
     * @param  story Story dto
     * @return       updated Story DTO with Id
     */
    @RemoteAction
    public static CE_WebAppModels.Story upsertStory(CE_WebAppModels.Story story) {
        if(story==null) throw new WebAppException('Story equals null');
        try{
            CE_Story__c storyToUpdate = null;
            if(story.id == null){
                storyToUpdate = new CE_Story__c(Project_Start_Date__c = Date.today(), Publisher__c = UserInfo.getUserId());
            } else {
                storyToUpdate = [SELECT Name, Description__c, Service_Offering__c FROM CE_Story__c WHERE Id = :story.id LIMIT 1];
            }
            storyToUpdate.Description__c = story.description;
            storyToUpdate.Name = story.title;
            storyToUpdate.Service_Offering__c = story.serviceOffering;
            if(story.id == null){
                mStoryService.createStories(new List<CE_Story__c>{storyToUpdate});
                story.id = storyToUpdate.Id;
            } else {
                mStoryService.updateStories(new List<CE_Story__c>{storyToUpdate});
            }
            
            return story;
        } catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches stories in Status!=Planning and Activitie Status!=Draft, also filter's by provided filter
     * @param  request request object with filter and pagination info
     * @return         StoryResponse(page)
     */
    @RemoteAction
    public static CE_WebAppModels.StoryResponse getStories(CE_WebAppModels.StoryRequest request) {
        try{
            CE_WebAppModels.StoryResponse response = new CE_WebAppModels.StoryResponse();
            List<CE_WebAppModels.Story> result = new List<CE_WebAppModels.Story>();
            String soql = 'SELECT {0} FROM CE_Story__c WHERE Status__c != \'\''+CE_Constants.STORY_PLANNING_STATUS+'\'\''+
                           ' AND Id IN (SELECT CE_Story__c FROM CE_Activity__c WHERE Status__c != \'\''+CE_Constants.STATUS_DRAFT+'\'\') ';

            Integer pageSize = 25;
            String paginationSoql = '';
            if(request!=null){
                //Applying filter is any
                if(request.filter!=null&&request.filter.hasAnyFilter()){
                    if(request.filter.showOnlyCompleted!=null && request.filter.showOnlyCompleted)
                        soql += ' AND Status__c = \'\''+CE_Constants.STORY_COMPLETED_STATUS+'\'\'';
                    if(String.isNotEmpty(request.filter.storyTitle)){
                        soql += ' AND Name LIKE \'\'%'+String.escapeSingleQuotes(request.filter.storyTitle)+'%\'\'';
                    }
                    if(String.isNotEmpty(request.filter.serviceOffering)){
                        soql += ' AND Service_Offering__c = \'\''+String.escapeSingleQuotes(request.filter.serviceOffering)+'\'\'';
                    }
                    if(String.isNotEmpty(request.filter.activityTitle) || String.isNotEmpty(request.filter.activityPhase)){
                        String activityFilter = ' AND Id IN (SELECT CE_Story__c FROM CE_Activity__c WHERE ';
                        if(String.isNotEmpty(request.filter.activityTitle)){
                            activityFilter += 'Name LIKE \'\'%'+String.escapeSingleQuotes(request.filter.activityTitle)+'%\'\'';
                        }
                        if(String.isNotEmpty(request.filter.activityPhase)){
                            if(String.isNotEmpty(request.filter.activityTitle))
                                activityFilter += ' AND ';
                            activityFilter += 'Status__c = \'\''+String.escapeSingleQuotes(request.filter.activityPhase)+'\'\'';
                        }
                        activityFilter += ' AND Status__c != \'\''+CE_Constants.STATUS_DRAFT+'\'\')';
                        soql += activityFilter;
                    }
                }
                pageSize = request.pageSize==null?pageSize:request.pageSize;
                if(pageSize<1) pageSize = 1;
                paginationSoql = ' LIMIT '+pageSize;
                if(request.page!=null)
                    paginationSoql += ' OFFSET '+((request.page - 1)*pageSize);
            } else {
                //If no filter just return first 25 stories
                paginationSoql = ' LIMIT '+pageSize;
            }
            String selectQuery = String.format(soql, new List<String>{STORY_FIELDS_MEMBER})+paginationSoql;
            System.debug(selectQuery);
            List<CE_Story__c> stories = Database.query(selectQuery);
            AggregateResult countResults = Database.query(String.format(soql, new List<String>{ COUNT_FIELD }));
            response.totalItems = (Integer)countResults.get('result');
            response.totalPages = response.totalItems / pageSize + 1;
            //Collect activities ids and stories
            Set<Id> activitiesIds = new Set<Id>();
            Map<Id, CE_WebAppModels.Story> storiesMap = new Map<Id, CE_WebAppModels.Story>();
            for(CE_Story__c story : stories){
                activitiesIds.addAll(new Map<Id, CE_Activity__c>(story.Activities__r).keySet());
                CE_WebAppModels.Story storyDto = new CE_WebAppModels.Story(story);
                result.add(storyDto);
                storiesMap.put(story.Id,storyDto);
            }
            //Querying activities and adding them to the corresponding stories
            List<CE_Activity__c> activities = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c WHERE Id IN :activitiesIds');
            for(CE_Activity__c activity : activities){
                storiesMap.get(activity.CE_Story__c).activities.add(new CE_WebAppModels.Activity(activity));
            }
            response.stories = result;
            return response;
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Registers current user to an activity
     * @param id Activity Id
     */
    @RemoteAction
    public static void registerToActivity(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            mActivityService.registerMember(UserInfo.getUserId(), new CE_Activity__c(Id = id));
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Cancels an Activity. Sets Activity.Status = Canceled.
     * @param id Activity Id
     */
    @RemoteAction
    public static void cancelActivity(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            mActivityService.updateActivities(new List<CE_Activity__c>{new CE_Activity__c(Id = id, Status__c = CE_Constants.STATUS_CANCELED)});
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Completes an Activity. Sets Activity.Status = Completed
     * @param id Activity Id
     */
    @RemoteAction
    public static void completeActivity(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            mActivityService.updateActivities(new List<CE_Activity__c>{new CE_Activity__c(Id = id, Status__c = CE_Constants.STATUS_COMPLETED)});
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Cancel a Story. Sets Activity.Status = Canceled
     * @param id Story Id
     */
    @RemoteAction
    public static void cancelStory(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            mStoryService.updateStories(new List<CE_Story__c>{new CE_Story__c(Id = id, Status__c = CE_Constants.STATUS_CANCELED)});
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Sends some email to the members. Wasn't clear from req what email must be sent
     * @param usersIds Collection of members' ids
     */
    @RemoteAction
    public static void emailToMember(List<Id> usersIds){
        if(usersIds==null || usersIds.size() == 0) throw new WebAppException('Seems like you\'ve tried to send email to nobody');
        try{
            List<User> users = [SELECT Email FROM User Where Id IN :usersIds];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(User usr : users){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{usr.Email}; 

                // Assign the addresses for the To and CC lists to the mail object.
                mail.setToAddresses(toAddresses);

                // Specify the address used when the recipients reply to the email. 
                mail.setReplyTo('support@acme.com');

                // Specify the name used as the display name.
                mail.setSenderDisplayName('CrowdExchange Support');
                // Specify the subject line for your email address.
                mail.setSubject('Subject');

                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);

                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);

                // Specify the text content of the email.
                mail.setPlainTextBody('Message');
                mails.add(mail);
            }
            
            // Send the email you have created.
            Messaging.sendEmail(mails);
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Assignes a member to an activity
     * @param  activityId Activity Id
     * @param  userId     User Id
     * @return            returns Assigned users registration DTO
     */
    @RemoteAction
    public static CE_WebAppModels.ActivityRegitration assignMember(Id activityId, Id userId){
        if(activityId==null) throw new WebAppException('Id cannot be null');
        try{
            
            mActivityService.assignMemberToActivity(new User(Id = userId), new CE_Activity__c(Id = activityId));
            CE_Registration__c reg = [SELECT Registration_Date__c, User__r.FirstName, User__r.LastName, User__r.SmallPhotoUrl FROM CE_Registration__c 
                                    WHERE CE_Activity__c =:activityId AND User__c = :userId LIMIT 1];
            CE_WebAppModels.ActivityRegitration result = new CE_WebAppModels.ActivityRegitration(reg);
            User usr = [SELECT (SELECT Skill__c, Skill__r.Name FROM Member_Skills__r),(SELECT Id FROM Submissions__r) FROM User WHERE Id = :userId];
            result.user.addSkills(usr.Member_Skills__r);
            result.user.activitiesDone = usr.Submissions__r.size();
            return result;
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Removes an assignment from Activity
     * @param activityId Activity Id
     */
    @RemoteAction
    public static void unassignMember(Id activityId){
        if(activityId==null) throw new WebAppException('Id cannot be null');
        try{
            mActivityService.assignMemberToActivity(new User(Id = null), new CE_Activity__c(Id = activityId));
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches recommended members for Activity
     * @param  id Activity Id
     * @return    Collection of recommended members DTO
     */
    @RemoteAction
    public static List<CE_WebAppModels.UserModel> getRecommendedMembers(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            List<CE_ActivitySkills__c> actSkills = [SELECT Skill__c FROM CE_ActivitySkills__c WHERE CE_Activity__c = :id];
            Set<Id> skillsIds = new Set<Id>();
            for(CE_ActivitySkills__c actSkill : actSkills)
                skillsIds.add(actSkill.Skill__c);
            List<User> users = [SELECT FirstName, LastName, SmallPhotoUrl,(SELECT Skill__c, Skill__r.Name FROM Member_Skills__r),(SELECT Id FROM Submissions__r)
                                FROM User 
                                WHERE Id IN (SELECT Member__c FROM CE_UserSkill__c WHERE Skill__c IN :skillsIds)];
            List<CE_WebAppModels.UserModel> result = new List<CE_WebAppModels.UserModel>();
            for(User usr : users){
                CE_WebAppModels.UserModel dto = new CE_WebAppModels.UserModel(usr);
                dto.addSkills(usr.Member_Skills__r);
                result.add(dto);
            }
            return result;
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Default Registrants collection page size
     */
    private static final Integer REGISTRANTS_PAGE_SIZE = 8;
    /**
     * Fetches registrants for an Activity
     * @param  id       Activity Id
     * @param  page     Page number. First page = 1
     * @param  pageSize Page's size
     * @return          Collection of Activity Registration DTO
     */
    @RemoteAction
    public static List<CE_WebAppModels.ActivityRegitration> getRegistrants(Id id, Integer page, Integer pageSize){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            List<CE_Registration__c> registrations = mActivityService.getRegistrations(new CE_Activity__c(Id = id));

            Map<Id, CE_WebAppModels.ActivityRegitration> resultMap = new Map<Id, CE_WebAppModels.ActivityRegitration>();
            for(CE_Registration__c reg : registrations){
                resultMap.put(reg.User__c, new CE_WebAppModels.ActivityRegitration(reg));
            }
            if(page==null||page<1)
                page = 1;
            if(pageSize==null||pageSize<0)
                pageSize = REGISTRANTS_PAGE_SIZE;
            Integer offset = (page-1)*pageSize;
            List<User> users = [SELECT (SELECT Skill__c, Skill__r.Name FROM Member_Skills__r),(SELECT Id FROM Submissions__r) FROM User WHERE Id IN :resultMap.keySet() LIMIT :pageSize OFFSET :offset];
            for(User usr : users){
                resultMap.get(usr.Id).user.addSkills(usr.Member_Skills__r);
                resultMap.get(usr.Id).user.activitiesDone = usr.Submissions__r.size();
            }
            return resultMap.values();
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches assigned member registration
     * @param  id       Activity Id
     * @return          Collection of Activity Registration DTO
     */
    @RemoteAction
    public static CE_WebAppModels.ActivityRegitration getAssignedMember(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            CE_Activity__c activity = [SELECT Assigned_Member__c FROM CE_Activity__c WHERE Id = :id];
            if(activity.Assigned_Member__c==null) return null;
            CE_Registration__c registration = [SELECT Name,CE_Activity__c,Registration_Date__c,User__c,User__r.Name,User__r.FirstName,User__r.LastName,User__r.SmallPhotoUrl 
                                            FROM CE_Registration__c 
                                            WHERE User__c = :activity.Assigned_Member__c AND CE_Activity__c = :id LIMIT 1];
            User usr = [SELECT (SELECT Skill__c, Skill__r.Name FROM Member_Skills__r),(SELECT Id FROM Submissions__r) FROM User WHERE Id = :activity.Assigned_Member__c];
            CE_WebAppModels.ActivityRegitration result = new CE_WebAppModels.ActivityRegitration(registration);
            result.user.activitiesDone = usr.Submissions__r.size();
            result.user.addSkills(usr.Member_Skills__r);
            return result;
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Creates basic activity and requirements from default requirements if activity model addDefaultRequirements is true.
     * @param  act activity DTO object
     * @return     created activity
     */
    @RemoteAction
    public static CE_WebAppModels.Activity createActivity(CE_WebAppModels.Activity act){
        if(act==null) throw new WebAppException('Activity cannot be null');
        try{
            CE_Activity__c activity = act.getSObject();
            activity.CE_Story__c = act.storyId;
            activity.Publisher__c = UserInfo.getUserId();
            mActivityService.createActivities(new List<CE_Activity__c>{activity});
            act.id = activity.Id;
            
            if(act.addDefaultRequirements != null && act.addDefaultRequirements) {
                
                // loading all default requirements
                List<CE_Default_Requirement__c> defaultRequirements = mActivityService.getDefaultRequirements();
                
                List<CE_Requirement__c> requirementList = new List<CE_Requirement__c>();
                Decimal counter = 1.0;
                for(CE_Default_Requirement__c dr:defaultRequirements) {
                    CE_Requirement__c requirement = new CE_Requirement__c ();
                    requirement.Requirement_Number__c = ''+ (counter.setScale(1));
                    requirement.CE_Activity__c = activity.Id;
                    requirement.Description__c = dr.Description__c;
                    requirement.Type__c = dr.Type__c;
                    requirement.Requirement_Weight__c = dr.Requirement_Weight__c;
                    counter++;
                    requirementList.add(requirement);
                }
                
                // inserting all new requirements created from default requirements
                if(!requirementList.isEmpty()) {
                    insert requirementList;
                    
                    // adding requirements to activity model
                    act.addRequirements(requirementList);
                }
            }
            return act;
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Deletes basic activity
     * @param  id activity Id
     * @return     created activity
     */
    @RemoteAction
    public static void deleteActivity(Id id){
        if(Id==null) throw new WebAppException('Activity cannot be null');
        try{
            mActivityService.deleteActivities(new List<CE_Activity__c>{new CE_Activity__c(Id = id)});
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Upserts activity with all child records
     * @param act Activity object DTO
     */
    @RemoteAction
    public static void upsertActivity(CE_WebAppModels.Activity act){
        if(act==null) throw new WebAppException('Activity cannot be null');
        Savepoint sp = Database.setSavepoint();
        try{
            List<sObject> objsToInsert = new List<sObject>();
            List<sObject> objsToUpdate = new List<sObject>();
            List<sObject> objsToDelete = new List<sObject>();
            Id activityId = act.id;
            CE_Activity__c activity = null;
            if(String.isBlank(activityId)){
                activity = act.getSObject();
                insert activity;
            } else {
                objsToUpdate.add(act.getSObject());
                //Retrieving current activity with all child objects
                activity = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c WHERE Id = :activityId LIMIT 1');
            }
    
            //Milestones update
            if(act.milestones!=null){
                //Creating standard milestones map Name->Milestone
                Map<String, CE_Milestone__c> stdMilestonesMap = new Map<String, CE_Milestone__c>();
                List<CE_Milestone__c> stdMilestones = [SELECT Name FROM CE_Milestone__c];
                for(CE_Milestone__c stdMilestone : stdMilestones)
                    stdMilestonesMap.put(stdMilestone.Name, stdMilestone);
                //Creating existing activity milestones map Name->Milestone
                Map<String, CE_ActivityMilestones__c> milestonesMap = new Map<String, CE_ActivityMilestones__c>();
                for(CE_ActivityMilestones__c milestone : activity.ActivityMilestones__r)
                    milestonesMap.put(milestone.CE_Milestone__r.Name, milestone);
                for(CE_WebAppModels.ActivityMilestone milestone : act.milestones){
                    CE_ActivityMilestones__c actMilestone = milestonesMap.get(milestone.name);
                    if(actMilestone==null){
                        actMilestone = milestone.getSObject();
                        actMilestone.CE_Activity__c = activity.Id;
                        actMilestone.CE_Milestone__c = stdMilestonesMap.get(milestone.name).Id;
                        objsToInsert.add(actMilestone);
                    } else{
                        actMilestone.Scheduled_Date__c = milestone.scheduledDate; 
                        objsToUpdate.add(actMilestone);
                    }
                }
            }
            System.debug(act.requirements);
            //Requirements update
            if(act.requirements!=null){
                //Map is used to detect missed requirements
                Map<Id, CE_Requirement__c> requirementsMap = new Map<Id, CE_Requirement__c>(activity.Requirements__r);
                List<CE_WebAppModels.ActivityRequirement> newRootDtoRequirements = new List<CE_WebAppModels.ActivityRequirement>();
                List<CE_Requirement__c> newRootRequirements = new List<CE_Requirement__c>();
                for(CE_WebAppModels.ActivityRequirement requirement : act.requirements){
                    if(String.isBlank(requirement.id)){
                        //Need to insert parent first before children
                        newRootDtoRequirements.add(requirement);
                        CE_Requirement__c req = requirement.getSObject();
                        req.CE_Activity__c = activity.Id;
                        newRootRequirements.add(req);
                        continue;
                    } else {
                        objsToUpdate.add(requirement.getSObject());
                        requirementsMap.remove(requirement.id);
                    }

                    if(requirement.childRequirements!=null){
                        for(CE_WebAppModels.ActivityRequirement childRequirement : requirement.childRequirements){
                            if(String.isBlank(childRequirement.id)){
                                CE_Requirement__c req = childRequirement.getSObject();
                                req.Parent_Requirement__c = requirement.id;
                                req.CE_Activity__c = activity.Id;
                                objsToInsert.add(req);
                            } else {
                                objsToUpdate.add(childRequirement.getSObject());
                                requirementsMap.remove(childRequirement.id);
                            }
                        }
                    }
                }
                //Inserting new root requirements and adding to insert all their child requirements
                if(newRootRequirements.size()>0) insert newRootRequirements;
                for(Integer i = 0; i< newRootRequirements.size(); i++){
                    CE_WebAppModels.ActivityRequirement requirement = newRootDtoRequirements[i];
                    for(CE_WebAppModels.ActivityRequirement childRequirement : requirement.childRequirements){
                        CE_Requirement__c req = childRequirement.getSObject();
                        req.Parent_Requirement__c = newRootRequirements[i].Id;
                        req.CE_Activity__c = activity.Id;
                        objsToInsert.add(req);
                    }
                }
                //Delete missed requirements
                objsToDelete.addAll((List<sObject>)requirementsMap.values());
            }
            
            //Activity skills update
            if(act.codeTypes!=null){
                if(act.codeTypes.size()==0)
                    objsToDelete.addAll((List<sObject>)activity.Activity_Skills__r); // if empty just remove all existing skills
                else {
                    
                    //Map for tracking deleted skills
                    Map<Id, CE_ActivitySkills__c> existingSkills = new Map<Id,CE_ActivitySkills__c>(activity.Activity_Skills__r);
                    for(CE_WebAppModels.CodeType codeType : act.codeTypes){
                        if(String.isNotBlank(codeType.id)){
                            //updating skill
                            CE_ActivitySkills__c existingSkill = existingSkills.get(codeType.id);
                            //If skill wasn't found seems like someone already deleted it
                            if(existingSkill != null){
                                // If skill exists just do nothing
                                existingSkills.remove(existingSkill.Id);
                            } else  {
                                //just insert it again
                                objsToInsert.add(new CE_ActivitySkills__c(Skill__c = codeType.skillId, CE_Activity__c = activity.Id));
                            }
                        } else {
                            //Inserting skill
                            objsToInsert.add(new CE_ActivitySkills__c(Skill__c = codeType.skillId, CE_Activity__c = activity.Id));
                        }
                    }
                    //Deleted all missing skills
                    objsToDelete.addAll((List<sObject>)existingSkills.values());
                }
            }
            //Prizes update
            if((act.noPrizes == null || act.noPrizes) || (act.prizes != null && act.prizes.size() == 0)) {
                //If no Prizes was set delete all awards if any.
                objsToDelete.addAll((List<sObject>)[SELECT Id FROM CE_Award__c WHERE CE_Activity__c = :activity.Id]);
            } else {
                if(act.prizes!=null){
                    Map<Integer, CE_Award__c> awardsMap = new Map<Integer, CE_Award__c>();
                    for(CE_Award__c award : activity.Awards__r)
                        awardsMap.put(award.Place__c.intValue(), award);
                    for(CE_WebAppModels.Prize prize : act.prizes){
                        CE_Award__c award = awardsMap.get(prize.place);
                        //If award for place was found update it
                        if(award!=null){
                            award.Payment__c = prize.amount;
                            objsToUpdate.add(award);
                        } else {
                            //If not insert new award
                            objsToInsert.add(new CE_Award__c(Payment__c = prize.amount, Place__c = prize.place, CE_Activity__c = activity.Id));
                        }
                    }
                }   
            }

            
            insert objsToInsert;
            update objsToUpdate;
            delete objsToDelete;

        }catch(Exception ex){
            Database.rollback(sp);
            //throw new WebAppException();
            throw new WebAppException();
        }
    }
    
    /**
     * Searches members by FirstName, LastName, Organization, Role, User skill and Internal project skill
     * @param  request search request with filters(optional)
     * @return         requested page with totalItems count information
     */
    @RemoteAction
    public static CE_WebAppModels.MembersSearchResponse searchMembers(CE_WebAppModels.MembersSearchRequest request){
        if(request==null||String.isBlank(request.query)) throw new WebAppException('Query cannot be empty');
        try{
            String query = String.escapeSingleQuotes(request.query);
            //Searching in Internal projects skills
            String soql = 'SELECT CE_Internal_Project__r.Member__c FROM CE_InternalProjectSkill__c WHERE Skill__r.Name LIKE \'\'%{0}%\'\'';
            Set<Id> usersIds = new Set<Id>();
            soql = String.format(soql, new List<String>{query});
            List<CE_InternalProjectSkill__c> intProjectSkills = (List<CE_InternalProjectSkill__c>)Database.query(soql);
            for(CE_InternalProjectSkill__c skill : intProjectSkills){
                if(skill.CE_Internal_Project__r.Member__c!=null)
                    usersIds.add(skill.CE_Internal_Project__r.Member__c);
            }
            //Searching in User's skills
            soql = 'SELECT Member__c FROM CE_UserSkill__c WHERE Skill__r.Name LIKE \'\'%{0}%\'\'';
            List<CE_UserSkill__c> matchedSkills = (List<CE_UserSkill__c>)Database.query(String.format(soql, new List<String>{query}));
            for(CE_UserSkill__c skill : matchedSkills){
                usersIds.add(skill.Member__c);
            }
            soql = 'SELECT {1} FROM User WHERE (Name LIKE \'\'%{0}%\'\' OR Username LIKE \'\'%{0}%\'\' OR Id IN :usersIds) AND Crowd_Exchange_User_Type__c = \'\''+CE_Constants.MEMBER+'\'\'';
            String filterSoql = '';
            //Applying filters
            if(request.filter!=null){   
                if(String.isNotBlank(request.filter.firstName)){
                    filterSoql += ' AND FirstName LIKE \'\'%'+String.escapeSingleQuotes(request.filter.firstName)+'%\'\'';
                }
                if(String.isNotBlank(request.filter.lastName)){
                    filterSoql += ' AND LastName LIKE \'\'%'+String.escapeSingleQuotes(request.filter.lastName)+'%\'\'';
                }
                if(String.isNotBlank(request.filter.organization)){
                    filterSoql += ' AND Crowd_Exchange_Organization__c LIKE \'\'%'+String.escapeSingleQuotes(request.filter.organization)+'%\'\'';
                }
                if(String.isNotBlank(request.filter.role)){
                    filterSoql += ' AND Crowd_Exchange_User_Type__c LIKE \'\'%'+String.escapeSingleQuotes(request.filter.role)+'%\'\'';
                }
                soql += filterSoql;
            }
            //Applying pagination
            String paginationSoql = '';
            if(request.pageSize!=null&&request.pageSize>1&&request.page!=null&&request.page>0){
                paginationSoql += ' LIMIT '+request.pageSize+' OFFSET '+(request.page - 1)*request.pageSize;
            }
            List<User> users = (List<User>)Database.query(String.format(soql+filterSoql+paginationSoql, new List<String>{query, MEMBER_FIELDS}));
            List<CE_WebAppModels.UserModel> result = new List<CE_WebAppModels.UserModel>();
            for(User usr : users){
                result.add(new CE_WebAppModels.UserModel(usr));
            }
            CE_WebAppModels.MembersSearchResponse response = new CE_WebAppModels.MembersSearchResponse();
            //Fetching totalItems count
            AggregateResult countResults = Database.query(String.format(soql+filterSoql, new List<String>{ query, COUNT_FIELD }));
            response.totalItems = (Integer)countResults.get('result');
            response.members = result;
            return response;
        }catch(Exception ex){
           throw new WebAppException(); 
        }  
    }
    /**
     * Searches activities by Title. 
     * @param  request activities search request with filters(optional)
     * @return         requested page with totalItems count information
     */
    @RemoteAction
    public static CE_WebAppModels.ActivitiesSearchResponse searchActivities(CE_WebAppModels.ActivitiesSeachRequest request){
        if(request==null||String.isBlank(request.query)) throw new WebAppException('Query cannot be empty');
        try{
            Set<Id> activitiesIds = new Set<Id>();
            //Searching in Activity's skills
            String soql = 'SELECT CE_Activity__c FROM CE_ActivitySkills__c WHERE Skill__r.Name LIKE \'\'%{0}%\'\'';
            List<CE_ActivitySkills__c> matchedSkills = (List<CE_ActivitySkills__c>)Database.query(String.format(soql, new List<String>{String.escapeSingleQuotes(request.query)}));
            for(CE_ActivitySkills__c skill : matchedSkills){
                activitiesIds.add(skill.CE_Activity__c);
            }
            soql = 'SELECT {1} FROM CE_Activity__c WHERE (Name LIKE \'\'%{0}%\'\' OR Id IN :activitiesIds) AND Status__c != \'\''+CE_Constants.STATUS_DRAFT+'\'\'';
            String filterSoql = '';
            //Applying the filters
            if(request.filter!=null){   
                if(String.isNotBlank(request.filter.title)){
                    filterSoql += ' AND Name LIKE \'\'%'+String.escapeSingleQuotes(request.filter.title)+'%\'\'';
                }
                if(String.isNotBlank(request.filter.challengeType)){
                    filterSoql += ' AND Challenge_Type__c = \'\''+String.escapeSingleQuotes(request.filter.challengeType)+'\'\'';
                }
                if(String.isNotBlank(request.filter.phase)){
                    filterSoql += ' AND Status__c = \'\''+String.escapeSingleQuotes(request.filter.phase)+'\'\'';
                }
                soql += filterSoql;
            }
            String paginationSoql = '';
            //Applying pagination
            if(request.pageSize!=null&&request.pageSize>1&&request.page!=null&&request.page>0){
                paginationSoql += ' LIMIT '+request.pageSize+' OFFSET '+(request.page - 1)*request.pageSize;
            }
            List<CE_Activity__c> activities = (List<CE_Activity__c>)Database.query(String.format(soql+filterSoql+paginationSoql, new List<String>{String.escapeSingleQuotes(request.query), ACTIVITY_LIGHT_FIELDS}));
            List<CE_WebAppModels.Activity> result = new List<CE_WebAppModels.Activity>();
            for(CE_Activity__c activity : activities)
                result.add(new CE_WebAppModels.Activity(activity));
            CE_WebAppModels.ActivitiesSearchResponse response = new CE_WebAppModels.ActivitiesSearchResponse();
            //Fetching totalItems count
            AggregateResult countResults = Database.query(String.format(soql+filterSoql, new List<String>{ String.escapeSingleQuotes(request.query), COUNT_FIELD }));
            response.totalItems = (Integer)countResults.get('result');
            response.activities = result;
            return response;
        }catch(Exception ex){
           throw new WebAppException(); 
        }   
    }
    /**
     * Searches stories by Title
     * @param  request stories search request with filters(optional)
     * @return         requested page with totalItems count information
     */
    @RemoteAction
    public static CE_WebAppModels.StoriesSearchResponse searchStories(CE_WebAppModels.StoriesSeachRequest request){
        if(request==null||String.isBlank(request.query)) throw new WebAppException('Query cannot be empty');
        try{
            String soql = 'SELECT {1} FROM CE_Story__c WHERE Name LIKE \'\'%{0}%\'\' AND Status__c != \'\''+CE_Constants.STORY_PLANNING_STATUS+'\'\'';
            String filterSoql = '';
            //Applying the filters
            if(request.filter!=null){   
                if(String.isNotBlank(request.filter.title)){
                    filterSoql += ' AND Name LIKE \'\'%'+String.escapeSingleQuotes(request.filter.title)+'%\'\'';
                }
                if(String.isNotBlank(request.filter.serviceOffering)){
                    filterSoql += ' AND Service_Offering__c = \'\''+String.escapeSingleQuotes(request.filter.serviceOffering)+'\'\'';
                }
                if(String.isNotBlank(request.filter.status)){
                    filterSoql += ' AND Status__c = \'\''+String.escapeSingleQuotes(request.filter.status)+'\'\'';
                }
                soql += filterSoql;
            }
            String paginationSoql = '';
            //Applying pagination
            if(request.pageSize!=null&&request.pageSize>1&&request.page!=null&&request.page>0){
                paginationSoql += ' LIMIT '+request.pageSize+' OFFSET '+(request.page - 1)*request.pageSize;
            }
            List<CE_Story__c> stories = (List<CE_Story__c>)Database.query(String.format(soql+filterSoql+paginationSoql, new List<String>{String.escapeSingleQuotes(request.query),STORY_FIELDS_MEMBER}));
            List<CE_WebAppModels.Story> result = new List<CE_WebAppModels.Story>();
            for(CE_Story__c story : stories)
                result.add(new CE_WebAppModels.Story(story));
            CE_WebAppModels.StoriesSearchResponse response = new CE_WebAppModels.StoriesSearchResponse();
            //Fetching totalItems count
            AggregateResult countResults = Database.query(String.format(soql+filterSoql, new List<String>{ String.escapeSingleQuotes(request.query), COUNT_FIELD }));
            response.totalItems = (Integer)countResults.get('result');
            response.stories = result;
            return response;
        }catch(Exception ex){
           throw ex;
        }     
    }
    /**
     * Searches all records(Members, Activities and Stories)
     * @param  request search request with filters(optional)
     * @return         requested page with totalItems count information
     */
    @RemoteAction
    public static CE_WebAppModels.AllRecordsSearchResponse search(CE_WebAppModels.PaginatedSearchRequest request){
        if(request==null || String.isBlank(request.query)) throw new WebAppException('Query cannot be empty');
        try{
            Integer activitiesCount = 0;
            Integer storiesCount = 0;
            Integer membersCount = 0;
            User currentUser = [SELECT Crowd_Exchange_User_Type__c FROM User WHERE Id = :UserInfo.getUserId()];
            String query = String.escapeSingleQuotes(request.query);

            //SOQL query for the stories
            String storiesSoql = 'SELECT {1} FROM CE_Story__c WHERE Name LIKE \'\'%{0}%\'\' AND Status__c != \'\''+CE_Constants.STORY_PLANNING_STATUS+'\'\'';

            Set<Id> activitiesIds = new Set<Id>();
            //Searching in Activity's skills
            String soql = 'SELECT CE_Activity__c FROM CE_ActivitySkills__c WHERE Skill__r.Name LIKE \'\'%{0}%\'\'';
            List<CE_ActivitySkills__c> matchedActivitySkills = (List<CE_ActivitySkills__c>)Database.query(String.format(soql, new List<String>{query}));
            for(CE_ActivitySkills__c skill : matchedActivitySkills){
                activitiesIds.add(skill.CE_Activity__c);
            }
            //SOQL query for the activities
            String activitiesSoql = 'SELECT {1} FROM CE_Activity__c WHERE (Name LIKE \'\'%{0}%\'\' OR Id IN :activitiesIds) AND Status__c != \'\''+CE_Constants.STATUS_DRAFT+'\'\'';
            //Searching in Internal project skills
            soql = 'SELECT CE_Internal_Project__r.Member__c FROM CE_InternalProjectSkill__c WHERE Skill__r.Name LIKE \'\'%{0}%\'\'';
            Set<Id> usersIds = new Set<Id>();
            soql = String.format(soql, new List<String>{query});
            List<CE_InternalProjectSkill__c> intProjectSkills = (List<CE_InternalProjectSkill__c>)Database.query(soql);
            for(CE_InternalProjectSkill__c skill : intProjectSkills){
                if(skill.CE_Internal_Project__r.Member__c!=null)
                    usersIds.add(skill.CE_Internal_Project__r.Member__c);
            }
            //Searching in Users' skills
            soql = 'SELECT Member__c FROM CE_UserSkill__c WHERE Skill__r.Name LIKE \'\'%{0}%\'\'';
            List<CE_UserSkill__c> matchedMembersSkills = (List<CE_UserSkill__c>)Database.query(String.format(soql, new List<String>{query}));
            for(CE_UserSkill__c skill : matchedMembersSkills){
                usersIds.add(skill.Member__c);
            }
            //SOQL query for the members
            String membersSoql = 'SELECT {1} FROM User WHERE (Name LIKE \'\'%{0}%\'\' OR Username LIKE \'\'%{0}%\'\' OR Id IN :usersIds) AND Crowd_Exchange_User_Type__c = \'\''+CE_Constants.MEMBER+'\'\'';

            // Fetching total items count
            AggregateResult countResults = Database.query(String.format(activitiesSoql, new List<String>{ query, COUNT_FIELD }));
            activitiesCount = (Integer)countResults.get('result');
            countResults = Database.query(String.format(membersSoql, new List<String>{ query, COUNT_FIELD }));
            membersCount = (Integer)countResults.get('result');
            countResults = Database.query(String.format(storiesSoql, new List<String>{ query, COUNT_FIELD }));
            storiesCount = (Integer)countResults.get('result');
            // END of Fetching total items count
            if(request.pageSize==null) request.pageSize = 10;
            if(request.page==null) request.page = 1;

            String paginationSoql = null;
            Integer recordsLeft = request.pageSize;
            Integer offset = request.pageSize * (request.page - 1);
            List<CE_WebAppModels.SearchItem> result = new List<CE_WebAppModels.SearchItem>();
            if(currentUser.Crowd_Exchange_User_Type__c == CE_Constants.PUBLISHER){
                //Fetching records in the following order: Members, Activities, Stories
                
                //If current offset larger than total rows there's no need to fetch records
                if(offset <= membersCount){
                    paginationSoql = ' LIMIT '+recordsLeft+' OFFSET '+offset; 
                    List<User> users = (List<User>)Database.query(String.format(membersSoql+paginationSoql, new List<String>{query, MEMBER_FIELDS}));
                    recordsLeft -= users.size();
                    for(User usr : users)
                        result.add(new CE_WebAppModels.SearchItem(new CE_WebAppModels.UserModel(usr), 'user'));
                }
                offset = offset-membersCount;
                //If current offset larger than total rows or requested page was fetch there's no need to fetch records
                if(recordsLeft > 0 && offset <= (membersCount+activitiesCount)){
                    paginationSoql = ' LIMIT '+recordsLeft+' OFFSET '+(offset<0?0:offset); 
                    List<CE_Activity__c> activities = (List<CE_Activity__c>)Database.query(String.format(activitiesSoql+paginationSoql, new List<String>{query, ACTIVITY_LIGHT_FIELDS}));
                    for(CE_Activity__c activity : activities)
                        result.add(new CE_WebAppModels.SearchItem(new CE_WebAppModels.Activity(activity), 'activity'));
                }
                offset = offset-activitiesCount;
                //If current offset larger than total rows or requested page was fetch there's no need to fetch records
                if(recordsLeft > 0 && offset <= (membersCount+activitiesCount+storiesCount)){
                    paginationSoql = ' LIMIT '+recordsLeft+' OFFSET '+(offset<0?0:offset); 
                    List<CE_Story__c> stories = (List<CE_Story__c>)Database.query(String.format(storiesSoql+paginationSoql, new List<String>{query, STORY_FIELDS_MEMBER}));
                    for(CE_Story__c story : stories) 
                        result.add(new CE_WebAppModels.SearchItem(new CE_WebAppModels.Story(story), 'story'));
                }
            } else if(currentUser.Crowd_Exchange_User_Type__c == CE_Constants.MEMBER){
                //Fetching records in the following order: Activities, Stories, Members
                
                //If current offset larger than total rows there's no need to fetch records
                if(offset <= activitiesCount){
                    paginationSoql = ' LIMIT '+recordsLeft+' OFFSET '+offset;
                    List<CE_Activity__c> activities = (List<CE_Activity__c>)Database.query(String.format(activitiesSoql+paginationSoql, new List<String>{query, ACTIVITY_LIGHT_FIELDS}));
                    for(CE_Activity__c activity : activities)
                        result.add(new CE_WebAppModels.SearchItem(new CE_WebAppModels.Activity(activity), 'activity'));
                }
                offset = offset-activitiesCount;
                //If current offset larger than total rows or requested page was fetch there's no need to fetch records
                if(recordsLeft > 0 && offset <= (storiesCount+activitiesCount)){
                    paginationSoql = ' LIMIT '+recordsLeft+' OFFSET '+(offset<0?0:offset); 
                    List<CE_Story__c> stories = (List<CE_Story__c>)Database.query(String.format(storiesSoql+paginationSoql, new List<String>{query, STORY_FIELDS_MEMBER}));
                    for(CE_Story__c story : stories) 
                        result.add(new CE_WebAppModels.SearchItem(new CE_WebAppModels.Story(story), 'story'));
                }
                offset = offset-storiesCount;
                //If current offset larger than total rows or requested page was fetch there's no need to fetch records
                if(recordsLeft > 0 && offset <= (membersCount+activitiesCount+storiesCount)){
                    paginationSoql = ' LIMIT '+recordsLeft+' OFFSET '+(offset<0?0:offset); 
                    List<User> users = (List<User>)Database.query(String.format(membersSoql+paginationSoql, new List<String>{query, MEMBER_FIELDS}));
                    recordsLeft -= users.size();
                    for(User usr : users)
                        result.add(new CE_WebAppModels.SearchItem(new CE_WebAppModels.UserModel(usr), 'user'));
                }
            }

            CE_WebAppModels.AllRecordsSearchResponse response = new CE_WebAppModels.AllRecordsSearchResponse();
            response.records = result;
            response.totalItems = activitiesCount + storiesCount + membersCount;
            return response;
        }catch(Exception ex){
            throw ex;
        }
    }
    /**
     * Fetches unread notifications for the current user
     * @return unread notifications count
     */
    @RemoteAction
    public static Integer getUnreadNotificationsCount(){
        try{
            String userId = UserInfo.getUserId();
            AggregateResult countResults = [SELECT Count(CE_Notification__c) result FROM CE_User_Notification__c 
                                            WHERE Recipient__c = :userId AND Status__c = :CE_Constants.NOTIFICATION_UNREAD AND IsArchived__c = false];
            return (Integer)countResults.get('result');
        }catch(Exception ex){
           throw new WebAppException(); 
        }        
    }
    /**
     * Fetches inbox notifications for the current user
     * @param  page     page number. Starts from 1
     * @param  pageSize notifications page size
     * @return          inbox notifications
     */
    @RemoteAction
    public static CE_WebAppModels.NotificationsResponse getInboxNotifications(Integer page, Integer pageSize){
        try{
            return getNotifications(false, page, pageSize);
        }catch(Exception ex){
           throw new WebAppException(); 
        }
    }
    /**
     * Fetches sent notifications for the current user
     * @param  page     page number. Starts from 1
     * @param  pageSize notifications page size
     * @return          sent notifications
     */
    @RemoteAction
    public static CE_WebAppModels.NotificationsResponse getOutboxNotifications(Integer page, Integer pageSize){
        try{
            return getNotifications(true, page, pageSize);
        }catch(Exception ex){
           throw new WebAppException(); 
        }        
    }
    /**
     * Fetches notifications for the current user
     * @param  onlySent if TRUE, returns sent notifications
     * @param  page     page number. Starts from 1
     * @param  pageSize notifications page size
     * @return          notifications list
     */
    private static CE_WebAppModels.NotificationsResponse getNotifications(Boolean onlySent, Integer page, Integer pageSize){
        if(onlySent==null) onlySent = false;
        if(page==null || page < 1) page = 1;
        if(pageSize==null || pageSize < 1) pageSize = 10;
        Integer totalItems = 0;
        Id userId = UserInfo.getUserId();
        Set<Id> notificationsIds = new Set<Id>();
        String archivedStatus = CE_Constants.NOTIFICATION_ARCHIVED;
        String paginationSoql = ' LIMIT '+pageSize+' OFFSET '+(page - 1)*pageSize;
        String soql = 'SELECT Date_Sent__c, Notification_Text__c, Subject__c, Type__c, '+
                                'FromUser__r.FirstName, FromUser__r.LastName, FromUser__r.SmallPhotoUrl, FromUser__r.Email, '+
                                '(SELECT Status__c, Recipient__r.FirstName, Recipient__r.LastName, '+
                                        'Recipient__r.SmallPhotoUrl, Recipient__r.Email, Recipient__c '+
                                 'FROM NotificationRecipients__r) '+
                        'FROM CE_Notification__c';

        //Appending required filter
        if(onlySent){
            AggregateResult countResults = [SELECT Count(Id) result FROM CE_Notification__c WHERE FromUser__c = :userId AND IsArchivedBySender__c = false];
            totalItems = (Integer)countResults.get('result');
            //Fetching sent notifications
            soql += ' WHERE FromUser__c = :userId AND IsArchivedBySender__c = false' + paginationSoql;
        } else {
            AggregateResult countResults = [SELECT Count(CE_Notification__c) result FROM CE_User_Notification__c 
                                            WHERE Recipient__c = :userId AND IsArchived__c != true];
            totalItems = (Integer)countResults.get('result');
            //Fetching inbound notifications
            soql += ' WHERE Id In (SELECT CE_Notification__c FROM CE_User_Notification__c WHERE Recipient__c = :userId AND IsArchived__c = false)' + paginationSoql;
        }
        CE_WebAppModels.NotificationsResponse result = new CE_WebAppModels.NotificationsResponse();
        List<CE_Notification__c> notifications = (List<CE_Notification__c>)Database.query(soql);
        List<CE_WebAppModels.Notification> dtoList = new List<CE_WebAppModels.Notification>();
        for(CE_Notification__c notification : notifications){
            CE_WebAppModels.Notification dtoNotification = new CE_WebAppModels.Notification(notification);
            List<User> recipients = new List<User>();
            //Adding notification's recipients 
            for(CE_User_Notification__c junctionRecipient : notification.NotificationRecipients__r){
                if(!onlySent&&junctionRecipient.Recipient__c == userId){
                    //If user is recipient setting status for the notifications
                    dtoNotification.status = junctionRecipient.Status__c;
                }
                recipients.add(junctionRecipient.Recipient__r);
            }
            //if current user is publisher. setting status to the read by default
            if(onlySent){
                dtoNotification.status = CE_Constants.NOTIFICATION_READ;
            }
            dtoNotification.addRecipients(recipients);
            dtoList.add(dtoNotification);
        }
        result.notifications = dtoList;
        result.totalItems = totalItems;
        return result;
    }
    /**
     * Marks the notifications as READ for the current user
     * @param  id Norification__c id
     * @return    TRUE if success
     */
    @RemoteAction
    public static Boolean markNotificationAsRead(Id id){
        if(id == null) throw new WebAppException('Id cannot be NULL');
        try{
            String userId = UserInfo.getUserId();
            CE_User_Notification__c notification = [SELECT Status__c FROM CE_User_Notification__c 
                                                                        WHERE CE_Notification__c = :id AND Recipient__c = :userId LIMIT 1];
            notification.Status__c = CE_Constants.NOTIFICATION_READ;
            update notification;
            return true;
        } catch(Exception ex){
            return false;
        }
    }
    /**
     * Archives notification for the current user
     * @param id CE_Notification__c Id
     */
    @RemoteAction
    public static void archiveNotification(Id id){
        if(id == null) throw new WebAppException('Id cannot be NULL');
        try{
            String userId = UserInfo.getUserId();
            CE_Notification__c notification = [SELECT IsArchivedBySender__c, FromUser__c, (SELECT IsArchived__c, Recipient__c FROM NotificationRecipients__r) 
                                                                    FROM CE_Notification__c WHERE Id = :id LIMIT 1];
            //User is publisher, archive CE_Notification__c object
            if(notification.FromUser__c == userId){
                notification.IsArchivedBySender__c = true;
                update notification;
            } else {
                //Try to find user in recipients
                CE_User_Notification__c notificationRecipient = null;
                for(CE_User_Notification__c junctionRecipient : notification.NotificationRecipients__r){
                    if(junctionRecipient.Recipient__c == userId){
                        notificationRecipient = junctionRecipient;
                        break;
                    }
                }
                //Recipient was not found
                if(notificationRecipient==null) return;
                notificationRecipient.IsArchived__c = true;
                update notificationRecipient;
            }                                 
        } catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches activities in Public or In Registrations phases where current user is the Publisher
     * @return list of publisher's matched activities
     */
    @RemoteAction
    public static List<CE_WebAppModels.Activity> getPublisherActivities(){
        try{
            Id userId = UserInfo.getUserId();
            String soql = 'SELECT {0} FROM CE_Activity__c WHERE (Status__c = \'\''+CE_Constants.STATUS_PUBLIC+
                                        '\'\' OR Status__c = \'\''+CE_Constants.STATUS_IN_REGISTRATION+'\'\') AND Publisher__c = :userId';
            List<CE_Activity__c> activities = Database.query(String.format(soql, new List<String>{ACTIVITY_LIGHT_FIELDS}));
            List<CE_WebAppModels.Activity> response = new List<CE_WebAppModels.Activity>();
            for(CE_Activity__c activity : activities)
                response.add(new CE_WebAppModels.Activity(activity));
            return response;
        }catch(Exception ex){ throw new WebAppException(); }

    }
    
     /**
     * add Submission for an activity
     * @param  activity id 
     * @param  submission name (will be same as corresponding attachment file name)
     * @return       inserted ActivitySubmission DTO with Id
     */
    @RemoteAction
    public static CE_WebAppModels.ActivitySubmission addSubmission(String activityId, String submissionName) {
        if(String.isBlank(activityId)) throw new WebAppException('Activity Id is null for add submission call');
        try{
            CE_Submission__c submission = new CE_Submission__c();
            submission.Name = submissionName;
            submission.CE_Activity__c = activityId;
            submission.Submission_Timestamp__c = DateTime.now();
            submission.Submitting_Member__c = UserInfo.getUserId();
            
            // Creating a submission 
            submission = mSubmissionService.createSubmission(submission, new CE_Activity__c(id = activityId), null);
            
            //copies requirements to Submission Requirement table for given submission and activity
            List<CE_Submission_Requirement__c> submissionsRequirements = mSubmissionService.initializeScorecard(new CE_Activity__c(id = activityId), new List<CE_Submission__c>{submission});
            
            return new CE_WebAppModels.ActivitySubmission(submission);
        } catch(Exception ex){
            throw new WebAppException();
        }
    }
    
    /**
     * get all active Submission for an activity for current logged in user
     * @param  activity id 
     * @return       list of  ActivitySubmissions 
     */
    @RemoteAction
    public static List<CE_WebAppModels.ActivitySubmission> getSubmissions(String activityId) {
        if(String.isBlank(activityId)) throw new WebAppException('Activity Id is null for get Submissions call');
        try{
            
            // getting review date as it will be just after submission. 
            List<CE_ActivityMilestones__c> milestones = [SELECT CE_Milestone__c, Scheduled_Date__c
                FROM CE_ActivityMilestones__c
                WHERE CE_Activity__c = :activityId AND CE_Milestone__r.Name LIKE :CE_Constants.REVIEW_DATE_MILESTONE_NAME];
            
            // submission Due Date == Review Schedule date 
            Date submissionDueDate = (!milestones.isEmpty() ? milestones[0].Scheduled_Date__c : system.today());
            
            //getting all submission with submission attachment
            List<CE_Submission__c> submissions = mSubmissionService.getValidSubmissions(new CE_Activity__c(id = activityId)); 
            
            // Quering user with the Crowd_Exchange_User_Type__c 
            User usr = [SELECT Crowd_Exchange_User_Type__c FROM User WHERE Id = :UserInfo.getUserId()];
            
            List<CE_WebAppModels.ActivitySubmission> activitySubmissionList = new List<CE_WebAppModels.ActivitySubmission>();
            for(CE_Submission__c submission:submissions) {
                
                // If current user is a member user, then only add submission submitted by him/her. Else add all submission for publisher
                if(submission.Submitting_Member__c == Userinfo.getUserId() && usr.Crowd_Exchange_User_Type__c == CE_Constants.MEMBER){
                    activitySubmissionList.add(new CE_WebAppModels.ActivitySubmission(submission, submissionDueDate));
                    
                }else if(usr.Crowd_Exchange_User_Type__c == CE_Constants.PUBLISHER) {
                    activitySubmissionList.add(new CE_WebAppModels.ActivitySubmission(submission, submissionDueDate));
                }
            }
            return activitySubmissionList;
        } catch(Exception ex){
            throw new WebAppException();  
        }
    }
    
    /**
     * get Submission Requirments for a submission by id
     * @param  activity id 
     * @return       list of  SubmissionRequirement 
     */
    @RemoteAction
    public static List<CE_WebAppModels.SubmissionRequirement> getSubmissionRequirements(String submissionId) {
        if(String.isBlank(submissionId)) throw new WebAppException('submission Id is null for getSubmissionRequirments call');
        try{            
            List<CE_Submission_Requirement__c> submissionRequirements = [Select CE_Submission__c, Review_Comment__c, 
                                            CE_Requirement__r.Requirement_Weight__c, CE_Requirement__r.Requirement_Number__c, 
                                            CE_Requirement__r.Requirement_Evaluation__c, CE_Requirement__r.Description__c, CE_Requirement__r.Type__c,
                                            CE_Requirement__c, Evaluation_Score__c From CE_Submission_Requirement__c 
                                            where CE_Submission__c =: submissionId order by CE_Requirement__r.Requirement_Number__c ASC];
             
             List<CE_WebAppModels.SubmissionRequirement> submissionRequirementModelList = new  List<CE_WebAppModels.SubmissionRequirement>();
             for(CE_Submission_Requirement__c sr:submissionRequirements) {
                submissionRequirementModelList.add(new CE_WebAppModels.SubmissionRequirement(sr));
             }
             return submissionRequirementModelList;
        } catch(Exception ex){
            throw new WebAppException();  
        }
    }
    
    /**
     * method to save submission and submission requirements reviewed by reviewer.
     * @param  activity id 
     * @return      void
     */
    @RemoteAction
    public static void saveSubmissionReview(CE_WebAppModels.ActivitySubmission submissionModel, List<CE_WebAppModels.SubmissionRequirement> submissionRequirementModelList, boolean markReviewComplete) {
        try{
            
            if(submissionRequirementModelList != null && !submissionRequirementModelList.isEmpty()) {
                
                List<CE_Submission_Requirement__c> submissionRequirementList = new List<CE_Submission_Requirement__c>();
                for(CE_WebAppModels.SubmissionRequirement srModel: submissionRequirementModelList) {
                    if(!String.isEmpty(srModel.id)) {
                        submissionRequirementList.add(srModel.getSObject());
                    }
                }
                // updating the reviewed details.
                if(!submissionRequirementList.isEmpty()) update submissionRequirementList;
            }
            
            if(submissionModel != null && !String.isEmpty(submissionModel.id)) {
                CE_Submission__c submission = new CE_Submission__c(id = submissionModel.id);
                submission.Overall_Comment__c = submissionModel.overallComment;
                
                // Setting the Reviewer to the submission on initail review. 
                submission.Reviewed_By__c = Userinfo.getUserId();
                
                // calculating submission score.
                mSubmissionService.calculateSubmissionScore(submission);
                
                // if markReviewComplete is true, mark submission review as Review complete 
                if(markReviewComplete != null && markReviewComplete) {
                    submission.Status__c = CE_Constants.REVIEW_COMPLETE_STATUS;
                    // setting review date on marking the review as complete.
                    submission.Review_Date__c = DateTime.now();
                }
                
                // Updating the submission with review score. 
                update submission;
            }
            
        } catch(Exception ex){
            throw new WebAppException();  
        }
    }
    
    /**
     * method to delete Submission.
     * @param  activity id 
     * @return      void
     */
    @RemoteAction
    public static void deleteSubmission(String submissionId) {
        if(String.isBlank(submissionId)) throw new WebAppException('submission Id is null for deleteSubmission call');
        try{
            delete new CE_Submission__c(id = submissionId);
        } catch(Exception ex){
            throw new WebAppException();  
        }
    }  
    
    public class WebAppException extends Exception{}
    
    /**
     * Performs login for portal or community user
     * @param  Wrapper for login information 
     * @return     modified startURL with session to login
     */
    @RemoteAction
    public static String portalLogin(CE_WebAppModels.LoginInformation objLoginInformation){
    
        if(objLoginInformation != null){
            System.debug('Username: ' + objLoginInformation.username);
            System.debug('Password: ' + objLoginInformation.password);
        }
        
        // only perform login operation for a user with type Member or Publisher
        List<User> lstUser = [SELECT Id, FirstName, LastName, Crowd_Exchange_User_Type__c FROM User Where Username = :objLoginInformation.username
            AND IsActive = TRUE 
            AND (Crowd_Exchange_User_Type__c = :USERTYPE_MEMBER OR 
                Crowd_Exchange_User_Type__c = :USERTYPE_PUBLISHER)];
        
        
        if(lstUser != null && lstUser.size() > 0){
            System.debug('User found: ' + lstUser[0].FirstName + ' ' + lstUser[0].LastName);
        }
        
        if(lstUser.isEmpty()) {
            System.debug('No Users found');
            return '';
        }

        String storyPageUrl = getLandingPageUrl();

        /*
        // we can add different subviews for Member or publisher as below
        String storyPageUrl = Page.CrowdExchangeWebApp.getUrl() + '#'
            lstUser[0].Crowd_Exchange_User_Type__c + 'Story';

        // If we assume Story subviews for Member and Publisher would be memberStory and publisherStory respectively
        // above url will be constructed as /CrowdExchangeWebApp#memberStory or /CrowdExchangeWebApp#publisherStory
        */

        // call standard login method
        PageReference result =  Site.login(objLoginInformation.username, 
            objLoginInformation.password,
            storyPageUrl);
            
        if(result != null){
            System.debug('Login successful forwarding to: ' + result.getUrl());
        }

        return (result == null) ? '' : result.geturl(); 
    }
    
     /**
     * Internal method to return the Landing page URL
     * @return     string
     */
    private static string getLandingPageUrl() {
        return Page.CrowdExchangeWebApp.getUrl();
    }

    /**
     * Allows portal or community users to reset their own passwords
     * @param  string user name
     * @return     boolean
     */
    @RemoteAction
    public static Boolean resetPassword(String username){
        
        // only perform forgot password operation for a user with type Member or Publisher
        List<User> lstUser = [SELECT Id FROM User Where Username = :username
            AND IsActive = TRUE 
            AND (Crowd_Exchange_User_Type__c = :USERTYPE_MEMBER OR 
                Crowd_Exchange_User_Type__c = :USERTYPE_PUBLISHER)];
        
        // call standard forgot password method
        if(!lstUser.isEmpty()) {
            return Site.forgotPassword(username);
        } else {
            return false;
        }
    }
}