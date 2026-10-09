public with sharing class Exercise4 {

    // Method in order to set the correct identifier on the offer according to opportunity
    public static void modifyOfferIdentifier(List<Offer__c> newList, Map<Id,Offer__c> oldMap) {

        // Creating a map of opportunity Id to list of offers which will be used to assign the identifier in the offer
        Map<Id,List<Offer__c>> oppIdToListOfferMap = new Map<Id,List<Offer__c>>();
        
        // Looping over the new list of values
        for(Offer__c off : newList){

            // If we are in an insert state or the opportunity has been changed 
            if(oldMap == null || off.Opportunity__c != oldMap.get(off.Id).Opportunity__c){

                // Checking if the opportunity key already exists in the map
                if(oppIdToListOfferMap.containsKey(off.Opportunity__c)){

                    // If yes then add the offer to the opportunity key
                    oppIdToListOfferMap.get(off.Opportunity__c).add(off);

                } else {

                    // If not then insert a new key opp Id with the list initialized with the offer
                    oppIdToListOfferMap.put(off.Opportunity__c,new List<Offer__c>{off});

                }
            }
        }

        // If the map is not empty
        if(!oppIdToListOfferMap.isEmpty()){

            // Looping over all the opportunity whose id are in my map's keyset
            for(Opportunity opp : [SELECT Identifier__c,TECH_Offer_Number__c FROM Opportunity WHERE Id IN: oppIdToListOfferMap.keySet()]){

                // Getting the opportunity's number of offers and casting it into an Integer (since it arrives as a double)
                Integer identNumber = (Integer)opp.TECH_Offer_Number__c;

                // Looping over all the offers that are related to this opportunity that are found in my original map (meaning whose identifier needs modification)
                for(Offer__c off : oppIdToListOfferMap.get(opp.Id)){

                    // Incrementing the number of offers by 1 and making it as a string
                    String identNumberString = String.valueOf(++identNumber);

                    // Shorthand notation of if to set the correct format on the identifier
                    // If the number in the roll up summary is made of 1 digit then add 2 zeros prior else if it has 2 digits then add 1 zero else keep it as it is
                    identNumberString = identNumberString.length() == 1 ? '00' + identNumberString : identNumberString.length() == 2 ? '0' + identNumberString : identNumberString;

                    // Assiging the identifier for the offer by adding the identifier of the opportuntiy along with the formatted string
                    off.Identifier__c = opp.Identifier__c + '-' + identNumberString;
                }
            }
        }
    }
}