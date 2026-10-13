public with sharing class AccountOpportunityController {

    public class AccountOpportunityWrapper {
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public List<Opportunity> opportunities { get; set; }
        @AuraEnabled public Integer opportunityCount { get; set; }
        @AuraEnabled public Decimal totalAmount { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountOpportunityWrapper> getAccountsWithOpportunities() {
        List<AccountOpportunityWrapper> wrapperList = new List<AccountOpportunityWrapper>();

        List<Account> accList = [
            SELECT Id, Name,
                   (SELECT Id, Name, StageName, Amount 
                    FROM Opportunities 
                    ORDER BY Name ASC)
            FROM Account
            ORDER BY Name ASC
            LIMIT 50
        ];

        for (Account acc : accList) {
            AccountOpportunityWrapper wrap = new AccountOpportunityWrapper();
            wrap.accountId = acc.Id;
            wrap.accountName = acc.Name;
            wrap.opportunities = acc.Opportunities;
            wrap.opportunityCount = acc.Opportunities.size();

            Decimal total = 0;
            for (Opportunity opp : acc.Opportunities) {
                if (opp.Amount != null) {
                    total += opp.Amount;
                }
            }
            wrap.totalAmount = total;
            wrapperList.add(wrap);
        }

        return wrapperList;
    }

    @AuraEnabled
    public static void updateOpportunityStage(String opportunityId, String newStage) {
        if (String.isNotBlank(opportunityId) && String.isNotBlank(newStage)) {
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
            opp.StageName = newStage;
            update opp;
        }
    }

    
}