@isTest
public class SalesProcessApiRestController_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
	 
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        concess.Domicilio__c = 'Test domicilio';
        insert concess;
        
        Account cli =  CreaObjetos.creaCuentaPersonal('nombre', 'apellido');
        insert cli;
        
        AuxAccount__c auxiliar =  new AuxAccount__c();
        auxiliar.birthdate__c = Date.today();
        auxiliar.companyId__c ='999';
        auxiliar.taxId_number_nuevo_txt__c='11111111X';
        auxiliar.taxId_documentType__c ='VATId';
        auxiliar.countryIso31661__c='ES';
        auxiliar.customerId__c='cli02';
        auxiliar.External_Id__c ='cli02/999';
        auxiliar.Delivering_addresses_city__c='Madrid';
        auxiliar.Delivering_addresses_countryIso31661__c='ES';
        auxiliar.Delivering_addresses_department__c='Madrid';
        auxiliar.Delivering_addresses_id__c='idAdrress1';
        auxiliar.Delivering_addresses_number__c ='17';
        auxiliar.Delivering_addresses_postalCode__c='28041';
        auxiliar.Delivering_addresses_street__c = 'Calle 1';
        auxiliar.duplicado__c='1';
        auxiliar.economicSectorId__c='idEconomic';
        auxiliar.Email__c ='prueba@emailPrueba.com';
        auxiliar.ID_Email__c='emailId1';
        auxiliar.firstSurname__c='pruebaFirstSurname';
        auxiliar.fiscalName__c ='PruebaFiscal';
        auxiliar.secondSurname__c= 'PruebaSecondSurname';
        auxiliar.Phone__c ='999999999';
        auxiliar.ID_Phone__c ='idPhone1';
        auxiliar.OtherPhone__c ='919999999';
        auxiliar.OtherPhone__c ='idOtherPhone1';
        auxiliar.Mobile__c ='666666666';
        auxiliar.ID_Mobile__c ='idMobile1';
        auxiliar.OtherMobile__c ='696666666';
        auxiliar.ID_OtherMobile__c = 'idOtherMobile1';
        auxiliar.OtherEmail__c ='OtherEmail@PruebaEmail.com';
        auxiliar.ID_OtherEmail__c ='idOtherEmail1';
        auxiliar.Invoicing_addresses_city__c='Madrid';
        auxiliar.Invoicing_addresses_countryIso31661__c='ES';
        auxiliar.Invoicing_addresses_id__c='idInvoicing';
        auxiliar.Invoicing_addresses_number__c='17';
        auxiliar.Invoicing_addresses_postalCode__c='28041';
        auxiliar.Invoicing_addresses_street__c='calle 2';
        auxiliar.Invoicing_addresses_region__c='Madrid';
        auxiliar.modificationDate__c =Datetime.now();
        auxiliar.personType__c='NaturalPerson';
        insert auxiliar;
        
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id,'c01','999');
        insert cliConcess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
        
         Opportunity opp = CreaObjetos.creaOportunidad(cli.Id, concess.Id, center.Id, 'sp01');
        opp.Name = 'opp01';
        insert opp;
        
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN02');
        dOferta.Modalidad__c = 'NewVehicle';
        Detalle_Oferta__c dOferta1 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN03');
        dOferta1.Modalidad__c = 'NewVehicle';
        Detalle_Oferta__c dOferta2 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN04');
        dOferta2.Modalidad__c = 'NewVehicle';
        List<Detalle_Oferta__c> detalleOfertas = new List<Detalle_Oferta__c>{dOferta,dOferta1,dOferta2}; 
        insert detalleOfertas;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 96300;
        veh_audi.kms_diarios__c = 100;
        veh_audi.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        veh_audi.Letra_Motor__c = 'CHJB';
       
        Vehiculo__c veh_skoda = CreaObjetos.creaVehiculo('VIN03', null, 'skoda', 'XXXX2');
        veh_skoda.ModeloString__c = 'SK-01';
        veh_skoda.kms__c = 96300;
        veh_skoda.kms_diarios__c = 100;
        veh_skoda.Fecha_actualizacion_kms__c = Datetime.now();
        veh_skoda.Fecha_fin_garantia__c = Datetime.now();
        veh_skoda.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_skoda.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_skoda.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        veh_skoda.Letra_Motor__c = 'CHJB';
        
        Vehiculo__c veh_hyundai = CreaObjetos.creaVehiculo('VIN04', null, 'HYUNDAI', 'XXXX3');
        veh_hyundai.ModeloString__c = 'HY-01';
        veh_hyundai.kms__c = 96300;
        veh_hyundai.kms_diarios__c = 100;
        veh_hyundai.Fecha_actualizacion_kms__c = Datetime.now();
        veh_hyundai.Fecha_fin_garantia__c = Datetime.now();
        veh_hyundai.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_hyundai.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_hyundai.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        veh_hyundai.Letra_Motor__c = 'CHJB';
        
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi,veh_skoda,veh_hyundai};
        insert lstVehicles;
        
        List<Detalle_venta__c> lstSaleDetails = new List<Detalle_venta__c>();
        Detalle_venta__c saleDetail_audi = CreaObjetos.creaDetalleVenta(concess.Id, center.Id, veh_audi.Id);
        saleDetail_audi.External_Id__c = 'sp01/VIN02';
        insert saleDetail_audi;
        /*lstSaleDetails.add(saleDetail_audi);
        Detalle_venta__c saleDetail_skoda = new Detalle_venta__c();
        saleDetail_skoda.Vehiculo__c = veh_skoda.Id;
        saleDetail_skoda.Comprador__c = cli.Id;
        saleDetail_skoda.Concesionario__c = concess.Id;
        saleDetail_skoda.Centro__c = center.Id;
        saleDetail_skoda.External_Id__c = 'sp03/VIN03';
        lstSaleDetails.add(saleDetail_skoda);
        Detalle_venta__c saleDetail_hyundai = new Detalle_venta__c();
        saleDetail_hyundai.Vehiculo__c = veh_hyundai.Id;
        saleDetail_hyundai.Comprador__c = cli.Id;
        saleDetail_hyundai.Concesionario__c = concess.Id;
        saleDetail_hyundai.Centro__c = center.Id;
        saleDetail_hyundai.External_Id__c = 'sp03/VIN04';
        lstSaleDetails.add(saleDetail_hyundai);
        insert lstSaleDetails;*/
        Gestion_encuesta__c manageSurvey_audi = CreaObjetos.creaGestionEncuesta('AUDI', center.Id, concess.Id);
        manageSurvey_audi.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_audi.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_audi.Dias_validez__c = 40.0;
        
        Gestion_encuesta__c manageSurvey_skoda = CreaObjetos.creaGestionEncuesta('SKODA', center.Id, concess.Id);
        manageSurvey_skoda.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_skoda.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_skoda.Dias_validez__c = 40.0;
        
        Gestion_encuesta__c manageSurvey_hyundai = CreaObjetos.creaGestionEncuesta('HYUNDAI', center.Id, concess.Id);
        manageSurvey_hyundai.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_hyundai.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_hyundai.Dias_validez__c = 40.0;
        
        List<Gestion_encuesta__c> lstManageSurveys = new List<Gestion_encuesta__c>{manageSurvey_audi, manageSurvey_skoda, manageSurvey_hyundai};
        insert lstManageSurveys;
		
    }
    
    @isTest
    static void NewVehicleTest() {

        Account cuenta = [SELECT Id FROM Account LIMIT 1];
        
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        CreaObjetos.creaCampaign();
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Oferta';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = '+34657657657';
        caso.SuppliedEmail = 'prueba@prueba.es';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '2';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.PayLoad.saleCompletedDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp01';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.salesForceId = caso.id;
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.engine = '';
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        SalesProcessApiRestModel.Equipment equip2 = new SalesProcessApiRestModel.Equipment();
        equip2.code = '002';
        equip2.description = 'Cuero rojo';
        offer.vehicle.equipments.add(equip2);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        SalesProcessApiRestModel.Accessory access2 = new SalesProcessApiRestModel.Accessory();
        access2.code = '002';
        access2.description = 'Manos libres';
        offer.vehicle.accessories.add(access2);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        SalesProcessApiRestModel.DetailCode dc2 = new SalesProcessApiRestModel.DetailCode();
        dc2.code = '3BE';
        dc2.description = 'Otro detalle';
        offerService.serviceDetails.add(dc2);
        offer.vehicle.services.add(offerService);
        offer.vehicle.deliveryDate = '';
        offer.vehicle.transmission = '';
        offer.vehicle.engineLetter = '';
        offer.vehicle.engineNumber = '';
        offer.vehicle.engineCode = '';
        offer.vehicle.registrationPlate = '';
        offer.vehicle.registrationPlateDate = '';
        offer.vehicle.kms = 0;
        offer.vehicle.warrantyStartDate = '';
        offer.vehicle.warrantyEndDate = '';
        offer.vehicle.warrantyExtensionStartDate = '';
        offer.vehicle.warrantyExtensionEndDate = '';
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.tariffDescription = 'Test tariff';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.rejectionDate = '2020-02-02T09:00:00Z';
        req.payload.rejectionReasonCode = '1';
        
        req.payload.cancellationDate = '2020-02-02T09:00:00Z';
        req.payload.cancellationReasonCode='1';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN01';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'HYUNDAI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.usedVehicleWarrantyStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.usedVehicleWarrantyEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.technicalVehicleClassification = 'Prueba1';
        req.payload.gearBox='1';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.completedProcessSales(req);
        SalesProcessApiRestController.failureProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        SalesProcessApiRestController.cancelCompletedProcessSales(req);
        SalesProcessApiRestController.cancelProcessSalesCancelled(req);
        Test.stopTest();
    }
    
    @isTest
    static void NewSalesProcessTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '2';
        req.payload.salesmanName = 'Luis Per Per';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.salesmanMobile = '600123456';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.PayLoad.saleCompletedDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp01';
        req.payload.customerId = 'cli02';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.engine = '';
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        SalesProcessApiRestModel.Equipment equip2 = new SalesProcessApiRestModel.Equipment();
        equip2.code = '002';
        equip2.description = 'Cuero rojo';
        offer.vehicle.equipments.add(equip2);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        SalesProcessApiRestModel.Accessory access2 = new SalesProcessApiRestModel.Accessory();
        access2.code = '002';
        access2.description = 'Manos libres';
        offer.vehicle.accessories.add(access2);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        SalesProcessApiRestModel.DetailCode dc2 = new SalesProcessApiRestModel.DetailCode();
        dc2.code = '3BE';
        dc2.description = 'Otro detalle';
        offerService.serviceDetails.add(dc2);
        offer.vehicle.services.add(offerService);
        offer.vehicle.deliveryDate = '';
        offer.vehicle.transmission = '';
        offer.vehicle.engineLetter = '';
        offer.vehicle.engineNumber = '';
        offer.vehicle.engineCode = '';
        offer.vehicle.registrationPlate = '';
        offer.vehicle.registrationPlateDate = '';
        offer.vehicle.kms = 0;
        offer.vehicle.warrantyStartDate = '';
        offer.vehicle.warrantyEndDate = '';
        offer.vehicle.warrantyExtensionStartDate = '';
        offer.vehicle.warrantyExtensionEndDate = '';
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.tariffDescription = 'Test tariff';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.rejectionDate = '2020-02-02T09:00:00Z';
        req.payload.rejectionReasonCode = '1';
        
        req.payload.cancellationDate = '2020-02-02T09:00:00Z';
        req.payload.cancellationReasonCode='1';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN01';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'HYUNDAI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.usedVehicleWarrantyStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.usedVehicleWarrantyEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.technicalVehicleClassification = 'Prueba1';
        req.payload.gearBox='1';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.completedProcessSales(req);
        SalesProcessApiRestController.failureProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        SalesProcessApiRestController.cancelCompletedProcessSales(req);
        SalesProcessApiRestController.cancelProcessSalesCancelled(req);
        SalesProcessApiRestController.SalesProcessAnonymized(req);
        Test.stopTest();
    }
    
    @isTest
    static void OldVehicleTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp01';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.saleCompletedDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.completedProcessSales(req);
        req.payload.salesmanEmail = 'foo3@bar.com';
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        SalesProcessApiRestController.cancelCompletedProcessSales(req);
        SalesProcessApiRestController.SalesProcessAnonymized(req);
        
        Test.stopTest();
    }

    @isTest
    static void ExceptionSalesProcessIdTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.failureProcessSales(req);
        SalesProcessApiRestController.completedProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        SalesProcessApiRestController.SalesProcessAnonymized(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionCenterTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.eventType = '';
        req.payload.salesProcessId = 'sp01';
        RestRequest req1 = new RestRequest(); 
        RestContext.request = req1;

        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
//        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionSalesmanTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.centerCode = '5';
        req.payload.salesProcessId = 'sp01';
        req.payload.salesmanEmail = '';
        
        Test.startTest();
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionClienteConcesionarioTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesProcessId = 'sp01';
        req.payload.salesType = '1';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.customerId = 'c02';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c03';
        req.payload.vin = 'VIN01';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionOpportunityTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.centerCode = '5';
        req.payload.salesProcessId = 'sp03';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.failureProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionDetalleOfertaTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '1';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp01';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE ID_Oportunidad_DMS__c = 'sp01' LIMIT 1];
        
        Detalle_Oferta__c offer = new Detalle_Oferta__c();
        offer.Opportunity__c = opp.Id;
        
        Test.startTest();
        insert offer;
        
        SalesProcessApiRestController.upsertProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionBrandTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '1';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp02';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.vin = 'VIN01';
        req.payload.brand = '';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void ExceptionModelTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesProcessId = 'sp01';
        req.payload.salesType = '1';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp02';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'HYUNDAI';
        offer.vehicle.brandCode = 'HYUNDAI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.vin = 'VIN01';
        req.payload.brand = 'HYUNDAI';
        req.payload.model = '';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyNoPersonalTest() {
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyNoGestionEncuestaTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        Gestion_encuesta__c manageSurvey = [SELECT Id FROM Gestion_encuesta__c LIMIT 1];
        delete manageSurvey;
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyNoGestionEncuesta2Test() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        Gestion_encuesta__c manageSurvey = [SELECT Id FROM Gestion_encuesta__c LIMIT 1];
        manageSurvey.Activa__c = false;
        manageSurvey.Centro_encuesta__c = null;
        update manageSurvey;
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyAlreadyExistsTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        Encuesta__c survey = new Encuesta__c();
        survey.Cliente__c = cli.Id;
        survey.vin__c = 'VIN02';
        survey.Resultado__c = 'Si';
        insert survey;
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyNoConsentsTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyCEMSuccessEmailMobileTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.PersonEmail = 'test@personal.com';
        cli.PersonMobilePhone = '678678678';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :cli.Id LIMIT 1];
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(cli.PersonEmail, con.Id, Label.channelEmail);
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(cli.PersonMobilePhone, con.Id, Label.channelMobile);
        lstConsents.add(consentMobile);
        insert lstConsents;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyCEMSuccessEmailTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.PersonEmail = 'test@personal.com';
        cli.PersonMobilePhone = '678678678';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :cli.Id LIMIT 1];
        
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(cli.PersonEmail, con.Id, Label.channelEmail);
        insert consentPersonEmail;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel= '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyCEMSuccessMobileTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.PersonEmail = 'test@personal.com';
        cli.PersonMobilePhone = '678678678';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :cli.Id LIMIT 1];
        
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(cli.PersonMobilePhone, con.Id, Label.channelMobile);
        insert consentMobile;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN02';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN02';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'AUDI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyExternaSuccessMobileTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.PersonEmail = 'test@personal.com';
        cli.PersonMobilePhone = '678678678';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :cli.Id LIMIT 1];
        
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(cli.PersonMobilePhone, con.Id, Label.channelMobile);
        insert consentMobile;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN03';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'SKODA';
        offer.vehicle.brandCode = 'SKODA';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN03';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'SKODA';
        req.payload.model = 'SK-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
    
    @isTest
    static void SurveyTelefonicaSuccessPhoneTest() {
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.PersonEmail = 'test@personal.com';
        cli.Phone = '917524371';
        cli.PersonMobilePhone = '678678678';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :cli.Id LIMIT 1];
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPhone = CreaObjetos.creaConsentimiento(cli.Phone, con.Id, Label.channelPhone);
        lstConsents.add(consentPhone);
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(cli.PersonMobilePhone, con.Id, Label.channelMobile);
        lstConsents.add(consentMobile);
        insert lstConsents;
        
        Cliente_Concesionario__c cliConcess = [SELECT Id, Cliente__c FROM Cliente_Concesionario__c LIMIT 1];
        cliConcess.Cliente__c = cli.Id;
        update cliConcess;
        
        
        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '13';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp03';
        req.payload.customerId = 'c01';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN04';
        offer.vehicle.modality = 'NewVehicle';
        offer.vehicle.brand = 'HYUNDAI';
        offer.vehicle.brandCode = 'HYUNDAI';
        offer.vehicle.model = 'HY-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        offer.vehicle.services.add(offerService);
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN04';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'HYUNDAI';
        req.payload.model = 'HY-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        SalesProcessApiRestController.upsertProcessSales(req);
        SalesProcessApiRestController.successProcessSales(req);
        SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
        Test.stopTest();
    }
	
    @isTest
    static void SalesmanOwnerChanged1Test() {
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo2@bar.com';
        salesman.Phone__c = '+34600212321';
        insert salesman;

        SalesProcessApiRestModel req = new SalesProcessApiRestModel();
        req.payLoad = new SalesProcessApiRestModel.Payload();
        req.payload.companyCode = '999';
        req.payload.centerCode = '5';
        req.payload.salesType = '2';
        req.payload.salesmanName = 'Luis Per Per';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.salesmanMobile = '600123456';
        req.payload.creationDate = '2020-01-01T09:00:00Z';
        req.PayLoad.saleCompletedDate = '2020-01-01T09:00:00Z';
        req.payload.salesProcessId = 'sp01';
        req.payload.customerId = 'cli02';
        req.payload.sourceCode = '10';
        req.payload.motiveCode = '2';
        
        req.payload.expirationDays = 0;
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.offers = new List<SalesProcessApiRestModel.Offer>();
        SalesProcessApiRestModel.Offer offer = new SalesProcessApiRestModel.Offer();
        offer.vehicle = new SalesProcessApiRestModel.ProductVehicle();
        offer.vehicle.vin = 'VIN01';
        offer.vehicle.brand = 'AUDI';
        offer.vehicle.brandCode = 'AUDI';
        offer.vehicle.model = 'AU-01';
        offer.vehicle.modelYear = '2020';
        offer.vehicle.extendedModelVersionKey = '';
        offer.vehicle.fuelCode = '1';
        offer.vehicle.power = 150;
        offer.vehicle.engineCapacity = 1500;
        offer.vehicle.engine = '';
        offer.vehicle.colorCode = 'CO';
        offer.vehicle.interiorCode = 'IN';
        offer.vehicle.equipments = new List<SalesProcessApiRestModel.Equipment>();
        SalesProcessApiRestModel.Equipment equip = new SalesProcessApiRestModel.Equipment();
        equip.code = '001';
        equip.description = 'Cuero negro';
        offer.vehicle.equipments.add(equip);
        SalesProcessApiRestModel.Equipment equip2 = new SalesProcessApiRestModel.Equipment();
        equip2.code = '002';
        equip2.description = 'Cuero rojo';
        offer.vehicle.equipments.add(equip2);
        offer.vehicle.accessories = new List<SalesProcessApiRestModel.Accessory>();
        SalesProcessApiRestModel.Accessory access = new SalesProcessApiRestModel.Accessory();
        access.code = '001';
        access.description = 'Bola Remolque';
        offer.vehicle.accessories.add(access);
        SalesProcessApiRestModel.Accessory access2 = new SalesProcessApiRestModel.Accessory();
        access2.code = '002';
        access2.description = 'Manos libres';
        offer.vehicle.accessories.add(access2);
        offer.vehicle.services = new List<SalesProcessApiRestModel.Service>();
        SalesProcessApiRestModel.Service offerService = new SalesProcessApiRestModel.Service();
        offerService.code = '1DS';
        offerService.description = 'Matriculación';
        offerService.serviceDetails = new List<SalesProcessApiRestModel.DetailCode>();
        SalesProcessApiRestModel.DetailCode dc = new SalesProcessApiRestModel.DetailCode();
        dc.code = '2AD';
        dc.description = 'Impuesto de matriculación';
        offerService.serviceDetails.add(dc);
        SalesProcessApiRestModel.DetailCode dc2 = new SalesProcessApiRestModel.DetailCode();
        dc2.code = '3BE';
        dc2.description = 'Otro detalle';
        offerService.serviceDetails.add(dc2);
        offer.vehicle.services.add(offerService);
        offer.vehicle.deliveryDate = '';
        offer.vehicle.transmission = '';
        offer.vehicle.engineLetter = '';
        offer.vehicle.engineNumber = '';
        offer.vehicle.engineCode = '';
        offer.vehicle.registrationPlate = '';
        offer.vehicle.registrationPlateDate = '';
        offer.vehicle.kms = 0;
        offer.vehicle.warrantyStartDate = '';
        offer.vehicle.warrantyEndDate = '';
        offer.vehicle.warrantyExtensionStartDate = '';
        offer.vehicle.warrantyExtensionEndDate = '';
        offer.economicSummary = new SalesProcessApiRestModel.EconomicSummary();
        offer.economicSummary.currencyType = 'EUR';
        offer.economicSummary.price = 20311.57;
        offer.economicSummary.discount = 711.57;
        offer.economicSummary.total = 20000.00;
        offer.financings = new List<SalesProcessApiRestModel.Financing>();
        SalesProcessApiRestModel.Financing fin = new SalesProcessApiRestModel.Financing();
        fin.financialCompanyCode = 'A123456789';
        fin.tariffCode = '8PL';
        fin.tariffDescription = 'Test tariff';
        fin.currencyType = 'EUR';
        fin.amount = 15000.00;
        offer.financings.add(fin);
        req.payload.offers.add(offer);
        
        req.payload.successDate = '2020-02-02T09:00:00Z';
        
        req.payload.rejectionDate = '2020-02-02T09:00:00Z';
        req.payload.rejectionReasonCode = '1';
        
        req.payload.cancellationDate = '2020-02-02T09:00:00Z';
        req.payload.cancellationReasonCode='1';
        
        req.payload.customerOwnerId = 'c01';
        req.payload.vin = 'VIN01';
        req.payload.deliveryDate = '2020-02-01T09:00:00Z';
        req.payload.brand = 'HYUNDAI';
        req.payload.model = 'AU-01';
        req.payload.modelYear = '2020';
        req.payload.version = '';
        req.payload.fuel = '1';
        req.payload.power = 150;
        req.payload.engineCapacity = 1500;
        req.payload.colorCode = 'CO';
        req.payload.interiorCode = 'IN';
        req.payload.kms = 10;
        req.payload.warrantyEndDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.warrantyExtensionEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.usedVehicleWarrantyStartDate = Datetime.now().addYears(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.usedVehicleWarrantyEndDate = Datetime.now().addYears(3).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        req.payload.technicalVehicleClassification = 'Prueba1';
        req.payload.gearBox='1';
        
        Test.startTest();
        SalesProcessApiRestController.createProcessSales(req);
        req.payload.salesmanName = 'Andrea Per Per';
        req.payload.salesmanEmail = 'foo3@bar.com';
        req.payload.salesmanMobile = '600123486';
        SalesProcessApiRestController.SalesmanOwnerChanged(req);
        req.payload.salesmanName = 'Luisa Per Per';
        req.payload.salesmanEmail = 'foo2@bar.com';
        req.payload.salesmanMobile = '608123486';
        SalesProcessApiRestController.SalesmanOwnerChanged(req);
        Test.stopTest();
    }
}