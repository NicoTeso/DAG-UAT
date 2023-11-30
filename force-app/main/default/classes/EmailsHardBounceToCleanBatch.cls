global class EmailsHardBounceToCleanBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{

    private Map<String,Invalid_Emails__c> mapEmails;
    private Id jobId;
        //casos, leads, cuentas, contactos y consentimientos (eliminar consentimiento con ese email)
    private List<Case> listCases;
    private List<Lead> listLeads;
    private List<Account> listAccounts;
    private List<Contact> listContacts;
    private List<Consentimientos__c> listConsentimientos;

    public EmailsHardBounceToCleanBatch() {
        mapEmails = new Map<String,Invalid_Emails__c>();
        listCases = new List<Case>();
        listLeads = new List<Lead>();
        listAccounts = new List<Account>();
        listContacts = new List<Contact>();
        listConsentimientos = new List<Consentimientos__c>();
    }

    public void execute(SchedulableContext sc) {
        System.debug('EmailsHardBounceToCleanBatch.execute sc ' + sc + ' triggerId ' + sc.getTriggerId());
        jobId = sc.getTriggerId();
        Id batchJobId = Database.executeBatch(this,1);
        System.debug('EmailsHardBounceToCleanBatch.execute sc batchJobId ' + batchJobId);
    }
    
	global List<Invalid_Emails__c> start(Database.BatchableContext bc) {

    	// Get a query locator
	 	Database.QueryLocator q = Database.getQueryLocator(
    		[SELECT Id, Email__c, New__c, Active__c FROM Invalid_Emails__c WHERE Active__c = true]);
		// Get an iterator
		Database.QueryLocatorIterator it =  q.iterator();
        integer i = 1; 
		// Iterate over the records
		while (it.hasNext())
		{
    		Invalid_Emails__c email = (Invalid_Emails__c)it.next();
    		System.debug('email: '+i+' '+email );
            mapEmails.put(email.Email__c,email);
            i = i+1;
 		}    
        
        System.debug('EmailsHardBounceToCleanBatch.start mapEmails ' + mapEmails.keySet());
        return mapEmails.values();

    }

    global void execute(Database.BatchableContext bc, List<Invalid_Emails__c> scope) {

        System.debug('EmailsHardBounceToCleanBatch.execute scope ' + scope);

        listCases = new List<Case>();
        listLeads = new List<Lead>();
        listAccounts = new List<Account>();
        listConsentimientos = new List<Consentimientos__c>();
        List<Exception__c> listExceptionToInsert = new List<Exception__c>();

        // findEmailsToRemove(new Set<String> {scope[0].Email__c}, listCases, listLeads, listAccounts, listConsentimientos);

        if(scope != null && !scope.isEmpty() && String.isNotBlank(scope[0].Email__c)){
            System.debug('EmailsHardBounceToCleanBatch.findEmailsToRemove dentro del if setEmails ' + scope[0].Email__c);
            listCases = [
                SELECT Id, SuppliedEmail, CustomerEmail__c
                FROM Case 
                WHERE SuppliedEmail = :scope[0].Email__c OR CustomerEmail__c = :scope[0].Email__c 
            ];
            listLeads = [SELECT Id, Email FROM Lead WHERE Email = :scope[0].Email__c]; 
            listAccounts = [
                SELECT Id, Email__c, PersonEmail, Other_Email__c, OtherEmail__pc, IsPersonAccount
                FROM Account 
                WHERE (Email__c = :scope[0].Email__c OR PersonEmail = :scope[0].Email__c OR 
                       Other_Email__c = :scope[0].Email__c OR OtherEmail__pc = :scope[0].Email__c)
            ];
            listConsentimientos = [SELECT Id, ChannelValue__c, RecordType.DeveloperName FROM Consentimientos__c WHERE RecordType.DeveloperName = 'Email' AND  ChannelValue__c = :scope[0].Email__c];
        }

        System.debug('EmailsHardBounceToCleanBatch.execute listCases ' + listCases);
        if(listCases != null && !listCases.isEmpty()){
            for(Case c: listCases){
                c.SuppliedEmail = c.SuppliedEmail != null && c.SuppliedEmail.equalsIgnoreCase(scope[0].Email__c) ? null : c.SuppliedEmail;
                c.CustomerEmail__c = c.CustomerEmail__c != null && c.CustomerEmail__c.equalsIgnoreCase(scope[0].Email__c) ? null : c.CustomerEmail__c;
            }
            System.debug('EmailsHardBounceToCleanBatch.execute after listCases ' + listCases);
            final Database.SaveResult[] results = Database.update(listCases, false);

            listExceptionToInsert = createErrors(results,null,65,listExceptionToInsert,scope[0].Email__c);
        }

        System.debug('EmailsHardBounceToCleanBatch.execute listLeads ' + listLeads);
        if(listLeads != null && !listLeads.isEmpty()){
            for(Lead l: listLeads){
                l.Email = l.Email != null && l.Email.equalsIgnoreCase(scope[0].Email__c) ? null : l.Email;
            }
            System.debug('EmailsHardBounceToCleanBatch.execute after listLeads ' + listLeads);
            final Database.SaveResult[] results = Database.update(listLeads, false);
            listExceptionToInsert = createErrors(results,null,93,listExceptionToInsert,scope[0].Email__c);
        }

        System.debug('EmailsHardBounceToCleanBatch.execute listAccounts ' + listAccounts);
        if(listAccounts != null && !listAccounts.isEmpty()){
            for(Account a: listAccounts){
                if (a.IsPersonAccount == true) {
                    a.PersonEmail = a.PersonEmail != null && a.PersonEmail.equalsIgnoreCase(scope[0].Email__c) ? null : a.PersonEmail;
                    a.OtherEmail__pc = a.OtherEmail__pc != null && a.OtherEmail__pc.equalsIgnoreCase(scope[0].Email__c) ? null : a.OtherEmail__pc;
                } else {
	                a.Email__c = a.Email__c != null && a.Email__c.equalsIgnoreCase(scope[0].Email__c) ? null : a.Email__c;
	                a.Other_Email__c = a.Other_Email__c != null && a.Other_Email__c.equalsIgnoreCase(scope[0].Email__c) ? null : a.Other_Email__c;
                }
                    
            }
            System.debug('EmailsHardBounceToCleanBatch.execute after listAccounts ' + listAccounts);
            final Database.SaveResult[] results = Database.update(listAccounts, false);
            listExceptionToInsert = createErrors(results,null,106,listExceptionToInsert,scope[0].Email__c);
        }

        System.debug('EmailsHardBounceToCleanBatch.execute listConsentimientos ' + listConsentimientos);
        if(listConsentimientos != null && !listConsentimientos.isEmpty()){
            final Database.DeleteResult[] deleteResults = Database.delete(listConsentimientos, false);
            listExceptionToInsert = createErrors(null,deleteResults,112,listExceptionToInsert,scope[0].Email__c);
        }

        System.debug('EmailsHardBounceToCleanBatch.execute listExceptionToInsert ' + listExceptionToInsert);
        if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()){
            insert listExceptionToInsert;
        }
    }

    global void finish(Database.BatchableContext bc) {

        /*if(!Test.isRunningTest() && jobId != null){
            System.AbortJob(jobId);
        }*/
        System.debug('EmailsHardBounceToCleanBatch.finish');
    }

    private List<Exception__c> createErrors(Database.SaveResult[] results, Database.DeleteResult[] deleteResults, Integer line, List<Exception__c> listExceptionToInsert, string EmailErr){ 
        Integer i = 0;
        if(deleteResults != null && !deleteResults.isEmpty()){
            // Iterate through each returned result
            for (Database.DeleteResult dr : deleteResults) {
                if (!dr.isSuccess()) {
                    // Operation failed                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred. err ' + err);
                        listExceptionToInsert.add(
                            new Exception__c(
                                Exception__c = err.getStatusCode() + ': ' + err.getMessage(),
                                Linea__c = line,
                                IdObjetos__c = EmailErr,
                                Clase_Metodo__c = 'EmailsHardBounceToCleanBatch.execute'
                            )
                        );
                    }
                }
                i++;
            }
            i = 0;
        }

        if(results != null && !results.isEmpty()){
            // Iterate through each returned result
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    // Operation failed                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred. err ' + err);
                        listExceptionToInsert.add(
                            new Exception__c(
                                Exception__c = err.getStatusCode() + ': ' + err.getMessage(),
                                Linea__c = line,
                                IdObjetos__c = EmailErr,
                                Clase_Metodo__c = 'EmailsHardBounceToCleanBatch.execute'
                            )
                        );
                    }
                }
                i++;
            }
        }
        return listExceptionToInsert;
    }
}