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
        for(Integer i = 0; i < 49; i++) {
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
        System.currentPageReference().getParameters().put('account', acc.Id);
        
        searchController controller = new searchController(sc);

        //set primary contact test
        controller.setPrimaryId(contactsList[0].Id);
        controller.setAsPrimary();
        List<Contact> primaryContacts = [SELECT Id, FirstName FROM Contact WHERE Is_Primary_Contact__c = true and AccountId = :acc.Id];
        System.assertEquals(1, primaryContacts.size());
        System.assertEquals('Primary', primaryContacts[0].FirstName);

        //page number test
        Integer pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        //total page count test
        Integer totalPages = controller.getTotalPages();
        System.assertEquals(3, totalPages);

        controller.Next();
        pageNumber = controller.getPageNumber();
        System.assertEquals(2, pageNumber);

        controller.End();
        pageNumber = controller.getPageNumber();
        System.assertEquals(2, pageNumber);

        //disable next test
        Boolean disableNext = controller.getDisableNext();
        System.assertEquals(true, disableNext);

        controller.Previous();
        pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        controller.Beginning();
        pageNumber = controller.getPageNumber();
        System.assertEquals(1, pageNumber);

        //disable previous test
        Boolean disablePrev = controller.getDisablePrevious();
        System.assertEquals(true, disablePrev);

        Test.stopTest();
    }
}