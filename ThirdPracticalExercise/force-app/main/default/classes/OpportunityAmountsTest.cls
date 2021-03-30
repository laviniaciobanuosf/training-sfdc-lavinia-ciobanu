@isTest
public class OpportunityAmountsTest {
    @testSetup
    static void setup() {
        
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

        List<Opportunity> oppList = new List<Opportunity>();
        Date closeDate = Date.today().addDays(-7);

        for (Integer i=0; i<10; i++) {
            Opportunity o = new Opportunity();
            o.AccountId = a.Id;
            o.Name = 'Opportunity' + i;
            o.CloseDate = closeDate;
            o.StageName = 'Closed Won';
            o.Amount = 1000;
            o.AccountId = a.Id;
            oppList.add(o);
        }
        insert oppList;    
    }
    
	@isTest static void test1() {
        Test.startTest();  
        ScheduleOpportunityAmounts s = new ScheduleOpportunityAmounts();
        s.execute(null);
  	    Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, ApexClassId, ApexClass.Name, Status, JobType
                                   FROM AsyncApexJob
                                   WHERE JobType = 'BatchApex'
                                   AND ApexClass.Name = 'ScheduleOpportunityAmounts'];
    }

    @isTest static void test2() {
        Test.startTest();
        Integer hourvalue = 14;
        String CRON_EXP = '0 0 14 30 3 ? 2021';
        String jobId = System.schedule('oppTest', CRON_EXP, new ScheduleOpportunityAmounts());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE Id = :jobId];

        Datetime now = Datetime.now();
        Datetime expected = Datetime.now();
        Integer hour = Datetime.now().hour();
        if(hour > hourValue) {
            Datetime temp = now.addDays(1);
            expected = Datetime.newInstance(temp.year(), temp.month(), temp.hour(), hourValue, 0, 0);
        } else {
            expected = Datetime.newInstance(now.year(), now.month(), now.hour(), hourvalue, 0, 0);
        }

        System.assertEquals(CRON_EXP, ct.CronExpression);
     //   System.assertEquals(String.valueOf(expected), String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

    @isTest static void test3() {
        String CRON_EXP = '0 0 14 30 3 ? 2021';
        List<Opportunity> oppList = new List<Opportunity>();
        Date closeDate = Date.today().addDays(-7);
        for (Integer i=0; i<10; i++) {
            Opportunity o = new Opportunity(
                Name = 'Opportunity ' + i,
                CloseDate = closeDate,
                StageName = 'Closed Won'
            );
            oppList.add(o);
        }
        insert oppList;
            
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(oppList);
        List<Id> opptIds = new List<Id>(oppMap.keySet());
        Test.startTest();
           
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new ScheduleOpportunityAmounts());
           
        List<Task> lt = [SELECT Id
                         FROM Task
                         WHERE WhatId IN :opptIds];
        System.assertEquals(0, lt.size(), 'Tasks exist before job has run');
        
        Test.stopTest();
    }
}