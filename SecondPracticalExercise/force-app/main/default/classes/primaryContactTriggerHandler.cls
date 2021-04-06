/*
* @author Lavinia Ciobanu
* @date Apr 6, 2021
* @name primaryContactTriggerHandler
* @description handler for primaryContact trigger
*/

public with sharing class primaryContactTriggerHandler {

    public void onBefore (Contact[] newContacts) {
        for (Contact c: newContacts) {
            if (c.Is_Primary_Contact__c) {
                try {
                    Integer primaryContactCount = [SELECT COUNT ()
                                                   FROM Contact
                                                   WHERE AccountId =: c.AccountId
                                                   AND Id != :c.Id
                                                   AND Is_Primary_Contact__c = TRUE];
                    if (primaryContactCount > 0) {
                        c.addError(Label.Primary_Contact_Error);
                    } 
                } catch (Exception e) {
                        System.debug('Exception ' + e.getMessage());
                }
            }
        }
    }

    public void onAfterInsert (Contact[] newContacts) {
        for (Contact c: newContacts) {
            if (c.Is_Primary_Contact__c) {
                Database.executeBatch (new updatePrimaryContactPhone(c.AccountId));
            }
        }
    }

    public void onAfterUpdate(Contact[] oldContacts, Contact[] newContacts) { 
        for (Integer i=0; i< newContacts.size(); i++) {
            Contact newContact = newContacts[i];
            Contact oldContact = oldContacts[i];

            if (newContact.Is_Primary_Contact__c && !oldContact.Is_Primary_Contact__c) {
                Database.executeBatch (new updatePrimaryContactPhone(newContact.AccountId));
            }
        }

    }
}
