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
}
