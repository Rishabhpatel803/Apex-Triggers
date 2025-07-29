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

    //Scenario 25
    public static void updateAccClientConact(List<Opportunity> oppList, Map<Id,Opportunity> oldValueMap){
        Set<Id> newOppId = new Set<Id>();
        for(Opportunity opp : oppList){
            Opportunity oldOppValue = oldValueMap.get(opp.Id);
            if(opp.Client_Contact__c != oldOppValue.Client_Contact__c){
                newOppId.add(opp.Id);
            }
        }
        if(newOppId.isEmpty())return;

        List<Account> accToUpdate = new List<Account>();
        for(Opportunity opp : [SELECT Id, AccountId, Client_Contact__c FROM Opportunity WHERE Id IN : newOppId]){
            accToUpdate.add(new Account(Id = opp.AccountId, Opp_Client_Contact__c = opp.Client_Contact__c));            
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }

    //Scenario 33
    public static void setMinAndMaxDate(List<Opportunity> oppList){
        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            if( opp.AccountId != null){
                accIdSet.add(opp.AccountId);
            }
        }
        if(accIdSet.isEmpty())return;

        List<AggregateResult> oppResult = [SELECT AccountId, MIN(CloseDate) minCloseDate, MAX(CloseDate) maxCloseDate FROM Opportunity WHERE AccountId IN : accIdSet GROUP BY AccountId];
        List<Account> accList = new List<Account>();

        for(AggregateResult ar : oppResult){
            accList.add(new Account(Id = (Id)ar.get('AccountId'), Min_Opp_Date__c = (Date)ar.get('minCloseDate'), Max_Opp_Date__c = (Date)ar.get('maxCloseDate')));
        }
        if(!accList.isEmpty()){
            update accList;
        }
    }

    //Scenario 34
    public static void setAccPicklistValues(List<Opportunity> oppList){
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accountIds.add(opp.AccountId);
            }
        }
        if(accountIds.isEmpty()) return;

        // Query all related Opportunities for each Account
        Map<Id, List<String>> accountToValues = new Map<Id, List<String>>();
        for(Opportunity opp : [
            SELECT AccountId, Sync_Values__c
            FROM Opportunity
            WHERE AccountId IN :accountIds AND Sync_Values__c != null
        ]) {
            if(!accountToValues.containsKey(opp.AccountId)){
                accountToValues.put(opp.AccountId, new List<String>());
            }
            List<String> existing = accountToValues.get(opp.AccountId);
            existing.addAll(opp.Sync_Values__c.split(';'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for(Id accId : accountToValues.keySet()){
            Set<String> uniqueValues = new Set<String>(accountToValues.get(accId));
            accountsToUpdate.add(new Account(
                Id = accId,
                Synced_Values__c = String.join(new List<String>(uniqueValues), ';')
            ));
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    }
}