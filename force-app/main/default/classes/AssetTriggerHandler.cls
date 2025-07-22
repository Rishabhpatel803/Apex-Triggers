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
}