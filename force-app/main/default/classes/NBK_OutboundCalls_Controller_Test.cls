/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_OutboundCalls_Controller_Test
     Created Date:      27/04/2021
     Company:           Nubika Consulting
     Author:            Alberto Sanchez - Juan Tamboleo
------------------------------------------------------------------------------------------*/
@IsTest
public class NBK_OutboundCalls_Controller_Test {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupOutboundControllerTestData();
    }

    public static void testAll() {
        Test.startTest();
        initComponentFromTareaLlamadaWithPhonesCallMethod();
        initComponentFromTareaLlamadaWithoutPhonesCallMethod();
        updateOutboundCallCallTaskCallMethod();
        updateOutboundCallCaseCallMethod();
        updateOutboundCallAccountCallMethod();
        initComponentVACallMethod();
        Test.stopTest();
    }

    @IsTest
    static void initComponentFromTareaLlamadaWithPhonesCallMethodTest() {
        test.startTest();
        initComponentFromTareaLlamadaWithPhonesCallMethod();
        test.stopTest();
    }

    @IsTest
    static void initComponentFromTareaLlamadaWithoutPhonesCallMethodTest() {
        test.startTest();
        initComponentFromTareaLlamadaWithoutPhonesCallMethod();
        test.stopTest();
    }

    @IsTest
    static void updateOutboundCallCallTaskCallMethodTest() {
        test.startTest();
        updateOutboundCallCallTaskCallMethod();
        test.stopTest();
    }

    @IsTest
    static void updateOutboundCallCaseCallMethodTest() {
        test.startTest();
        updateOutboundCallCaseCallMethod();
        test.stopTest();
    }

    @IsTest
    static void updateOutboundCallAccountCallMethodTest() {
        test.startTest();
        updateOutboundCallAccountCallMethod();
        test.stopTest();
    }

    @IsTest
    static void initComponentVAMethodTest() {
        test.startTest();
        initComponentVACallMethod();
        test.stopTest();
    }

    private static void initComponentFromTareaLlamadaWithPhonesCallMethod() {
        Call_Task__c ct = [
                SELECT Id, Brand_Phone__c, Target_Phone__c
                FROM Call_Task__c
                WHERE Brand_Phone__c != NULL AND Target_Phone__c != NULL
                LIMIT 1
        ];

        String jsonResult = NBK_OutboundCalls_Controller.initComponent(ct.Id);
        NBK_OutboundCalls_Controller.ApexRestResultWrapper wrapper = (NBK_OutboundCalls_Controller.ApexRestResultWrapper) JSON.deserialize(jsonResult, NBK_OutboundCalls_Controller.ApexRestResultWrapper.class);
        System.assertEquals(wrapper.brandPhone, ct.Brand_Phone__c);
        System.assertEquals(wrapper.customerPhone, ct.Target_Phone__c);
        System.assertEquals(wrapper.brandPhonesMap, null);
    }

    private static void initComponentFromTareaLlamadaWithoutPhonesCallMethod() {
        Call_Task__c ct = [
                SELECT Id, Target_Phone__c
                FROM Call_Task__c
                WHERE Brand_Phone__c = NULL AND Target_Phone__c != NULL
                LIMIT 1
        ];

        String jsonResult = NBK_OutboundCalls_Controller.initComponent(ct.Id);
        NBK_OutboundCalls_Controller.ApexRestResultWrapper wrapper = (NBK_OutboundCalls_Controller.ApexRestResultWrapper) JSON.deserialize(jsonResult, NBK_OutboundCalls_Controller.ApexRestResultWrapper.class);
        System.assertEquals(wrapper.brandPhone, null);
        System.assertEquals(wrapper.customerPhonesMap.values().get(0), ct.Target_Phone__c);
        System.assert(!wrapper.brandPhonesMap.isEmpty());
    }

    private static void updateOutboundCallCallTaskCallMethod() {
        Call_Task__c ct = [
                SELECT Id
                FROM Call_Task__c
                WHERE OwnerId = :UserInfo.getUserId()
                LIMIT 1
        ];
        String result = NBK_OutboundCalls_Controller.updateOutboundCallTask(ct.Id, '+34666666666', '+34666666666');
        NBK_OutboundCalls_Controller.ApexRestResultWrapper wrapper = (NBK_OutboundCalls_Controller.ApexRestResultWrapper) JSON.deserialize(result, NBK_OutboundCalls_Controller.ApexRestResultWrapper.class);
    }

    private static void updateOutboundCallCaseCallMethod() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        String result = NBK_OutboundCalls_Controller.updateOutboundCallTask(c.Id, '+34666666666', '+34666666666');
        NBK_OutboundCalls_Controller.ApexRestResultWrapper wrapper = (NBK_OutboundCalls_Controller.ApexRestResultWrapper) JSON.deserialize(result, NBK_OutboundCalls_Controller.ApexRestResultWrapper.class);
        System.assert(wrapper.success);
    }


    private static void updateOutboundCallAccountCallMethod() {
        Account acc = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        String result = NBK_OutboundCalls_Controller.updateOutboundCallTask(acc.Id, '+34666666666', '+34666666666');
        NBK_OutboundCalls_Controller.ApexRestResultWrapper wrapper = (NBK_OutboundCalls_Controller.ApexRestResultWrapper) JSON.deserialize(result, NBK_OutboundCalls_Controller.ApexRestResultWrapper.class);
        System.assert(wrapper.success);
    }

    private static void initComponentVACallMethod() {
        Vehiculo__c vehicle = [SELECT Id, Propietario__r.Phone FROM Vehiculo__c];
        String resultJSON = NBK_OutboundCalls_Controller.initComponentVA(vehicle.Id);
        NBK_OutboundCalls_Controller.ApexRestResultWrapper wrapper = (NBK_OutboundCalls_Controller.ApexRestResultWrapper) JSON.deserialize(resultJSON, NBK_OutboundCalls_Controller.ApexRestResultWrapper.class);
        System.assertEquals(wrapper.customerPhonesMap.values().get(0), vehicle.Propietario__r.Phone);
    }
}