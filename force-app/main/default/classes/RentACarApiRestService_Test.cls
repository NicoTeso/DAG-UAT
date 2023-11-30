@isTest
public class RentACarApiRestService_Test {
    
	@testSetup
    static void setup() {
        Concesionario__c concess = new Concesionario__c();
        concess.Id_Concesionario_Sima__c = '41';
        concess.Domicilio__c = 'Test domicilio';
        concess.CIF__c = '123123123';
        concess.Es_propio__c = true;
        insert concess;
        
        Account cli = CreaObjetos.creaCuentaPersonal('CaseTest', 'Personal');
        cli.PersonEmail = 'pruebaotheremail@test.com';
        cli.OtherEmail__pc = 'pruebaemail@test.com';
        cli.Phone ='999999999';
        cli.PersonMobilePhone = '699999999';
        cli.BillingCountry = 'ESPAÑA';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = new Cliente_Concesionario__c();
        cliConcess.Concesionario__c = concess.Id;
        cliConcess.Id_Cliente_DMS__c = '41';
        cliConcess.External_Id__c = '875/41';
        cliConcess.Cliente__c = cli.Id;
        insert cliConcess;

        Account cli1 = CreaObjetos.creaCuentaPersonal('Cliente2', 'Personal2');
        cli1.PersonEmail = 'pruebaotheremail2@test.com';
        cli1.OtherEmail__pc = 'pruebaemail2@test.com';
        cli1.Phone ='999999988';
        cli1.PersonMobilePhone = '688888888';
        cli1.BillingCountry = 'ESPAÑA';
        insert cli1;
        
        Cliente_Concesionario__c cliConcess1 = new Cliente_Concesionario__c();
        cliConcess1.Concesionario__c = concess.Id;
        cliConcess1.Id_Cliente_DMS__c = '41';
        cliConcess1.External_Id__c = '876/41';
        cliConcess1.Cliente__c = cli1.Id;
        insert cliConcess1;

        Account cli2 = CreaObjetos.creaCuentaPersonal('OtroCliente3', 'Personal3');
        cli2.PersonEmail = 'pruebaotheremail3@test.com';
        cli2.OtherEmail__pc = 'pruebaemail3@test.com';
        cli2.Phone ='999999955';
        cli2.PersonMobilePhone = '655555555';
        cli2.BillingCountry = 'ESPAÑA';
        insert cli2;
        
        Cliente_Concesionario__c cliConcess2 = new Cliente_Concesionario__c();
        cliConcess2.Concesionario__c = concess.Id;
        cliConcess2.Id_Cliente_DMS__c = '41';
        cliConcess2.External_Id__c = '877/41';
        cliConcess2.Cliente__c = cli1.Id;
        insert cliConcess2;
        
        Centro__c center = new Centro__c();
        center.Id_Centro_Sima__c = '41';
        center.Concesionario__c = concess.Id;
        insert center;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        
        Vehiculo__c veh = new Vehiculo__c();
        veh.VIN__c = 'VIN02';
        veh.kms__c = 0;
        veh.Fecha_fin_garantia__c = Datetime.now();
        veh.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        insert veh;
    }
    
