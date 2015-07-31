trigger SubmissionHandler on Submission__c (after insert, after update) {
	
	// processing Submission to marke them as review complete.
	WorkflowManager.processSubmissionReview(Trigger.new);
}