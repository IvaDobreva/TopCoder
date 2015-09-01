public with sharing class CE_WebApp_ConfigController {
	public CE_WebApp_ConfigController() {
		User usr = [SELECT FirstName,LastName, SmallPhotoUrl, FullPhotoUrl, Crowd_Exchange_User_Type__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        currentUser = new CE_WebAppModels.UserModel(usr);

        List<CE_Milestone__c> milestones = [SELECT Name, Display_In_Initial_Setup__c,Default_Time_Period__c,Step_Number__c FROM CE_Milestone__c Order By Step_Number__c];
        List<CE_WebAppModels.MilestoneInfo> milestonesInfo = new List<CE_WebAppModels.MilestoneInfo>();
        for(CE_Milestone__c milestone : milestones){
            milestonesInfo.add(new CE_WebAppModels.MilestoneInfo(milestone));
        }
        this.milestones = JSON.serialize(milestonesInfo);
	}
    public String milestones {get;set;}
    public CE_WebAppModels.UserModel currentUser {get;set;}


}