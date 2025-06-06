public class ContactDuplicateTriggerHandler {
    public static void preventDuplicate(List<Contact> conList) {
        Set<String> keySet = new Set<String>();
        for(Contact existing : [Select Id, Email, Phone From Contact]){
            if(existing.Email != null && existing.Phone != null){
                String duplicateData = existing.Email.toLowerCase() + '_' + existing.Phone;
                keySet.add(duplicateData);
            }
        }
        for(Contact con : conList){
            if(con.Email != null && con.Phone != null){
                String newData = con.Email.toLowerCase() + '_' + con.Phone;
                if(keySet.contains(newData)){
                    con.addError('Duplicate Email and Phone found. Please use other Email and Phone');
                }
            }
        }
    }
}
