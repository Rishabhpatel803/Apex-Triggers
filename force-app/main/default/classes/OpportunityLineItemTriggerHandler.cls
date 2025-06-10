public with sharing class OpportunityLineItemTriggerHandler {
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
}