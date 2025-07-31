trigger QuoteLineItemTrigger on QuoteLineItem (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        QuoteLineItemTriggerHandler.insertQuoteLineItemSerialNo(Trigger.new);//Scenario 27
    }
}