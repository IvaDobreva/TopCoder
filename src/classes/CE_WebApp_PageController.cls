public with sharing class CE_WebApp_PageController {
	public CE_WebApp_PageController() {
		List<CE_Skills__c> skills = [SELECT Name FROM CE_Skills__c];
        codeTypes = new List<CE_WebAppModels.CodeType>();
        for(CE_Skills__c skill : skills)
            codeTypes.add(new CE_WebAppModels.CodeType(skill));
	}
    public List<CE_WebAppModels.CodeType> codeTypes { get; set; }
}