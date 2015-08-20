public with sharing class CE_MemberSearchEmailController {
	public CE_MemberSearchEmailController() {
		initialized = false;
	}
    public Boolean initialized {get;set;}
    public String emailTemplate { get; private set; }
    public String emailSubject { get; private set; }

    /**
     * Compiles email template
     */
    public void getEmailTemplate(){
        try{
            //Fetching email template
            EmailTemplate sendTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Member Search' AND Folder.Name = 'Crowd Exchange Templates' LIMIT 1];
            // Here we will build the single email message
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'invalid@emailaddr.es'};
            mail.setToAddresses(toAddresses);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setSenderDisplayName('MMPT');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setTemplateId(sendTemplate.Id);
            //Hacking email sending. Email won't be sent but email template will be compiled.
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            Database.rollback(sp);
            

            emailTemplate = mail.getPlainTextBody();
            emailSubject = mail.getSubject();
        }catch(Exception ex){        }
        initialized = true;
    }
}