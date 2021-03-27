global class OpportunityAmounts implements Database.Batchable <SObject>, Database.Stateful {
    //@TestVisible static Integer emailLimits;
    public List<Opportunity> opp;
    public String AccountName {get;set;} 
  //  public List<lstOpp> lstOpportunities {get;set;}
    Map<Contact, Map<String, Double>> mapConOpps = new Map<Contact, Map<String, Double>>();
    Map<Contact, Map<String, Double>> mapConAcc = new Map<Contact, Map<String, Double>>();
    List<Account> accountsList = new List<Account>();
    
   // global Decimal sumOfOpportunityAmounts;
    global OpportunityAmounts() {}
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        String Query = 'SELECT Name, (SELECT Id, Name, Email FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT Id, Name, Amount, StageName  FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true) LIMIT 10';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){   
        List<Opportunity> opp= [SELECT Name, stageName, Amount FROM Opportunity WHERE Account.Name=:AccountName];
         
      //  List<String> primaryContactsEmail = [SELECT Email FROM Contact WHERE IS_PRIMARY_CONTACT__C = true];
    	AggregateResult[] closedWonStage = [SELECT Account.Name accClosedWon, SUM(Amount) oppamountClosedWon 
                                             FROM Opportunity 
                                             WHERE isWon = true AND CreatedDate = THIS_MONTH
                                             GROUP BY Account.Name]; 
   
         String accountNameWonOpp = String.valueOf(closedWonStage[0].get('accClosedWon'));
         String sumOfWonOpp = String.valueOf(closedWonStage[0].get('oppamountClosedWon'));
        
        for(AggregateResult ag: closedWonStage){
            System.debug('Sum of Opp Amount' + sumOfWonOpp);  
        }
            
         AggregateResult[] closedLostStage = [SELECT Account.Name accClosedLost, SUM(Amount) oppamountClosedLost 
                                             FROM Opportunity 
                                             WHERE isWon = false AND isClosed = true AND CreatedDate = THIS_MONTH
                                             GROUP BY Account.Name];  
                                            
        String accountNameLostOpp = String.valueOf(closedLostStage[0].get('accClosedLost'));
        String sumOfLostOpp = String.valueOf(closedLostStage[0].get('oppamountClosedLost'));
    
        for(AggregateResult ag: closedLostStage){
            System.debug('Account Name' + ag.get('accClosedLost'));
            System.debug('Sum of Opp Amount for Closed Lost' + ag.get('oppamountClosedLost'));
        }
            
        AggregateResult[] OpenStage = [SELECT Account.Name accOpen, SUM(Amount) oppamountOpen, Account.Primary_Contact__c pr
                                             FROM Opportunity 
                                             WHERE isClosed = false AND CreatedDate = THIS_MONTH
                                             GROUP BY Account.Name, Account.Primary_Contact__c];  

        String accountNameOpenOpp = String.valueOf(OpenStage[0].get('accOpen'));
        String sumOfOpenOpp = String.valueOf(OpenStage[0].get('oppamountOpen')); 
        //String primaryContactId = String.valueOf(OpenStage[0].get('pr'));
  
        for(AggregateResult ag: OpenStage){
            System.debug('Sum of Opp Amount' + ag.get('oppamountOpen'));
        }
               
        for(Account acc: scope) {
            Map<String, Double> mapOppAmount = new Map<String, Double>();
            for(Opportunity objOpp: acc.Opportunities) {
                mapOppAmount.put(objOpp.StageName, objOpp.Amount);
            }
            mapConOpps.put(acc.Contacts,mapOppAmount);
        }

        Map<Contact, Double> mapCon_Amount = new Map<Contact, Double>();
  
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Contact con: mapConOpps.keySet()) {
            for(Account a1: scope) {
        //    for(Contact con: [SELECT Id, Email FROM Contact WHERE Is_Primary_Contact__c = true]){      
        //    for(Contact con: [Select Id, Email FROM Contact WHERE AccountId IN :accIds AND Email <> null AND Is_Primary_Contact__c = true]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            mail.setSenderDisplayName('Apex batches');
            mail.setSubject('Sum of Opportunities Amount');
            String body ='';
            
          //  Double sum = 0;
            //for(String op: mapConOpps.get(con).keySet()) {
           //     sum += mapConOpps.get(con).get(op);
           // }
            
            body = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';

            body += '<tr><td>' + accountNameWonOpp + '</td><td>' + '  Closed/Won  ' + '</td><td>' + sumOfWonOpp + '</td></tr>';
            body += '<tr><td>' + accountNameLostOpp + '</td><td>' + '  Closed/Lost  ' + '</td><td>' + sumOfLostOpp + '</td></tr>';
 			body += '<tr><td>' + accountNameOpenOpp + '</td><td>' + '  Open  ' + '</td><td>' + sumOfOpenOpp + '</td></tr>';
                 
        //    for(Account a: [SELECT Name, (SELECT Id, Name, Email FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT Id, Name, Amount, StageName  FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true) LIMIT 10]) {
        //       for(Opportunity o: [SELECT Name, StageName, Amount FROM Opportunity WHERE Account.Name=:AccountName AND StageName != 'Closed Won' AND StageName != 'Closed Lost']){
        //            String accountName = a.Name;
       //             String stageName = o.StageName;
        //     	    body += '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sum + '</td></tr>';
       // System.debug('Account Name:' + accountName);
       // System.debug('StageName: ' + stageName);
       // System.debug('AmountL ' + sum);
          // 		}        
         //   }

             body += '</table>'; 
           	 mail.setHtmlBody(body);
             mails.add(mail);
            } 

        Messaging.sendEmail(mails);
        System.debug('Email is sent Successfully.');
        }             
    } 

    global void finish(Database.BatchableContext bc){
   //OpportunityAmounts.emailLimits = Limits.getEmailInvocations();
    }
}