public with sharing class searchController {

    private Account a;
    private List<Contact> contactsList;
    private Id primaryId;
    private String accountId = ApexPages.currentPage().getParameters().get('a');
    private Boolean refreshPage {get;set;} 
    public List<Contact> ct {get;set;}
    public String searchKey {get;set;}
    private Contact c {get;set;}
    private Integer counter=0;
    private Integer listSize = 20;
    private Integer totalSize;
    ApexPages.StandardController sc;

    public Id getPrimaryId() {
        return primaryId;
    }
      
    public void setPrimaryId(Id primaryId) {
        this.primaryId = primaryId;
    }

    private ApexPages.StandardController stdCtrl {get; set;}

    public searchController(ApexPages.StandardController sc) {
        this.sc=sc;

        try {
            totalSize = [SELECT COUNT() FROM Contact 
                         WHERE AccountId = :accountId];
            a = [SELECT id, Name, Phone, Fax, Type, AccountNumber, Active__c
                 FROM Account
                 WHERE id = :accountId];
        } catch (Exception e){
            System.debug('Exception ' + e.getMessage());
        }

        refreshPage=true;
      //   a = (Account)controller.getRecord();  

    }
    
    public void search() {
        String searchQuery = 'SELECT Name, Title, Phone, Is_Primary_Contact__c FROM Contact WHERE Name Like \'%' + searchKey + '%\'';
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
            
            refreshPage = true;
        } catch (Exception e) {
            System.debug('Exception' + e.getMessage());
        }
            return null;      
    }

    public PageReference Previous() { 
        counter -= listSize;
        refreshPage=true;
        return null;
    }

    public PageReference Next() { //user clicked next button
        counter += listSize;
        refreshPage=true;
        return null;
    }

    public PageReference Beginning() {
        counter = 0;
        refreshPage=true;
        return null;
    }

    public PageReference End() { //user clicked end
        counter = totalSize - listSize;
        refreshPage=true;
        return null;
    }

    public Integer getPageNumber() {
        return counter/listSize + 1;
    }

    public Integer getTotalPages() {
        return totalSize/listSize;     
    }

    public Boolean getDisablePrevious() { 
        if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() {
        if (counter + listSize < totalSize) return false; else return true;
    }

    public Boolean getRefreshPage() {
        return refreshPage;
    }
}