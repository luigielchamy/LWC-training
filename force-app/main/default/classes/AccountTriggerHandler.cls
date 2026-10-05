public with sharing class AccountTriggerHandler extends TriggerHandler implements ITriggerHandler{

    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;
    private List<Account> TriggerNew;
    private List<Account> TriggerOld;
    
    public AccountTriggerHandler(){
        this.newMap = (Map<Id, Account>) Trigger.newMap;
        this.oldMap = (Map<Id, Account>) Trigger.oldMap;
        this.TriggerNew= (List<Account>) Trigger.New;
        this.TriggerOld= (List<Account>) Trigger.Old;
    }
    
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {

    }
    public override void afterInsert() {
    }
    public  override void beforeUpdate() {
        
    }
    public override void afterUpdate() {
    }
    
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUnDelete() {
        
    }
}