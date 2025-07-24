public with sharing class OpportunityLineItemTriggerHandler {
    //Scenario 8,23
    public static void createAsset(List<OpportunityLineItem> newOppLineItemList) {
        // Map to group OLIs by OpportunityId
        Map<Id, List<OpportunityLineItem>> newMap = new Map<Id, List<OpportunityLineItem>>();
        Set<Id> oppIds = new Set<Id>();

        for (OpportunityLineItem oppLI : newOppLineItemList) {
            oppIds.add(oppLI.OpportunityId);
            if (!newMap.containsKey(oppLI.OpportunityId)) {
                newMap.put(oppLI.OpportunityId, new List<OpportunityLineItem>());
            }
            newMap.get(oppLI.OpportunityId).add(oppLI);
        }

        if (newMap.isEmpty()) return;

        // Query Opportunity data
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Name, AccountId FROM Opportunity WHERE Id IN :oppIds]
        );

        List<Asset> assetCreate = new List<Asset>();

        for (Id oppId : newMap.keySet()) {
            Opportunity opp = oppMap.get(oppId);
            if (opp != null && opp.AccountId != null) {
                List<OpportunityLineItem> oliList = newMap.get(oppId);
                for (OpportunityLineItem oppLI : oliList) {
                    Asset assetInsert = new Asset();
                    assetInsert.Name = opp.Name + ' Asset';
                    assetInsert.State = 'Shipped';
                    assetInsert.Product2Id = oppLI.Product2Id;
                    assetInsert.AccountId = opp.AccountId; // Required field
                    assetCreate.add(assetInsert);
                }
            }
        }

        if (!assetCreate.isEmpty()) {
            insert assetCreate;
        }
    }

    //Scenario 10
    public static void sendMail(List<OpportunityLineItem> newList){
        Set<Id> oppId = new Set<Id>();
        for(OpportunityLineItem oli : newList){
            if (oli.OpportunityId != null){
            oppId.add(oli.OpportunityId);
            }
        }

        Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Name, Account.Name, Account.Email__c FROM Opportunity WHERE Id IN :oppId]);

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (OpportunityLineItem oli : newList) {
            Opportunity opp = oppMap.get(oli.OpportunityId);
            if (opp != null && opp.Account != null && String.isNotBlank(opp.Account.Email__c)) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { opp.Account.Email__c });
                email.setSubject('Product Added to Opportunity');
                email.setPlainTextBody(
                    'Hi ' + opp.Account.Name + ',\n\n' +
                    'A new product has been added to your opportunity "' + opp.Name + '".\n\n' +
                    'Regards,\nYour Company'
                );
                emailMessages.add(email);
            }
        }

        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
    }

    //Scenario 12
    public static void setProductQty(List<OpportunityLineItem> newList){
        //Gathering all the opportunity id
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem oli : newList){
            oppIds.add(oli.OpportunityId);
        }

        // Map OpportunityId → AccountId
        Map<Id, Id> oppIdToAccountId = new Map<Id, Id>();
        for(Opportunity opp : [
            SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds
        ]){
            if (opp.AccountId != null) {
                oppIdToAccountId.put(opp.Id, opp.AccountId);
            }
        }

        Set<Id> accountIds = new Set<Id>(oppIdToAccountId.values());

        // Query all Opps for these Accounts
        Map<Id, List<Id>> accountToOppIds = new Map<Id, List<Id>>();
        for(Opportunity opp : [
            SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accountIds
        ]) {
            if (!accountToOppIds.containsKey(opp.AccountId)) {
                accountToOppIds.put(opp.AccountId, new List<Id>());
            }
            accountToOppIds.get(opp.AccountId).add(opp.Id);
        }

        // Now get total quantity for each account
        Map<Id, Decimal> accountToTotalQty = new Map<Id, Decimal>();
        for(Id accId : accountToOppIds.keySet()){
            List<Id> allOppIds = accountToOppIds.get(accId);
            AggregateResult[] results = [
                SELECT SUM(Quantity) totalQty
                FROM OpportunityLineItem
                WHERE OpportunityId IN :allOppIds
            ];
            if(results.size() > 0 && results[0].get('totalQty') != null){
                accountToTotalQty.put(accId, (Decimal)results[0].get('totalQty'));
            }
        }

        // Prepare Account updates
        List<Account> accToUpdate = new List<Account>();
        for(Id accId : accountToTotalQty.keySet()){
            accToUpdate.add(new Account(
                Id = accId,
                Total_Quantity__c = accountToTotalQty.get(accId)
            ));
        }

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }

    //Scenario 16
    public static void deleteRelatedOpportunity(List<OpportunityLineItem> oldList){
        List<Id> oppId = new List<Id>();
        for(OpportunityLineItem oli : oldList){
            System.debug('Related Opportunity : '+oli.OpportunityId);
            oppId.add(oli.OpportunityId);
        }
        if(!oppId.isEmpty()){
            List<Opportunity> oppList = [Select Id, Name FROM Opportunity WHERE Id IN : oppId];
            if(!oppList.isEmpty()){
                delete oppList;
            }
        }
    }

    //Scenario 18
    public static void insertQuotation(List<OpportunityLineItem> newOppList){
        Set<Id> oppId = new Set<Id>();
        for(OpportunityLineItem oli : newOppList){
            oppId.add(oli.OpportunityId);        
        }
        List<Quote> insertQuote = new List<Quote>();
        if(!oppId.isEmpty()){
        for (Opportunity opp : [SELECT Id, Name, AccountId, CloseDate FROM Opportunity WHERE Id IN :oppId]){
                Quote newQuote = new Quote();
                newQuote.Name = opp.Name + ' Quote';
                newQuote.OpportunityId = opp.Id;
                newQuote.ExpirationDate= opp.CloseDate;
                insertQuote.add(newQuote);
            }
        }
        if(!insertQuote.isEmpty()){
            insert insertQuote;
        }
    }

    //Scenario 20
    public static void populateTotalQTY(List<OpportunityLineItem> oliList){

        Set<Id> oppIdSet = new Set<Id>();
        for(OpportunityLineItem oli : oliList){
            if(oli.OpportunityId != null){
                oppIdSet.add(oli.OpportunityId);
            }
        }

        Map<Id,Opportunity> accIdOppMap = new Map<Id,Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE AccountId != null AND Id IN: oppIdSet]);

        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity opp : accIdOppMap.values()){
            if(opp.AccountId != null){
                accIdSet.add(opp.AccountId);
            }
        }

        if(accIdSet.isEmpty())return;
        
        List<AggregateResult> ar = [SELECT Opportunity.AccountId oppAccId, SUM(Quantity) totalQty FROM OpportunityLineItem WHERE Opportunity.AccountId IN : accIdSet GROUP BY Opportunity.AccountId];

        Map<Id,Decimal> accValue = new Map<Id, Decimal>();
        for(AggregateResult result : ar){
            accValue.put((Id)result.get('oppAccId'),(Decimal)result.get('totalQty'));
        }   


        if(accValue.isEmpty())return;

        List<Account> accToUpdate = new List<Account>();
        for(Id accId : accIdSet){
            accToUpdate.add(new Account(Id = accId, Total_Line_Items__c = accValue.containsKey(accId)? accValue.get(accId) : 0 ));
        }

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
}