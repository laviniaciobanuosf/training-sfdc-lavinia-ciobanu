global inherited sharing class OpportunityAmounts implements Database.Batchable <SObject>, Database.Stateful {
    private Map<Id,String> primaryAccountEmailMap;
    private List<AggregateResult> result;
    global OpportunityAmounts(Map<Id,String> primaryAccountEmailMap, List<AggregateResult> result) {
        this.primaryAccountEmailMap = primaryAccountEmailMap;
        this.result = result;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) {
        return result;
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        System.debug('records size: ' + scope.size());
        Map<Id,String> mailContents = getMailContents(scope);
        List<Messaging.SingleEmailMessage> mails = getMails(mailContents);

        Messaging.sendEmail(mails);
    }

    private Map<Id,String> getMailContents(List<SObject> scope) {
        Map<Id,String> mailContents = new Map<Id,String>();
        for (SObject s: scope) {
            AggregateResult ar = (AggregateResult)s;
            Id accountId = (Id)ar.get('AccountId');
            String accountName = (String)ar.get('AccountName');
            String stageName = (String)ar.get('StageName');
            String sumOfOpportunityAmount = (String)ar.get('SumOfOpportunityAmount');

            String body = mailContents.get(accountId);
            if(String.isBlank(body)) {
                body = '<table border="1" style="border-collapse: collapse"><tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
            }

            body += '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sumOfOpportunityAmount + '</td></tr>';
            mailContents.put(accountId, body);
        }
        return mailContents;
    }

    private List<Messaging.SingleEmailMessage> getMails(Map<Id,String> mailContents) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Id accountId : mailContents.keySet()) {
            String mailCon = mailContents.get(accountId);
            mailCon += '</table>';
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(new List<String>{primaryAccountEmailMap.get(accountId)});
            message.setSubject('Sum of Opportunity Amount');
            message.setHtmlBody(mailCon);
            mails.add(message);
        }
        return mails;
    }

    global void finish(Database.BatchableContext bc) {
        try {
            AsyncApexJob async = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                  FROM AsyncApexJob
                                  WHERE Id = :bc.getJobId()];

            System.debug('*******' + async.Id);
        } catch (Exception e) {
            System.debug('Exception' + e.getMessage());
        }
    }
}