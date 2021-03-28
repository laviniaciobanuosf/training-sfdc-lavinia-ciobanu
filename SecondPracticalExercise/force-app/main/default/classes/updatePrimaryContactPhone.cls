public class updatePrimaryContactPhone implements Database.Batchable<SObject>, Database.Stateful {
	public Contact primaryContact;
	//Get the primary contact and set to the state object
	public updatePrimaryContactPhone(Id accountId) {
		List<Contact> primaryContacts = [SELECT Id, Phone, AccountId
		                                 FROM Contact
		                                 WHERE AccountId = :accountId and Is_Primary_Contact__c = true
		                                 LIMIT 1];
		if (primaryContacts != null && primaryContacts.size() > 0) {
			this.primaryContact = primaryContacts[0];
		}
	}

	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String Query = 'SELECT Id FROM Contact WHERE AccountId = primaryContact.AccountId AND Id != primaryContact.Id';
		try {
				return Database.getQueryLocator(Query);
				
		} catch (Exception e) {
			System.debug('Exception' + e.getMessage());
			return null;
		}
	}

	public void execute(Database.BatchableContext bc, List<Contact> scope) {
		try {
			for (Contact contact : scope){
				contact.Primary_Contact_Phone__c = primaryContact.Phone;
			}
			update scope;
		} catch (Exception e) {
			System.debug('Exception' + e.getMessage());
		}
	}

	public void finish(Database.BatchableContext bc) {
	
	}
}