trigger ActivityHandler on Activity__c (after insert, after update) {
	
	// processing activites for setting status as Accepted or Complete
	WorkflowManager.processActivitiesAfterReview(Trigger.new);
}