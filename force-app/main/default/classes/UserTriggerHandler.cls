public with sharing class UserTriggerHandler {
    
    //Scenario 30
    public static void sendMailtoManager(List<User> usersList){
        Set<Id> userId = new Set<Id>();
        
        for(User u : usersList){
            if(u.ManagerId != null){
                userId.add(u.Id);
            }
        }
        if(userId.isEmpty())return;

        List<User> usersWithManager = [SELECT Id, ManagerId, Manager.Email FROM User WHERE Id IN : userId AND Manager.Email != null];
        Map<Id,String> userManagerMap = new Map<Id,String>();
        for(User users : usersWithManager){
            userManagerMap.put(users.Id, users.Manager.Email);
        }
        if(!userManagerMap.isEmpty()){
            sendEmailToManagers(userManagerMap);
        }
    }

    @future
    public static void sendEmailToManagers(Map<Id,String> userManagerMap) {
        List<AggregateResult> accResults = [SELECT COUNT(Id) totalAcc, OwnerId FROM Account WHERE OwnerId IN : userManagerMap.keySet() GROUP BY OwnerId];

        Map<Id,Integer> accMap = new Map<Id,Integer>();
        for(AggregateResult ar : accResults){
            accMap.put((Id)ar.get('OwnerId'), (Integer)ar.get('totalAcc'));
        }

        List<AggregateResult> conResults = [SELECT COUNT(Id) totalCon, OwnerId FROM Contact WHERE OwnerId IN : userManagerMap.keySet() GROUP BY OwnerId];

        Map<Id,Integer> conMap = new Map<Id,Integer>();
        for(AggregateResult ar : conResults){
            conMap.put((Id)ar.get('OwnerId'),(Integer)ar.get('totalCon'));
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id u : userManagerMap.keySet()) {
            String managerEmail = userManagerMap.get(u);
            Integer totalAccount = accMap.containsKey(u) ? accMap.get(u) : 0;
            Integer totalContact = conMap.containsKey(u) ? conMap.get(u) : 0;

            String body = 'Hi,\n\n' +
                          'A user under your supervision was updated.\n\n' +
                          'User Id: ' + u + '\n' +
                          'Total Accounts Owned: ' + totalAccount + '\n' +
                          'Total Contacts Owned: ' + totalContact + '\n\n' +
                          'Regards,\nSalesforce System';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { managerEmail });
            email.setSubject('User Update');
            email.setPlainTextBody(body);

            emails.add(email);
        }
        try {
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        } catch (Exception e) {
            System.debug('Email error: ' + e.getMessage());
        }     
    }
}