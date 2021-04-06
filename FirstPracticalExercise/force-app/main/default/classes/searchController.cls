/*
* @author Lavinia Ciobanu
* @date Apr 6, 2021
* @name searchController
* @description controller for AccountPrimaryContact page 
*/

public with sharing class searchController {

    private Account a;
    private List<Contact> contactsList;
    private Id primaryId;
    private String accountId = ApexPages.currentPage().getParameters().get('a');
    private Boolean refreshPage {get;set;} 
    public List<Contact> ct {get;set;}
    private String searchKey = '';
    private Contact c {get;set;}
    private Integer counter=0;
    private Integer listSize = 20;
    private Integer totalSize;
    ApexPages.StandardController sc;

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getPrimaryId
    * @description get method for primaryId parameter
    * @param null
    * @return primaryId
    */
    public Id getPrimaryId() {
        return primaryId;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name setPrimaryId
    * @description set method for primaryId parameter
    * @param Id primaryId
    * @return void
    */   
    public void setPrimaryId(Id primaryId) {
        this.primaryId = primaryId;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getAccount
    * @description get method for Account parameter
    * @param null
    * @return a
    */
    public Account getAccount() {
        return a;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getSearchKey
    * @description get method for searchKey parameter
    * @param null
    * @return searchKey
    */
    public String getSearchKey() {
        return searchKey;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name setSearchKey
    * @description set method for searchKey parameter
    * @param String searchKey
    * @return void
    */
    public void setSearchKey(String searchKey) {
        this.searchKey = searchKey;
    }

    public searchController(ApexPages.StandardController sc) {
        this.sc=sc;

        try {
            totalSize = [SELECT COUNT() FROM Contact 
                         WHERE AccountId = :accountId];
            a = [SELECT id, Name, Phone, Fax, Type, AccountNumber, Active__c
                 FROM Account
                 WHERE Id = :accountId];
        } catch (Exception e){
            System.debug('Exception ' + e.getMessage());
        }

        refreshPage=true;
        // a = getAccount();
        // a = (Account)sc.getRecord();  

    }
    
    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name search
    * @description method to search contacts with searchKey
    * @param null
    * @return list of contacts
    */
    public void search() {
        try {
        String searchQuery = 'SELECT Name, Title, Phone, Is_Primary_Contact__c FROM Contact WHERE Name Like \'%' + searchKey + '%\' ORDER BY Id LIMIT ' + listSize + 'OFFSET ' + counter;
        ct = Database.query(searchQuery);
        } catch (Exception e) {
            System.debug('Exception' + e.getMessage());
        }
    } 
    
    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getContacts
    * @description get method for Contacts list
    * @param null
    * @return List<Contact>
    */
    public List<Contact> getContacts() {
        try {
            String searchTerm = '%' + searchKey + '%';
            contactsList = [SELECT Id, Name, Title, Phone, Is_Primary_Contact__c
                            FROM Contact 
                            WHERE AccountId = :accountId
                            AND Name like :searchTerm
                            ORDER BY Id 
                            LIMIT :listSize 
                            OFFSET :counter];
        	refreshPage=true;
            return contactsList;
            
        } catch (QueryException e) {
            System.debug('Exception' + e);
            ApexPages.addMessages(e);   
            return null;
        }
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name setAsPrimary
    * @description sets the selected contact as primary
    * @param null
    * @return PageReference
    */
    public PageReference setAsPrimary() {
        refreshPage = false;
        try {
        List<Contact> primaryContacts = [SELECT Id, Is_Primary_Contact__c FROM Contact WHERE AccountId = :accountId AND (Is_Primary_Contact__c = true OR Id = :primaryId)];
            for(Contact primaryContact : primaryContacts) {
                if (primaryContact.Is_Primary_Contact__c) {
                 primaryContact.Is_Primary_Contact__c = false; 
                }  
                else if (primaryContact.Id == primaryId) {
                     primaryContact.Is_Primary_Contact__c = true;
                }    
            }
            update primaryContacts;
            
            refreshPage = true;
        } catch (Exception e) {
            System.debug('Exception' + e.getMessage());
        }
            return null;      
    }   

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name Previous
    * @description go to the previous page
    * @param null
    * @return PageReference
    */
    public PageReference Previous() { 
        counter -= listSize;
        refreshPage=true;
        return null;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name Next
    * @description go to the next page
    * @param null
    * @return PageReference
    */
    public PageReference Next() { 
        counter += listSize;
        refreshPage=true;
        return null;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name Beginning
    * @description go to the first page
    * @param null
    * @return PageReference
    */
    public PageReference Beginning() {
        counter = 0;
        refreshPage=true;
        return null;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name End
    * @description go to the last page
    * @param null
    * @return PageReference
    */
    public PageReference End() { 
        counter = totalSize - listSize;
        refreshPage=true;
        return null;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getPageNumber
    * @description get method for page number
    * @param null
    * @return Integer
    */
    public Integer getPageNumber() {
        return counter/listSize + 1;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getTotalPages
    * @description get method for total number of pages
    * @param null
    * @return Integer
    */
    public Integer getTotalPages() {
        if (math.mod(totalSize, listSize) > 0) {
            return totalSize/listSize + 1;
        } else {
            return (totalSize/listSize);
        }    
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getDisablePrevious
    * @description get method to disable previous and beggining buttons
    * @param null
    * @return Boolean
    */
    public Boolean getDisablePrevious() { 
        if (counter>0) return false; else return true;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getDisableNext
    * @description get method to disable next and end buttons
    * @param null
    * @return Boolean
    */
    public Boolean getDisableNext() {
        if (counter + listSize < totalSize) return false; else return true;
    }

    /*
    * @author Lavinia Ciobanu
    * @date Apr 6, 2021
    * @name getPrimaryId
    * @description get method for refreshPage parameter
    * @param null
    * @return Boolean
    */
    public Boolean getRefreshPage() {
        return refreshPage;
    }
}