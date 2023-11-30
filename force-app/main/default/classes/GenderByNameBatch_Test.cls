@isTest
public class GenderByNameBatch_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        /* List<Account> accountList = new List<Account>();
		accountList.add(CreaObjetos.creaCuentaPersonal('nombre compuesto', 'apellidos'));
        accountList.add(CreaObjetos.creaCuentaPersonal('testeo', 'apellidos'));
        insert accountList; */

        ApiConnect__c api = new ApiConnect__c(ApiGetGenderByNameHost__c = 'https://api.genderize.io/?');
        insert api;

        Genero_de_Nombre__c gn = new Genero_de_Nombre__c(
            Nombre__c = 'testeo',
            Codigo_Pais__c = 'ES',
            Genero_Asignado__c = 'Male'
        );
        insert gn;
    }
    
    @isTest
    static void batchTestExisting() {
        Test.startTest();
        Genero_de_Nombre__c gn = [SELECT Id, Nombre_Pais__c FROM Genero_de_Nombre__c LIMIT 1];
        insert CreaObjetos.creaCuentaPersonal('testeo', 'apellidos');
        Database.executeBatch(new GenderByNameBatch(null, new Set<String>{gn.Nombre_Pais__c}));
        Test.stopTest();
    }

    @isTest
    static void batchTestNew() {
        Test.startTest();
        insert CreaObjetos.creaCuentaPersonal('nombre compuesto', 'apellidos');
        Database.executeBatch(new GenderByNameBatch());
        Test.stopTest();
    }

    @isTest
    static void batchTestNewKO() {
        Test.startTest();
        Account acc = CreaObjetos.creaCuentaPersonal('nombre compuesto', 'apellidos');
        acc.PersonMobilePhone = '666666666';
        insert acc;
        Database.executeBatch(new GenderByNameBatch());
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        Genero_de_Nombre__c gn = [SELECT Id, Nombre_Pais__c FROM Genero_de_Nombre__c LIMIT 1];
        GenderByNameBatch sch = new GenderByNameBatch(null, new Set<String>{gn.Nombre_Pais__c});
        String chron = '0 0 1 * * ?';
        system.schedule('Test for gender batch', chron, sch);
		Test.stopTest();
	}
}