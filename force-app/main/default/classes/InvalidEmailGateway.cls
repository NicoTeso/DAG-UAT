public class InvalidEmailGateway {

        
    public static Map<String, Invalid_Emails__c> getInvalidEmailByEmail(List<String> listEmails) {
        Map<String, Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String, Invalid_Emails__c>();
        
        if (!listEmails.isEmpty()) {
            List<Invalid_Emails__c> lstInvalidEmail = [SELECT Id, Email__c, New__c, Active__c  
                                                    FROM Invalid_Emails__c 
                                    				WHERE Active__c = true AND Email__c in :listEmails LIMIT 2000];

            
            for (Invalid_Emails__c InvalidEmail : lstInvalidEmail) {
                 mapInvalidEmailByEmail.put(InvalidEmail.Email__c, InvalidEmail);
                
            }
        }
        return mapInvalidEmailByEmail;
    }
    
}