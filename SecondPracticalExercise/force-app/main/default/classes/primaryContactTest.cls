@isTest
public class primaryContactTest {
	@isTest
	static void testCreate(){
		Test.startTest();
		List<Account> accounts = [select Id
		                          from Account
		                          where Name = 'Burger Trigger Company'
		                          LIMIT 1];
		Contact contact = new Contact(FirstName = 'TestCreate', LastName = 'TestCreate', Phone = '9999', Is_Primary_Contact__c = true, AccountId = accounts[0].Id);
		insert contact;
		Test.stopTest();

		List<Contact> randomContacts = [Select Id, Primary_Contact_Phone__c
		                                from Contact
		                                where AccountId = :accounts[0].Id and Id != :contact.Id and Is_Primary_Contact__c != true
		                                limit 1];

		System.assertEquals(contact.phone, randomContacts[0].Primary_Contact_Phone__c);
	}

	@isTest
	static void testUpdate(){
		Test.startTest();
		List<Contact> contacts = [Select Id, Phone
		                          from Contact
		                          where FirstName = 'TriggerTest' and Is_Primary_Contact__c != true
		                          limit 1];
		Contact contactToUpdate = contacts[0];
		contactToUpdate.Is_Primary_Contact__c = true;
		update contactToUpdate;
		Test.stopTest();

		List<Contact> randomContacts = [Select Id, Primary_Contact_Phone__c
		                                from Contact
		                                where FirstName = 'TriggerTest' and Id != :contactToUpdate.Id and Is_Primary_Contact__c != true
		                                limit 1];

		System.assertEquals(contactToUpdate.phone, randomContacts[0].Primary_Contact_Phone__c);
	}

	@isTest
	static void testExistingPrimary(){
		Boolean DidThrowException = false;
		Test.startTest();
		try{

			List<Contact> contacts = [Select Id, Phone
			                          from Contact
			                          where FirstName = 'TriggerTest' and Is_Primary_Contact__c != true
			                          limit 2];
			Contact firstPrimary = contacts[0];
			firstPrimary.Is_Primary_Contact__c = true;
			update firstPrimary;

			Contact secondTry = contacts[1];
			secondTry.Is_Primary_Contact__c = true;
			update secondTry;

		} catch (DmlException ex){
            DidThrowException = true;
		}

		Test.stopTest();
        System.assertEquals(true, DidThrowException);
	}

	@TestSetup
	static void makeData(){
		Account account = new Account(Name = 'Burger Trigger Company');
		insert account;
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < 50; i++){
			contacts.add(new Contact(FirstName = 'TriggerTest', LastName = 'Last ' + i, Phone = '55555555' + i, AccountId = account.Id));
		}

		insert contacts;
	}
}