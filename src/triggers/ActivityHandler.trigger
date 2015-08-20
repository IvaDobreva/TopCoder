trigger ActivityHandler on CE_Activity__c (after insert, after update) {
	
    // processing activities for cancelation process
    if(Trigger.isUpdate){
        CE_WorkflowManager.processActivityCancel(Trigger.oldMap, Trigger.newMap);
    }
    // processing activites for setting status as Accepted or Complete
	CE_WorkflowManager.processActivitiesAfterReview(Trigger.new);
}