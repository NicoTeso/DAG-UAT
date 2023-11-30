/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_CaseTriggerHandler_Test
     Created Date:      15/04/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
@IsTest
public class NBK_CaseTriggerHandler_Test {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll() {
        Test.startTest();
            proccessCasesForLeadManagementCallMethod();
            proccessCasesForLeadManagementCallInMethod();
            rescheduleCasesMethod();
            getQueueMethod();
            assignCaseIdToMessagingSessionInvocableMethod();
        Test.stopTest();
    }

    @IsTest
    static void proccessCasesForLeadManagementCallMethodTest() {
        Test.startTest();
            proccessCasesForLeadManagementCallMethod();
        Test.stopTest();
    }

    @IsTest
    static void proccessCasesForLeadManagementCallInMethodTest() {
        Test.startTest();
            proccessCasesForLeadManagementCallInMethod();
        Test.stopTest();
    }

    @IsTest
    static void rescheduleCasesMethodTest() {
        Test.startTest();
            rescheduleCasesMethod();
        Test.stopTest();
    }

    @IsTest
    static void getQueueMethodTest() {
        Test.startTest();
            getQueueMethod();
        Test.stopTest();
    }

    @IsTest
    static void assignCaseIdToMessagingSessionInvocableMethodTest() {
        Test.startTest();
            assignCaseIdToMessagingSessionInvocableMethod();
        Test.stopTest();
    }

    public static void proccessCasesForLeadManagementCallMethod() {
        Lead_Management__c leadManagement = NBK_SetupClassTest.getLeadManagement('CALL');
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = :leadManagement.Type__c];
        Case caseObj = new Case();
        caseObj.RecordTypeId = rt.Id;
        caseObj.Marca__c = leadManagement.Brand__c;
        caseObj.Centro__c = leadManagement.Establishment__c;
        caseObj.Origin = leadManagement.Origin__c;
        caseObj.Campana__c = leadManagement.Campaign__c;
        caseObj.Intencion_de_compra__c = leadManagement.Purchase_Reason__c;
        insert caseObj;
        caseObj.Call_Again__c = true;
        update caseObj;
    }

    public static void proccessCasesForLeadManagementCallInMethod() {
        Lead_Management__c leadManagement = NBK_SetupClassTest.getLeadManagement('CALL_IN');
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = :leadManagement.Type__c];
        Case caseObj = new Case();
        caseObj.RecordTypeId = rt.Id;
        caseObj.Marca__c = leadManagement.Brand__c;
        caseObj.Centro__c = leadManagement.Establishment__c;
        caseObj.Origin = leadManagement.Origin__c;
        caseObj.Campana__c = leadManagement.Campaign__c;
        caseObj.Intencion_de_compra__c = leadManagement.Purchase_Reason__c.split(';')[0];
        insert caseObj;
    }

    public static void rescheduleCasesMethod() {
        Lead_Management__c leadManagement = NBK_SetupClassTest.getLeadManagement('');
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = :leadManagement.Type__c];
        Case caseObj = new Case();
        caseObj.RecordTypeId = rt.Id;
        caseObj.Marca__c = leadManagement.Brand__c;
        caseObj.Centro__c = leadManagement.Establishment__c;
        caseObj.Origin = leadManagement.Origin__c;
        caseObj.Campana__c = leadManagement.Campaign__c;
        caseObj.Intencion_de_compra__c = leadManagement.Purchase_Reason__c;
        insert caseObj;
        caseObj.Call_Again__c = true;
        update caseObj;
    }

    public static void getQueueMethod() {
        List<RecordType> lCaseRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case'];
        Map<String,RecordType> mCaseRecordTypeByDeveloperName = new Map<String,RecordType>();
        for(RecordType rt : lCaseRecordTypes){
            mCaseRecordTypeByDeveloperName.put(rt.DeveloperName,rt);
        }

        Case caseObj = new Case(
            RecordTypeId = mCaseRecordTypeByDeveloperName.get('Gestion_de_Lead').Id,
            RecordType = mCaseRecordTypeByDeveloperName.get('Gestion_de_Lead'),
            Marca__c = 'VOLKSWAGEN',
            PurchasePriority__c = '1'
        );
        NBK_CaseTriggerHandler.getQueue(caseObj);

        caseObj.PurchasePriority__c = '2';
        NBK_CaseTriggerHandler.getQueue(caseObj);

        caseObj.Marca__c = 'HYUNDAI';
        caseObj.PurchasePriority__c = '1';
        NBK_CaseTriggerHandler.getQueue(caseObj);

        caseObj.PurchasePriority__c = '2';
        NBK_CaseTriggerHandler.getQueue(caseObj);

        caseObj.RecordTypeId = mCaseRecordTypeByDeveloperName.get('Gestion_de_Lead_VO').Id;
        caseObj.RecordType = mCaseRecordTypeByDeveloperName.get('Gestion_de_Lead_VO');
        caseObj.PurchasePriority__c = '1';
        NBK_CaseTriggerHandler.getQueue(caseObj);

        caseObj.PurchasePriority__c = '2';
        NBK_CaseTriggerHandler.getQueue(caseObj);

        caseObj.Origin = 'Feria_AVIS';
        NBK_CaseTriggerHandler.getQueue(caseObj);

    }

    public static void assignCaseIdToMessagingSessionInvocableMethod(){
        List<Id> casesIds = new List<Id>();
        List<Case> casessList = [SELECT Id FROM Case LIMIT 5];
        for(Case caseItem : casessList){
            caseItem.Enviado_plantilla_2_Llamada__c = true;
            casesIds.add(caseItem.Id);
        }

        update casessList;
        NBK_CaseTriggerHandler.messagingSessionMapping(casesIds);
    }

}