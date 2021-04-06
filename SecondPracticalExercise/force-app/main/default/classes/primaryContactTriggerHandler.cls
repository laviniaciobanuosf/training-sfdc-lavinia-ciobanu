/*
* @author Lavinia Ciobanu
* @date Apr 6, 2021
* @name primaryContactTriggerHandler
* @description handler for primaryContact trigger
*/

public with sharing class primaryContactTriggerHandler {

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name onBefore
    * @description executes before insert-update logic
    * @param Contact[] newContacts
    * @return void
    */
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

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name onAfterInsert
    * @description executes after insert logic 
    * @param Contact[] newContacts
    * @return void
    */
    public void onAfterInsert (Contact[] newContacts) {
        for (Contact c: newContacts) {
            if (c.Is_Primary_Contact__c) {
                Database.executeBatch (new updatePrimaryContactPhone(c.AccountId));
            }
        }
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name onAfterUpdate
    * @description executes after update logic 
    * @param Contact[] newContacts, Contact[] newContacts
    * @return void
    */
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
