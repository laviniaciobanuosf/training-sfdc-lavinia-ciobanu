global class OpportunityAmounts implements Database.Batchable <SObject>, Database.Stateful {
    //@TestVisible static Integer emailLimits;
    public list<Opportunity> opp;
    public String AccountName {get;set;}
  //  public List<lstOpp> lstOpportunities {get;set;}
    Map<Contact, Map<String, Double>> mapConOpps = new Map<Contact, Map<String, Double>>();
    
    global Decimal sumOfOpportunityAmounts;
    global OpportunityAmounts() {}
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        String Query = 'SELECT Name, (SELECT Id, Name, Email FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT Id, Name, Amount, StageName  FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true) LIMIT 10';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){   
        List<Opportunity> opp= [SELECT Name, stageName, Amount FROM Opportunity WHERE Account.Name=:AccountName];
       // AggregateResult[] agregate = [SELECT SUM(Amount) oppamount FROM Opportunity];
        
     //   for(AggregateResult ag: agregate){
     //       sumOfOpportunityAmounts = (Decimal)ag.get('oppamount');
    //    }
        
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
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            //mail.setReplyTo('lavinia.ciobanu@osf.digital');
            mail.setSenderDisplayName('Apex batches');
            mail.setSubject('Sum of Opportunities Amount');
            String body ='';
            
            Double sum = 0;
            for(String op: mapConOpps.get(con).keySet()) {
                sum += mapConOpps.get(con).get(op);
            }
            
            body = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            
            for(Account a: [SELECT Name, (SELECT Id, Name, Email FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT Id, Name, Amount, StageName  FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true) LIMIT 10]) {
                for(Opportunity o: [SELECT Name, StageName, Amount FROM Opportunity WHERE Account.Name=:AccountName AND StageName = 'Closed Won']){
                    String accountName = a.Name;
                    String closedWonStage = o.StageName;
                    body += '<tr><td>' + accountName + '</td><td>' + closedWonStage + '</td><td>' + sum + '</td></tr>';
                }    
            }
            
            for(Account a: [SELECT Name, (SELECT Id, Name, Email FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT Id, Name, Amount, StageName  FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true) LIMIT 10]) {
                for(Opportunity o: [SELECT Name, StageName, Amount FROM Opportunity WHERE Account.Name=:AccountName AND StageName = 'Closed Lost']){
                    String accountName = a.Name;
                    String closedLostStage = o.StageName;
                    body += '<tr><td>' + accountName + '</td><td>' + closedLostStage + '</td><td>' + sum + '</td></tr>';
                }    
            }
                       
            for(Account a: [SELECT Name, (SELECT Id, Name, Email FROM Contacts WHERE Is_Primary_Contact__c = true), (SELECT Id, Name, Amount, StageName  FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true) LIMIT 10]) {
               for(Opportunity o: [SELECT Name, StageName, Amount FROM Opportunity WHERE Account.Name=:AccountName AND StageName != 'Closed Won' AND StageName != 'Closed Lost']){
                    String accountName = a.Name;
                    String stageName = o.StageName;
             	    body += '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sum + '</td></tr>';
       // System.debug('Account Name:' + accountName);
       // System.debug('StageName: ' + stageName);
       // System.debug('AmountL ' + sum);
           		}        
            }
             body += '</table>'; 
           	 mail.setHtmlBody(body);
             mails.add(mail);
        } 
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
		System.OrgLimit apiRequestsLimit = limitsMap.get('SingleEmail');
        System.debug('Limit Name: ' + apiRequestsLimit.getName());
        System.debug('Usage Value: ' + apiRequestsLimit.getValue());
        System.debug('Maximum Limit: ' + apiRequestsLimit.getLimit());
    
        Messaging.sendEmail(mails);
        System.debug('Email is sent Successfully.');
    }
                  
    global void finish(Database.BatchableContext bc){
        //OpportunityAmounts.emailLimits = Limits.getEmailInvocations();
    }
}