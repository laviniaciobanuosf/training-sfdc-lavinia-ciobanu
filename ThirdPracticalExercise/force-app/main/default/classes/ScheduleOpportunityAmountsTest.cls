@isTest
public class ScheduleOpportunityAmountsTest {
    static testmethod void testScheduledJob() {
        String CRON_EXP = '0 0 0 29 3 ? 2021';
        List<Opportunity> opptys = new List<Opportunity>();
        Date closeDate = Date.today().addDays(-7);
        for (Integer i=0; i<10; i++) {
            Opportunity o = new Opportunity(
                Name = 'Opportunity ' + i,
                CloseDate = closeDate,
                StageName = 'Closed Won'
            );
            opptys.add(o);
        }
        insert opptys;
        
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>(opptys);
        List<Id> opptyIds = new List<Id>(opptyMap.keySet());
        Test.startTest();
       
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new ScheduleOpportunityAmounts());
       
        List<Task> lt = [SELECT Id
            FROM Task
            WHERE WhatId IN :opptyIds];
        System.assertEquals(0, lt.size(), 'Tasks exist before job has run');
    
        Test.stopTest();
       
        lt = [SELECT Id
            FROM Task
            WHERE WhatId IN :opptyIds];
       // System.assertEquals(opptyIds.size(),lt.size(),'Tasks were not created');
    }

}