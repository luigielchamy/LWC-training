trigger CompetitorTrigger on Competitor__c (before insert, before update) {
    new CompetitorTriggerHandler().run();
}