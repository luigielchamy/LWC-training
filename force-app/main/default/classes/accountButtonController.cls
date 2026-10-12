public with sharing class accountButtonController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(String accountId) {
        return [
            SELECT Id, FirstName, LastName, Email, Phone, Title 
            FROM Contact 
            WHERE AccountId = :accountId 
            ORDER BY LastName ASC
        ];
    }
}