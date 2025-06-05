public class ContactCreateTriggerHandler {
    public static void createContact(List<Contact> newContact) {
        String emailTemplateName = 'Contact_Created';
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:emailTemplateName];
        List<Id> conId = new List<Id>();
        for(Contact con : newContact){
            if(con.Email != null){
                conId.add(con.Id);
            }
        }
        sendBulkEmails(conId, et.Id);
    }

    public static void sendBulkEmails(List<Id> contactIds, Id templateId) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Id contactId : contactIds) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(contactId);
            email.setTemplateId(templateId);
            emails.add(email);
        }
        
        Messaging.sendEmail(emails);
    }
}