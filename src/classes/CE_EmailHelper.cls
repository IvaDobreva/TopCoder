/**************************************************
* Test Data Factory
* -------------------------------------------------
* Created By: Arun Sampath (arun.sampath@hp.com)*             
* Last Modified: 6/22/2015
* -------------------------------------------------
* An apex class which provides helper methods to send 
notification email
**************************************************/


public with sharing class CE_EmailHelper {
  // can pass in String for emailtemplate instead of templateID - use String subjectName 
  public boolean sendEmail(List<User> userList, ID templateID)  { 	
 
  	
  // 	EmailTemplate template = ['SELECT ID FROM EmailTemplate where name = subjectName'];
  	Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();   	
  	List<Messaging.Email> messageList = new List<Messaging.Email>();
  	List<ID> idList = new List<ID>();  	
  	List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
  	boolean value = false;
  	
  	if(!userList.isEmpty()) { 
  		for (User user : userList) {
  			idList.add(user.Id);
  		}
  	} 
  	mail.setTemplateID(templateID); 
  	//mail.setTemplateID(template.Id);
  	mail.setTargetObjectIds(idList);
  	mail.setSaveAsActivity(false);  	 
  	messageList.add(mail);  	  		
  	
  	results=  Messaging.sendEmail(messageList, true);  	
  	for(Messaging.SendEmailResult result : results){
  		value = result.isSuccess();  	  		
  	}
  	
  	return value;
  	}  
  	  
}