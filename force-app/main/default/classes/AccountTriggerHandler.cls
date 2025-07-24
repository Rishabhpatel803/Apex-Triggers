public class AccountTriggerHandler {
    public static boolean hasRun = false;
    public static Boolean hasUpdateTotalOppAmountRun = false;
    public static void updateShipping(List<Account> accountList) {
        List<Id> accList = new List<Id>(); //gather all accounts where billing address is not null
        for(Account acc : accountList){
            if(acc.BillingStreet != null || acc.BillingCity != null || acc.BillingCountry != null || acc.BillingGeocodeAccuracy != null || acc.BillingLatitude != null || acc.BillingLongitude != null || acc.BillingPostalCode != null || acc.BillingState != null){
                accList.add(acc.Id);
            }
        }
        List<Account> newAccList = new List<Account>();
        for(Account acc : [SELECT Id, BillingStreet, BillingCity,BillingCountry,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState FROM Account Where Id IN :accList]){
            Account newAcc = new Account();
            newAcc.Id = acc.Id;
            newAcc.ShippingStreet = acc.BillingStreet;
            newAcc.ShippingCity = acc.BillingCity;
            newAcc.ShippingCountry = acc.BillingCountry;
            newAcc.ShippingGeocodeAccuracy = acc.BillingGeocodeAccuracy;
            newAcc.ShippingLatitude = acc.BillingLatitude;
            newAcc.ShippingLongitude = acc.BillingLongitude;
            newAcc.ShippingPostalCode = acc.BillingPostalCode;
            newAcc.ShippingState = acc.BillingState;
            newAccList.add(newAcc);
        }
        update newAccList;
    }
    //Scenario 7
    // Static variable to control recursion within the same transaction
    public static void  updateOpportunity(List<Account> updatedAccounts){

        // Prevent recursion
        if (hasRun) return; // If it's already run, exit early
        hasRun = true; // Mark that it has run

        Set<Id> accListId = new Set<Id>();
        //Create a roll up summary on Account which count no of opportunities on account
        for(Account acc : updatedAccounts){
            if(acc.Opportunity_Count__c != 0){
                accListId.add(acc.Id);
            }
        }
        List<Opportunity> updatedOpportunity = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, Name, StageName, CreatedDate FROM Opportunity WHERE AccountId IN :accListId]){
            // Convert CreatedDate (DateTime) to Date
            Date createdDateOnly = opp.CreatedDate.date();
            
            // Calculate days between today and created date
            Integer daysOld = createdDateOnly.daysBetween(System.today());
            System.debug(daysOld);
            if(daysOld > 30){
                Opportunity updateOpp = new Opportunity();
                updateOpp.Id = opp.id;
                updateOpp.StageName = 'Closed Lost';
                updatedOpportunity.add(updateOpp);
            }
        }
        if (!updatedOpportunity.isEmpty()) {
            update updatedOpportunity;
        }
    }

    //Scenario 9
    public static void createClientContact(List<Account> newListAccount){
        Set<String> accName = new Set<String>();
        List<Contact> countContactInsert = new List<Contact>();
        for(Account acc : newListAccount){
            accName.add(acc.name);
            Contact countContactCreate = new Contact();
            countContactCreate.LastName = acc.Name;
            countContactInsert.add(countContactCreate);
        }
        if(!countContactInsert.isEmpty()){
            insert countContactInsert;//insert new count contact on account creation

            Map<String,Id> accUpdate = new Map<String,Id>();
            for(Contact c : [SELECT Id, LastName FROM Contact WHERE LastName IN :accName]){
                accUpdate.put(c.LastName,c.Id);
            }

            Set<String> accountName = new Set<String>(accUpdate.keySet());
            List<Account> accountUpdate = [SELECT Id, Name, Client_Contact__c FROM Account WHERE Name IN :accountName];

            for(Account acc : accountUpdate){
                Id contactId = accUpdate.get(acc.Name);
                acc.Client_Contact__c = contactId;
            }

            if(!accountUpdate.isEmpty()){
                update accountUpdate;
            }
        }
    }

    //Scenario 11
    public static void sendAdminMail(List<Account> accountList){
        List<User> adminUsers = [SELECT Id, Name,Email FROM User WHERE Profile.Name = 'System Administrator'];
        List<String> adUser = new List<String>();//conditon check that user email is not blank
        for(User users : adminUsers){
            if(users.Email != null){
                adUser.add(users.Email);
            }
        }
        List<Account> accList = new List<Account>();
        for(Account acc : accountList){
            if(acc.Email__c != null){
                accList.add(acc);
            }
        }
        if(!accList.isEmpty()){
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            
            for(Account acc : accList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(adUser);
                email.setSubject('New Account Creation');
                email.setPlainTextBody(
                    'Hi an account has been created and name is '+acc.Name
                );
                emailMessages.add(email);
            }
            if (!emailMessages.isEmpty()) {
                Messaging.sendEmail(emailMessages);
            }
        }
    }

    //Scenario 13
    public static void updateTotalOppAmount(List<Account> newAccList){
        if(hasUpdateTotalOppAmountRun == false){
            hasUpdateTotalOppAmountRun = true;
            //creating map for storing all the related opportunities to the account
            Map<Id,List<Id>> accOppMap = new Map<Id,List<Id>>();
            
            for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :newAccList]){
                if(!accOppMap.containsKey(opp.AccountId)){
                    accOppMap.put(opp.AccountId, new List<Id>());
                }
                accOppMap.get(opp.AccountId).add(opp.Id);
            }
            
            Map<Id,Decimal> updateAcc = new Map<Id, Decimal>();
            for(Id accId : accOppMap.keySet()){
                List<Id> oppId = accOppMap.get(accId);
                AggregateResult[] results = [SELECT SUM(Amount) Amt FROM Opportunity WHERE Id IN :oppId];

                if(results.size() > 0 && results[0].get('Amt') != null){
                    updateAcc.put(accId, (Decimal)results[0].get('Amt'));
                }else{
                    updateAcc.put(accId, 0);
                }
            }
            List<Account> accUpdate = new List<Account>();
            if(!updateAcc.isEmpty()){
                for(Id accId : updateAcc.keySet()){
                    Account acc = new Account(Id = accId, Total_Opportunity_Amount__c = updateAcc.get(accId));
                    accUpdate.add(acc);
                }
            }
            if(!accUpdate.isEmpty()){
                update accUpdate;
            }
        }else{
            return;
        }
    }

    //Scenario 15
    public static void updateAndSendEmail(List<Account> newAcc){
        List<Id> accId = new List<Id>();
        for(Account acc : newAcc){
            Account oldAcc = (Account)Trigger.oldMap.get(acc.Id);
            if(acc.Type != oldAcc.Type){
                accId.add(acc.Id);
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
            email.setSubject('Update on your Account');
            email.setPlainTextBody('Hi'+c.FirstName+' '+c.LastName+', your account Type has been upgraded.');

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

    //Scenario 22
    public static void createCopyOLIToAsset(List<Account> updatedAccList){
        Set<Id> accList = new Set<Id>();
        for(Account acc : updatedAccList){
            if(!accList.contains(acc.Id)){
                accList.add(acc.Id);
            }
        }
        if(accList.isEmpty())return;

        List<OpportunityLineItem> oliList = [SELECT Id, Name, Product2Id, ProductCode, Quantity, ListPrice, Opportunity.AccountId FROM OpportunityLineItem WHERE Opportunity.AccountId IN : accList];

        Map<Id, Set<String>> assetNameMap = new Map<Id, Set<String>>();
        for (Asset a : [
            SELECT Name, AccountId
            FROM Asset
            WHERE AccountId IN :accList
        ]) {
            if (!assetNameMap.containsKey(a.AccountId)) {
                assetNameMap.put(a.AccountId, new Set<String>());
            }            
            assetNameMap.get(a.AccountId).add(a.Name);
        }

        List<Asset> assetToInsert = new List<Asset>();
        for(OpportunityLineItem oli : oliList){
            Id accId = oli.Opportunity.AccountId;
            String assetOLIName = oli.Name + ' Asset';

            // Make sure we have a set for this account
            if (!assetNameMap.containsKey(accId)) {
                assetNameMap.put(accId, new Set<String>());
            }
            Set<String> nameSet = assetNameMap.get(accId);

            // Skip if name already exists
            if (nameSet.contains(assetOLIName)) {
                continue;
            }

            // Create new Asset
            Asset assetDup = new Asset();
            assetDup.Name = assetOLIName;
            assetDup.Product2Id = oli.Product2Id;
            assetDup.Quantity = oli.Quantity;
            assetDup.Price = oli.ListPrice;
            assetDup.AccountId = accId;
            assetToInsert.add(assetDup);

            // Track the name to prevent duplicate inserts in same run
            nameSet.add(assetOLIName);
        }
        if(!assetToInsert.isEmpty()){
            insert assetToInsert;
        }
    }
}