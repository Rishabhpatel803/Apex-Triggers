public class OpportunityTriggerHandler {

     public static void setPricebook(List<Opportunity> oppList) {
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        for (Opportunity opp : oppList) {
            if (opp.StageName == 'Prospecting' && opp.Pricebook2Id == null) {
                opp.Pricebook2Id = standardPB.Id;
            }
        }
    }
        public static void addLineItem(List<Opportunity> newOppList) {
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

        // Get Standard Pricebook
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        // Get 1 active PricebookEntry
        List<PricebookEntry> pricebookEntries = [
            SELECT Id, Product2Id 
            FROM PricebookEntry 
            WHERE IsActive = true AND Pricebook2Id = :standardPricebook.Id 
            LIMIT 1
        ];
        if (pricebookEntries.isEmpty()) return;

        Id pricebookEntryId = pricebookEntries[0].Id;

        for (Opportunity opp : newOppList) {
            if (opp.StageName == 'Prospecting') {
                OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    PricebookEntryId = pricebookEntryId,
                    Quantity = 4,
                    UnitPrice = 100,
                    Description = 'This Line item is added via Trigger'
                );
                oppLineItems.add(oli);
            }
        }

        if (!oppLineItems.isEmpty()) {
            insert oppLineItems;
        }
    }

    //Scenario 17
    public static void sendEmailToAccContacts(List<Opportunity> oppList){
        List<Id> accId = new List<Id>();
        for(Opportunity opp : oppList){
            Opportunity oldOppMap = (Opportunity)Trigger.oldMap.get(opp.Id);
            if(opp.StageName != oldOppMap.StageName){
                accId.add(opp.AccountId);
            }
        }
        if(!accId.isEmpty()){
            sendEmailToContacts(accId);
        }
    }

    public static void sendEmailToContacts(List<Id> accountId) {
        List<Contact> contacts = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE AccountId IN :accountId];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Contact c : contacts) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { c.Email });
            email.setSubject('Update on your Opportunity');
            email.setPlainTextBody('Hi '+c.FirstName+' '+c.LastName+', your Opportuntiy has been updated.');

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