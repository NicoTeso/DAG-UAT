@isTest
global class ApiHttpCalloutVehicleMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setStatus('OK');
        VehicleExternalModel vehModel = new VehicleExternalModel();
        vehModel.brand ='Hyundai';
        vehModel.engine = 'prueba engine';
        vehModel.engineCapacity = 199;
        vehModel.engineCode = '121';
        vehModel.engineLetter = 'A';
        vehModel.engineNumber ='12';
        vehModel.fuel ='Gasolina';
        vehModel.fuelCode ='1';
        vehModel.gearBox ='box';
        vehModel.kms = 1000;
        vehModel.model = 'hiunday scoda';
        vehModel.modelCode = '12';
        vehModel.power = 190;
        vehModel.registrationPlate ='VIN1211';
        vehModel.registrationPlateDate ='2021-10-12T22:00:00Z';
        vehModel.technicalVehicleClassification ='1';
        vehModel.version = '1';
        vehModel.modelYear = '2020';
        vehModel.transmission = 'transmission';
        vehModel.vin ='VIN04';
        vehModel.warrantyStartDate ='2021-10-12T22:00:00Z';
        vehModel.warrantyEndDate ='2025-10-12T22:00:00Z';
        vehModel.warrantyExtensionStartDate = '2025-10-12T22:00:00Z';
        vehModel.warrantyExtensionEndDate = '2026-10-12T22:00:00Z';
        vehModel.usedVehicleWarrantyStartDate ='2022-10-12T22:00:00Z';
        vehModel.usedVehicleWarrantyEndDate ='2023-10-12T22:00:00Z';
        vehModel.technicalVehicleClassification ='1';
        response.setBody(JSON.serialize(vehModel)) ;
        response.setStatusCode(200);
        return response; 
    }
}