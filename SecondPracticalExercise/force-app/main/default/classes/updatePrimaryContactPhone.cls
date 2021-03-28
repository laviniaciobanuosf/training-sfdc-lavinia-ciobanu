public class updatePrimaryContactPhone implements Database.Batchable<SObject>, Database.Stateful {
	private Id accountId;
    private String primaryContactPhone;

    public updatePrimaryContactPhone(Id accountId) {
        this.accountId = accountId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        List<Contact> primaryContacts = [select Id, Phone from Contact where AccountId = :accountId and Is_Primary_Contact__c = true LIMIT 1];
        if(!primaryContacts.IsEmpty()) {
            primaryContactPhone = primaryContacts[0].Phone;
        }

        return Database.getQueryLocator('select Id, Is_Primary_Contact__c, Primary_Contact_Phone__c from Contact where AccountId = \'' + accountId + '\'');
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        
        try {
            // process each batch of records
            for(Contact c : scope) {
                c.Primary_Contact_Phone__c = primaryContactPhone;
            }

            update scope;
        } catch (Exception e){
            System.debug('Exception' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}