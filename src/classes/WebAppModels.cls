public with sharing abstract class WebAppModels {
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
     * DTO object for the Story__c object
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
        public Story(Story__c model){
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
        public CodeType(ActivitySkills__c model){
            this.id = model.id;
            this.name = model.Skill__r.Name;
            this.skillId = model.Skill__c;
        }
        public CodeType(Skills__c model){
            this.skillId = model.id;
            this.name = model.Name;
        }
        public CodeType(UserSkill__c model){
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

        public MilestoneInfo(Milestone__c model){
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
        public ActivityMilestone(ActivityMilestones__c model){
            super(model.Milestone__r);
            this.scheduledDate = model.Scheduled_Date__c;
            this.completedDate = model.Completed_Date__c;
            this.name = model.Milestone__r.Name;
        }
        public ActivityMilestones__c getSObject(){
            return new ActivityMilestones__c(
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
        public ActivityRequirement(Requirement__c model){
            this.id = model.Id;
            this.requirementNumber = model.Requirement_Number__c;
            this.importance = model.Requirement_Weight__c;
            this.description = model.Description__c;
            this.type = model.Type__c;
            this.childRequirements = new List<ActivityRequirement>();
        }
        public Requirement__c getSObject(){
            return new Requirement__c(
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
        }
        public void addSkills(List<UserSkill__c> skills){
            if(this.skills == null)
                this.skills = new List<CodeType>();
            for(UserSkill__c skill : skills){
                this.skills.add(new CodeType(skill));
            }
        }
    }
    /**
     * DTO model for the Registration__c object
     */
    public class ActivityRegitration{
        public Id id { get; set; }
        public DateTime registrationDate { get; set; }
        public UserModel user { get; set; } 

        public ActivityRegitration(Registration__c model){
            this.id = model.Id;
            this.registrationDate = model.Registration_Date__c;
            try{
                this.user = new UserModel(model.User__r);
            } catch(Exception ex){}
        }
    }
    /**
     * DTO model for the Submission__c object
     */
    public class ActivitySubmission{
        public Id id { get; set; }
        public DateTime submissionDate { get; set; }
        public UserModel user { get; set; } 

        public ActivitySubmission(Submission__c model){

        }
    }
    /**
     * DTO model for the Award__c object
     */
    public class Prize{
        public Id id { get; set; }
        public Integer place { get; set; }
        public Decimal amount { get; set; }
        public Prize(Award__c award){
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
     * DTO model for the Activity__c object
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
        public UserModel assignedMember { get;set; }
        public Activity(Activity__c model){
            this.id = model.Id;
            this.title = model.Name;
            this.description = model.Description__c;
            this.codeTypes = new List<CodeType>();
            this.phase = model.Status__c;
            this.isRegistered = false;
            this.challengeType = model.Challenge_Type__c;
            this.story = new Story(model.Story__r);
            if(model.Assigned_Member__c!=null)
                this.assignedMember = new UserModel(model.Assigned_Member__r);
            this.noPrizes = model.hasAwards__c==null?false:!model.hasAwards__c;
            for(ActivitySkills__c skill : model.Activity_Skills__r){
                this.codeTypes.add(new CodeType(skill));
            }
            this.milestones = new List<ActivityMilestone>();
            for(ActivityMilestones__c milestone : model.ActivityMilestones__r){
                this.milestones.add(new ActivityMilestone(milestone));
            }
            this.milestones.sort();
            this.requirements = new List<ActivityRequirement>();
            Map<Id, ActivityRequirement> requirementsMap = new Map<Id, ActivityRequirement>();
            List<Requirement__c> childRequirements = new List<Requirement__c>();
            for(Requirement__c requirement : model.Requirements__r){
                if(requirement.Parent_Requirement__c!=null){
                    childRequirements.add(requirement);
                } else {
                    ActivityRequirement requirementDto = new ActivityRequirement(requirement);
                    this.requirements.add(requirementDto);
                    requirementsMap.put(requirement.Id, requirementDto);
                }
            }
            for(Requirement__c requirement : childRequirements){
                requirementsMap.get(requirement.Parent_Requirement__c).childRequirements.add(new ActivityRequirement(requirement));
            }
            this.prizes = new List<Prize>();
            for(Award__c award : model.Awards__r)
                this.prizes.add(new Prize(award));

            this.registrations = new List<ActivityRegitration>();
            this.registrationsCount = model.Registrations__r.size();
            String userId = UserInfo.getUserId();
            for(Registration__c reg : model.Registrations__r){
                //ActivityRegitration regDto = new ActivityRegitration(reg);
                //this.registrations.add(regDto); //too hight payload. used separate fetch
                if(reg.User__r.Id==userId)
                    this.isRegistered = true;
            }
            this.submissions = new List<ActivitySubmission>();
            this.submissionsCount = model.Submissions__r.size();
            //too hight payload. create and use separate fetch
            //for(Submission__c submission : model.Submissions__r){
            //    this.submissions.add(new ActivitySubmission(submission));
            //}
            this.documents = new List<ActivityDocument>();
            for(Attachment att : model.Attachments){
                this.documents.add(new ActivityDocument(att));
            }
        }
        public Activity__c getSObject(){
            Activity__c result = new Activity__c(
                Id = this.id,
                Name = this.title,
                Description__c = this.description,
                Status__c = this.phase,
                Challenge_Type__c = this.challengeType,
                hasAwards__c = this.noPrizes==null?false:!this.noPrizes
                );
            if(String.isNotBlank(this.storyId))
                result.Story__c = this.storyId;
            return result;
        }
    }
}