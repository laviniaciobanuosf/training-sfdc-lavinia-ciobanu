@isTest
public class OpportunityAmountsTest {
    @testSetup
    static void setup() {
        
        List<Opportunity> opportunities = new List<Opportunity>();
        
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Contact c = new Contact();
        c.FirstName = 'Test Contact';
        c.LastName = 'Test';
        c.Email = 'lavinia.ciobanu@osf.digital';
        c.AccountId = a.Id;
        c.Is_Primary_Contact__c = true;
        insert c;

        List<Opportunity> opptys = new List<Opportunity>();
        Date closeDate = Date.today().addDays(-7);

        for(Integer i=0; i<10; i++) {
            Opportunity o = new Opportunity();
            o.AccountId = a.Id;
            o.Name = 'Opportunity' + i;
            o.CloseDate = closeDate;
            o.StageName = 'Closed Won';
            o.Amount = 1000;
            o.AccountId = a.Id;
            opptys.add(o);
        }
        insert opptys;    
    }
    
	@isTest static void test() {
     
        Test.startTest();
        OpportunityAmounts obj = new OpportunityAmounts();
        Id batchId = Database.executeBatch(obj);
  	    Test.stopTest();

        System.assertEquals(10, [SELECT COUNT() FROM Opportunity WHERE NAME LIKE 'Opportunity %']);

     //   System.assertEquals(1, Limits.getEmailInvocations());

   // System.assertEquals(10000, o.amount);

   // System.assertEquals(acc.Sum_of_Opportunity_Amount__c, o.amount);

  
  //  System.assertEquals(10, [select count() from Opportunity where Name like 'Test Opportunity %']);
 //   System.assertEquals(10000, sumOfOpportunityAmounts);

   // EmailMessage[] newEmail = new EmailMessage[0];
   // newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'lavinia.ciobanu@osf.digital', Subject = 'Test email', TextBody = '23456 ')); 
   // insert newEmail;
    }
}