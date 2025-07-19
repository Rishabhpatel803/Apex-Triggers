public with sharing class LeadTriggerHanlder {
    private static Boolean hasRun = false;
    public static void createDuplicate(List<Lead> newLeads) {
        //To insert the duplicate records successfully you need to turn off duplicate 
        //record rule for Lead

        if (hasRun) return; // ✅ Prevents recursion
        hasRun = true;

        List<Lead> dupLead = new List<Lead>();
        for(Lead insertedLeads : newLeads){
            Lead newDupleads = new Lead();
            newDupleads.FirstName = insertedLeads.FirstName;
            newDupleads.LastName = insertedLeads.LastName + ' Copy';
            newDupleads.Company = insertedLeads.Company;
            newDupleads.Status = insertedLeads.Status;
            dupLead.add(newDupleads);
        }
        insert dupLead;
    }

    public static void sendWelcomeEmailToNewLead(List<Lead> newleads){
        List<Id> validLeadList = new List<Id>();
        for(Lead leads : newleads){
            if(String.isNotBlank(leads.Email)){
                validLeadList.add(leads.Id);
            }
        }
        sendWelcomeEmail(validLeadList);
    }

    public static void sendWelcomeEmail(List<Id> leadIds) {
        List<Lead> leads = [SELECT Id, Email FROM Lead WHERE Id IN :leadIds];

        // Fetch the PDF from Documents
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Title = 'Aggregate Functions in SOQL' ORDER BY CreatedDate DESC LIMIT 1];

        // Prepare the PDF attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(cv.Title + '.pdf');
        attachment.setBody(cv.VersionData);
        attachment.setContentType('application/pdf');

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Lead l : leads) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { l.Email });
            email.setSubject('Welcome');
            email.setPlainTextBody('Welcome to our services! Please find the attached document for Aggregate Result Lecture.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            emails.add(email);
        }
        try {
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        } catch (Exception e) {
            System.debug('Email error: ' + e.getMessage());
        }     
    }
}