global with sharing class PreChatController {
    public PreChatController(ApexPages.StandardController controller) {}
    
    @RemoteAction
    global static String getAccountByEmail(String customerEmail) {
        if (!String.isBlank(customerEmail)) {
            List<Account> lstAccount = [SELECT Id
                                        FROM Account
                                        WHERE Email__c = :customerEmail
                                            OR PersonEmail = :customerEmail
                                            OR Other_Email__c = :customerEmail
                                            OR OtherEmail__pc = :customerEmail];
            
            if (lstAccount.size() == 1) {
                return lstAccount[0].Id;
            }
            else if (lstAccount.size() == 0) {
                return 'none';		// "Boolean" to search Lead
            }
        }
        
		return null;
    }
    
    @RemoteAction
    global static String getLeadByEmail(String customerEmail) {
        List<Lead> lstLead = [SELECT Id  FROM Lead WHERE Email = :customerEmail];
        
        if (lstLead.size() == 1) {
            return lstLead[0].Id;
        }
        
		return null;
    }
}