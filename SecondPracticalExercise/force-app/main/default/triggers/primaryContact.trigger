trigger primaryContact on Contact (before insert, before update, after insert, after update) {
	try {
		if (Trigger.isBefore) {
		
			Set<Id> accountIds = new Set<Id>();
			for (Contact c : Trigger.New) {
				
				Boolean isPrimaryContactSet = Trigger.isUpdate ? C.Is_Primary_Contact__c && !Trigger.oldMap.get(c.Id).Is_Primary_Contact__c : c.Is_Primary_Contact__c;
				if (isPrimaryContactSet){
					accountIds.add(c.AccountId);
				}
			}
		
			if (!accountIds.isEmpty()) {
				List<Contact> primaryContacts = [SELECT Id, AccountId
				                                 FROM Contact
				                                 WHERE Is_Primary_Contact__c = true AND AccountId IN :accountIds];

				Map<Id, List<Contact>> contactsMap = new Map<Id, List<Contact>>();
			
				for (Contact c : primaryContacts) {
					if (!contactsMap.containsKey(C.AccountId)){
						contactsMap.put(C.AccountId, new List<Contact>());
					}
					contactsMap.get(c.AccountId).add(c);
				}

				for (Contact c : Trigger.New) {
					List<Contact> contactsList = contactsMap.get(c.AccountId);
					if (contactsList != null && contactsList.size() > 0){
						Trigger.newMap.get(c.Id).addError('There is primary contact that already exist.');
					}
				}
			}
		} else {
			for (Contact c : Trigger.New) {
				if (c.Is_Primary_Contact__c) {
					Contact oldContact = Trigger.isUpdate ? Trigger.oldMap.get(c.Id) : null;
					if (Trigger.isInsert || Trigger.isUpdate && oldContact != null && !oldContact.Is_Primary_Contact__c) {
						updatePrimaryContactPhone batchInstance = new updatePrimaryContactPhone(c.AccountId);
						Id batchId = Database.executeBatch(batchInstance);
					}
				}
			}
		}
	} catch(Exception e) {
        System.debug('Exception' + e.getMessage());
	}
}