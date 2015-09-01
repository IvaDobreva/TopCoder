@isTest
private class CE_WebAppModelsTest {
	
	@isTest static void mainStoryTest() {
    CE_Story__c story = CE_TestFactory.createFullStory();
		new CE_WebAppModels.Story(story);
    for(CE_Activity__c act : Database.query('SELECT '+CE_RemoteController.ACTIVITY_FULL_FIELDS+' FROM CE_Activity__c'))
      new CE_WebAppModels.Activity(act);
	}
  
}