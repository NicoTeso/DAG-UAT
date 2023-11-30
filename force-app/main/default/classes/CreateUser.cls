/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public without sharing class CreateUser {

    public class CreateUserException extends Exception{}

    @AuraEnabled
    public static String registerUser(String NIF){
        
        NBK_ResultWrapper rw = new NBK_ResultWrapper();
        if(String.isEmpty(NIF)){
            return JSON.serialize(new NBK_ResultWrapper(false, null, Label.register_IntroduceDNI));
        }

        try{
            List<Account> accountList = AccountSelector.getWithoutSharingContext().getAccountsByNIE(new Set<String>{NIF.trim()});
            //If account already exists with that NIF
            if(accountList.size() == 1 && !String.isEmpty(accountList[0].PersonContactId)){
                List<User> users = UserSelector.getWithoutSharingContext().getUsersByContactId(new Set<Id>{accountList[0].PersonContactId});
                if(users.size() == 0 && checkAccountFields(accountList[0])){
                    rw = new NBK_ResultWrapper(true,null,JSON.serialize(createUser(accountList[0])));
                }
            }else{
                Logger.error('Accounts found with NIF = '+ NIF + ' -- \n accountList.size() = ' + accountList.size() + ' -- ' + JSON.serialize(accountList));
                throw new CreateUserException(Label.register_unknownException);
            }
        } catch(Exception e) {
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            rw = new NBK_ResultWrapper(false, e, null);
        }
        Logger.saveLog();

        return JSON.serialize(rw);
    }

    private static Boolean checkAccountFields(Account acc){
        if(String.isEmpty(acc.PersonEmail)){
            throw new CreateUserException(Label.register_ContactMailUnregistered);
        }
        return true;
    }

    private static User createUser(Account Acc) {
        Logger.info('Account to create with NIF --> '+ acc.Documento__c + ' -- JSON: \n ' + JSON.serialize(Acc));
        List<Profile> P = [SELECT id, name FROM Profile WHERE Name = 'External App Login DAG'];
        User u = new User();
        u.FirstName = acc.FirstName;
        u.LastName = acc.LastName;
        u.contactId = acc.PersonContactID;
        u.Email = acc.Personemail;
        
        if(!String.isEmpty(acc.FirstName) && !String.isEmpty(acc.LastName)){
            if(acc.LastName.length() >= 3){
                u.Alias = acc.FirstName.substring(0,1)+acc.LastName.substring(0,3);
            }else{
                u.Alias = acc.FirstName.substring(0,1)+acc.LastName;
            }
        }else{
            Logger.info('Acc.NIF --> ' + acc.Documento__c + ' Firstname --> ' + acc.FirstName + ' LastName -->' +  acc.LastName);
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now())
                .replace(' ', '')
                .replace(':', '')
                .replace('-', '');
            Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
            String uniqueName = orgId + dateString + randomInt;
            u.Alias = uniqueName.substring(18, 23);
        }
        
        String usernameNoblancks=acc.Documento__c.trim() + '@mydag.com'; 
        usernameNoblancks=usernameNoblancks.replace(' ', '');
        u.Username=usernameNoblancks;
        u.CommunityNickname = 'u'+acc.id; 
        u.Preferencias_de_Contacto__c = acc.Preferencia_de_Contacto__pc;
        u.MobilePhone = acc.PersonMobilePhone;
        u.Phone = acc.Phone;
        u.City = acc.BillingCity;
        u.Country = acc.BillingCountry;
        u.PostalCode = acc.BillingPostalCode;
        u.State = acc.BillingState;
        u.Street = acc.BillingStreet;  
        u.CommunityNickname = 'u'+acc.id;
        u.LocaleSidKey = 'es_ES';
        u.TimeZoneSidKey = 'Europe/Lisbon';
        u.ProfileID = P[0].id;
        u.LanguageLocaleKey = 'es';
        u.EmailEncodingKey = 'UTF-8';
        u.FU__c = true;
        Savepoint sp = Database.setSavepoint();
        try{
            insert u; 
            List<Consentimientos__c> consentimientos = ConsentimientosSelector.getWithoutSharingContext().getConsentimientosFichaUnicaByPCIds(new Set<Id>{acc.PersonContactID});
            Consentimientos__c cnto = new Consentimientos__c();
            if(consentimientos.size() == 0){
                MyDagConfig__mdt dagConfig = NBK_GlobalConstants.DAG_CONFIG;
                cnto.RecordTypeId = NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID;
                cnto.Contact__c = acc.PersonContactId;
                cnto.Concesionario__c = dagConfig.dealership_Id__c;
                cnto.communicationType__c = 'myDAG';
                cnto.EnviarAmulesoft__c = false;
                cnto.realCommunicationDate__c = system.now();
                cnto.entryDate__c = system.now();
                insert cnto;
            }else{
                updateConsentimiento(true, consentimientos[0].id);
            }
            acc.PoliticaPrivacidadAceptada__c = true;
            update acc;
        }catch(Exception e){
            Database.rollback(sp);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            throw new CreateUserException(Label.register_unknownException);
        }

        return u;
    }
    
    @AuraEnabled
    public static string checkNifbyAccount(string Acc) {
        //Decision: 0 --> Error / 1 --> Not found / 2 --> Already exist / id --> OK (ContactId)
        NBK_ResultWrapper rw = new NBK_ResultWrapper();
        String returnDecision = 'error';

        try{
            List<Account> accountList = AccountSelector.getWithoutSharingContext().getAccountsByNIE(new Set<String>{Acc.trim()});
            system.debug('IMP Account Size : ' + accountList.size());
            if(accountList.size() == 1){
                List<User> users = UserSelector.getWithoutSharingContext().getUsersByContactId(new Set<Id>{accountList[0].PersonContactId});
                if(users.size() != 0){
                    returnDecision = 'userFound';
                }else{
                    if(accountList[0].Cliente_Propio__c){
                        returnDecision = accountList[0].PersonContactId;
                    }else{
                        returnDecision = 'noClientePropio';
                    }
                }
            }else if(accountList.size() == 0){
                returnDecision = 'accountNotFound';
                // please contact Domingo Alonso
            }else{
                Logger.error('Several accounts (' +accountList.size() +') for the NIE -- ' + Acc);
                returnDecision = 'severalAccounts';
            }
            rw = new NBK_ResultWrapper(true, null, returnDecision);
        } catch(Exception e) {
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            rw = new NBK_ResultWrapper(false,e, 'error');
        }

        Logger.saveLog();

        return JSON.serialize(rw);
    }
    
        
    @AuraEnabled
    public static string checkOppositionRecord(string Acc) {
        //Decision: 0 --> Error / 1 --> Not Registered / 2 --> Registered and accepted  / id --> Registered but old
        string returnDecision = '0';
        try{
            Boolean fuAccept = false;
            List<Account> A = [SELECT id, FirstName, LastName, PersonContactID, PersonEmail, Cliente_Propio__c, Documento__c, Phone, PoliticaPrivacidadAceptada__c, Preferencia_de_contacto__pc,	PersonMobilePhone,billingCity, billingCountry, billingPostalCode, billingState, billingStreet FROM Account WHERE Documento__c = :Acc.trim()];
            if(A.size() > 0){
                if(!A[0].Cliente_Propio__c){
                    returnDecision = 'noClientePropio';
                    fuAccept = false;
                }else{
                    Id rT = NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID;
                    List<Consentimientos__c> consentimientos = [SELECT id, oppositionDate__c, entryDate__c, EnviarAmulesoft__c , realCommunicationDate__c, communicationType__c  FROM Consentimientos__c where Contact__c = :A[0].PersonContactID AND RecordTypeId =: rT ];
                    if(consentimientos.size() > 0){
                        Consentimientos__c cnto = consentimientos[0];
                        if(cnto.oppositionDate__c == null){
                            if(cnto.entryDate__c < System.now()){
                                    returnDecision = '2';
                                    fuAccept= true; 
                            }else{
                                returnDecision = cnto.id;
                                fuAccept = false;
                            }
                        }else{
                            returnDecision = cnto.id;
                            fuAccept = false;
                        }
                    }else {
                        returnDecision = '1';
                        fuAccept = false;
                    }
                }
                updateFU(fuAccept);     
            }
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
        return returnDecision;
    }


    @AuraEnabled
    public static string checkOppositionRecordByUser() {
        //Decision: 0 --> Error / 1 --> Not Registered / 2 --> Registered and accepted  / id --> Registered but denied
        string returnDecision = '0';
        try{
            Boolean fuAccept = false;
            Id userId = UserInfo.getUserId();
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
        
            Id rT =  Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName().get('Ficha_unica').getRecordTypeId(); 
            List<Consentimientos__c> consentimientos = [SELECT id, oppositionDate__c, entryDate__c, EnviarAmulesoft__c , realCommunicationDate__c, communicationType__c  FROM Consentimientos__c where Contact__c = :u[0].ContactId AND RecordTypeId =: rT ];
            if(u.size() > 0){
                List<Account> A = [SELECT id, Cliente_Propio__c FROM Account WHERE personContactID = :u[0].contactId];
                if(!A[0].Cliente_Propio__c){
                        returnDecision = 'noClientePropio';
                        fuAccept = false;
                }else{
                        if(consentimientos.size() > 0){
                            Consentimientos__c cnto = consentimientos[0];
                            if(cnto.oppositionDate__c == null){
                                if(cnto.entryDate__c < System.now()){
                                        returnDecision = '2';
                                        fuAccept= true; 
                                }else if(cnto.entryDate__c == null){
                                    returnDecision = '1';
                                    fuAccept = false;  
                                } else{
                                    returnDecision = '1';
                                    fuAccept = false;  
                                }
                            }else{
                                returnDecision = cnto.id;
                                fuAccept = false;    
                            }
                        }else {
                            returnDecision = '1';
                            fuAccept = false;  
                        }
                    }
                updateFU(fuAccept); 
            }  
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
        System.debug('checkOppositionRecord : ' + returnDecision);
        return returnDecision;
    }
    
    @AuraEnabled
    public static void updatePoliticaPrivacidad(Boolean accept) {
        try{
            Id userId = UserInfo.getUserId();
            if(userId != null){
                List<User> u = [SELECT id, ContactId FROM User WHERE Id =: userId];
                if(u.size()>0){
                    List<Account> acc = [SELECT id, PoliticaPrivacidadAceptada__c FROM Account WHERE personContactID =: u[0].ContactId];
                    if(acc.size()>0){
                        acc[0].PoliticaPrivacidadAceptada__c = true;
                        update acc;
                    }
                }
            }
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
    @AuraEnabled
    public static void acceptFU(Boolean accept) {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            if(accept){
                u[0].FU__c = true;
            }else{
                u[0].FU__c = false;
            }
            update u;
            createConsentimiento(accept,u[0].ContactId);
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
    @AuraEnabled
    public static void updateFU(Boolean accept) {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            if(u.size() > 0){
                if(accept){
                    u[0].FU__c = true;
                }else{
                    u[0].FU__c = false;
                }
                update u;
            }
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }

    @AuraEnabled
    public static void createConsentimiento(Boolean accept, Id contactId) {
        try {
            Consentimientos__c cnto = new Consentimientos__c();
            Id rT =  NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID;
            List<Consentimientos__c> consentimientos = [SELECT id FROM Consentimientos__c WHERE RecordTypeId =: rT AND Contact__c =: contactId];
            if(consentimientos.size() == 0){
                MyDagConfig__mdt dagConfig = NBK_GlobalConstants.DAG_CONFIG;
                cnto.RecordTypeId = rT;
                cnto.Contact__c = contactId;
                cnto.Concesionario__c = dagConfig.dealership_Id__c;
                cnto.communicationType__c = 'myDAG';
                cnto.EnviarAmulesoft__c = false;
                cnto.realCommunicationDate__c = system.now();
                cnto.entryDate__c = system.now();
                if(!accept){
                    cnto.oppositionDate__c = system.now();
                }else{
                    updatePoliticaPrivacidad(accept);
                }
                insert cnto;
            }else{
                updateConsentimiento(accept, consentimientos[0].id);
            }
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
    
    @AuraEnabled
    public static void updateConsentimiento(Boolean accept, String cntoId) {
        try{
            Id rT =  Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName().get('Ficha_unica').getRecordTypeId(); 
            Consentimientos__c cnto = [SELECT id FROM Consentimientos__c WHERE Id =:cntoId];
            cnto.communicationType__c = 'myDAG';
            cnto.EnviarAmulesoft__c = false;
            cnto.realCommunicationDate__c = system.now();
            cnto.entryDate__c = system.now();
            if(accept){
                cnto.oppositionDate__c = null ;
                //updatePoliticaPrivacidad(accept);
            }else{
                cnto.oppositionDate__c = system.now();
            }
            update cnto;
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
    
    @AuraEnabled
    public static void acceptConsentimiento(Boolean accept) {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            Id rT =  Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName().get('Ficha_unica').getRecordTypeId(); 
            List<Consentimientos__c> consentimientos = [SELECT id, oppositionDate__c, entryDate__c, EnviarAmulesoft__c , realCommunicationDate__c, communicationType__c  FROM Consentimientos__c where Contact__c = :u[0].ContactId AND RecordTypeId =: rT ];
            if(u.size() > 0){
                if(consentimientos.size() > 0){
                    updateFU(accept);
                    updateConsentimiento(accept, consentimientos[0].id);
                }else{
                    updateFU(accept);  
                    createConsentimiento(accept,u[0].ContactId);
                }
            }
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
        }
    }

    @AuraEnabled
    public static Boolean getPermissions() {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            List<Account> acc = [SELECT id, PoliticaPrivacidadAceptada__c, AceptadoComunicacionesWAH__c FROM Account WHERE personContactID =: u[0].ContactId];
            if(acc[0].PoliticaPrivacidadAceptada__c && acc[0].AceptadoComunicacionesWAH__c){
                return true;
            }else{
                return false;
            }
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
        return false;
    }

    @AuraEnabled
    public static void updatePermissions() {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            List<Account> acc = [SELECT id, PoliticaPrivacidadAceptada__c, AceptadoComunicacionesWAH__c, Socio_WAH__pc FROM Account WHERE personContactID =: u[0].ContactId];
            acc[0].AceptadoComunicacionesWAH__c = true;
            acc[0].Socio_WAH__pc = true;
            update acc;
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
    
    @AuraEnabled
    public static void unsubscribeComms() {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            List<Account> acc = [SELECT id, PoliticaPrivacidadAceptada__c, AceptadoComunicacionesWAH__c FROM Account WHERE personContactID =: u[0].ContactId];
            acc[0].AceptadoComunicacionesWAH__c = false;
            update acc;
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
   
}