public with sharing class QuoteLineItemTriggerHandler {
    //Scenario 27
    public static void insertQuoteLineItemSerialNo(List<QuoteLineItem> qliList){
        Decimal lastSerialNo = 0;
        List<QuoteLineItem> qli = [SELECT Id, Serial_No__c FROM QuoteLineItem ORDER BY Serial_No__c ASC];
        if(!qli.isEmpty()){
            lastSerialNo = (Decimal)qli[qli.size()-1].Serial_No__c == null ? 0 : qli[qli.size()-1].Serial_No__c;
        }
        for(QuoteLineItem quoteLineItems : qliList){
            lastSerialNo += 1;
            quoteLineItems.Serial_No__c = lastSerialNo;
        }
    }
}