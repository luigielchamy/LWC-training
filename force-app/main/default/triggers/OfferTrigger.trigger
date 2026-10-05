trigger OfferTrigger on Offer__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OfferTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            OfferTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}