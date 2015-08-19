public class Constants {
	//////////////////////////////////////////// Milestone Constants \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	public static final String PUBLISH_DATE_MILESTONE_NAME = 'Publish Date';
	public static final String START_DATE_MILESTONE_NAME = 'Start Date';
	public static final String REGISTRATION_DATE_MILESTONE_NAME = 'Registration Date';
	public static final String ASSIGNMENT_DATE_MILESTONE_NAME = 'Assignment Date';
	public static final String SUBMISSION_DATE_MILESTONE_NAME = 'Submission Date';
	public static final String REVIEW_DATE_MILESTONE_NAME = 'Review Date';
	public static final String ACCEPTANCE_DATE_MILESTONE_NAME = 'Acceptance Date';
	public static final String END_DATE_MILESTONE_NAME = 'End Date';
	public static final Integer NUMBER_OF_MILESTONES = 8;
	
	////////////////////////////////////////// END Milestone Constants \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	//////////////////////////////////////////// Submission Constants \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	public static final String READY_TO_REVIEW_STATUS = 'Ready to Review';
	public static final String REVIEW_COMPLETE_STATUS = 'Review Complete';
	////////////////////////////////////////// END Submission Constants \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	//////////////////////////////////////////// Submission Constants \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	public static final String STORY_PLANNING_STATUS = 'Planning';
	public static final String STORY_COMPLETED_STATUS = 'Completed';
	public static final String STORY_IN_PROGRESS_STATUS = 'In Progress';
	////////////////////////////////////////// END Submission Constants \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	// Activity Status Constants
	public static final String STATUS_DRAFT = 'Draft';
	public static final String STATUS_PUBLIC = 'Public';
	public static final String STATUS_IN_REGISTRATION = 'In Registration';
	public static final String STATUS_IN_ASSIGNMENT = 'In Assignment';
	public static final String STATUS_IN_SUBMISSION = 'In Submission';
	public static final String STATUS_IN_REVIEW = 'In Review';
	public static final String STATUS_ACCEPTED = 'Accepted';
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String STATUS_CANCELED = 'Canceled';

	public static final Map<String, Integer> REQUIRMENT_SCORE_BY_WEIGHT = new Map<String, Integer>{'Critical' => 4, 'High' => 3, 'Normal' => 2, 'Low' => 1};
	public static final Decimal MIN_SCORE_PER_REQUIREMENT = 10;

	 // Story Status Constatns
    public static final String STATUS_STORY_COMPLETED = 'Completed';    
    public static final String STATUS_STORY_CANCELLED = 'Canceled';    
	
	public static final String PUBLISHER = 'Publisher';
	public static final String MEMBER = 'Member';

    // Notification Codes (picklist value)
	public static final String NOTIFICATION_UNREAD = 'Unread';
	public static final String NOTIFICATION_READ = 'Read';
	public static final String NOTIFICATION_ARCHIVED = 'Archived';
	
	
	public static final String NOTIFICATION_NO_REGISTERED_USERS = 'No Registered Users';
    public static final String NOTIFICATION_NO_REVIEWS_RECEIVED = 'No Reviews Received';
    public static final String NOTIFICATION_NO_SUBMISSIONS = 'No Submissions';
    public static final String NOTIFICATION_ACTIVITY_ASSIGNED = 'Activity Assigned';
    public static final String NOTIFICATION_ACTIVITY_REGISTRATION_COMPLETE = 'Activity Registration Complete';
    // Registration
    public static final String NOTIFICATION_ACTIVITY_CANCELLED = 'Activity Cancelled';
    public static final String NOTIFICATION_STORY_CANCELLED = 'Story Cancelled';
    // Submission
    public static final String NOTIFICATION_SUBMISSION_REVIEW_COMPLETE = 'Submission Review Complete';
    public static final String NOTIFICATION_ACTIVITY_AWARDED = 'Activity Awarded';
    
    public static final String ID = 'id';
    public static final String EXPERIENCE_LEVEL = 'Experience_Level__c';
    public static final String MEMBER_SEARCH = 'Member Search';  
    
}