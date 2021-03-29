public with sharing class searchController {

    private Account a;
    private List<Contact> contactsList {get;set;};
    private Id primaryId;
    private String accountId = ApexPages.currentPage().getParameters().get('a');
    private Boolean refreshPage {get; set;} 
   // private List<Contact> ct { get; set;}
    private String searchKey {get;set;}
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
        // newPrimaryContactId='';
    
    }
    
    public void search() {
        String searchQuery = 'SELECT Name, Title, Phone, Is_Primary_Contact__c FROM Contact WHERE Name Like \'%'+searchKey+'%\' Limit 50';
        contactsList = Database.query(searchQuery);
    } 
   
 //   public Contact cc {get;set;}
       
  //  public Id newPrimaryContactId {get;set;}
  


    public PageReference setPrimaryContact() {
        refreshPage = false;
        List<Contact> primaryContacts = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE AccountId = :accountId AND Is_Primary_Contact__c = true];
            for(Contact primaryContact : primaryContacts) {
                primaryContact.Is_Primary_Contact__c = false;
            }
            update primaryContacts;
            
            Contact c = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE Id = :primaryId];
            c.Is_Primary_Contact__c = true;
            update c;
            
            refreshPage=true;
            return null;
        
    }
}