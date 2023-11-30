public without sharing class NBK_SelfRegisterController {

    /**
    * @description
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param password
    * @param confirmPassword
    * @return boolean
    **/
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    /**
    * @description
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param communityUrl
    * @return boolean
    **/
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    /**
    * @description
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param u
    * @param password
    * @param confirmPassword
    **/
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    /**
    * @description Method to register in the app and create a user.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param dni
    * @param password
    * @param confirmPassword
    * @param startUrl
    * @return String
    **/
    @AuraEnabled
    public static String selfRegister(String dni, String password, String confirmPassword, String startUrl) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            if(dni == null){
                throw new NBK_SelfRegisterControllerException('Dni no puede ser nulo');
            }

            List<Account> accountList = AccountSelector.getWithoutSharingContext().getAccountsByNIE(new Set<String>{dni.trim()});
            //If account already exists with that dni
            if(accountList.size() == 1){
                User u = new User();
                String usernameNoblanks = dni.trim() + '@mydag.com';
                usernameNoblanks = usernameNoblanks.replace(' ', '');
                u.Username = usernameNoblanks;
                u.FirstName = accountList[0].FirstName;
                u.LastName = accountList[0].LastName;
                u.contactId = accountList[0].PersonContactID;
                u.Email = accountList[0].PersonEmail;
                u.CommunityNickname = 'u' + dni;
                u.Phone = accountList[0].Phone;
                u.City = accountList[0].BillingCity;
                u.Country = accountList[0].BillingCountry;
                u.PostalCode = accountList[0].BillingPostalCode;
                u.State = accountList[0].BillingState;
                u.Street = accountList[0].BillingStreet;
                u.MobilePhone = accountList[0].PersonMobilePhone;
                u.Preferencias_de_Contacto__c = accountList[0].Preferencia_de_Contacto__pc;
                u.LocaleSidKey = 'es_ES';
                u.TimeZoneSidKey = 'Europe/Lisbon';
                u.LanguageLocaleKey = 'es';
                u.EmailEncodingKey = 'UTF-8';
                u.FU__c = true;

                String networkId = Network.getNetworkId();

                // If using site to host the community the user should not hit s1 after logging in from mobile.
                if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                    u.put('UserPreferencesHideS1BrowserUI',true);
                }

                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }

                validatePassword(u, password, confirmPassword);

                String userId = Site.createExternalUser(u, accountList[0].Id, password, true);
                // create a fake userId for test.
                if (Test.isRunningTest()) {
                    userId = 'fakeUserId';
                }

                if (userId != null) {
                    if (password != null && password.length() > 1) {
                        ApexPages.PageReference lgn = Site.login(usernameNoblanks, password, startUrl);
                        if(!Test.isRunningTest()) {
                            aura.redirect(lgn);
                        }
                        createConsentimiento(true, accountList[0].PersonContactID);
                        accountList[0].PoliticaPrivacidadAceptada__c = true;
                        update accountList[0];
                    }
                }
                return null;
            } else{
                Logger.error('Accounts found with NIF = '+ dni + ' -- \n accountList.size() = ' + accountList.size() + ' -- ' + JSON.serialize(accountList));
                Logger.saveLog();
                return Label.register_ClientNotVerified;
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }

    /**
    * @description Method to check if an account exists with this dni.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param dni
    * @return String
    **/
    @AuraEnabled
    public static String checkDnibyAccount(String dni) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            if(String.isEmpty(dni)){
                throw new NBK_SelfRegisterControllerException('Dni no puede ser nulo');
            }

            List<Account> accountList = AccountSelector.getWithoutSharingContext().getAccountsByNIE(new Set<String>{dni.trim()});
            //If account already exists with that dni
            if(accountList.size() == 1 && !String.isEmpty(accountList[0].PersonContactId)){
                List<User> users = UserSelector.getWithoutSharingContext().getUsersByContactId(new Set<Id>{accountList[0].PersonContactId});
                if(users.size() == 0 && checkAccountFields(accountList[0])){
                    if(accountList[0].Cliente_Propio__c){
                        return null;
                    } else {
                        return Label.register_NotClient;
                    }
                }
                else {
                    return Label.dniAlreadyRegistered;
                }
            }else{
                Logger.error('Accounts found with NIF = '+ dni + ' -- \n accountList.size() = ' + accountList.size() + ' -- ' + JSON.serialize(accountList));
                Logger.saveLog();
                return Label.register_ClientNotVerified;
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            if(e.getMessage() == Label.register_ContactMailUnregistered){
                return e.getMessage();
            } else {
                return Label.register_IntroduceDNI;
            }
        }
    }

    /**
    * @description Method to get the "Name" of the account related to dni.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param dni
    * @return String
    **/
    @AuraEnabled
    public static String getAccountName(String dni) {
        try{
            if(String.isEmpty(dni) || dni == null){
                throw new NBK_SelfRegisterControllerException('Dni no puede ser nulo');
            } else {
                List<Account> accountList = AccountSelector.getWithoutSharingContext().getAccountsByNIE(new Set<String>{dni.trim()});
                if(accountList.size() == 1){
                    return accountList[0].FirstName;
                }
            }
            return null;

        } catch(Exception e) {
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }

    /**
    * @description Method to check the opposition for this user.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param dni
    * @return string
    **/
    @AuraEnabled
    public static string checkOppositionRecord(string dni) {
        //Decision: 0 --> Error / 1 --> Not Registered / 2 --> Registered and accepted  / id --> Registered but old
        string returnDecision = '0';
        try{
            if(String.isEmpty(dni) || dni == null){
                throw new NBK_SelfRegisterControllerException('Dni no puede ser nulo');
            }
            Boolean fuAccept = false;
            List<Account> acc = [SELECT id, FirstName, LastName, PersonContactID, PersonEmail, Cliente_Propio__c, Documento__c, Phone, PoliticaPrivacidadAceptada__c, Preferencia_de_contacto__pc,	PersonMobilePhone,billingCity, billingCountry, billingPostalCode, billingState, billingStreet FROM Account WHERE Documento__c = :dni.trim()];
            if(acc.size() > 0){
                if(!acc[0].Cliente_Propio__c){
                    returnDecision = 'noClientePropio';
                    fuAccept = false;
                }else{
                    Id rT = NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID;
                    List<Consentimientos__c> consentimientos = [SELECT id, oppositionDate__c, entryDate__c, EnviarAmulesoft__c , realCommunicationDate__c, communicationType__c  FROM Consentimientos__c where Contact__c = :acc[0].PersonContactID AND RecordTypeId =: rT ];
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

    /**
    * @description Method to update FU__c.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param accept
    **/
    @AuraEnabled
    public static void updateFU(Boolean accept) {
        try{
            Id userId = UserInfo.getUserId();
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            if(u.size() > 0){
                if(accept){
                    u[0].FU__c = true;
                } else{
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

    /**
    * @description Method to create a Consentimientos__c for this contact.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param accept
    * @param contactId
    **/
    public static void createConsentimiento(Boolean accept, Id contactId) {
        try {
            Consentimientos__c cnto = new Consentimientos__c();
            Id rT =  NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID;
            List<Consentimientos__c> consentimientos = ConsentimientosSelector.getWithoutSharingContext().getConsentimientosFichaUnicaByPCIds(new Set<Id>{contactId});
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

    /**
    * @description Method to update consentimiento.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param accept
    * @param cntoId
    **/
    public static void updateConsentimiento(Boolean accept, String cntoId) {
        try{
            Consentimientos__c cnto = [SELECT id FROM Consentimientos__c WHERE Id =:cntoId];
            cnto.communicationType__c = 'myDAG';
            cnto.EnviarAmulesoft__c = false;
            cnto.realCommunicationDate__c = system.now();
            cnto.entryDate__c = system.now();
            if(accept){
                cnto.oppositionDate__c = null ;
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

    /**
    * @description Method to check that the Account has PersonEmail.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param acc
    * @return Boolean
    **/
    private static Boolean checkAccountFields(Account acc){
        if(String.isEmpty(acc.PersonEmail)){
            throw new NBK_SelfRegisterControllerException(Label.register_ContactMailUnregistered);
        }
        return true;
    }

    public class NBK_SelfRegisterControllerException extends Exception{}
}