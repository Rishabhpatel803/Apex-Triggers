public with sharing class AssetTriggerHandler {

    //Scenario 19
    public static void updateFieldOnAccount(List<Asset> assetList) {
        Set<Id> assetIdSet = new Set<Id>();
        for(Asset asset : assetList){
            if(asset.AccountId != null){
                assetIdSet.add(asset.AccountId);
            }
        }
        Map<Id,Date> accountUpdateMap = new Map<Id,Date>();
        List<Account> accToUpdate = new List<Account>();
        if(!assetIdSet.isEmpty()){
            for(AggregateResult ar : [SELECT AccountId, MIN(UsageEndDate) minDate FROM Asset WHERE AccountId IN : assetIdSet AND UsageEndDate != null GROUP BY AccountId]){
                accountUpdateMap.put((Id)ar.get('AccountId'), (Date)ar.get('minDate'));
            }
            for(Id accId : accountUpdateMap.keySet()){
                Date assetMinDate = accountUpdateMap.get(accId);
                Account acc = new Account(Id = accId,Asset_Minimum_Expiration_Date__c = assetMinDate);
                accToUpdate.add(acc);
            }
            if(!accToUpdate.isEmpty()){
                update accToUpdate;
            }
        }else return;
    }

    //Scenario 29
    public static void createData(List<Asset> assetList){
        Set<Id> assetId = new Set<Id>();//gather all asset id which have the account related
        for(Asset asset : assetList){
            if(asset.AccountId != null){
                assetId.add(asset.Id);
            }
        }
        System.debug('0:'+assetId);
        List<Opportunity> oppList = new List<Opportunity>();
        for(Asset assets : [SELECT Name, AccountId FROM Asset WHERE ID IN : assetId]){
            oppList.add(new Opportunity(
                Name = assets.Name + ' Opportunity', 
                AccountId = assets.AccountId,
                StageName = 'Prospecting',
                CloseDate = System.today(),
                LeadSource = 'Opportunity From Asset'
                ));
                System.debug('1:'+oppList);
        }
        if(!oppList.isEmpty()){
            insert oppList;
            System.debug('1: Inserted'+oppList);
        }

        //logic for inserting opportunity line items
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

        for (Opportunity opp : [SELECT Id, StageName, LeadSource FROM Opportunity]) {
            if (opp.StageName == 'Prospecting' && opp.LeadSource == 'Opportunity From Asset') {
                OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    PricebookEntryId = pricebookEntryId,
                    Quantity = 4,
                    UnitPrice = 100,
                    Description = 'This Line item is added via Trigger'
                );
                oppLineItems.add(oli);
                System.debug('2:'+oppLineItems);
            }
        }

        if (!oppLineItems.isEmpty()) {
            insert oppLineItems;
            System.debug('2:'+oppLineItems);
        }
    }
}