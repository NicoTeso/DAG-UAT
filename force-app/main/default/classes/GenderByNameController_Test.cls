@isTest
public class GenderByNameController_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		Account a = CreaObjetos.creaCuentaPersonal('test', 'apellidos');
        a.Cliente_Propio__c = true;
        a.Fecha_Limite_Cliente_Propio__c = Date.today()-1;
        insert a;

        ApiConnect__c api = new ApiConnect__c(ApiGetGenderByNameHost__c = 'https://api.genderize.io/?');
        insert api;
    }
    
    @isTest
    static void testOK() {
        Test.startTest();
        Account a = [SELECT Id, FirstName FROM Account LIMIT 1];
        GenderByNameModel model = GenderByNameController.getGenderByName(a.FirstName);
        System.debug('GenderByNameController_Test.testOK model ' + model);
        System.assert(model != null);
        Test.stopTest();
    }

    @isTest
    static void testKO() {
        Test.startTest();
        GenderByNameModel model = GenderByNameController.getGenderByName(null);
        System.assert(model == null);
        Test.stopTest();
    }

    @isTest
    static void testModel() {
        Test.startTest();
        GenderByNameModel model = new GenderByNameModel();
        model.count = '100';
        model.country_id = 'ES';
        model.gender = 'Female';
        model.name = 'maria';
        model.probability = '0.99';
        model.remaining = 999;
        model.status = 'OK';
        model.statusCode = 200;
        System.assert(model != null);
        Test.stopTest();
    }
}