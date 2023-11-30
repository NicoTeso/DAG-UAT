/**
 * @description  : 
 * @author       : development@nubika.com 
**/
@isTest
public class CreateUserTest {

    @isTest static void testWithoutLastname(){
        List<RecordType> recordTypeId =[SELECT id from Recordtype WHERE Name = 'Cuenta Personal'];
        Account accWithoutFirstname = new Account(LastName = 'Name', Documento__c = '48114001C', Cliente_Propio__c = true, personEmail = 'salesforce.crm@birchmangroup.com', RecordTypeId = recordTypeId[0].id);
        insert accWithoutFirstname;
        CreateUser.registerUser('48114001C'); 
    }
    @isTest static void runNewUserFlow(){
        List<Account> accList = createAccount();
        String response;
        NBK_ResultWrapper toCompare = new NBK_ResultWrapper();
        String toCompareString;
        //Comprobar documento válido
        for(Account acc : accList){
                response = checkNif(acc.Documento__c);
                toCompare = new NBK_ResultWrapper(true, null, acc.PersonContactID);
                toCompareString = JSON.serialize(toCompare);
                System.assertEquals(response,toCompareString); 
        }
        
        //Comprueba la FU
        for (Account acc : accList){
            response = CreateUser.checkOppositionRecord(acc.Documento__c);
            System.assertEquals(response,'1');

            //Crear usuario
            CreateUser.registerUser(acc.Documento__c); 
            checkNif(acc.Documento__c);
        }
        CreateUser.createConsentimiento(TRUE, accList.get(0).PersonContactID);
        for (Account acc : accList){
            response = CreateUser.checkOppositionRecord(acc.Documento__c);
            System.assertEquals(response,'2');

            //Crear usuario
            CreateUser.registerUser(acc.Documento__c); 
            checkNif(acc.Documento__c);
        }

        // *** Comprobar consentimientos ***
        //Creo un consentimiento con fecha de oposición
        List <Consentimientos__c> consentimientoList = crearTestConsentimiento(false, accList);
        Boolean oppositionValue = false;
        for(Consentimientos__c constentimiento : consentimientoList){
            if(constentimiento.oppositionDate__c != null){
                oppositionValue = true;
            }
            System.assertEquals(oppositionValue, true);
        }
        

        //Compruebo el estado del consentimiento por usuario logado -> Debe ser consentimiento con fecha de opp y FU de cuenta a FALSE
        comprobarConsentimiento(false, accList);


        //Accepto el consentiemiento previo
        acceptarTestConsentimiento(true,accList);

        //Compruebo el estado del consentimiento por usuario logado -> Debe ser consentimiento correcto y FU de cuenta a TRUE
        comprobarConsentimiento(true, accList);

        //Elimino el consentimiento previo
        delete consentimientoList;

        //Creo un consentimiento aprobado
        consentimientoList = crearTestConsentimiento(true, accList);
        oppositionValue = false;
        for (Consentimientos__c consentimiento : consentimientoList){
            if(consentimiento.oppositionDate__c != null){
                oppositionValue = true;
            }
        }
        System.assertEquals(oppositionValue, false);

        //Compruebo el estado del consentimiento por usuario logado -> Debe ser consentimiento correcto y FU de cuenta a TRUE
        comprobarConsentimiento(true, accList);

        //Opongo el consentiemiento previo
        acceptarTestConsentimiento(false, accList);

        //Compruebo el estado del consentimiento por usuario logado -> Debe ser consentimiento con fecha de opp y FU de cuenta a FALSE
        comprobarConsentimiento(false, accList);

        //Elimino el consentimiento previo
        delete consentimientoList;

        //Acceptar fu desde audiencia NO_FU
        CreateUser.acceptFU(true);

        //Denegar fu desde audiencia NO_FU
        CreateUser.acceptFU(false);

        for(User u : [SELECT Id FROM user WHERE Profile.Name = 'External App Login DAG' AND isActive = true LIMIT 2]){
            System.runAs(u){
                CreateUser.unsubscribeComms();
            }
        }
    }

    @isTest static List<Account> createAccount(){
        List<RecordType> recordTypeId =[SELECT id from Recordtype WHERE Name = 'Cuenta Personal'];
        List<Profile> P = [SELECT id, name FROM Profile WHERE Name = 'External App Login DAG'];
        List<Account> accList = new List<Account>();

        Account acc = new Account(FirstName = 'First', LastName = 'Name', Documento__c = '48004001C', Cliente_Propio__c = true, personEmail = 'salesforce.crm@birchmangroup.com', RecordTypeId = recordTypeId[0].id);
        accList.add(acc);

        insert accList;
        List<Account> acc2 = [SELECT id, personContactID, Documento__c From Account WHERE Cliente_Propio__c = true];   
        return acc2;
    }

    static String checkNif(String documento){
        String checkNifResponse = CreateUser.checkNifbyAccount(documento);
        return checkNifResponse;
    }

    static List<Consentimientos__c> crearTestConsentimiento(Boolean accept, List<Account> accountList){
        Id rT =  Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName().get('Ficha_unica').getRecordTypeId();
        List<Consentimientos__c> consentimientosList = new List<Consentimientos__c>();
        for(Account acc : accountList){
            CreateUser.createConsentimiento(accept, acc.PersonContactID);
            Consentimientos__c consentimientos = [SELECT id, oppositionDate__c, entryDate__c FROM Consentimientos__c where Contact__c = : acc.PersonContactID AND RecordTypeId =: rT];
            consentimientosList.add(consentimientos);
        }
        return consentimientosList;
    }
    static void comprobarConsentimiento(Boolean respuestaEsperada, List<Account> accList){
        List<Id> accountIdList = new List<Id>();
        List<Id> personContactIdList = new List<Id>();
        for (Account acc : accList){
            accountIdList.add(acc.Id);
        }
        List<Account> accList2 = [SELECT id, personContactID, Documento__c From Account WHERE id IN: accountIdList];  
        for (Account acc : accList2){
            personContactIdList.add(acc.personContactID);
        }
        List<User> userList = [SELECT id, FU__c, ContactId FROM User WHERE contactId IN: personContactIdList];
        for(User u : userList){
            System.runAs(u) {
                String respuestaConsentimientoOposicion = CreateUser.checkOppositionRecordByUser();
                if(respuestaEsperada){
                    System.assertEquals(respuestaConsentimientoOposicion, '2');
                } else{
                    Boolean respuestaFU = respuestaConsentimientoOposicion != '2';
                    System.assertEquals(respuestaFU, true);
                }
                // Account accConsentimiento = [SELECT id, FU__c FROM Account WHERE id = :acc.id];
                // System.assertEquals(accConsentimiento.FU__c, respuestaEsperada);
                
            }
        }
        
    }
    static void acceptarTestConsentimiento(Boolean acceptado, List<Account> accList){
        List<Id> accountIdList = new List<Id>();
        List<Id> personContactIdList = new List<Id>();
        for (Account acc : accList){
            accountIdList.add(acc.Id);
        }
        List<Account> accList2 = [SELECT id, personContactID, Documento__c From Account WHERE id IN: accountIdList];  
        for (Account acc : accList2){
            personContactIdList.add(acc.personContactID);
        }
        List<User> userList = [SELECT id, FU__c, ContactId FROM User WHERE contactId IN: personContactIdList];
        for(User u : userList){
            System.runAs(u) {
                CreateUser.updatePermissions();
                CreateUser.getPermissions();
                CreateUser.acceptConsentimiento(acceptado);
            }
        }
    }

}