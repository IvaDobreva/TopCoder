@isTest
private class WebAppModelsTest {
	
	@isTest static void mainStoryTest() {
    Story__c story = TestFactory.createFullStory();
		new WebAppModels.Story(story);
    for(Activity__c act : Database.query('SELECT '+CrowdExchangeRemoteController.ACTIVITY_FULL_FIELDS+' FROM Activity__c'))
      new WebAppModels.Activity(act);
	}
  
}