public with sharing class CrowdExchangeWebApp_PageController {
	public CrowdExchangeWebApp_PageController() {
		List<Skills__c> skills = [SELECT Name FROM Skills__c];
        codeTypes = new List<WebAppModels.CodeType>();
        for(Skills__c skill : skills)
            codeTypes.add(new WebAppModels.CodeType(skill));
	}
    public List<WebAppModels.CodeType> codeTypes { get; set; }
}