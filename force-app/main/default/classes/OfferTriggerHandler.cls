public with sharing class OfferTriggerHandler {

    public static void handleBeforeInsert(List<Offer__c> newOffers) {
        List<Offer__c> offersToProcess = new List<Offer__c>();
        for (Offer__c offer : newOffers) {
            if (offer.Opportunity__c != null) {
                offersToProcess.add(offer);
            }
        }
        if (!offersToProcess.isEmpty()) {
            generateIdentifiers(offersToProcess);
        }
    }

    public static void handleBeforeUpdate(List<Offer__c> newOffers, Map<Id, Offer__c> oldOffersMap) {
        List<Offer__c> offersToProcess = new List<Offer__c>();
        for (Offer__c offer : newOffers) {
            Offer__c oldOffer = oldOffersMap.get(offer.Id);
            // Process if the opportunity parent has changed
            if (offer.Opportunity__c != oldOffer.Opportunity__c && offer.Opportunity__c != null) {
                offersToProcess.add(offer);
            }
        }
        if (!offersToProcess.isEmpty()) {
            generateIdentifiers(offersToProcess);
        }
    }

    private static void generateIdentifiers(List<Offer__c> offers) {
        Set<Id> oppIds = new Set<Id>();
        for (Offer__c offer : offers) {
            oppIds.add(offer.Opportunity__c);
        }

        // Fetch parent Opportunity Identifiers
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Identifier__c 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ]);

        // Determine the current maximum suffix number for each Opportunity
        Map<Id, Integer> oppNextSequenceMap = new Map<Id, Integer>();
        
        // Initialize map with 0 for all target opportunities
        for (Id oppId : oppIds) {
            oppNextSequenceMap.put(oppId, 0);
        }

        // Query existing offers to find the highest suffix sequence used so far
        List<Offer__c> existingOffers = [
            SELECT Id, Opportunity__c, Identifier__c 
            FROM Offer__c 
            WHERE Opportunity__c IN :oppIds AND Identifier__c != null
        ];

        for (Offer__c extOffer : existingOffers) {
            Id oppId = extOffer.Opportunity__c;
            String ident = extOffer.Identifier__c;
            
            // Extract the numeric suffix (assuming format 'XXX-000')
            if (ident.contains('-')) {
                try {
                    String suffixStr = ident.substringAfterLast('-');
                    Integer suffixNum = Integer.valueOf(suffixStr);
                    if (suffixNum >= oppNextSequenceMap.get(oppId)) {
                        oppNextSequenceMap.put(oppId, suffixNum + 1);
                    }
                } catch (Exception e) {
                    // Handle edge cases where format might be manual or corrupted
                }
            }
        }

        // Assign the new identifiers and increment the sequence sequentially for in-memory records
        for (Offer__c offer : offers) {
            Opportunity parentOpp = oppMap.get(offer.Opportunity__c);
            if (parentOpp != null && parentOpp.Identifier__c != null) {
                Integer nextSeq = oppNextSequenceMap.get(offer.Opportunity__c);
                
                // Format the counter to 3 digits (e.g., 002)
                String paddedSequence = String.valueOf(nextSeq).leftPad(3, '0');
                
                // Set the combined identifier
                offer.Identifier__c = parentOpp.Identifier__c + '-' + paddedSequence;
                
                // Increment counter for the next record in the same batch
                oppNextSequenceMap.put(offer.Opportunity__c, nextSeq + 1);
            }
        }
    }
}