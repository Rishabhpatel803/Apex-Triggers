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
}