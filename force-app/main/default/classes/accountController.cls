public with sharing class accountController {
    @AuraEnabled
    public static string createNewAccount(String accountName){
        Account acc= new Account();
        insert acc;
        return JSON.serialize(acc);
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer maxRecords) {
        List<Account> accounts = [SELECT Id, Name 
                                  FROM Account 
                                  ORDER BY CreatedDate 
                                  DESC LIMIT: maxRecords];
        return accounts;
    }
}