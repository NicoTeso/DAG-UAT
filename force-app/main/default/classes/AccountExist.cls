@RestResource(urlMapping='/AccountExist/*')
global with sharing class AccountExist { 
    //services/apexrest/AccountExist?nombre=Gregorio&apellido=Ferreras&email=gregorio.ferrerasdeleon@atos.net&telefono=659921459
   
    @HttpGet
    global static ResponseHandler GET() {
        // gestión de la llamada
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String firstname = RestContext.request.params.get('nombre');
        String lastname = RestContext.request.params.get('apellido');
        String email = RestContext.request.params.get('email');
        String phone = RestContext.request.params.get('telefono');
        
        System.debug('===>URL: ' + firstname + ' ' + lastname + ' ' + email + ' ' + phone);
        
        // Trabajo con la llamada
        List<Account> lstAccount = getAccount(firstname, lastname, email, phone);
        Account returnAccount;
        System.debug('===>GETACCOUNT' + lstAccount);
        
        if (lstAccount != null && !lstAccount.isEmpty()) {
            returnAccount = lstAccount[0];
        }
        
        // Respondo
        ResponseHandler response = handleResponse(returnAccount);
        
        return response;
    }
    
    private static ResponseHandler handleResponse(Account returnAccount){
        ResponseHandler response = new ResponseHandler();
        
        if (returnAccount != null) {
            response.Status = 'Success';
            response.ErrorCode = '';
            response.Data = new List<SObject> {returnAccount};
            response.Message = 'Cliente encontrado';
        }
        else {
            response.ErrorCode = '0001';
            response.Status = 'error';
            response.Message = 'El cliente no existe';
        }  
        
        return response;
    }
    
    public static List<Account> getAccount(String firstname, String lastname, String email, String phone) {
       // String aux = 'SELECT Id, FirstName, LastName, PersonEmail, Phone FROM Account WHERE ';
        //aux += '(FirstName= \'' + firstname + '\' AND LastName= \'' + lastname + '\' AND PersonEmail= \''  + email + '\' AND Phone=\'' + phone + '\')';
        //System.debug(aux);
        
        /*List<Account> lstAccs = [SELECT Id, FirstName, LastName, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone
                                 FROM Account
                                 WHERE (FirstName = :firstname 
                                       AND LastName = :lastname
                                       AND (PersonEmail = :email OR OtherEmail__pc = :email)
                                       AND (Phone = :phone OR PersonOtherPhone = :phone OR PersonMobilePhone = :phone OR Other_Mobile__c = :phone))
                                    OR (FirstName = :firstname
                                       AND LastName = :lastname
                                       AND (PersonEmail = :email OR OtherEmail__pc = :email))
                                 LIMIT 1];
        
        if (!lstAccs.isEmpty()) {
            return lstAccs;
        }
		*/
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.FirstName = firstname;
        acc.LastName = lastname;
        acc.PersonEmail = !String.isBlank(email)?email:null;
        acc.OtherEmail__pc = !String.isBlank(email)?email:null;
        acc.Phone = !String.isBlank(phone)?phone:null; 
        acc.PersonOtherPhone = !String.isBlank(phone)?phone:null; 
        acc.PersonMobilePhone = !String.isBlank(phone)?phone:null; 
        acc.Other_Mobile__c = !String.isBlank(phone)?phone:null;
        
        // Find duplicates
        List<Account> lstDuplicates = new List<Account>();
        lstDuplicates.add(acc);
        System.debug('=====>LSTDUPS: ' + lstDuplicates);
        List<Datacloud.FindDuplicatesResult> resultados = Datacloud.FindDuplicates.findDuplicates(lstDuplicates);
        if (resultados.size()> 0) {
            system.debug('resultados:'+resultados);
            Datacloud.FindDuplicatesResult resultFindDuplicate = resultados[0];
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
                        Account auxAcc = (Account) record;
                    
                        if (auxAcc != null) {
                            acc.Id = auxAcc.Id;
                            System.debug(acc.Id);
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