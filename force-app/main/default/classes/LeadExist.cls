@RestResource(urlMapping='/LeadExist/*')
global with sharing class LeadExist {
    //services/apexrest/LeadExist?nombre=Raúl&apellido=Martínez&email=user-test-sf@company.com&telefono=644525955
        
    @HttpGet
    global static ResponseHandler GET() {
        // gestión de la llamada
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String firstname = RestContext.request.params.get('nombre');
        String lastname = RestContext.request.params.get('apellido');
        String email = RestContext.request.params.get('email');
        String phone = RestContext.request.params.get('telefono');
        
        // Trabajo con la llamada
        List<Lead> lstLead = getLead(firstname, lastname, email, phone);
        Lead returnLead;
        
        if (lstLead != null) {
            returnLead = lstLead[0];
        }
        
        // Respondo
        ResponseHandler response = handleResponse(returnLead);
        return response;
    }
    
    private static ResponseHandler handleResponse(Lead  returnLead){
        ResponseHandler response = new ResponseHandler();
        
        if (returnLead != null) {
            response.Status = 'Success';
            response.ErrorCode = '';
            response.Data = new List<SObject> {returnLead};
            response.Message = 'Candidato encontrado';
        }
        else {
            response.ErrorCode = '0001';
            response.Status = 'error';
            response.Message = 'No existe el candidato';
        }  
        
        return response;
    }
    
    public static List<Lead> getLead(String firstname, String lastname, String email, String phone) {
        //String aux = 'SELECT Email,FirstName,Id,LastName,Phone FROM Lead where ';
        //aux += '(FirstName= \'' + firstname + '\' AND LastName= \'' + lastname + '\' AND Email= \''  + email + '\' AND Phone=\'' + phone + '\')';
        //System.debug(aux);
        /*
        List<Lead> lstLeads = [SELECT Id, Email, FirstName, LastName, Phone 
                               FROM Lead 
                               WHERE (FirstName = :firstname AND LastName = :lastname AND Email = :email AND Phone = :phone) 
                             		OR (FirstName = :firstname AND LastName = :lastname AND Email = :email)
                               LIMIT 1];
        
        if (!lstLeads.isEmpty()) {
            return lstLeads;
        }
        */
        Lead le = new Lead();
        le.FirstName = firstname;
        le.LastName = lastname;
        le.Email = !String.isBlank(email)?email:null;
        le.Phone = !String.isBlank(phone)?phone:null;
        
        List<Lead> lstDuplicates = new List<Lead>();
        lstDuplicates.add(le);
        System.debug('=====>LSTDUPS: ' + lstDuplicates);
		List<Datacloud.FindDuplicatesResult> resultados = Datacloud.FindDuplicates.findDuplicates(lstDuplicates);
            
        if (resultados.size() > 0) {
            system.debug('resputados: ->'+ resultados);
            Datacloud.FindDuplicatesResult resultFindDuplicate = Datacloud.FindDuplicates.findDuplicates(lstDuplicates)[0];
            System.debug('=====>LSTDUPSRESULT: ' + resultFindDuplicate);
            for (Datacloud.DuplicateResult recordDuplicate: resultFindDuplicate.getDuplicateResults()){
                 System.debug('recordDuplicate:'+recordDuplicate);
                 String ruleDuplicateDN = recordDuplicate.getDuplicateRule();
                 if(!ruleDuplicateDN.equalsIgnoreCase('PAccountLead')){
                    List<Datacloud.MatchRecord> recordListMatch = recordDuplicate.getMatchResults()[0].getMatchRecords();
                    System.debug('=====>RECORDLISTMATCH: ' + recordListMatch);
                    if (!recordListMatch.isEmpty()) {
                        Datacloud.MatchRecord recordMatch = recordListMatch[0];
                        SObject record = recordMatch.getRecord();
                        System.debug('RECORD: ' + record);
                        Lead auxLead = (Lead) record;
                    
                        if (auxLead != null) {
                            le.Id = auxLead.Id;
                            System.debug(le.Id);
                        
                            return lstDuplicates;
                        }
                        else {
                            new customException('FAIL');
                        }
                    }
                    else {
                        System.debug('NO recordMatch');
                    }
                 } 		
                 else {
                        system.debug('Duplicado con Lead crear registro duplicado: regla:'+ ruleDuplicateDN);
                        system.debug('duplicado:'+  recordDuplicate.getMatchResults()[0].getMatchRecords());
                 }
            }
        }    
        else {
            System.debug('NO DUPLICATES!');
        }
        
        return null;
    }
}