public with sharing class CrowdExchangeWebApp_ConfigController {
	public CrowdExchangeWebApp_ConfigController() {
		User usr = [SELECT FirstName,LastName, SmallPhotoUrl, FullPhotoUrl, Crowd_Exchange_User_Type__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        currentUser = new WebAppModels.UserModel(usr);

        List<Milestone__c> milestones = [SELECT Name, Display_In_Initial_Setup__c,Default_Time_Period__c,Step_Number__c FROM Milestone__c Order By Step_Number__c];
        List<WebAppModels.MilestoneInfo> milestonesInfo = new List<WebAppModels.MilestoneInfo>();
        for(Milestone__c milestone : milestones){
            milestonesInfo.add(new WebAppModels.MilestoneInfo(milestone));
        }
        this.milestones = JSON.serialize(milestonesInfo);
	}
    public String milestones {get;set;}
    public WebAppModels.UserModel currentUser {get;set;}


}