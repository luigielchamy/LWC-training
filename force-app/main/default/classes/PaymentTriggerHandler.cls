public class PaymentTriggerHandler extends TriggerHandler implements ITriggerHandler {
    private Map<Id, Payment__c> newMap;
    private Map<Id, Payment__c> oldMap;
    private List<Payment__c> triggerNew;
    private List<Payment__c> triggerOld;

    public PaymentTriggerHandler() {
        this.newMap = (Map<Id, Payment__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Payment__c>) Trigger.oldMap;
        this.triggerNew = (List<Payment__c>) Trigger.New;
        this.triggerOld = (List<Payment__c>) Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled() {
        return TriggerDisabled;
    }

    public override void beforeInsert() {
        exercise_5.validatePayments(this.triggerNew, null);
    }

    public override void beforeUpdate() {
        exercise_5.validatePayments(this.triggerNew, this.oldMap);
    }

    public override void beforeDelete() {
        exercise_5.validatePaymentDeletion(this.triggerOld);
    }

    public override void afterInsert() {
        exercise_5.rollupTotalPaid(this.triggerNew, null);
    }

    public override void afterUpdate() {
        exercise_5.rollupTotalPaid(this.triggerNew, this.oldMap);
    }

    public override void afterDelete() {
        exercise_5.rollupTotalPaid(null, this.oldMap);
    }

    public override void afterUnDelete() {
        exercise_5.rollupTotalPaid(this.triggerNew, null);
    }
}