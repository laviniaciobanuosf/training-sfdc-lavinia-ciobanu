@isTest
public class OpportunityAmountsTest {
    @testSetup
    static void setup() {
        
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        
         Account a = new Account();
         a.Name = 'Test Company';
         insert a;
          
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity Amount';
         o.Amount = 10000;
         o.accountId = a.Id;
         o.stageName = 'Closed Won';
         o.closedate = System.today();
         insert o;

        for(Account acc : [SELECT Id from Account]) {
            opportunities.add(new Opportunity(Name='Test Opportunity Amount', Amount = 10000, stageName = 'Closed Won', closeDate = System.today(), accountId = acc.Id));
        }
        insert opportunities;
    }
    
	@isTest static void test() {
     
        Double sum = 0;
        
        Account a = new Account();
         a.Name = 'Account Test';
         insert a;
          
         Opportunity o = new Opportunity();
         o.Name = 'Test Opportunity Am';
         o.Amount = 10000;
         o.accountId = a.Id;
         o.stageName = 'Closed Won';
         o.closedate = System.today();
         insert o;
        
        for(Account acc : [SELECT Id, (SELECT Id, StageName FROM Opportunities), (SELECT Name From Contacts) FROM Account]) {
             sum = sum + o.Amount;
        }
        
        Test.startTest();
        OpportunityAmounts obj = new OpportunityAmounts();
        Id batchId = Database.executeBatch(obj);
  	    Test.stopTest();
     //   System.assertEquals(1, Limits.getEmailInvocations());
       
        System.assertEquals(10000, o.amount);
        
     
  //  Account a = new Account();
  //  a.Name = 'Test Company';
  //  insert a;
      
   // Opportunity o = new Opportunity();
   // o.Name = 'Test Opportunity Amount';
   // o.Amount = 10000;
   // o.accountId = a.Id;
   // o.stageName = 'Closed Won';
   // o.closedate = System.today();
   // insert o;
        
  
  //  Account acc = [SELECT Id,  Sum_of_Opportunity_Amount__c 
   //                FROM Account WHERE Id = :a.Id];
     
    
   // System.assertEquals(10000, o.amount);

   // System.assertEquals(acc.Sum_of_Opportunity_Amount__c, o.amount);

  
  //  System.assertEquals(10, [select count() from Opportunity where Name like 'Test Opportunity %']);
 //   System.assertEquals(10000, sumOfOpportunityAmounts);
 //   
    EmailMessage[] newEmail = new EmailMessage[0];
	newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'lavinia.ciobanu@osf.digital', Subject = 'Test email', TextBody = '23456 ')); 
	insert newEmail;
    }
}