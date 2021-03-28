trigger primaryContact on Contact (before insert, before update, after insert, after update){
	try{
		if (Trigger.isBefore){
			//Get accountIds to use in the soql query. The query will retrieve all the primary contacts of given set of Id's.
			Set<Id> accountIds = new Set<Id>();
			for (Contact contact : Trigger.New){
				//Check if a new contact is primary or for update - is contacts primary field changed.
				Boolean isPrimaryContactSet = Trigger.isUpdate ? contact.Is_Primary_Contact__c && !Trigger.oldMap.get(contact.Id).Is_Primary_Contact__c : contact.Is_Primary_Contact__c;
				if (isPrimaryContactSet){
					accountIds.add(contact.AccountId);
				}
			}
			//Retrieve primary contacts.
			if (!accountIds.isEmpty()){
				List<Contact> primaryContacts = [select Id, AccountId
				                                 from Contact
				                                 Where Is_Primary_Contact__c = true and AccountId IN :accountIds];

				Map<Id, List<Contact>> contactsMap = new Map<Id, List<Contact>>();
				//Filter contacts by accountId and put to a map to execute validations on each.
				for (Contact contact : primaryContacts){
					if (!contactsMap.containsKey(contact.AccountId)){
						contactsMap.put(contact.AccountId, new List<Contact>());
					}
					contactsMap.get(contact.AccountId).add(contact);
				}

				for (Contact contact : Trigger.New){
					List<Contact> contacts = contactsMap.get(contact.AccountId);
					if (contacts != null && contacts.size() > 0){
						Trigger.newMap.get(contact.Id).addError('Cannot set primary contact since account already has one');
					}
				}
			}
		} else{
			for (Contact contact : Trigger.New){
				if (contact.Is_Primary_Contact__c){
					Contact oldContact = Trigger.isUpdate ? Trigger.oldMap.get(contact.Id) : null;
					if (Trigger.isInsert || Trigger.isUpdate && oldContact != null && !oldContact.Is_Primary_Contact__c){
						updatePrimaryContactPhone batchInstance = new updatePrimaryContactPhone(contact.AccountId);
						Id batchId = Database.executeBatch(batchInstance);
					}
				}
			}
		}
	} catch(Exception e){
        System.debug('Exception' + e.getMessage());
	}
}