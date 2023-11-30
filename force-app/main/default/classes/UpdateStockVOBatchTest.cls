@isTest
public class UpdateStockVOBatchTest {
    
    @testSetup
    static void setup() {
//        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();

        RelacionesVO__c RelacionesVO = new RelacionesVO__c();
		RelacionesVO.Decremento_Precio__c = 20;
        RelacionesVO.Grupo_Modelo_1__c = 'A1;AB1';
        RelacionesVO.Grupo_Modelo_2__c = 'I10';
        RelacionesVO.Grupo_Modelo_3__c = 'A4';
        RelacionesVO.Grupo_Modelo_4__c = 'R8';
        RelacionesVO.Grupo_Modelo_5__c = 'A3';
        RelacionesVO.Grupo_Modelo_6__c = 'A5';
        RelacionesVO.Grupo_Modelo_7__c = 'H10';
        RelacionesVO.Grupo_Modelo_8__c = 'H11';
        RelacionesVO.Incremento_Precio__c = 20;
        RelacionesVO.Importe_Desde__c = 900;
        RelacionesVO.Importe_Hasta__c = 1100;
        insert RelacionesVO;
        
        List<Concesionario__c> listConcesionarios = new List<Concesionario__c>();
        Concesionario__c conce = CreaObjetos.creaConcesionario('20');
        //insert conce;
        listConcesionarios.add(conce);
        Concesionario__c conce2 = CreaObjetos.creaConcesionario('21');
        conce2.Integrado_con_SIMA__c = true;
        listConcesionarios.add(conce2);
        insert listConcesionarios;
        
        Account acc = CreaObjetos.creaCuentaPersonal('CaseTest', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.OtherEmail__pc = 'pruebaemail@test.com';
        acc.Phone ='999999999';
        acc.PersonMobilePhone = '699999999';
        insert acc;
        
        Centro__c center = new Centro__c();
        center.Name = 'Centro01';
        center.Concesionario__c = conce.Id;
        center.Gestiona_LEAD__c = true;
        insert center;

        Centro__c center02 = new Centro__c();
        center02.Name = 'Centro02';
        center02.Concesionario__c = conce2.Id;
        center02.Gestiona_LEAD__c = true;
        insert center02;

        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        
        Vehiculo__c hyundai = new Vehiculo__c();
        hyundai.VIN__c = 'VIN04';
        hyundai.Concesionario__c = conce.Id;
        hyundai.MarcaString__c = 'HYUNDAI';
        hyundai.ModeloString__c = 'I10';
        hyundai.kms__c = 0;
        hyundai.Fecha_cumpleanos__c = Date.today().addDays(-1);
        hyundai.Numero_de_cumpleanos__c = 4;
        hyundai.Fecha_fin_garantia__c = Datetime.now();
        hyundai.Fecha_inicio_extension_garantia__c = Datetime.now();
        hyundai.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        hyundai.Actualizar_Sima__c = true;
        hyundai.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        hyundai.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        hyundai.Precio__c = 1000;
        Hyundai.Activo_stock_VO__c = true;
        Hyundai.Fecha_entrada_stock_VO__c = date.today().addDays(-3);
        insert hyundai;

        Vehiculo__c audi = new Vehiculo__c();
        audi.VIN__c = 'VIN05';
        audi.Concesionario__c = conce.Id;
        audi.MarcaString__c = 'AUDI';
        audi.ModeloString__c = 'A1';
        audi.kms__c = 0;
        audi.Fecha_cumpleanos__c = Date.today().addDays(-1);
        audi.Numero_de_cumpleanos__c = 4;
        audi.Fecha_fin_garantia__c = Datetime.now();
        audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        audi.Actualizar_Sima__c = true;
        audi.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        audi.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        audi.Precio__c = 1000;
        audi.Activo_stock_VO__c = true;
        audi.Fecha_entrada_stock_VO__c = date.today().addDays(-3);
        insert audi;

        Vehiculo__c audi0 = new Vehiculo__c();
        audi0.VIN__c = 'VIN055';
        audi0.Concesionario__c = conce.Id;
        audi0.MarcaString__c = 'AUDI';
        audi0.ModeloString__c = 'AB1';
        audi0.kms__c = 0;
        audi0.Fecha_cumpleanos__c = Date.today().addDays(-1);
        audi0.Numero_de_cumpleanos__c = 4;
        audi0.Fecha_fin_garantia__c = Datetime.now();
        audi0.Fecha_inicio_extension_garantia__c = Datetime.now();
        audi0.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        audi0.Actualizar_Sima__c = true;
        audi0.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        audi0.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        audi0.Activo_stock_VO__c = false;
        audi0.Fecha_salida_stock_VO__c = date.today().addDays(-3);
        insert audi0;

        Vehiculo__c audi1 = new Vehiculo__c();
        audi1.VIN__c = 'VIN056';
        audi1.Concesionario__c = conce.Id;
        audi1.MarcaString__c = 'AUDI';
        audi1.ModeloString__c = 'AB1';
        audi1.kms__c = 0;
        audi1.Fecha_cumpleanos__c = Date.today().addDays(-1);
        audi1.Numero_de_cumpleanos__c = 4;
        audi1.Fecha_fin_garantia__c = Datetime.now();
        audi1.Fecha_inicio_extension_garantia__c = Datetime.now();
        audi1.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        audi1.Actualizar_Sima__c = true;
        audi1.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        audi1.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        audi1.Precio__c = 1000;
        audi1.Activo_stock_VO__c = true;
        audi1.Fecha_entrada_stock_VO__c = date.today().addDays(-3);
        insert audi1;
        
        Vehiculo__c audi2 = new Vehiculo__c();
        audi2.VIN__c = 'VIN06';
        audi2.Concesionario__c = conce.Id;
        audi2.MarcaString__c = 'AUDI';
        audi2.ModeloString__c = 'A1';
        audi2.kms__c = 0;
        audi2.Fecha_cumpleanos__c = Date.today().addDays(-1);
        audi2.Numero_de_cumpleanos__c = 4;
        audi2.Fecha_fin_garantia__c = Datetime.now();
        audi2.Fecha_inicio_extension_garantia__c = Datetime.now();
        audi2.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        audi2.Actualizar_Sima__c = true;
        audi2.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        audi2.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        audi2.Precio__c = 1000;
        audi2.Activo_stock_VO__c = true;
        audi2.Fecha_entrada_stock_VO__c = date.today().addDays(-3);
        insert audi2;

        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'HYUNDAI';
        ca.Origin ='e-commerce';
        ca.Intencion_de_compra__c = 'Financiar';
        ca.Campana__c = camp.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Description = 'trae a un amigo';
        ca.brandVO__c = 'HYUNDAI';
        ca.modelVO__c = 'I10';
        ca.VIN__c = 'VIN04';
        ca.Vehiculo__c = hyundai.id;
        ca.priceInitial__c = 1000;
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca;        

        Case ca0 = new Case();
        ca0.AccountId = acc.Id;
        ca0.Centro__c = center.Id;
        ca0.Marca__c = 'HYUNDAI';
        ca0.Origin ='e-commerce';
        ca0.Intencion_de_compra__c = 'Financiar';
        ca0.Campana__c = camp.Id;
        ca0.SuppliedPhone = '918887765';
        ca0.SuppliedEmail = 'case@test.com';
        ca0.EnvioMulesoft__c = 'OK';
        ca0.Description = 'trae a un amigo';
        ca0.VIN__c = 'VIN04';
        ca0.Vehiculo__c = hyundai.id;
        ca0.priceInitial__c = 1000;
        ca0.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca0;        

        Case ca1 = new Case();
        ca1.AccountId = acc.Id;
        ca1.Centro__c = center.Id;
        ca1.Marca__c = 'HYUNDAI';
        ca1.Origin ='e-commerce';
        ca1.Intencion_de_compra__c = 'Financiar';
        ca1.Campana__c = camp.Id;
        ca1.SuppliedPhone = '918887765';
        ca1.SuppliedEmail = 'case@test.com';
        ca1.EnvioMulesoft__c = 'OK';
        ca1.Description = 'trae a un amigo';
        ca1.brandVO__c = 'HYUNDAI';
        ca1.modelVO__c = 'H11';
        ca1.VIN__c = 'VIN04';
        ca1.Vehiculo__c = hyundai.id;
        ca1.priceInitial__c = 1000;
        ca1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca1;        
        
        Case ca2 = new Case();
        ca2.AccountId = acc.Id;
        ca2.Centro__c = center.Id;
        ca2.Marca__c = 'AUDI';
        ca2.Origin ='e-commerce';
        ca2.Intencion_de_compra__c = 'Financiar';
        ca2.Campana__c = camp.Id;
        ca2.SuppliedPhone = '918887765';
        ca2.SuppliedEmail = 'case@test.com';
        ca2.EnvioMulesoft__c = 'OK';
        ca2.Description = 'trae a un amigo';
        ca2.brandVO__c = 'AUDI';
        ca2.modelVO__c = 'A1';
        ca2.VIN__c = 'VIN05';
        ca2.priceInitial__c = 1000;
        ca2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca2;        

        Case ca2b = new Case();
        ca2b.AccountId = acc.Id;
        ca2b.Centro__c = center.Id;
        ca2b.Marca__c = 'AUDI';
        ca2b.Origin ='e-commerce';
        ca2b.Intencion_de_compra__c = 'Financiar';
        ca2b.Campana__c = camp.Id;
        ca2b.SuppliedPhone = '918887765';
        ca2b.SuppliedEmail = 'case@test.com';
        ca2b.EnvioMulesoft__c = 'OK';
        ca2b.Description = 'trae a un amigo';
        ca2b.brandVO__c = 'AUDI';
        ca2b.modelVO__c = 'A1';
        ca2b.VIN__c = 'VIN055';
        ca2b.priceInitial__c = 1000;
        ca2b.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca2b;        
        
        Case ca3 = new Case();
        ca3.AccountId = acc.Id;
        ca3.Centro__c = center.Id;
        ca3.Marca__c = 'AUDI';
        ca3.Origin ='e-commerce';
        ca3.Intencion_de_compra__c = 'Financiar';
        ca3.Campana__c = camp.Id;
        ca3.SuppliedPhone = '918887765';
        ca3.SuppliedEmail = 'case@test.com';
        ca3.EnvioMulesoft__c = 'OK';
        ca3.Description = 'trae a un amigo';
        ca3.brandVO__c = 'AUDI';
        ca3.modelVO__c = 'A1';
        ca3.priceInitial__c = 1000;
        ca3.VIN__c = 'VIN08';
        ca3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca3;        

        Case ca4 = new Case();
        ca4.AccountId = acc.Id;
        ca4.Centro__c = center.Id;
        ca4.Marca__c = 'AUDI';
        ca4.Origin ='e-commerce';
        ca4.Intencion_de_compra__c = 'Financiar';
        ca4.Campana__c = camp.Id;
        ca4.SuppliedPhone = '918887765';
        ca4.SuppliedEmail = 'case@test.com';
        ca4.EnvioMulesoft__c = 'OK';
        ca4.Description = 'trae a un amigo';
        ca4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert ca4;        
        
    }
    
    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new UpdateStockVOBatch());
        Test.stopTest();

    }

}