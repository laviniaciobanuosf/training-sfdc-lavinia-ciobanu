/*
* @author Lavinia Ciobanu
* @date Apr 6, 2021
* @name primaryContactTest
* @description test class for primary contact 
*/

@isTest
public class primaryContactTest {
	@isTest
	static void testCreate() {
		Test.startTest();
		List<Account> accountsList = [SELECT Id
		                          FROM Account
		                          WHERE Name = 'Test Company'
		                          LIMIT 1];
		Contact c = new Contact(FirstName = 'TriggerTest', LastName = 'LastName', Phone = '123456789', Is_Primary_Contact__c = true, AccountId = accountsList[0].Id);
		insert c;
		Test.stopTest();

		List<Contact> randomContacts = [SELECT Id, Primary_Contact_Phone__c
		                                FROM Contact
		                                WHERE AccountId = :accountsList[0].Id AND Id != :c.Id and Is_Primary_Contact__c != true
		                                LIMIT 1];

		System.assertEquals(c.phone, randomContacts[0].Primary_Contact_Phone__c);
	}

	@isTest
	static void testUpdate() {
		Test.startTest();
		List<Contact> contactsList = [SELECT Id, Phone
		                          	  FROM Contact
		                         	  WHERE FirstName = 'TriggerTest' AND Is_Primary_Contact__c != true
									  LIMIT 1];
		Contact contactToUpdate = contactsList[0];
		contactToUpdate.Is_Primary_Contact__c = true;
		update contactToUpdate;
		Test.stopTest();

		List<Contact> randomContacts = [SELECT Id, Primary_Contact_Phone__c
		                                FROM Contact
		                                WHERE FirstName = 'TriggerTest' AND Id != :contactToUpdate.Id AND Is_Primary_Contact__c != true
		                                LIMIT 1];

		System.assertEquals(contactToUpdate.phone, randomContacts[0].Primary_Contact_Phone__c);
	}

	@isTest
	static void testExistingPrimary() {
		Boolean DidThrowException = false;
		Test.startTest();
		try{

			List<Contact> contactsList = [SELECT Id, Phone
			                         	  FROM Contact
			                          	  WHERE FirstName = 'TriggerTest' AND Is_Primary_Contact__c != true
			                          	  LIMIT 2];
			Contact firstPrimary = contactsList[0];
			firstPrimary.Is_Primary_Contact__c = true;
			update firstPrimary;

			Contact secondTry = contactsList[1];
			secondTry.Is_Primary_Contact__c = true;
			update secondTry;

		} catch (DmlException ex) {
            DidThrowException = true;
		}

		Test.stopTest();
        System.assertEquals(true, DidThrowException);
	}

	@TestSetup
	static void makeData(){
		Account acc = new Account(Name = 'Test Company');
		insert acc;
		List<Contact> contactsList = new List<Contact>();
		for (Integer i = 0; i < 50; i++){
			contactsList.add(new Contact(FirstName = 'TriggerTest', LastName = 'LastName' + i, Phone = '1111111' + i, AccountId = acc.Id));
		}
		insert contactsList;
	}
}