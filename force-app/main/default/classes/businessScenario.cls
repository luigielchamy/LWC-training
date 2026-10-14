public with sharing class businessScenario {
    public class CampaignWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String status;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public Boolean isAlreadyEnrolled;
        @AuraEnabled public String enrollmentStatus;
        @AuraEnabled public Boolean disabled;
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignWrapper> getFilteredCampaigns(
        String searchName, 
        String campaignType, 
        Date filterStartDate, 
        Date filterEndDate, 
        String alreadyEnrolledIdsStr
    ) {
        Set<String> alreadyEnrolledSet = new Set<String>();
        if (String.isNotBlank(alreadyEnrolledIdsStr)) {
            for (String cid : alreadyEnrolledIdsStr.split(',')) {
                alreadyEnrolledSet.add(cid.trim());
            }
        }

        String query = 'SELECT Id, Name, Type, Status, StartDate, EndDate FROM Campaign WHERE Status IN (\'Active\', \'Draft\')';
        List<Campaign> campaigns = Database.query(query);

        List<CampaignWrapper> wrappers = new List<CampaignWrapper>();

        for (Campaign c : campaigns) {
            // Filter by Campaign Name
            if (String.isNotBlank(searchName)) {
                if (c.Name == null || !c.Name.containsIgnoreCase(searchName)) {
                    continue;
                }
            }

            // Filter by Campaign Type
            if (String.isNotBlank(campaignType) && campaignType != 'ALL') {
                if (c.Type != campaignType) {
                    continue;
                }
            }

            // Filter by Date Range (Overlapping check)
            // A campaign overlaps if: (Campaign Start <= Filter End) AND (Campaign End >= Filter Start)
            // Handle null StartDate/EndDate gracefully
            if (filterStartDate != null && c.EndDate != null && c.EndDate < filterStartDate) {
                continue;
            }
            if (filterEndDate != null && c.StartDate != null && c.StartDate > filterEndDate) {
                continue;
            }

            Boolean enrolled = alreadyEnrolledSet.contains(c.Id);

            CampaignWrapper wrap = new CampaignWrapper();
            wrap.id = c.Id;
            wrap.name = c.Name;
            wrap.type = c.Type;
            wrap.status = c.Status;
            wrap.startDate = c.StartDate;
            wrap.endDate = c.EndDate;
            wrap.isAlreadyEnrolled = enrolled;
            wrap.enrollmentStatus = enrolled ? 'Already Enrolled' : 'Not Enrolled';
            wrap.disabled = enrolled;

            wrappers.add(wrap);
        }

        return wrappers;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCampaignTypeOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        options.add(new Map<String, String>{'label' => '--All Types--', 'value' => 'ALL'});
        
        Schema.DescribeFieldResult fieldResult = Campaign.Type.getDescribe();
        for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
            options.add(new Map<String, String>{
                'label' => ple.getLabel(), 
                'value' => ple.getValue()
            });
        }
        return options;
    }
}