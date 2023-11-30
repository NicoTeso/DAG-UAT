@isTest
public class CustomerLifetimeValueBatch_Test {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        ApiConnect.activaApiConnect();

        Account acc = CreaObjetos.creaCuentaPersonal('CaseTest', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.OtherEmail__pc = 'pruebaemail@test.com';
        acc.Phone ='999999999';
        acc.PersonMobilePhone = '699999999';
        insert acc;

        Customer_Lifetime_Value__c clv = new Customer_Lifetime_Value__c();
        clv.Account__c = acc.id; 
        clv.clv__c = 12.45;
        clv.prob_churn__c = 34;
        clv.average_owner_vehicle__c = 9;
        insert clv;

        Account acc1 = CreaObjetos.creaCuentaPersonal('Otra Cuenta', 'Personalclv');
        acc1.PersonEmail = 'pruebaotracuenta@test.com';
        acc1.OtherEmail__pc = 'pruebaotracuenta1@test.com';
        acc1.Phone ='934563211';
        acc1.PersonMobilePhone = '688776633';
        insert acc1;
    }
    
    @isTest
    static void batchTest() {
//        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutCLVMock());
        
        Test.startTest();
        Database.executeBatch(new CustomerLifetimeValueBatch('1'));
        Test.stopTest();
    }
    
    @isTest
    static void batchFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        
        Test.startTest();
        Database.executeBatch(new CustomerLifetimeValueBatch('1'));
        Test.stopTest();
      
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        CustomerLifetimeValueBatch sch = new CustomerLifetimeValueBatch('1');
        String chron = '0 0 1 * * ?';
        system.schedule('Test for clv batch', chron, sch);
		Test.stopTest();
	}

}