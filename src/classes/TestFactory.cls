@isTest
public class TestFactory {
	public static Story__c createStory() {
		return new Story__c(
		           Name = 'TestStory',
		           Budget__c = 5000,
		           Description__c = 'Description',
		           Project_Start_Date__c = Date.today(),
		           Publisher__c = UserInfo.getUserId(),
		           Status__c = 'Planning',
		           Remaining_Budget__c = 5000
		       );
	}
	public static Activity__c createActivity(Story__c story) {
		return new Activity__c(
		           Name = 'TestActivity',
		           Activity_Type__c = 'Competition',
		           Budget_Authorized__c = true,
		           Cost__c = 1000,
		           Description__c = 'Description',
		           Minimum_Viable_Score__c = 75,
		           Possible_Score__c = 25,
		           Publisher__c = UserInfo.getUserId(),
		           Story__c = story.Id,
		           Status__c = 'Draft'
		       );
	}
	public static Skills__c createSkill(String skill) {
		return new Skills__c(
		           Skill__c = skill,
		           Experience_Level__c = 'Specialist'
		       );
	}
	public static ActivitySkills__c createActivitySkill(Activity__c activity, Skills__c skill) {
		return new ActivitySkills__c(
		           Activity__c = activity.Id,
		           Skill__c = skill.Id
		       );
	}

	public static List<Milestone__c> createDefaultMilestones() {
		Milestone__c publishDateMilestone = new Milestone__c(Name = Constants.PUBLISH_DATE_MILESTONE_NAME, Due_Date__c = DateTime.now().addDays(1));
		Milestone__c startDateMilestone = new Milestone__c(Name = Constants.START_DATE_MILESTONE_NAME, Due_Date__c = DateTime.now().addDays(2));
		Milestone__c registrationDateMilestone = new Milestone__c(Name = Constants.REGISTRATION_DATE_MILESTONE_NAME, Due_Date__c = DateTime.now().addDays(3));
		Milestone__c submissionDateMilestone = new Milestone__c(Name = Constants.SUBMISSION_DATE_MILESTONE_NAME, Due_Date__c = DateTime.now().addDays(4));
		Milestone__c reviewDateMilestone = new Milestone__c(Name = Constants.REVIEW_DATE_MILESTONE_NAME, Due_Date__c = DateTime.now().addDays(5));
		Milestone__c endDateMilestone = new Milestone__c(Name = Constants.END_DATE_MILESTONE_NAME, Due_Date__c = DateTime.now().addDays(6));

		return new List<Milestone__c> {	publishDateMilestone,
		                                startDateMilestone,
		                                registrationDateMilestone,
		                                submissionDateMilestone,
		                                reviewDateMilestone,
		                                endDateMilestone
		                              };
	}

	public static ActivityMilestones__c createActivityMilestone(Activity__c activity, Milestone__c milestone) {
		return new ActivityMilestones__c(Activity__c = activity.Id, Milestone__c = milestone.Id);
	}

	public static UserActivityMilestone__c createMemberActivityMilestone(Id userId, Activity__c activity, ActivityMilestones__c milestone) {
		return new UserActivityMilestone__c(
		           Activity__c = activity.Id,
		           ActivityMilestones__c = milestone.Id,
		           Activity_Milestone_Timestamp__c = DateTime.now(),
		           User__c = UserInfo.getUserId());
	}

	public static List<Default_Requirement__c> createDefaultRequirements() {
		List<Default_Requirement__c> result = new List<Default_Requirement__c>();
		for (Integer i = 0; i < 3; i++)
			result.add(new Default_Requirement__c(
			               Name = 'Application Functionality ' + 1,
			               Description__c = 'Application Functionality ' + 1,
			               Requirement_Weight__c = 'Medium',
			               Type__c = 'Application Functionality'
			           ));
		for (Integer i = 0; i < 3; i++)
			result.add(new Default_Requirement__c(
			               Name = 'Code Standard ' + 1,
			               Description__c = 'Code Standard ' + 1,
			               Requirement_Weight__c = 'Medium',
			               Type__c = 'Code Standard'
			           ));
		for (Integer i = 0; i < 3; i++)
			result.add(new Default_Requirement__c(
			               Name = 'Deployment ' + 1,
			               Description__c = 'Deployment ' + 1,
			               Requirement_Weight__c = 'Medium',
			               Type__c = 'Deployment'
			           ));
		for (Integer i = 0; i < 3; i++)
			result.add(new Default_Requirement__c(
			               Name = 'Documentation ' + 1,
			               Description__c = 'Documentation ' + 1,
			               Requirement_Weight__c = 'Medium',
			               Type__c = 'Documentation'
			           ));
		return result;
	}

	public static Requirement__c createRequirement(Activity__c activity, Default_Requirement__c requirement) {
		return new Requirement__c(
		           Name = 'TestRequirement',
		           Activity__c = activity.Id,
		           Description__c = 'Description',
		           Requirement_Evaluation__c = 'Meets requirement',
		           Requirement_Weight__c = 'Medium',
		           Type__c = requirement.Type__c
		       );
	}

	public static Award__c createAward(Activity__c activity) {
		return new Award__c(
		           Activity__c = activity.Id,
		           Payment__c = 500
		       );
	}


	public static User createUser() {
		// Setup test data
		// This code runs as the system user
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		String email = 'awesometestuser' + Crypto.getRandomInteger() + '@testorg.com';
		User user = new User(Alias = 'standt', Email = email,
		                     EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                     LocaleSidKey = 'en_US', ProfileId = profile.Id,
		                     TimeZoneSidKey = 'America/Los_Angeles', UserName = email);

		return user;
	}
	
	public static Submission__c createSubmission(Activity__c activity){
		return new Submission__c(
			Name = 'TestSubmission',
	        Activity__c = activity.Id,
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
	
	public static Submission_Requirement__c createSubmissionRequirement(Submission__c submission, Requirement__c requirement){
		return new Submission_Requirement__c(Submission__c = submission.Id, Requirement__c = requirement.Id, Evaluation_Score__c = 0);
	}
}