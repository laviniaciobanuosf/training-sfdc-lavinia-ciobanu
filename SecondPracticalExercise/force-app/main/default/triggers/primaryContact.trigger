trigger primaryContact on Contact (before insert, before update, after insert, after update) {
	try {
		if (Trigger.isBefore) {
		
			Set<Id> accountIds = new Set<Id>();
			for (Contact contact : Trigger.New) {
				
				Boolean isPrimaryContactSet = Trigger.isUpdate ? contact.Is_Primary_Contact__c && !Trigger.oldMap.get(contact.Id).Is_Primary_Contact__c : contact.Is_Primary_Contact__c;
				if (isPrimaryContactSet){
					accountIds.add(contact.AccountId);
				}
			}
		
			if (!accountIds.isEmpty()) {
				List<Contact> primaryContacts = [SELECT Id, AccountId
				                                 FROM Contact
				                                 WHERE Is_Primary_Contact__c = true and AccountId IN :accountIds];

				Map<Id, List<Contact>> contactsMap = new Map<Id, List<Contact>>();
			
				for (Contact contact : primaryContacts) {
					if (!contactsMap.containsKey(contact.AccountId)){
						contactsMap.put(contact.AccountId, new List<Contact>());
					}
					contactsMap.get(contact.AccountId).add(contact);
				}

				for (Contact contact : Trigger.New) {
					List<Contact> contacts = contactsMap.get(contact.AccountId);
					if (contacts != null && contacts.size() > 0){
						Trigger.newMap.get(contact.Id).addError('Cannot set primary contact since account already has one');
					}
				}
			}
		} else {
			for (Contact contact : Trigger.New) {
				if (contact.Is_Primary_Contact__c) {
					Contact oldContact = Trigger.isUpdate ? Trigger.oldMap.get(contact.Id) : null;
					if (Trigger.isInsert || Trigger.isUpdate && oldContact != null && !oldContact.Is_Primary_Contact__c) {
						updatePrimaryContactPhone batchInstance = new updatePrimaryContactPhone(contact.AccountId);
						Id batchId = Database.executeBatch(batchInstance);
					}
				}
			}
		}
	} catch(Exception e) {
        System.debug('Exception' + e.getMessage());
	}
}