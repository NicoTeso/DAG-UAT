public class LeadGateway {

/*    
    public static Map<String,List<String>> getLeadIdByEmails(List<String> lstEmail) {
        Map<String,List<String>> mapEmailToLeads = new Map<String, List<String>>();
        
        if (!lstEmail.isEmpty()) {
            for(Lead candidato :[SELECT Id,Email,Name, Documento__c FROM Lead WHERE Email in :lstEmail  LIMIT 2000]){
                String email = candidato.Email;
                List<String> listCuenta = mapEmailToLeads.containsKey(email)?mapEmailToLeads.get(email):new List<String>();
                listCuenta.add(candidato.Id);
                mapEmailToLeads.put(email, listCuenta);
                
            }
        }
        
        return mapEmailToLeads;
    }
*/
    
    public static Lead getLeadById(String id) {
        Lead candidato;
        
        if (!String.isBlank(id)) {
            Map<String, Lead> mapIdToLead = getLeadIdByIds(new List<String>{id});
            
            if (!mapIdToLead.isEmpty()) {
                candidato = mapIdToLead.get(id);
            }
        }
        
        return candidato;
    }
    
	public static Map<String,Lead> getLeadIdByIds(List<String> lstIds) {
        Map<String,Lead> mapIdToLeads = new Map<String,Lead>();
        
        if (!lstIds.isEmpty()) {
            for(Lead candidato :[SELECT Id,Email,Name,Phone, MobilePhone, FirstName, LastName, Salutation, Country, 
                                        Street, PostalCode, City, State, LastModifiedDate, Documento__c, 
										ConCasosMKTImp__c, SyncMKTCloud__c, ConCasosMKTNoImp__c, ConEcosistema__c
                                   FROM Lead WHERE Id in :lstIds  LIMIT 2000]){
                mapIdToLeads.put(candidato.Id, candidato);
                
            }
        }
        
        return mapIdToLeads;
    }
    
}