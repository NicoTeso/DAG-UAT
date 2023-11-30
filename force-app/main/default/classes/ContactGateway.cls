public class ContactGateway {
    
    public static Contact getContactById(String identificador) {
        Contact contacto;
        if (!String.isBlank(identificador)) {
            Map<String, Contact> mapIdToContact = getContactById(new List<String>{identificador});
            if (!mapIdToContact.isEmpty()) {
                contacto = mapIdToContact.get(identificador);
            }
        }
        
        return contacto;
    }
   
    public static Map<String, Contact> getContactById(List<String> listId) {
        Map<String, Contact> mapIdToContact = new Map<String, Contact>();
        if (!listId.isEmpty()) {
            List<Contact> contactos = [SELECT Id, AccountId, Account.IsPersonAccount FROM Contact WHERE Id in :listId LIMIT 2000];
            for(Contact contacto : contactos) {
                mapIdToContact.put(contacto.Id, contacto);
            }
        }
        
        return mapIdToContact;
    }
    
	public static Map<String, Contact> getContactByAccountId(List<String> listId) {
        Map<String, Contact> mapAccountIdToContact = new Map<String, Contact>();
        if (!listId.isEmpty()) {
            List<Contact> contactos = [SELECT Id,AccountId, Account.IsPersonAccount, Account.ConCasosMKTImp__c ,Account.ConCasosMKTNoImp__c FROM Contact WHERE AccountId in :listId LIMIT 2000];
            
            for(Contact contacto : contactos){
                mapAccountIdToContact.put(contacto.AccountId, contacto);
            }
        }
        
        return mapAccountIdToContact;
    }
    
    public static Contact getContactByAccountId(String accId) {
        Contact con;
        
        if (!String.isBlank(accId)) {
            List<Contact> lstContacts = [SELECT Id,
												AccountId
                                     	 FROM Contact
                                    	 WHERE AccountId = :accId];
            
            if (!lstContacts.isEmpty()) {
                con = lstContacts[0];
            }
        }
        
        return con;
    }
    
    public static Map<String, List<Contact>> getContactsByEAccountId(List<String> listId) {
        Map<String, List<Contact>> mapAccountIdToContacts = new Map<String, List<Contact>>();
        if (!listId.isEmpty()) {
            List<Contact> contactos = [SELECT Id,AccountId FROM Contact WHERE AccountId in :listId LIMIT 2000];
            
            for(Contact contacto : contactos){
                List<Contact> listContact = mapAccountIdToContacts.containsKey(contacto.AccountId)?mapAccountIdToContacts.get(contacto.AccountId):new List<Contact>();
                listContact.add(contacto);
                mapAccountIdToContacts.put(contacto.AccountId, listContact);
            }
        }
        
        return mapAccountIdToContacts;
    }
    
    
    
}