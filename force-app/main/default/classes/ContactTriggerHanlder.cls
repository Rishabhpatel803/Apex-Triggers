public with sharing class ContactTriggerHanlder {
    //Scenario 21
    public static void updateAccField(List<Contact> newConList){
        Set<Id> accList = new Set<Id>();
        for(Contact con : newConList){
            if(con.AccountId != null){
                accList.add(con.AccountId);
            }
        }
        if(accList.isEmpty())return;

        List<AggregateResult> result = [SELECT AccountId, SUM(Amount) totalAmt FROM Opportunity WHERE AccountId IN : accList GROUP BY AccountId];

        Map<Id, Decimal> accMap = new Map<Id,Decimal>();
        for(AggregateResult ar : result){
            accMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalAmt'));
        }

        List<Account> accToUpdate = new List<Account>();
        for(Id accId : accMap.keySet()){
            accToUpdate.add(new Account(Id = accId,Total_Opp_Amount__c = accMap.get(accId)));
        }

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
}