    @isTest
    static void testOK() {
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContractRentACarApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        
        String requestString = '{"company":"41","reference":"1000000001","uuid":"test_testDummy","statusCA":{"codeCA":"close","nameCA":"Cerrado"},"estimatedPickUpDate":"2021-07-03T15:00:00Z","estimatedReturnDate":"2021-07-17T09:16:00Z",';
        requestString += '"pickUpLocation":{"locationId":2,"locationName":"Aeropuerto Fuerteventura","zone":{"zoneId":6,"zoneName":"Aeropuerto Fuerteventura","area":{"areaId":2,"areaName":"Fuerteventura"}}},"returnLocation":{"locationId":2,"locationName":"Aeropuerto Fuerteventura","zone":{"zoneId":6,"zoneName":"Aeropuerto Fuerteventura","area":{"areaId":2,"areaName":"Fuerteventura"}}},';
        requestString += '"vehicleGroup":{"vehicleGroupCode":"C","vehicleGroupName":"Compact","vehicleGroupSippCode":"CCMR"},"rate":{"rateCode":"BFF","rateName":"Budget F/F","periodUnit":"day","brand":{"brandCode":"budget","brandName":"Budget"}},"distributionChannel":{"channelCode":"api","channelName":"Api"},"channel":{"channelCode":"brokers","channelName":"Brokers"},';
        requestString += '"customer":875,"driver":876,"account":877,"language":"es","voucher":{"voucherNumber":"ES000000000","voucherType":{"voucherCode":"TE","voucherName":"Electronic value voucher"}},"vehicle":{"plate":"1234ABC","color":"white","brand":"Citroën","model":"C4 Cactus","version":"1.2 PureTech 82 CV Feel","vin":"VIN02","vehicleGroup":{"vehicleGroupCode":"C2","vehicleGroupName":"Compact","vehicleGroupSippCode":"CBMR"}},"actualPickupDate":"2021-07-03T11:16:00Z","initKms":50992,"initFuel":"G8","employeePickup":{"username":"prueba","employeeName":"prueba","employeeEmail":"prueba@prueba.es"},"actualReturnDate":"2021-07-17T07:00:00Z","finalKms":52070,"finalFuel":"G8",';
        requestString += '"employeeReturn":{"username":"prueba2","employeeName":"prueba2","employeeEmail":"prueba2@prueba2.es"},"invoices":[{"customer":875,"docNumber":"INV0000000001","issueDate":"2021-07-17T07:38:38Z","totalAmount":20,"periodUnit":"day","invoicedPeriod":14,"lines":[{"lineNumber":1,"lineType":"vehicle","lineConcept":"Día(s)","lineAmount":20}]},{"customer":877,"docNumber":"0000000002","issueDate":"2021-07-17T07:38:38Z","totalAmount":10,"periodUnit":"day","invoicedPeriod":14,"lines":[{"lineNumber":1,"lineType":"extra","lineConcept":"LI - Seguro de Lunas","lineAmount":4},{"lineNumber":2,"lineType":"extra","lineConcept":"SCDW - Seguro Daños a todo Riesgo","lineAmount":3},{"lineNumber":3,"lineType":"extra","lineConcept":"Segundo Conductor","lineAmount":3}]}]}';
        req.requestBody = Blob.valueOf(requestString);
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        RentACarApiRestService.rentACarApi();
        
        requestString.replace('INV0000000001', 'INV0000000011');
        RentACarApiRestService.rentACarApi();
        
        Test.stopTest();
    }

    @isTest
    static void testOK1() {
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContractRentACarApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        
        String requestString = '{"company":"41","reference":"1000000001","uuid":"test_testDummy","statusCA":{"codeCA":"close","nameCA":"Cerrado"},"estimatedPickUpDate":"2021-07-03T15:00:00Z","estimatedReturnDate":"2021-07-17T09:16:00Z",';
        requestString += '"pickUpLocation":{"locationId":2,"locationName":"Aeropuerto Fuerteventura","zone":{"zoneId":6,"zoneName":"Aeropuerto Fuerteventura","area":{"areaId":2,"areaName":"Fuerteventura"}}},"returnLocation":{"locationId":2,"locationName":"Aeropuerto Fuerteventura","zone":{"zoneId":6,"zoneName":"Aeropuerto Fuerteventura","area":{"areaId":2,"areaName":"Fuerteventura"}}},';
        requestString += '"vehicleGroup":{"vehicleGroupCode":"C","vehicleGroupName":"Compact","vehicleGroupSippCode":"CCMR"},"rate":{"rateCode":"BFF","rateName":"Budget F/F","periodUnit":"day","brand":{"brandCode":"xtravans","brandName":"xtravans"}},"distributionChannel":{"channelCode":"api","channelName":"Api"},"channel":{"channelCode":"brokers","channelName":"Brokers"},';
        requestString += '"customer":875,"driver":875,"account":875,"language":"es","voucher":{"voucherNumber":"ES000000000","voucherType":{"voucherCode":"TE","voucherName":"Electronic value voucher"}},"vehicle":{"plate":"1237ABC","color":"white","brand":"Citroën","model":"C4 Cactus","version":"1.2 PureTech 82 CV Feel","vin":"VIN03","vehicleGroup":{"vehicleGroupCode":"C2","vehicleGroupName":"Compact","vehicleGroupSippCode":"CBMR"}},"actualPickupDate":"2021-07-03T11:16:00Z","initKms":50992,"initFuel":"G8","employeePickup":{"username":"prueba","employeeName":"prueba","employeeEmail":"prueba@prueba.es"},"actualReturnDate":"2021-07-17T07:00:00Z","finalKms":52070,"finalFuel":"G8",';
        requestString += '"employeeReturn":{"username":"prueba2","employeeName":"prueba2","employeeEmail":"prueba2@prueba2.es"},"invoices":[{"customer":875,"docNumber":"INV0000000001","issueDate":"2021-07-17T07:38:38Z","totalAmount":20,"periodUnit":"day","invoicedPeriod":14,"lines":[{"lineNumber":1,"lineType":"vehicle","lineConcept":"Día(s)","lineAmount":20}]},{"customer":200393,"docNumber":"0000000002","issueDate":"2021-07-17T07:38:38Z","totalAmount":10,"periodUnit":"day","invoicedPeriod":14,"lines":[{"lineNumber":1,"lineType":"extra","lineConcept":"LI - Seguro de Lunas","lineAmount":4},{"lineNumber":2,"lineType":"extra","lineConcept":"SCDW - Seguro Daños a todo Riesgo","lineAmount":3},{"lineNumber":3,"lineType":"extra","lineConcept":"Segundo Conductor","lineAmount":3}]}]}';
        req.requestBody = Blob.valueOf(requestString);
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        RentACarApiRestService.rentACarApi();
        
        requestString.replace('INV0000000001', 'INV0000000011');
        RentACarApiRestService.rentACarApi();
        
        Test.stopTest();
    }
    
