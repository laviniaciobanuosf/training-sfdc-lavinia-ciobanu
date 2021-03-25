trigger primaryContact on Contact (before insert, before update, after insert, 
                                   after update, after delete, after undelete) {
    List<Id> accountIds = new List<Id>();
    List<Contact> contactsList = new List<Contact>(); 
    List<Id> contactsIds = new List<Id>(); 
    String primaryPhoneNumber;
                                       
    if(trigger.IsBefore && (trigger.IsInsert || trigger.IsUpdate)){
        for(Contact c : Trigger.new){
            if(c.Is_Primary_Contact__c == true){
                primaryPhoneNumber = c.Primary_Contact_Phone__c;
                accountIds.add(c.AccountId);
                contactsIds.add(c.Id);
                contactsList.add(c);
            }
        }
    }
                                                                           
    List<Account> relatedAccounts = ([SELECT Id, (SELECT Id, Is_Primary_Contact__c 
                                                  FROM Contacts
                                                  WHERE Is_Primary_Contact__c = true)
                                                  FROM Account WHERE Id in:accountIds]);
    
    for (Contact everyContact: contactsList){
        for (Account everyAccount: relatedAccounts){
            if(everyContact.AccountId == everyAccount.Id && everyAccount.Contacts.size()>0){
                everyContact.addError('There is primary contact that already exist.');
            }
            else everyContact.Primary_Contact_Phone__c = primaryPhoneNumber;
        }    
    }
                                     
    List<Id> acctIds = new List<Id>();
    
    if (trigger.IsInsert || trigger.IsUpdate || trigger.IsUndelete){
        for(Contact c: trigger.New){
            if(c.AccountId!=NULL){
                acctIds.add(c.AccountId);
            }
        }
    }
                                       
    if (trigger.IsDelete){
        for(Contact c: trigger.Old){
           if(c.AccountId!=NULL){
               acctIds.add(c.AccountId);
            }
        }
    }
                                       
    List<Account> updateAccountsList = new List<Account>();
                                       
    for(Account a:[SELECT Id, Name,
                   (SELECT Id, FirstName, LastName, Is_Primary_Contact__c FROM Contacts
                   WHERE Is_Primary_Contact__c = TRUE LIMIT 1)
                   FROM Account WHERE Id=:acctIds]){
                       if(a.Contacts.size()>0){
                         a.Primary_Contact__c=a.Contacts[0].Id;
                         updateAccountsList.add(a);  
                       }          
                   }
                                       
    try{
        if(!updateAccountsList.isEmpty()){
            update updateAccountsList;
        }
    } catch(Exception e){
        System.debug('Exception' + e.getMessage());
    }
                                       
}