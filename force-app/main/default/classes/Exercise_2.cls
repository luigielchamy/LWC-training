public with sharing class Exercise_2 {
    public static void updateAccountContactCounts() {
        if () { 
            Set<Id> accountIds = new Set<Id>();
            for (Account acc : Trigger.New) {
                if (acc.Id != null) {
                    accountIds.add(acc.Id);
                }
            }
        }

        List<Account> accounts = [SELECT id, (SELECT id 
                                              FROM contacts 
                                              WHERE FirstName = null  OR LastName = 'Smith')
                                  FROM Account 
                                  WHERE id IN :accountIds];

        for (Account acc : accounts){
            Integer i = acc.contacts.size();
        }
    }
}

