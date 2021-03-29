@isTest
private class searchControllerTest {
    static testmethod void testPageController() {
        Account acc = new Account();
        acc.Name='Test Account';
        insert acc;

        Contact primaryContact = new Contact();
        primaryContact.AccountId = acc.Id;
        primaryContact.FirstName = 'Primary'; 
        primaryContact.LastName = 'LastName'; 
        primaryContact.Phone = '123456789';
        primaryContact.Is_Primary_Contact__c = true;
        insert primaryContact;

        List<Contact> contactsList = new List<Contact>();
        for(Integer i = 0; i < 50; i++) {
            Contact c = new Contact();
            c.AccountId = acc.Id;
            c.FirstName = 'FirstName'; 
            c.LastName = 'LastName' + i; 
            c.Phone = '11223344' + i; 
            c.Is_Primary_Contact__c = false;
            contactsList.add(c);
        }
        insert contactsList;

        Map<Id, Contact> contactsMap = new Map<Id, Contact>(contactsList);

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);

        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('a', acc.Id);
        
        searchController controller = new searchController(sc);

        controller.setPrimaryId(contactsList[0].Id);
        controller.setAsPrimary();
        List<Contact> primaryContacts = [SELECT Id, FirstName FROM Contact WHERE Is_Primary_Contact__c = true and AccountId = :acc.Id];
        System.assertEquals(1, primaryContacts.size());
        System.assertEquals('FirstName', primaryContacts[0].FirstName);

        Integer pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        controller.Next();
        pageNumber = controller.getPageNumber();
        System.assertEquals(2, pageNumber);

        Integer totalPages = controller.getTotalPages();
        System.assertEquals(3, totalPages);

        controller.End();
        pageNumber = controller.getPageNumber();
        System.assertEquals(2, pageNumber);

        Boolean disableNext = controller.getDisableNext();
        System.assertEquals(true, disableNext);

        controller.Previous();
        pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        controller.Beginning();
        pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        Boolean disablePrev = controller.getDisablePrevious();
        System.assertEquals(true, disablePrev);

        controller.setSearchKey('Primary');
        List<Contact> filteredContacts = controller.getContacts();
        System.assertEquals(1, filteredContacts.size());

        Boolean refreshPage = controller.getRefreshPage();
        System.assertEquals(true, refreshPage);

        Test.stopTest();
    }
}