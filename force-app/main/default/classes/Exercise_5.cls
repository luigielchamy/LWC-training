public with sharing class Exercise_5 {
    //Validates field-level rules and checks if the total paid amount exceeds the Opportunity amount.
    public static void validatePayments(List<Payment__c> newPayments, Map<Id, Payment__c> oldMap) {
        Set<Id> oppIdsToCheck = new Set<Id>();
        List<Payment__c> paymentsToEvaluate = new List<Payment__c>();

        for (Payment__c newPay : newPayments) {
            Payment__c oldPay = oldMap != null ? oldMap.get(newPay.Id) : null;

            //Amount must be greater than 0
            if (newPay.Amount__c <= 0) {
                newPay.Amount__c.addError('The amount must be greater than 0.');
                continue;
            }

            //The amount of a paid payment cannot be modified
            if (oldPay != null && oldPay.Status__c == 'Paid' && newPay.Amount__c != oldPay.Amount__c) {
                newPay.Amount__c.addError('The amount of a paid payment cannot be modified.');
                continue;
            }

            //A paid payment requires a payment date, not in the future
            if (newPay.Status__c == 'Paid') {
                if (newPay.Payment_Date__c == null) {
                    newPay.Payment_Date__c.addError('A paid payment requires a payment date.');
                    continue;
                } else if (newPay.Payment_Date__c > Date.today()) {
                    newPay.Payment_Date__c.addError('The payment date cannot be in the future.');
                    continue;
                }
            }

            //Gather Opportunity IDs to evaluate the total ceiling rule bulk-safely
            if (newPay.Opportunity__c != null && newPay.Status__c == 'Paid') {
                oppIdsToCheck.add(newPay.Opportunity__c);
                paymentsToEvaluate.add(newPay);
            }
            
            //If the Opportunity changed, we must also track the old Opportunity
            if (oldPay != null && oldPay.Opportunity__c != null && oldPay.Opportunity__c != newPay.Opportunity__c) {
                oppIdsToCheck.add(oldPay.Opportunity__c);
            }
        }

        if (oppIdsToCheck.isEmpty()) return;

        //Fetch target opportunities and their existing Paid payments (excluding current records being processed)
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Amount, (SELECT Id, Amount__c 
                                FROM Payments__r 
                                WHERE Status__c = 'Paid' 
                                AND Id NOT IN :newPayments) 
            FROM Opportunity 
            WHERE Id IN :oppIdsToCheck
        ]);

        //Keep a running simulation of the total paid per opportunity during this transaction context
        Map<Id, Decimal> simulatedTotals = new Map<Id, Decimal>();
        for (Opportunity opp : oppMap.values()) {
            Decimal currentPaidSum = 0;
            for (Payment__c p : opp.Payments__r) {
                currentPaidSum += p.Amount__c;
            }
            simulatedTotals.put(opp.Id, currentPaidSum);
        }

        //Validate that the total paid can never exceed the opportunity’s amount
        for (Payment__c newPay : paymentsToEvaluate) {
            Opportunity opp = oppMap.get(newPay.Opportunity__c);
            if (opp != null) {
                Decimal runningTotal = simulatedTotals.get(opp.Id) + newPay.Amount__c;
                Decimal maxAllowed = opp.Amount != null ? opp.Amount : 0;

                if (runningTotal > maxAllowed) {
                    newPay.addError('The total paid amount (' + runningTotal + ') exceeds the opportunity\'s amount (' + maxAllowed + ').');
                } else {
                    //Update simulation map in case multiple payments are inserted/updated for the same Opp simultaneously
                    simulatedTotals.put(opp.Id, runningTotal);
                }
            }
        }
    }

    //Restricts users from deleting any payment that has a 'Paid' status.
    public static void validatePaymentDeletion(List<Payment__c> oldPayments) {
        for (Payment__c oldPay : oldPayments) {
            if (oldPay.Status__c == 'Paid') {
                oldPay.addError('A paid payment cannot be deleted.');
            }
        }
    }

    //Calculates the read-only Total_Paid__c field on Opportunity.
    public static void rollupTotalPaid(List<Payment__c> newPayments, Map<Id, Payment__c> oldMap) {
        Set<Id> oppIds = new Set<Id>();

        if (newPayments != null) {
            for (Payment__c p : newPayments) {
                if (p.Opportunity__c != null) oppIds.add(p.Opportunity__c);
                //catch the old opportunity ID
                if (oldMap != null && oldMap.containsKey(p.Id) && oldMap.get(p.Id).Opportunity__c != p.Opportunity__c) {
                    if (oldMap.get(p.Id).Opportunity__c != null) {
                        oppIds.add(oldMap.get(p.Id).Opportunity__c);
                    }
                }
            }
        }

        if (newPayments == null && oldMap != null) { // Deletion context
            for (Payment__c p : oldMap.values()) {
                if (p.Opportunity__c != null) oppIds.add(p.Opportunity__c);
            }
        }

        if (oppIds.isEmpty()) return;

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        //Query the aggregate sums of Paid payments grouped by Opportunity
        Map<Id, Decimal> rollupResults = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Opportunity__c oppId, SUM(Amount__c) totalPaid 
            FROM Payment__c 
            WHERE Status__c = 'Paid' AND Opportunity__c IN :oppIds 
            GROUP BY Opportunity__c
        ]) {
            rollupResults.put((Id)ar.get('oppId'), (Decimal)ar.get('totalPaid'));
        }

        //Build the update list (setting it to 0 if no paid payments remain)
        for (Id oppId : oppIds) {
            Decimal totalPaid = rollupResults.containsKey(oppId) ? rollupResults.get(oppId) : 0;
            oppsToUpdate.add(new Opportunity(Id = oppId, Total_Paid__c = totalPaid));
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}