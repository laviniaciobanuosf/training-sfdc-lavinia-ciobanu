global class OpportunityAmounts implements Database.Batchable<SObject>, Database.Stateful {
	
	Map<Id, ContactAccountInfo> accountPrimaryContactMap;
	Map<Id, List<CustomOpportunity>> opportunitiesByAccountId;
	
	public List<Account> start(Database.BatchableContext bc) {
		try{
			
			List<Account> accountsWithPrimaryContacts = [Select Id, Name, (SELECT Email
			                                                               FROM Contacts
			                                                               WHERE Is_Primary_Contact__c = true
			                                                               LIMIT 1)
			                                             From Account 
			                                             Where Id IN (SELECT AccountId
			                                                          FROM Contact
			                                                          WHERE Is_Primary_Contact__c = true AND Email != null)];
		
			accountPrimaryContactMap = new Map<Id, ContactAccountInfo>();
			for (Account account : accountsWithPrimaryContacts){
				ContactAccountInfo contactItem = new ContactAccountInfo();
				contactItem.AccountName = account.Name;
				contactItem.Email = account.Contacts[0].Email;
				AccountPrimaryContactMap.put(account.Id, contactItem);
			}

			GetOpportunities();

			return accountsWithPrimaryContacts;
		} catch (Exception e) {
			System.debug('Exception ' + e.getMessage());
			return null;
		}
	}

	public void GetOpportunities() {
		try{
			
			Date lastModifiedFilter = Date.today().addMonths(-1);

			List<AggregateResult> opportunitiesResult = [SELECT AccountId, Account.Name AccountName, StageName, Format(Sum(Amount))AmountSum
			                                             FROM Opportunity
			                                             WHERE AccountId IN :accountPrimaryContactMap.keySet() AND (CreatedDate >= :lastModifiedFilter OR LastModifiedDate >= :lastModifiedFilter)
			                                             GROUP BY AccountId, Account.Name, StageName
			                                             ORDER BY StageName];

			if (opportunitiesResult != null && !opportunitiesResult.isEmpty()) {
				opportunitiesByAccountId = new Map<Id, List<CustomOpportunity>>();
			
				for (AggregateResult result : opportunitiesResult){
					Id key = (Id)result.get('AccountId');
					if (!opportunitiesByAccountId.containsKey(key)){
						opportunitiesByAccountId.put(key, new List<CustomOpportunity>());
					}
					CustomOpportunity value = new CustomOpportunity();            
					value.StageName = (String)result.get('StageName');
					value.AmountSum = (String)result.get('AmountSum');              
					opportunitiesByAccountId.get(key).add(value);
				}
			}
		} catch (Exception e){
			System.debug('Exception ' + e.getMessage());
		}
	}

	public void execute(Database.BatchableContext bc, List<Account> scope) {
		try{
			List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
			if (opportunitiesByAccountId != null && !opportunitiesByAccountId.isEmpty()) {
				
				for (Id key : opportunitiesByAccountId.keySet()) {
					ContactAccountInfo primaryContact = accountPrimaryContactMap.get(key);
					List<CustomOpportunity> opportunities = opportunitiesByAccountId.get(key);
	
					Messaging.SingleEmailMessage mail = getEmail(primaryContact, opportunities);
					if (mail != null)
						mailList.Add(mail);
				}
				if (mailList.size() > 0){
					Messaging.sendEmail(mailList);
				}
			}
		} catch (Exception e){
			System.debug('Exception ' + e.getMessage());
		}
	}

	public void finish(Database.BatchableContext bc) {

	}

	public Messaging.SingleEmailMessage getEmail(ContactAccountInfo primaryContact, List<CustomOpportunity> opportunities) {
		try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSubject('Opportunities related to ' + primaryContact.AccountName);
			List<String> emailAddresses = new List<String>();
			emailAddresses.Add(primaryContact.Email);
			mail.setToAddresses(emailAddresses);
			String oppSection = '';

			if (opportunities != null && opportunities.size() > 0) { 
				String rows = '';
				Set<String> stages = new Set<String>{'Closed Won', 'Closed Lost'};

			//	Set<String> openStages = new Set<String>{'Prospecting', 'Qualification',
			//										'Need Analysis', 'Value Proposition', 'Id. Decision Makers', 
			//										'Perception Analysis', 'Proposal/Price Quote', 'Negotiation/Review'};
		
				for (CustomOpportunity item : opportunities) {
					stages.remove(item.StageName);
					String row = '<tr><td>' + primaryContact.AccountName + '</td><td>' + item.StageName + '</td><td> ' + item.AmountSum + '</td></tr>';
					rows += row;
				//	Decimal sumOfOpen = 0;
                //    if (item.StageName != 'Closed Won' && item.StageName != 'Closed Lost') {
                //  	  sumOfOpen +=  Decimal.valueOf(item.AmountSum);       
                //    }
                //    row = '<tr><td>' + primaryContact.AccountName + '</td><td>' + 'Open' + '</td><td> ' + sumOfOpen + '</td></tr>';
                //    rows += row;
                }
				if (!stages.isEmpty()) {
					for (String item : stages){
						String row = '<tr><td>' + primaryContact.AccountName + '</td><td>' + item + '</td><td></td></tr>';
						rows += row;
					}
				}
               
				oppSection = '<table><tr><th>Account</th><th>Stage</th><th>Amount</th> ' + rows + '</tr></table>';
			} else { 
				oppSection = '<p>Your account does not have any opportunities in Open, Closed Won, Closed Lost stages.</p>';
			}

			return mail;
		} catch (Exception e) {
			System.debug('Exception ' + e.getMessage());
			return null;
		}
	}

	public class ContactAccountInfo {
		public String AccountName {get;set;}
		public String Email {get;set;}
	}

	public class CustomOpportunity {
		public String StageName {get;set;}
		public String AmountSum {get;set;}
	}
}