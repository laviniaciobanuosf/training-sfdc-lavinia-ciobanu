global inherited sharing class ScheduleOpportunityAmounts implements Schedulable {
    
  global void execute(SchedulableContext sc) {
 
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