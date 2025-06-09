public class AccountTriggerHandler {
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
    public static Boolean hasRun = false;
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
}