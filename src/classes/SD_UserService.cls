public with sharing class SD_UserService 
{
	public SD_UserService()
	{}
	
	public List<Skills__c> getUserSkills(User u)
	{
		List<Skills__c> sList = [SELECT Skill__c FROM Skills__c WHERE User__c = :u.Id];
		return sList;
	}
	
	public void insertSkills(List<String> skillsList, User u)
	{
		List<Skills__c> skillsToInsert = new List<Skills__c>();
		
		if (!skillsList.isEmpty())
		{
			for (String s : skillsList)
			{
				Skills__c skill = new Skills__c();
				skill.User__c = u.Id;
				skill.Skill__c = s;
				skillsToInsert.add(skill);	
			}
			
			if (!skillsToInsert.isEmpty())
				insert skillsToInsert;
		}
	}
}