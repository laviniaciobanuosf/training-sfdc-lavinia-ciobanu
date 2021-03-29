public class updatePrimaryContactPhone implements Database.Batchable<SObject>, Database.Stateful {
	public Contact primaryContact;
	private String primaryContactPhone;
	private Id accountId;

	public updatePrimaryContactPhone(Id accountId) {
		this.accountId = accountId;
		List<Contact> primaryContacts = [SELECT Id, Phone, AccountId
		                                 FROM Contact
		                                 WHERE AccountId = :accountId AND Is_Primary_Contact__c = true
		                                 LIMIT 1];
		if (primaryContacts != null && primaryContacts.size() > 0) {
			this.primaryContact = primaryContacts[0];
		}
	}

	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		List<Contact> primaryContacts = [SELECT Id, Phone 
										 FROM Contact 
										 WHERE AccountId = :accountId 
										 AND Is_Primary_Contact__c = true LIMIT 1];
		if (!primaryContacts.isEmpty()) {
			primaryContactPhone = primaryContacts[0].Phone;
		}
	
		return Database.getQueryLocator('SELECT Id FROM Contact ' + 
										'WHERE AccountId = \'' + PrimaryContact.AccountId + '\' AND Id != \'' + PrimaryContact.Id + '\'');					
	}

	public void execute(Database.BatchableContext bc, List<Contact> scope) {
		try {
			for (Contact c : scope){
				c.Primary_Contact_Phone__c = primaryContact.Phone;
			}
			update scope;
		} catch (Exception e) {
			System.debug('Exception' + e.getMessage());
		}
	}

	public void finish(Database.BatchableContext bc) {
	
	}
}