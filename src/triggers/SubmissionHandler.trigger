trigger SubmissionHandler on CE_Submission__c (after insert, after update) {
	
	// processing Submission to marke them as review complete.
	CE_WorkflowManager.processSubmissionReview(Trigger.new);
}