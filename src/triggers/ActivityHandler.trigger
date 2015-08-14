trigger ActivityHandler on Activity__c (after insert, after update) {
	
    // processing activities for cancelation process
    if(Trigger.isUpdate){
        WorkflowManager.processActivityCancel(Trigger.oldMap, Trigger.newMap);
    }
    // processing activites for setting status as Accepted or Complete
	WorkflowManager.processActivitiesAfterReview(Trigger.new);
}