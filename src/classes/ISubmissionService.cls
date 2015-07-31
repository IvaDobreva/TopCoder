public interface ISubmissionService {
	/**
	 * copies requirements to Submission Requirement table.
	 * @param  activity    parent activity of the submissions
	 * @param  submissions list of submission for which we initialize scorecards
	 * @return             List<Submission_Requirement__c>
	 */
	List<Submission_Requirement__c> initializeScorecard(Activity__c activity, List<Submission__c> submissions);
	/**
	 * only allow users to create submission before submission due date or review date.
	 * @param  submission submission record to create
	 * @param  activity   submission's parent activity
	 * @param  attachment submission's attachment
	 * @return            Submission__c
	 */
	Submission__c createSubmission(Submission__c submission, Activity__c activity, Attachment attachment);
	/**
	 * update score for a lists of requirements
	 * @param submissionRequirements [description]
	 */
	void evaluateRequirement(List<Submission_Requirement__c> submissionRequirements);
	/**
	 * updates scoring in parent Submission object
	 * @param  submission submission for which we need to calculate score
	 * @return            Integer - Summary score
	 */
	Integer calculateSubmissionScore(Submission__c submission);
	List<Submission__c> updateStatus(List<Submission__c> submissions);
	/**
	 * Gets the list of submissions is the last submitted (most recent) submission for each user submitted before the review date
	 * @param  activity activity for which we need to return submissions
	 * @return          List<Submission__c>
	 */
	List<Submission__c> getValidSubmissions(Activity__c activity);
	/**
	 * returns a collections of submissions for a particular member
	 * @param  user user for who we need to return submissions
	 * @return      List<Submission__c>
	 */
	List<Submission__c> getSubmissionsForUser(User user);
	/**
	 * handles file upload process to SFDC
	 * @param  attachment new attachment for submission
	 * @param  submission Attachment's parent submission
	 * @return            Attachment - inserted attachment
	 */
	Attachment uploadFile(Attachment attachment, Submission__c submisison);
}