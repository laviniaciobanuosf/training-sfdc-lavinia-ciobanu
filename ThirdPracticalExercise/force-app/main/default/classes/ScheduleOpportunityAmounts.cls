global inherited sharing class ScheduleOpportunityAmounts implements Schedulable {
    
  global void execute(SchedulableContext sc) {

    //   List<Contact> primaryContacts = [SELECT Id, AccountId, Email
    //                                    FROM Contact
    //                                    WHERE Is_Primary_Contact__c = true];

    //   Map<Id,String> primaryAccountEmailMap = new Map<Id,String>();
    //   for(Contact c: primaryContacts) {
    //     if (!primaryAccountEmailMap.containsKey(c.AccountId)) {
    //       primaryAccountEmailMap.put(c.AccountId, c.Email);
    //     }
    //   }

    //   Set<Id> accountIdSet = primaryAccountEmailMap.keySet();
    //   Datetime now = System.now();
    //   Date startDate = Date.newInstance(now.year(), now.month(), 1);
    //   System.debug('*****' + String.valueOf(startDate));

    //   List<AggregateResult> result = [SELECT AccountId, Account.Name, StageName, format(sum(Amount))sumOfOpportunityAmount
    //                                   FROM Opportunity
    //                                   WHERE AccountId IN :accountIdSet
    //                                   AND (CreatedDate >= :startDate
    //                                   OR LastModifiedDate >= :startDate)
    //                                   GROUP BY AccountId, Account.Name, StageName
    //                                   ORDER BY AccountId];

    //  OpportunityAmounts batch = new OpportunityAmounts(primaryAccountEmailMap, result);
    //  Database.executeBatch(batch);
     
    OpportunityAmounts batch = new OpportunityAmounts();
    Database.executeBatch(batch);
  }
}

/*
ScheduleOpportunityAmounts scheduler = new ScheduleOpportunityAmounts();
  
String sch1 = '0 0 10 * * ?';
String sch2 = '0 0 13 ? * 6 *';
String sch3 = '0 0 18 ? * 6L';

String jobID1 = System.schedule('Daily email', sch1, scheduler);
String jobID2 = System.schedule('Weekly email', sch2, scheduler);
String jobID3 = System.schedule('Monthly email', sch3, scheduler);

ScheduleOpportunityAmounts s = new ScheduleOpportunityAmounts();
s.execute(null);
*/