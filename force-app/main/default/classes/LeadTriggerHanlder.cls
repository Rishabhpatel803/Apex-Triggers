public with sharing class LeadTriggerHanlder {
    private static Boolean hasRun = false;
    public static void createDuplicate(List<Lead> newLeads) {
        //To insert the duplicate records successfully you need to turn off duplicate 
        //record rule for Lead

        if (hasRun) return; // ✅ Prevents recursion
        hasRun = true;

        List<Lead> dupLead = new List<Lead>();
        for(Lead insertedLeads : newLeads){
            Lead newDupleads = new Lead();
            newDupleads.FirstName = insertedLeads.FirstName;
            newDupleads.LastName = insertedLeads.LastName + ' Copy';
            newDupleads.Company = insertedLeads.Company;
            newDupleads.Status = insertedLeads.Status;
            dupLead.add(newDupleads);
        }
        insert dupLead;
    }
}