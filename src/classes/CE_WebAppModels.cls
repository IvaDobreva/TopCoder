public with sharing abstract class CE_WebAppModels {
    /**
     * DTO model for fetching stories list
     */
    public class StoryRequest{
        public Integer page { get; set; }
        public Integer pageSize { get; set; }
        public StoryFilter filter { get; set; }
    }
    /**
     * Stories filter object for the StoryRequest
     */
    public class StoryFilter{
        public String storyTitle { get; set; }
        public String activityTitle { get; set; }
        public String serviceOffering { get; set; }
        public String activityPhase { get; set; }
        public Boolean showOnlyCompleted { get; set; }

        public Boolean hasAnyFilter(){
            return storyTitle!=null||activityTitle!=null||serviceOffering!=null||activityPhase!=null||showOnlyCompleted;
        }
    }
    /**
     * Stories list response
     */
    public class StoryResponse{
        public List<Story> stories { get; set; }
        public Integer totalItems { get; set; }
        public Integer totalPages { get; set; }
    }
    /**
     * DTO object for the CE_Story__c object
     */
    public class Story {
        public Id id { get; set; }
        public String title { get; set; }
        public String description { get; set; }
        public String phase { get; set; }
        public String serviceOffering { get; set; }
        public List<Activity> activities { get; set; }
        public UserModel publisher { get; set; }
        public Story(){}
        public Story(CE_Story__c model){
            try{
                this.id = model.Id;
                this.serviceOffering = model.Service_Offering__c;
                this.title = model.Name;
                this.description = model.Description__c;
                this.phase = model.Status__c;
                this.activities = new List<Activity>();
                this.publisher = new UserModel(model.Publisher__r);
            }catch(Exception ex){
                //Just for Activity as a root case       
            }
        }
    }
    /**
     * DTO model for the Skills objects
     */
    public class CodeType{
        public Id id { get; set; } 
        public String name { get; set; }
        public String skillId { get; set; }
        public CodeType(CE_ActivitySkills__c model){
            this.id = model.id;
            this.name = model.Skill__r.Name;
            this.skillId = model.Skill__c;
        }
        public CodeType(CE_Skills__c model){
            this.skillId = model.id;
            this.name = model.Name;
        }
        public CodeType(CE_UserSkill__c model){
            this.id = model.id;
            this.name = model.Skill__r.Name;
            this.skillId = model.Skill__c;
        }
    }
    /**
     * DTO model for the standard milestones
     */
    public virtual class MilestoneInfo implements Comparable{
        public String name {get;set;}
        public Integer defaultDuration {get;set;}
        public Integer stepNumber {get;set;}
        public Boolean display {get;set;}

        public MilestoneInfo(CE_Milestone__c model){
            this.name = model.Name;
            this.display = model.Display_In_Initial_Setup__c;
            if(model.Default_Time_Period__c!=null)
                this.defaultDuration = model.Default_Time_Period__c.intValue();
            this.stepNumber = model.Step_Number__c.intValue();
        }
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to MilestoneInfo
            MilestoneInfo compareToMilestone = (MilestoneInfo)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.stepNumber > compareToMilestone.stepNumber) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.stepNumber < compareToMilestone.stepNumber) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    /**
     * DTO model for the Activity's milestone object
     */
    public class ActivityMilestone extends MilestoneInfo{
        public Date scheduledDate { get; set; } 
        public Date completedDate { get; set; } 
        public Id milestoneId { get; set; }
        public ActivityMilestone(CE_ActivityMilestones__c model){
            super(model.CE_Milestone__r);
            this.scheduledDate = model.Scheduled_Date__c;
            this.completedDate = model.Completed_Date__c;
            this.name = model.CE_Milestone__r.Name;
        }
        public CE_ActivityMilestones__c getSObject(){
            return new CE_ActivityMilestones__c(
                Scheduled_Date__c = this.scheduledDate
                );
        }

    }
    /**
     * DTO model for the Activity's Requirement object
     */
    public class ActivityRequirement {
        public Id id { get; set; }
        public List<ActivityRequirement> childRequirements { get; set; }
        public String requirementNumber { get; set; }
        public String importance { get; set; }
        public String description { get; set; }
        public String type { get; set; }
        public Decimal weightScore { get; set; }
        public ActivityRequirement(CE_Requirement__c model){
            this.id = model.Id;
            this.requirementNumber = model.Requirement_Number__c;
            this.importance = model.Requirement_Weight__c;
            this.description = model.Description__c;
            this.type = model.Type__c;
            this.childRequirements = new List<ActivityRequirement>();
            this.weightScore = model.Requirement_Weight__c != null ? CE_Constants.REQUIRMENT_SCORE_BY_WEIGHT.get(model.Requirement_Weight__c) : CE_Constants.MIN_SCORE_PER_REQUIREMENT;
        }
        public CE_Requirement__c getSObject(){
            return new CE_Requirement__c(
                Id = this.id,
                Requirement_Number__c = this.requirementNumber,
                Requirement_Weight__c = this.importance ,
                Description__c = this.description ,
                Type__c = this.type 
                );
        }
    }
    /**
     * DTO model for the User object
     */
    public class UserModel{
        public Id id { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String photoUrl { get; set; }
        public String role { get; set; }
        public String email { get; set; }
        public String organization { get; set; }
        public Integer activitiesDone { get; set; }
        public List<CodeType> skills { get; set; }
        public UserModel(User model){
            this.id = model.Id;
            this.firstName = model.FirstName;
            this.lastName = model.LastName;
            this.photoUrl = model.SmallPhotoUrl;
            try{
                this.activitiesDone = model.Submissions__r.size();
            } catch(Exception ex){}
            try{
                this.role = model.Crowd_Exchange_User_Type__c;
            } catch(Exception ex){}
            try{
                this.organization = model.Crowd_Exchange_Organization__c ;
            } catch(Exception ex){}
            try{
                this.addSkills(model.User_Skills__r);
            } catch(Exception ex){}
            try{
                this.email = model.Email;
            } catch(Exception ex){}
        }
        public void addSkills(List<CE_UserSkill__c> skills){
            if(this.skills == null)
                this.skills = new List<CodeType>();
            for(CE_UserSkill__c skill : skills){
                this.skills.add(new CodeType(skill));
            }
        }
    }
    /**
     * DTO model for the CE_Registration__c object
     */
    public class ActivityRegitration{
        public Id id { get; set; }
        public DateTime registrationDate { get; set; }
        public UserModel user { get; set; } 

        public ActivityRegitration(CE_Registration__c model){
            this.id = model.Id;
            this.registrationDate = model.Registration_Date__c;
            try{
                this.user = new UserModel(model.User__r);
            } catch(Exception ex){}
        }
    }
    /**
     * DTO model for the CE_Submission__c object
     */
    public class ActivitySubmission{
        public Id id { get; set; }
        public String name { get; set; }
        public DateTime submissionDate { get; set; }
        public Date submissionDueDate { get; set; }
        public UserModel user { get; set; } 
        public SubmissionDocument document { get; set; }
        public boolean isSubmissionEnd {get;set;}
        public Decimal submissionScore {get;set;}
        public String overallComment {get;set;}
        public Decimal evaluationPercentage {get;set;}
        public boolean isReviewComplete {get;set;}
        
        public ActivitySubmission(CE_Submission__c model, Date submissionDueDate) {
        	this(model);
        	this.submissionDueDate = submissionDueDate;
        	this.isSubmissionEnd = (this.submissionDueDate <= Datetime.now());
        }

        public ActivitySubmission(CE_Submission__c model){
			this.id = model.Id;
			this.name = model.name;
			this.submissionDate = model.Submission_Timestamp__c;
			this.submissionScore = model.Submission_Score__c;
			this.overallComment = model.Overall_Comment__c;
			this.evaluationPercentage = model.Evaluation_Percentage__c != null ? (model.Evaluation_Percentage__c).setScale(2) : 0;
			this.isReviewComplete = model.Status__c == CE_Constants.REVIEW_COMPLETE_STATUS ? true : false;
			
			// setting the document
			if(model.Attachments != null && !model.Attachments.isEmpty()) {
				this.document = new SubmissionDocument(model.Attachments[0]);
			}
			try{
                this.user = new UserModel(model.Submitting_Member__r);
            } catch(Exception ex){}
        }
    }
    
    /**
     * DTO model for the Submission's attachment
     */
    public class SubmissionDocument{
        public Id id { get; set; }
        public String name { get; set; } 
        public String description { get; set; }
        public Datetime createdDate { get; set; }

        public SubmissionDocument(Attachment att){
            this.id = att.Id;
            this.name = att.Name;
            this.description = att.Description;
            this.createdDate = att.CreatedDate;
        }
    }
    /**
     * DTO model for the CE_Award__c object
     */
    public class Prize{
        public Id id { get; set; }
        public Integer place { get; set; }
        public Decimal amount { get; set; }
        public Prize(CE_Award__c award){
            this.id = award.Id;
            this.place = award.Place__c.intValue();
            this.amount = award.Payment__c;
        }
    }
    /**
     * DTO model for the Activity's attachment
     */
    public class ActivityDocument{
        public Id id { get; set; }
        public String name { get; set; } 
        public String description { get; set; }
        public Datetime createdDate { get; set; }

        public ActivityDocument(Attachment att){
            this.id = att.Id;
            this.name = att.Name;
            this.description = att.Description;
            this.createdDate = att.CreatedDate;
        }
    }
    /**
     * DTO model for the CE_Activity__c object
     */
    public class Activity{
        public Id id { get; set; }
        public String title { get; set; }
        public String description { get; set; }
        public String phase { get; set; }
        public Boolean isRegistered { get; set; }
        public List<CodeType> codeTypes { get; set; }
        public String challengeType { get; set; }
        public List<ActivityRequirement> requirements { get; set; }
        public List<ActivityMilestone> milestones { get; set; }
        public List<ActivityRegitration> registrations { get; set; }
        public List<ActivitySubmission> submissions { get; set; }
        public Integer registrationsCount { get; set; }
        public Integer submissionsCount { get; set; }
        public List<ActivityDocument> documents { get; set; }
        public List<Prize> prizes { get; set; }
        public Id storyId { get; set; }
        public Story story { get; set; }
        public Boolean noPrizes { get; set; }
        public Boolean addDefaultRequirements { get; set; }
        public UserModel assignedMember { get;set; }
        // variable to check weather submission allowed by current user or not
        // if current user is equals to assigned user, then he willbe allowed to submit
        public Boolean allowSubmission { get; set; }
        public Activity(CE_Activity__c model){
            this.id = model.Id;
            this.title = model.Name;
            this.description = model.Description__c;
            this.codeTypes = new List<CodeType>();
            this.phase = model.Status__c;
            this.isRegistered = false;
            this.allowSubmission = false;
            this.addDefaultRequirements = false;
            this.challengeType = model.Challenge_Type__c;
            this.story = new Story(model.CE_Story__r);
            if(model.Assigned_Member__c!=null) {
                this.assignedMember = new UserModel(model.Assigned_Member__r);
                this.allowSubmission = (this.assignedMember.id == UserInfo.getUserId());
            }
            this.noPrizes = model.hasAwards__c==null?false:!model.hasAwards__c;
            for(CE_ActivitySkills__c skill : model.Activity_Skills__r){
                this.codeTypes.add(new CodeType(skill));
            }
            this.milestones = new List<ActivityMilestone>();
            for(CE_ActivityMilestones__c milestone : model.ActivityMilestones__r){
                this.milestones.add(new ActivityMilestone(milestone));
            }
            this.milestones.sort();
            this.requirements = new List<ActivityRequirement>();
            Map<Id, ActivityRequirement> requirementsMap = new Map<Id, ActivityRequirement>();
            List<CE_Requirement__c> childRequirements = new List<CE_Requirement__c>();
            for(CE_Requirement__c requirement : model.Requirements__r){
                if(requirement.Parent_Requirement__c!=null){
                    childRequirements.add(requirement);
                } else {
                    ActivityRequirement requirementDto = new ActivityRequirement(requirement);
                    this.requirements.add(requirementDto);
                    requirementsMap.put(requirement.Id, requirementDto);
                }
            }
            for(CE_Requirement__c requirement : childRequirements){
                requirementsMap.get(requirement.Parent_Requirement__c).childRequirements.add(new ActivityRequirement(requirement));
            }
            this.prizes = new List<Prize>();
            for(CE_Award__c award : model.Awards__r)
                this.prizes.add(new Prize(award));

            this.registrations = new List<ActivityRegitration>();
            this.registrationsCount = model.Registrations__r.size();
            String userId = UserInfo.getUserId();
            for(CE_Registration__c reg : model.Registrations__r){
                //ActivityRegitration regDto = new ActivityRegitration(reg);
                //this.registrations.add(regDto); //too hight payload. used separate fetch
                if(reg.User__r.Id==userId)
                    this.isRegistered = true;
            }
            this.submissions = new List<ActivitySubmission>();
            this.submissionsCount = model.Submissions__r.size();
            //too hight payload. create and use separate fetch
            //for(CE_Submission__c submission : model.Submissions__r){
            //    this.submissions.add(new ActivitySubmission(submission));
            //}
            this.documents = new List<ActivityDocument>();
            for(Attachment att : model.Attachments){
                this.documents.add(new ActivityDocument(att));
            }
        }
        
        // Method to add requirements to ActivityRequirement model
        public void addRequirements(List<CE_Requirement__c> requirements) {
        	this.requirements = new List<ActivityRequirement>();
        	for(CE_Requirement__c  requirement : requirements) {
        		ActivityRequirement requirementDto = new ActivityRequirement(requirement);
         		this.requirements.add(requirementDto);
        	}
        }
        
        public CE_Activity__c getSObject(){
            CE_Activity__c result = new CE_Activity__c(
                Id = this.id,
                Name = this.title,
                Description__c = this.description,
                Status__c = this.phase,
                Challenge_Type__c = this.challengeType,
                hasAwards__c = this.noPrizes==null?false:!this.noPrizes
                );
            if(String.isNotBlank(this.storyId))
                result.CE_Story__c = this.storyId;
            return result;
        }
    }
    /**
     * DTO model for the CE_Notification__c object
     */
    public class Notification {
        public Id id { get; set; }
        public Datetime dateSent { get; set; }
        public String text { get; set; }
        public String subject { get; set; }
        public String type { get; set; }
        public String status { 
            get; 
            set{
                this.status = value;
                this.isRead = this.status != CE_Constants.NOTIFICATION_UNREAD;
            } 
        }
        public Boolean isRead { get; private set; }
        public UserModel sender { get; set; }
        public List<UserModel> recipients { get; set; }

        public Notification(CE_Notification__c model){
            this.id = model.Id;
            this.dateSent = model.Date_Sent__c;
            this.text = model.Notification_Text__c;
            this.subject = model.Subject__c;
            this.type = model.Type__c;
            this.sender = new UserModel(model.FromUser__r);
            this.recipients = new List<UserModel>();
            
        }
        public void addRecipients(List<User> recipients){
            for(User recipient : recipients)
                this.recipients.add(new UserModel(recipient));
        }
    }
    /**
     * Response DTO for the notifications list
     */
    public class NotificationsResponse extends ListResponse {
        public List<Notification> notifications { get; set; }
    }
    /**
     * Base class for the collection responses
     */
    public virtual class ListResponse{
        public Integer totalItems { get; set; }
    }
    /**
     * Base class for the paginated search requests
     */
    public virtual class PaginatedSearchRequest{
        public String query { get; set; }
        public Integer page { get; set; }
        public Integer pageSize { get; set; }
    }
    /**
     * Stories search request object
     */
    public class StoriesSeachRequest extends PaginatedSearchRequest{        
        public StoriesSeachFilter filter { get; set; }
    }
    /**
     * Stories search filter object
     */
    public class StoriesSeachFilter {
        public String title { get; set; }
        public String description { get; set; }
        public String serviceOffering { get; set; }
        public String status { get; set; }
    }
    /**
     * Activities search request object
     */
    public class ActivitiesSeachRequest extends PaginatedSearchRequest{
        public ActivitiesSeachFilter filter { get; set; }
    }
    /**
     * Activities search filter object
     */
    public class ActivitiesSeachFilter {
        public String title { get; set; }
        public String description { get; set; }
        public String challengeType { get; set; }
        public String phase { get; set; }
    }
    /**
     * Members search request object
     */
    public class MembersSearchRequest extends PaginatedSearchRequest{
        public MembersSearchFilter filter { get; set; }
    }
    /**
     * Members search filter object
     */
    public class MembersSearchFilter {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String organization { get; set; }
        public String role { get; set; }
    }
    /**
     * Stories search response object
     */
    public class StoriesSearchResponse extends ListResponse{
        public List<Story> stories { get; set; }
    }
    /**
     * Members search response object
     */
    public class MembersSearchResponse extends ListResponse{
        public List<UserModel> members { get; set; }
    }
    /**
     * Activities search response object
     */
    public class ActivitiesSearchResponse extends ListResponse{
        public List<Activity> activities { get; set; }
    }
    /**
     * DTO for response item in the "All Records" search
     */
    public class SearchItem {
        public String type { get; set; }
        public Object item { get; set; }

        public SearchItem(Object item, String type){
            this.item = item;
            this.type = type;
        }
    }
    /**
     * All records search response object
     */
    public class AllRecordsSearchResponse extends ListResponse{
        public List<SearchItem> records { get; set; }
    }
    
      /**
     * DTO model for the Submission Requirements object
     */
    public class SubmissionRequirement {
        public Id id { get; set; }
        public String evaluationScore { get; set; }
        public String reviewComment {get;set;}
        public ActivityRequirement requirement {get;set;}
        
        public SubmissionRequirement(CE_Submission_Requirement__c model) {
        	this.id = model.id;
        	this.evaluationScore = ''+model.Evaluation_Score__c;
        	this.reviewComment = model.Review_Comment__c;
        	
        	try{
                this.requirement = new ActivityRequirement((CE_Requirement__c)model.getsObject('Requirement__r'));
            } catch(Exception ex){}
        }
        
        // Creating CE_Submission_Requirement__c sObject
        public CE_Submission_Requirement__c getSObject(){
            return new CE_Submission_Requirement__c(
                Id = this.id,
                Evaluation_Score__c = this.evaluationScore != null ? Decimal.valueOf(this.evaluationScore): null,
                Review_Comment__c = this.reviewComment
            );
        }
        
        
    }
    
    public class LoginInformation{

        // parameters
        public String username { get; set; } 
        public String password { get; set; } 

        // constructor
        public LoginInformation(String username, String password){
            this.username = username;
            this.password = password;
        }
    }
    
}