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
}