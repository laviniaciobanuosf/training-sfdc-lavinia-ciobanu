public with sharing class searchController {

    private Account a;
    private List<Contact> contactsList;
    private Id primaryId;
    private String accountId = ApexPages.currentPage().getParameters().get('a');
    private Boolean refreshPage {get;set;} 
    public List<Contact> ct {get;set;}
    public String searchKey {get;set;}
    private Contact c {get;set;}

    public Id getPrimaryId() {
        return primaryId;
    }
      
    public void setPrimaryId(Id primaryId) {
        this.primaryId = primaryId;
    }

    private ApexPages.StandardController stdCtrl {get; set;}

    public searchController(ApexPages.StandardController controller){
        stdCtrl=controller;
        Account a = (Account)controller.getRecord();  
    }
    
    public void search() {
        String searchQuery = 'SELECT Name, Title, Phone, Is_Primary_Contact__c FROM Contact WHERE Name Like \'%' + searchKey + '%\' Limit 50';
        ct = Database.query(searchQuery);
    } 

    public PageReference setAsPrimary() {
        refreshPage = false;
        try {
        List<Contact> primaryContacts = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE AccountId = :accountId AND Is_Primary_Contact__c = true];
            for(Contact primaryContact : primaryContacts) {
                primaryContact.Is_Primary_Contact__c = false;
            }
            update primaryContacts;
            
            Contact c = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE Id = :primaryId];
            c.Is_Primary_Contact__c = true;
            update c;
            
            refreshPage=true;
        } catch (Exception e) {
            System.debug('Exception' + e.getMessage());
        }
            return null;
        
    }
}