    @isTest
    static void testKO() {
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContractRentACarApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        
        String requestString = '{"company":"41","reference":"1000000001","uuid":"","statusCA":{"codeCA":"close","nameCA":"Cerrado"},"estimatedPickUpDate":"2021-07-03T15:00:00Z","estimatedReturnDate":"2021-07-17T09:16:00Z",';
        requestString += '"pickUpLocation":{"locationId":2,"locationName":"Aeropuerto Fuerteventura","zone":{"zoneId":6,"zoneName":"Aeropuerto Fuerteventura","area":{"areaId":2,"areaName":"Fuerteventura"}}},"returnLocation":{"locationId":2,"locationName":"Aeropuerto Fuerteventura","zone":{"zoneId":6,"zoneName":"Aeropuerto Fuerteventura","area":{"areaId":2,"areaName":"Fuerteventura"}}},';
        requestString += '"vehicleGroup":{"vehicleGroupCode":"C","vehicleGroupName":"Compact","vehicleGroupSippCode":"CCMR"},"rate":{"rateCode":"BFF","rateName":"Budget F/F","periodUnit":"day","brand":{"brandCode":"xtravans","brandName":"xtravans"}},"distributionChannel":{"channelCode":"api","channelName":"Api"},"channel":{"channelCode":"brokers","channelName":"Brokers"},';
        requestString += '"customer":875,"driver":875,"account":875,"language":"es","voucher":{"voucherNumber":"ES000000000","voucherType":{"voucherCode":"TE","voucherName":"Electronic value voucher"}},"vehicle":{"plate":"1234ABC","color":"white","brand":"Citroën","model":"C4 Cactus","version":"1.2 PureTech 82 CV Feel","vin":"VIN02","vehicleGroup":{"vehicleGroupCode":"C2","vehicleGroupName":"Compact","vehicleGroupSippCode":"CBMR"}},"actualPickupDate":"2021-07-03T11:16:00Z","initKms":50992,"initFuel":"G8","employeePickup":{"username":"prueba","employeeName":"prueba","employeeEmail":"prueba@prueba.es"},"actualReturnDate":"2021-07-17T07:00:00Z","finalKms":52070,"finalFuel":"G8",';
        requestString += '"employeeReturn":{"username":"prueba2","employeeName":"prueba2","employeeEmail":"prueba2@prueba2.es"},"invoices":[{"customer":875,"docNumber":"INV0000000001","issueDate":"2021-07-17T07:38:38Z","totalAmount":20,"periodUnit":"day","invoicedPeriod":14,"lines":[{"lineNumber":1,"lineType":"vehicle","lineConcept":"Día(s)","lineAmount":20}]},{"customer":200393,"docNumber":"0000000002","issueDate":"2021-07-17T07:38:38Z","totalAmount":10,"periodUnit":"day","invoicedPeriod":14,"lines":[{"lineNumber":1,"lineType":"extra","lineConcept":"LI - Seguro de Lunas","lineAmount":4},{"lineNumber":2,"lineType":"extra","lineConcept":"SCDW - Seguro Daños a todo Riesgo","lineAmount":3},{"lineNumber":3,"lineType":"extra","lineConcept":"Segundo Conductor","lineAmount":3}]}]}';
        req.requestBody = Blob.valueOf(requestString);
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        RentACarApiRestService.rentACarApi();
        
        requestString.replace('INV0000000001', 'INV0000000011');
        RentACarApiRestService.rentACarApi();
        
        Test.stopTest();
    }
}