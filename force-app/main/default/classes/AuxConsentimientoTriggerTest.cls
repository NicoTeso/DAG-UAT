@isTest
public class AuxConsentimientoTriggerTest {

    @testSetup static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();        
    }
    
    @isTest static void AuxConsentimientoCallTest(){
         String documento = '11111111X';
        String companyId = 'idCompany1';
        String customerId ='1';
        Concesionario__c cons = CreaObjetos.creaConcesionario(companyId);
        insert cons;
        Account cliente = CreaObjetos.creaCuentaPersonal('Prueba', 'lastname');
        insert cliente;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id,cons.Id,customerId, companyId);
        insert cConcesionario;
        
    	AuxConsentimiento__c auxiliar = new AuxConsentimiento__c();
        auxiliar.companyId__c = companyId;
        auxiliar.CustomerId__c = customerId;
        auxiliar.ContactChannel__c='Call';
        auxiliar.Contact__c = 'Andres 999999999';
        auxiliar.AfterSales__c='Allow';
        auxiliar.CustomerSatisfaction__c ='Allow';
        auxiliar.EventInvitation__c='Allow';
        auxiliar.MarketResearch__c='Allow';
        auxiliar.ProductSale__c='Allow';
        auxiliar.ResponseDate__c= Datetime.now();
        
        Test.startTest();
        insert auxiliar;
        test.stopTest();
        
    }
    
     @isTest static void AuxConsentimientoCallMovilTest(){
         String documento = '11111111X';
        String companyId = 'idCompany1';
        String customerId ='1';
        Concesionario__c cons = CreaObjetos.creaConcesionario(companyId);
        insert cons;
        Account cliente = CreaObjetos.creaCuentaPersonal('Prueba', 'lastname');
        insert cliente;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id,cons.Id,customerId, companyId);
        insert cConcesionario;
        
    	AuxConsentimiento__c auxiliar = new AuxConsentimiento__c();
        auxiliar.companyId__c = companyId;
        auxiliar.CustomerId__c = customerId;
        auxiliar.ContactChannel__c='Call';
        auxiliar.Contact__c = 'Andres 666666666';
        auxiliar.AfterSales__c='Allow';
        auxiliar.CustomerSatisfaction__c ='Allow';
        auxiliar.EventInvitation__c='Allow';
        auxiliar.MarketResearch__c='Allow';
        auxiliar.ProductSale__c='Allow';
        auxiliar.ResponseDate__c= Datetime.now();
        
        Test.startTest();
        insert auxiliar;
        test.stopTest();
        
    }
   
    @isTest static void AuxConsentimientoSMSTest(){
         String documento = '11111111X';
        String companyId = 'idCompany1';
        String customerId ='1';
        Concesionario__c cons = CreaObjetos.creaConcesionario(companyId);
        insert cons;
        Account cliente = CreaObjetos.creaCuentaPersonal('Prueba', 'lastname');
        insert cliente;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id,cons.Id,customerId, companyId);
        insert cConcesionario;
        
    	AuxConsentimiento__c auxiliar = new AuxConsentimiento__c();
        auxiliar.companyId__c = companyId;
        auxiliar.CustomerId__c = customerId;
        auxiliar.ContactChannel__c='SMS';
        auxiliar.Contact__c = 'Andres 666666666';
        auxiliar.AfterSales__c='Allow';
        auxiliar.CustomerSatisfaction__c ='Allow';
        auxiliar.EventInvitation__c='Allow';
        auxiliar.MarketResearch__c='Allow';
        auxiliar.ProductSale__c='Allow';
        auxiliar.ResponseDate__c= Datetime.now();
        
        Test.startTest();
        insert auxiliar;
        test.stopTest();
        
    }
    
    @isTest static void AuxConsentimientoEmailTest(){
         String documento = '11111111X';
        String companyId = 'idCompany1';
        String customerId ='1';
        Concesionario__c cons = CreaObjetos.creaConcesionario(companyId);
        insert cons;
        Account cliente = CreaObjetos.creaCuentaPersonal('Prueba', 'lastname');
        insert cliente;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id,cons.Id,customerId, companyId);
        insert cConcesionario;
        
    	AuxConsentimiento__c auxiliar = new AuxConsentimiento__c();
        auxiliar.companyId__c = companyId;
        auxiliar.CustomerId__c = customerId;
        auxiliar.ContactChannel__c='Email';
        auxiliar.Contact__c = 'Prueba@prueba.com';
        auxiliar.AfterSales__c='Allow';
        auxiliar.CustomerSatisfaction__c ='Allow';
        auxiliar.EventInvitation__c='Allow';
        auxiliar.MarketResearch__c='Allow';
        auxiliar.ProductSale__c='Allow';
        auxiliar.ResponseDate__c= Datetime.now();
        
        Test.startTest();
        insert auxiliar;
        test.stopTest();
        
    }
    
}