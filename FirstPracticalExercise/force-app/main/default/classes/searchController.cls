public with sharing class searchController {
    
    public List<Contact> ct { get; set;}
    public String searchKey {get;set;}
    public Contact c {get;set;}
    public Account a {get;set;}

    private ApexPages.StandardController stdCtrl {get; set;}

    public searchController(ApexPages.StandardController controller){
        stdCtrl=controller;
        Account a = (Account)controller.getRecord();  
        // newPrimaryContactId='';
    
    }
    
    public void search() {
        String searchQuery = 'SELECT Name, Title, Phone, Is_Primary_Contact__c FROM Contact WHERE Name Like \'%'+searchKey+'%\' Limit 50';
        ct = Database.query(searchQuery);
    } 
   
    public void setAsPrimary(){
        
        for (Contact c : ct) {
            if (c.Is_Primary_Contact__c == false){
            
                c.Is_Primary_Contact__c = true;
      		 }   
   		}    
    }
   
    public Contact cc {get;set;}
       
    public Id newPrimaryContactId {get;set;}
  
    public PageReference SetPrimary() {
       // Id accountId = ApexPages.currentPage().getParameters().get('newPrimaryContactId');
       // System.debug('The value in contactId: ' + newPrimaryContactId);
       // c = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE Id =:newPrimaryContactId];
        newPrimaryContactId = System.currentPageReference().getParameters().get('newPrimaryContactId');
        List<Contact> contactToSetPrimary = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE Id =:'newPrimaryContactId'];
        System.debug('newPrimaryContactId');
        for(Contact ctt: contactToSetPrimary){
            if(ctt.Is_Primary_Contact__c == FALSE){
                ctt.Is_Primary_Contact__c = TRUE;
            }
        }
        update contactToSetPrimary;
        return null;  
    }
}