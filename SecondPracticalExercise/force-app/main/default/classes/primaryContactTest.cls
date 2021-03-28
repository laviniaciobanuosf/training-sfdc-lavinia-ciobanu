@isTest
public class primaryContactTest {
	@isTest
	static void testCreate() {
		Test.startTest();
		List<Account> accountsList = [SELECT Id
		                          FROM Account
		                          WHERE Name = 'Test Company'
		                          LIMIT 1];
		Contact c = new Contact(FirstName = 'FirstName', LastName = 'Last', Phone = '12345678', Is_Primary_Contact__c = true, AccountId = accountsList[0].Id);
		insert c;
		Test.stopTest();

		List<Contact> randomContacts = [SELECT Id, Primary_Contact_Phone__c
		                                FROM Contact
		                                WHERE AccountId = :accountsList[0].Id and Id != :c.Id and Is_Primary_Contact__c != true
		                                LIMIT 1];

		System.assertEquals(c.phone, randomContacts[0].Primary_Contact_Phone__c);
	}

	@isTest
	static void testUpdate() {
		Test.startTest();
		List<Contact> contactsList = [SELECT Id, Phone
		                          FROM Contact
		                          WHERE FirstName = 'Test' and Is_Primary_Contact__c != true
		                          LIMIT 1];
		Contact contactToUpdate = contactsList[0];
		contactToUpdate.Is_Primary_Contact__c = true;
		update contactToUpdate;
		Test.stopTest();

		List<Contact> randomContacts = [SELECT Id, Primary_Contact_Phone__c
		                                FROM Contact
		                                WHERE FirstName = 'Test' and Id != :contactToUpdate.Id and Is_Primary_Contact__c != true
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
			                          WHERE FirstName = 'Test' and Is_Primary_Contact__c != true
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
	static void makeData() {
		Account account = new Account(Name = 'Test Company');
		insert account;
		List<Contact> contactsList = new List<Contact>();
		for (Integer i = 0; i < 50; i++) {
			contactsList.add(new Contact(FirstName = 'Test', LastName = 'LastName' + i, Phone = '111111' + i, AccountId = account.Id));
		}

		insert contactsList;
	}
}