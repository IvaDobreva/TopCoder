public with sharing class CrowdExchangeRemoteController {
    private static IActivityService mActivityService = new ActivityService();
    private static IStoryService mStoryService = new StoryService();
    public CrowdExchangeRemoteController() {
        
    }
    
    @TestVisible private final static String ACTIVITY_LIGHT_FIELDS = 'Name, Description__c, hasAwards__c, Challenge_Type__c, Story__c, Status__c, '+
                                                ' Assigned_Member__c, Assigned_Member__r.FirstName, Assigned_Member__r.LastName, Assigned_Member__r.SmallPhotoUrl, '+
                                                'Story__r.Name, Story__r.Service_Offering__c,'+
                                                ' (SELECT Id FROM Registrations__r),'+
                                                ' (SELECT Id FROM Submissions__r),';
    @TestVisible private final static String ACTIVITY_FULL_FIELDS = 'Name, Description__c, hasAwards__c, Challenge_Type__c, Story__c, Status__c, '+
                                                ' Assigned_Member__c, Assigned_Member__r.FirstName, Assigned_Member__r.LastName, Assigned_Member__r.SmallPhotoUrl, '+
                                                'Story__r.Name, Story__r.Service_Offering__c,'+
                                                ' (SELECT Scheduled_Date__c, Completed_Date__c, Milestone__r.Name,Milestone__r.Display_In_Initial_Setup__c,Milestone__r.Default_Time_Period__c,Milestone__r.Step_Number__c FROM ActivityMilestones__r),'+
                                                ' (SELECT Skill__c, Skill__r.Name FROM Activity_Skills__r),'+
                                                ' (SELECT Type__c, Requirement_Weight__c, Requirement_Number__c, Description__c, Parent_Requirement__c FROM Requirements__r),'+
                                                ' (SELECT Registration_Date__c, User__r.FirstName, User__r.LastName, User__r.SmallPhotoUrl FROM Registrations__r),'+
                                                ' (SELECT Review_Date__c, Evaluation_Percentage__c, Reviewed_By__r.FirstName, Reviewed_By__r.LastName, Reviewed_By__r.SmallPhotoUrl, '+
                                                        'Status__c, Submission_Timestamp__c, Submitting_Member__r.FirstName, Submitting_Member__r.LastName, '+
                                                        'Submitting_Member__r.SmallPhotoUrl FROM Submissions__r),'+
                                                ' (SELECT Name, Description, ContentType, BodyLength, CreatedDate  FROM Attachments),'+
                                                ' (SELECT Place__c, Payment__c FROM Awards__r)';

    @TestVisible private final static String STORY_FIELDS = 'Service_Offering__c, Name, Description__c, Publisher__r.FirstName, Publisher__r.LastName, Publisher__r.SmallPhotoUrl,'+
                                                ' Publisher__r.Crowd_Exchange_Organization__c, Status__c';
    @TestVisible private final static String STORY_FIELDS_MEMBER = STORY_FIELDS + ', (SELECT Id FROM Activities__r WHERE Status__c != \''+Constants.STATUS_DRAFT+'\')';
    @TestVisible private final static String STORY_FIELDS_PUBLISHER = STORY_FIELDS + ', (SELECT Id FROM Activities__r)';
    
    private final static String COUNT_FIELD = 'Count(Id) result';
    /**
     * Fetches a story by id
     * @param  id   Story Id
     * @param  deep defines if need to fetch all activities with all child records
     * @return      Story object DTO
     */
    @RemoteAction
    public static WebAppModels.Story getStory(String id, Boolean deep) {
        try{
            if(String.isNotEmpty(id)){
                WebAppModels.Story response;
                Story__c story = null;
                User usr = [SELECT Crowd_Exchange_User_Type__c FROM User WHERE Id = :UserInfo.getUserId()];
                if(usr.Crowd_Exchange_User_Type__c == Constants.PUBLISHER)
                    story = Database.query('SELECT '+STORY_FIELDS_PUBLISHER+' FROM Story__c WHERE Id = :id LIMIT 1');
                else 
                    story = Database.query('SELECT '+STORY_FIELDS_MEMBER+' FROM Story__c WHERE Id = :id AND Status__c != :Constants.STORY_PLANNING_STATUS LIMIT 1');
                response = new WebAppModels.Story(story);
                Set<Id> activitiesIds = new Set<Id>();
                for(Activity__c activity : story.Activities__r)
                    activitiesIds.add(activity.Id);
                if(deep){
                   //Querying activities and adding them to the corresponding stories
                    List<Activity__c> activities = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM Activity__c WHERE Id IN :activitiesIds');
                    for(Activity__c activity : activities){
                        response.activities.add(new WebAppModels.Activity(activity));
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
    public static WebAppModels.Activity getActivity(String id) {
        try{
            if(String.isNotEmpty(id)){
                //Querying activities and adding them to the corresponding stories
                Activity__c activity = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM Activity__c WHERE Id = :id');
                return new WebAppModels.Activity(activity);
                        
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
    public static List<WebAppModels.CodeType> getDefaultSkills(){
        List<Skills__c> skills = [SELECT Name FROM Skills__c];
        List<WebAppModels.CodeType> codeTypes = new List<WebAppModels.CodeType>();
        for(Skills__c skill : skills)
            codeTypes.add(new WebAppModels.CodeType(skill));
        return codeTypes;
    }
    /**
     * Upserts story
     * @param  story Story dto
     * @return       updated Story DTO with Id
     */
    @RemoteAction
    public static WebAppModels.Story upsertStory(WebAppModels.Story story) {
        if(story==null) throw new WebAppException('Story equals null');
        try{
            Story__c storyToUpdate = null;
            if(story.id == null){
                storyToUpdate = new Story__c(Project_Start_Date__c = Date.today(), Publisher__c = UserInfo.getUserId());
            } else {
                storyToUpdate = [SELECT Name, Description__c, Service_Offering__c FROM Story__c WHERE Id = :story.id LIMIT 1];
            }
            storyToUpdate.Description__c = story.description;
            storyToUpdate.Name = story.title;
            storyToUpdate.Service_Offering__c = story.serviceOffering;
            if(story.id == null){
                mStoryService.createStories(new List<Story__c>{storyToUpdate});
                story.id = storyToUpdate.Id;
            } else {
                mStoryService.updateStories(new List<Story__c>{storyToUpdate});
            }
            
            return story;
        } catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Fetches stories in Status!=Planning and Activitie Status!=Draft, alsfo filter's by provided filter
     * @param  request request object with filter and pagination info
     * @return         StoryResponse(page)
     */
    @RemoteAction
    public static WebAppModels.StoryResponse getStories(WebAppModels.StoryRequest request) {
        try{
            WebAppModels.StoryResponse response = new WebAppModels.StoryResponse();
            List<WebAppModels.Story> result = new List<WebAppModels.Story>();
            String soql = 'SELECT {0} FROM Story__c WHERE Status__c != \'\''+Constants.STORY_PLANNING_STATUS+'\'\''+
                           ' AND Id IN (SELECT Story__c FROM Activity__c WHERE Status__c != \'\''+Constants.STATUS_DRAFT+'\'\') ';

            Integer pageSize;
            String paginationSoql = '';
            if(request!=null){
                //Applying filter is any
                if(request.filter!=null&&request.filter.hasAnyFilter()){
                    if(request.filter.showOnlyCompleted!=null && request.filter.showOnlyCompleted)
                        soql += ' AND Status__c = \'\''+Constants.STORY_COMPLETED_STATUS+'\'\'';
                    if(String.isNotEmpty(request.filter.storyTitle)){
                        soql += ' AND Name LIKE \'\'%'+String.escapeSingleQuotes(request.filter.storyTitle)+'%\'\'';
                    }
                    if(String.isNotEmpty(request.filter.serviceOffering)){
                        soql += ' AND Service_Offering__c = \'\''+String.escapeSingleQuotes(request.filter.serviceOffering)+'\'\'';
                    }
                    if(String.isNotEmpty(request.filter.activityTitle) || String.isNotEmpty(request.filter.activityPhase)){
                        String activityFilter = ' AND Id IN (SELECT Story__c FROM Activity__c WHERE ';
                        if(String.isNotEmpty(request.filter.activityTitle)){
                            activityFilter += 'Name LIKE \'\'%'+String.escapeSingleQuotes(request.filter.activityTitle)+'%\'\'';
                        }
                        if(String.isNotEmpty(request.filter.activityPhase)){
                            if(String.isNotEmpty(request.filter.activityTitle))
                                activityFilter += ' AND ';
                            activityFilter += 'Status__c = \'\''+String.escapeSingleQuotes(request.filter.activityPhase)+'\'\'';
                        }
                        activityFilter += ' AND Status__c != \'\''+Constants.STATUS_DRAFT+'\'\')';
                        soql += activityFilter;
                    }
                }
                pageSize = request.pageSize==null?pageSize:request.pageSize;
                paginationSoql = ' LIMIT '+pageSize;
                if(request.page!=null)
                    paginationSoql += ' OFFSET '+((request.page - 1)*pageSize);
            } else {
                //If no filter just return first 25 stories
                pageSize = 25;
                paginationSoql = ' LIMIT '+pageSize;
            }
            String selectQuery = String.format(soql, new List<String>{STORY_FIELDS_MEMBER})+paginationSoql;
            System.debug(selectQuery);
            List<Story__c> stories = Database.query(selectQuery);
            AggregateResult countResults = Database.query(String.format(soql, new List<String>{ COUNT_FIELD }));
            response.totalItems = (Integer)countResults.get('result');
            response.totalPages = response.totalItems / pageSize + 1;
            //Collect activities ids and stories
            Set<Id> activitiesIds = new Set<Id>();
            Map<Id, WebAppModels.Story> storiesMap = new Map<Id, WebAppModels.Story>();
            for(Story__c story : stories){
                activitiesIds.addAll(new Map<Id, Activity__c>(story.Activities__r).keySet());
                WebAppModels.Story storyDto = new WebAppModels.Story(story);
                result.add(storyDto);
                storiesMap.put(story.Id,storyDto);
            }
            //Querying activities and adding them to the corresponding stories
            List<Activity__c> activities = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM Activity__c WHERE Id IN :activitiesIds');
            for(Activity__c activity : activities){
                storiesMap.get(activity.Story__c).activities.add(new WebAppModels.Activity(activity));
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
            mActivityService.registerMember(UserInfo.getUserId(), new Activity__c(Id = id));
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
            mActivityService.updateActivities(new List<Activity__c>{new Activity__c(Id = id, Status__c = Constants.STATUS_CANCELED)});
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
            mActivityService.updateActivities(new List<Activity__c>{new Activity__c(Id = id, Status__c = Constants.STATUS_COMPLETE)});
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
            mStoryService.updateStories(new List<Story__c>{new Story__c(Id = id, Status__c = Constants.STATUS_CANCELED)});
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
    public static WebAppModels.ActivityRegitration assignMember(Id activityId, Id userId){
        if(activityId==null) throw new WebAppException('Id cannot be null');
        try{
            
            mActivityService.assignMemberToActivity(new User(Id = userId), new Activity__c(Id = activityId));
            Registration__c reg = [SELECT Registration_Date__c, User__r.FirstName, User__r.LastName, User__r.SmallPhotoUrl FROM Registration__c 
                                    WHERE Activity__c =:activityId AND User__c = :userId LIMIT 1];
            WebAppModels.ActivityRegitration result = new WebAppModels.ActivityRegitration(reg);
            User usr = [SELECT (SELECT Skill__c, Skill__r.Name FROM User_Skills__r),(SELECT Id FROM Submissions__r) FROM User WHERE Id = :userId];
            result.user.addSkills(usr.User_Skills__r);
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
            mActivityService.assignMemberToActivity(new User(Id = null), new Activity__c(Id = activityId));
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
    public static List<WebAppModels.UserModel> getRecommendedMembers(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            List<ActivitySkills__c> actSkills = [SELECT Skill__c FROM ActivitySkills__c WHERE Activity__c = :id];
            Set<Id> skillsIds = new Set<Id>();
            for(ActivitySkills__c actSkill : actSkills)
                skillsIds.add(actSkill.Skill__c);
            List<User> users = [SELECT FirstName, LastName, SmallPhotoUrl,(SELECT Skill__c, Skill__r.Name FROM User_Skills__r),(SELECT Id FROM Submissions__r)
                                FROM User 
                                WHERE Id IN (SELECT Member__c FROM UserSkill__c WHERE Skill__c IN :skillsIds)];
            List<WebAppModels.UserModel> result = new List<WebAppModels.UserModel>();
            for(User usr : users){
                WebAppModels.UserModel dto = new WebAppModels.UserModel(usr);
                dto.addSkills(usr.User_Skills__r);
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
    public static List<WebAppModels.ActivityRegitration> getRegistrants(Id id, Integer page, Integer pageSize){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            List<Registration__c> registrations = mActivityService.getRegistrations(new Activity__c(Id = id));

            Map<Id, WebAppModels.ActivityRegitration> resultMap = new Map<Id, WebAppModels.ActivityRegitration>();
            for(Registration__c reg : registrations){
                resultMap.put(reg.User__c, new WebAppModels.ActivityRegitration(reg));
            }
            if(page==null||page<1)
                page = 1;
            if(pageSize==null||pageSize<0)
                pageSize = REGISTRANTS_PAGE_SIZE;
            Integer offset = (page-1)*pageSize;
            List<User> users = [SELECT (SELECT Skill__c, Skill__r.Name FROM User_Skills__r),(SELECT Id FROM Submissions__r) FROM User WHERE Id IN :resultMap.keySet() LIMIT :pageSize OFFSET :offset];
            for(User usr : users){
                resultMap.get(usr.Id).user.addSkills(usr.User_Skills__r);
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
    public static WebAppModels.ActivityRegitration getAssignedMember(Id id){
        if(id==null) throw new WebAppException('Id cannot be null');
        try{
            Activity__c activity = [SELECT Assigned_Member__c FROM Activity__c WHERE Id = :id];
            if(activity.Assigned_Member__c==null) return null;
            Registration__c registration = [SELECT Name,Activity__c,Registration_Date__c,User__c,User__r.Name,User__r.FirstName,User__r.LastName,User__r.SmallPhotoUrl 
                                            FROM Registration__c 
                                            WHERE User__c = :activity.Assigned_Member__c AND Activity__c = :id LIMIT 1];
            User usr = [SELECT (SELECT Skill__c, Skill__r.Name FROM User_Skills__r),(SELECT Id FROM Submissions__r) FROM User WHERE Id = :activity.Assigned_Member__c];
            WebAppModels.ActivityRegitration result = new WebAppModels.ActivityRegitration(registration);
            result.user.activitiesDone = usr.Submissions__r.size();
            result.user.addSkills(usr.User_Skills__r);
            return result;
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Creates basic activity
     * @param  act activity DTO object
     * @return     created activity
     */
    @RemoteAction
    public static WebAppModels.Activity createActivity(WebAppModels.Activity act){
        if(act==null) throw new WebAppException('Activity cannot be null');
        try{
            Activity__c activity = act.getSObject();
            activity.Story__c = act.storyId;
            activity.Publisher__c = UserInfo.getUserId();
            mActivityService.createActivities(new List<Activity__c>{activity});
            act.id = activity.Id;
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
            mActivityService.deleteActivities(new List<Activity__c>{new Activity__c(Id = id)});
        }catch(Exception ex){
            throw new WebAppException();
        }
    }
    /**
     * Upserts activity with all child records
     * @param act Activity object DTO
     */
    @RemoteAction
    public static void upsertActivity(WebAppModels.Activity act){
        if(act==null) throw new WebAppException('Activity cannot be null');
        Savepoint sp = Database.setSavepoint();
        try{
            List<sObject> objsToInsert = new List<sObject>();
            List<sObject> objsToUpdate = new List<sObject>();
            List<sObject> objsToDelete = new List<sObject>();
            Id activityId = act.id;
            Activity__c activity = null;
            if(String.isBlank(activityId)){
                activity = act.getSObject();
                insert activity;
            } else {
                objsToUpdate.add(act.getSObject());
                //Retrieving current activity with all child objects
                activity = Database.query('SELECT '+ACTIVITY_FULL_FIELDS+' FROM Activity__c WHERE Id = :activityId LIMIT 1');
            }
    
            //Milestones update
            if(act.milestones!=null){
                //Creating standard milestones map Name->Milestone
                Map<String, Milestone__c> stdMilestonesMap = new Map<String, Milestone__c>();
                List<Milestone__c> stdMilestones = [SELECT Name FROM Milestone__c];
                for(Milestone__c stdMilestone : stdMilestones)
                    stdMilestonesMap.put(stdMilestone.Name, stdMilestone);
                //Creating existing activity milestones map Name->Milestone
                Map<String, ActivityMilestones__c> milestonesMap = new Map<String, ActivityMilestones__c>();
                for(ActivityMilestones__c milestone : activity.ActivityMilestones__r)
                    milestonesMap.put(milestone.Milestone__r.Name, milestone);
                for(WebAppModels.ActivityMilestone milestone : act.milestones){
                    ActivityMilestones__c actMilestone = milestonesMap.get(milestone.name);
                    if(actMilestone==null){
                        actMilestone = milestone.getSObject();
                        actMilestone.Activity__c = activity.Id;
                        actMilestone.Milestone__c = stdMilestonesMap.get(milestone.name).Id;
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
                Map<Id, Requirement__c> requirementsMap = new Map<Id, Requirement__c>(activity.Requirements__r);
                List<WebAppModels.ActivityRequirement> newRootDtoRequirements = new List<WebAppModels.ActivityRequirement>();
                List<Requirement__c> newRootRequirements = new List<Requirement__c>();
                for(WebAppModels.ActivityRequirement requirement : act.requirements){
                    if(String.isBlank(requirement.id)){
                        //Need to insert parent first before children
                        newRootDtoRequirements.add(requirement);
                        Requirement__c req = requirement.getSObject();
                        req.Activity__c = activity.Id;
                        newRootRequirements.add(req);
                        continue;
                    } else {
                        objsToUpdate.add(requirement.getSObject());
                        requirementsMap.remove(requirement.id);
                    }

                    if(requirement.childRequirements!=null){
                        for(WebAppModels.ActivityRequirement childRequirement : requirement.childRequirements){
                            if(String.isBlank(childRequirement.id)){
                                Requirement__c req = childRequirement.getSObject();
                                req.Parent_Requirement__c = requirement.id;
                                req.Activity__c = activity.Id;
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
                    WebAppModels.ActivityRequirement requirement = newRootDtoRequirements[i];
                    for(WebAppModels.ActivityRequirement childRequirement : requirement.childRequirements){
                        Requirement__c req = childRequirement.getSObject();
                        req.Parent_Requirement__c = newRootRequirements[i].Id;
                        req.Activity__c = activity.Id;
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
                    Map<Id, ActivitySkills__c> existingSkills = new Map<Id,ActivitySkills__c>(activity.Activity_Skills__r);
                    for(WebAppModels.CodeType codeType : act.codeTypes){
                        if(String.isNotBlank(codeType.id)){
                            //updating skill
                            ActivitySkills__c existingSkill = existingSkills.get(codeType.id);
                            //If skill wasn't found seems like someone already deleted it
                            if(existingSkill != null){
                                // If skill exists just do nothing
                                existingSkills.remove(existingSkill.Id);
                            } else  {
                                //just insert it again
                                objsToInsert.add(new ActivitySkills__c(Skill__c = codeType.skillId, Activity__c = activity.Id));
                            }
                        } else {
                            //Inserting skill
                            objsToInsert.add(new ActivitySkills__c(Skill__c = codeType.skillId, Activity__c = activity.Id));
                        }
                    }
                    //Deleted all missing skills
                    objsToDelete.addAll((List<sObject>)existingSkills.values());
                }
            }
            //Prizes update
            if((act.noPrizes == null || act.noPrizes) || (act.prizes != null && act.prizes.size() == 0)) {
                //If no Prizes was set delete all awards if any.
                objsToDelete.addAll((List<sObject>)[SELECT Id FROM Award__c WHERE Activity__c = :activity.Id]);
            } else {
                if(act.prizes!=null){
                    Map<Integer, Award__c> awardsMap = new Map<Integer, Award__c>();
                    for(Award__c award : activity.Awards__r)
                        awardsMap.put(award.Place__c.intValue(), award);
                    for(WebAppModels.Prize prize : act.prizes){
                        Award__c award = awardsMap.get(prize.place);
                        //If award for place was found update it
                        if(award!=null){
                            award.Payment__c = prize.amount;
                            objsToUpdate.add(award);
                        } else {
                            //If not insert new award
                            objsToInsert.add(new Award__c(Payment__c = prize.amount, Place__c = prize.place, Activity__c = activity.Id));
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
    public class WebAppException extends Exception{}
}