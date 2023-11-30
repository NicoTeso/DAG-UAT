global class SalesProcessApiRestModel {
    global String eventType{get;set;}
    global PayLoad payload {get;set;}
    
    global class PayLoad {
        global String companyCode {get;set;} // o companyCode
        global String centerCode {get;set;}
        //global String operationId {get;set;} ¿ya no hay operation Id?
        //global String modality {get;set;} // dentro del vehículo
        global String salesType {get;set;}
        global String creationDate {get;set;}
        global String salesProcessId {get;set;} // id del prooceso de venta id externa
        global String deliveryDate {get;set;}
        global String salesmanEmail {get;set;}
        global String customerId {get;set;}
        global String sourceCode {get;set;} //antes cource
        global String motiveCode {get;set;} //antes motive
        global Integer expirationDays {get;set;}
        global List<Offer> offers {get;set;}
        //global List<TestDrive> testDrives {get;set;} //¿que paso con los testDrive?
        //global List<NeedsDetection> needsDetections {get;set;} //¿que paso con los nedds Detections?
    
        //evento de éxito
        global String successDate {get;set;}
        //evento de fracaso
        global String rejectionDate {get;set;} //antes failureDate
        global String rejectionReasonCode {get;set;} // antes rejectionReason
        
        //evento de completo
        global String saleCompletedDate {get;set;}
        
        //evento entrega de vehículo
        global String customerOwnerId {get;set;}
        global String vin {get;set;} // nuevo
        //global String modality {get;set;}
        //global String brandCode {get;set;} //antes brand
        global String brand {get;set;} 
        global String model {get;set;} 
        global String modelCode {get;set;}
        global String modelYear {get;set;}
        //global String extendedModelVersionKey {get;set;}
        global String version {get;set;}
        global String fuel {get;set;}
        global Integer power {get;set;}
        global Integer engineCapacity{get;set;}
        global String engine {get;set;}
        global String colorCode {get;set;}
        global String interiorCode {get;set;}
        global String transmission {get;set;}
        global String engineLetter {get;set;}
        global String engineNumber {get;set;}
        global String engineCode {get;set;}
        global String registrationPlate {get;set;}
        global String registrationPlateDate {get;set;}
        global Double kms {get;set;}
        global String warrantyStartDate {get;set;}
        global String warrantyEndDate {get;set;}
        global String warrantyExtensionStartDate {get;set;}
        global String warrantyExtensionEndDate {get;set;}
        global String usedVehicleWarrantyStartDate {get;set;}
        global String usedVehicleWarrantyEndDate {get;set;}
        global String gearBox {get;set;}
        global String technicalVehicleClassification {get;set;}

        global Intermediary intermediary {get;set;}

        //evento de cancelación tras exito
        global String cancellationDate {get;set;}
        global String cancellationReasonCode {get;set;}
        
        //evento cambio de vendedor
        global String salesmanName {get;set;}
        global String salesmanMobile {get;set;}
        global String salesForceId {get;set;}
    }
    
    global class Offer {
        global ProductVehicle vehicle {get;set;}
        global EconomicSummary economicSummary {get;set;}
        global List<Financing> financings {get;set;}
    }
    
    global class ProductVehicle {
        global String vin {get;set;} // nuevo
        global String modality {get;set;}
        global String brandCode {get;set;} //antes brand
        global String brand {get;set;} 
        global String model {get;set;} 
        global String modelCode {get;set;}
        global String modelYear {get;set;}
        global String extendedModelVersionKey {get;set;}
        global String modelDescription {get;set;}
        global String modelGroup {get;set;}
        global String modelGroupCode {get;set;}
        //global String version {get;set;}
        global String fuelCode {get;set;}
        global Integer power {get;set;}
        global Integer engineCapacity{get;set;}
        global String engine {get;set;}
        global String colorCode {get;set;}
        global String colorDescription {get;set;}
        global String interiorCode {get;set;}
        global String interiorDescription {get;set;}
        
        global List<Equipment> equipments {get;set;} // cambio antes string
        global List<Accessory> accessories {get;set;} //nuevo
        global List<Service> services {get;set;}
        
        global String deliveryDate {get;set;}
        global String transmission {get;set;}
        global String engineLetter {get;set;}
        global String engineNumber {get;set;}
        global String engineCode {get;set;}
        global String registrationPlate {get;set;}
        global String registrationPlateDate {get;set;}
        global Double kms {get;set;}
        global String warrantyStartDate {get;set;}
        global String warrantyEndDate {get;set;}
        global String warrantyExtensionStartDate {get;set;}
        global String warrantyExtensionEndDate {get;set;}
 //Inma 3-2       
        global String usedVehicleWarrantyStartDate {get;set;}
        global String usedVehicleWarrantyEndDate {get;set;}
        global String gearBox {get;set;}
        global String technicalVehicleClassification {get;set;}

    }
    
    global class Equipment {
        global String code {get;set;}
        global String description {get;set;}
    }
    
    global class Accessory {
        global String code {get;set;}
        global String description {get;set;}
    }
    
    global class Service {
        global String code {get;set;}   // serviceTypeDn
        global String description {get;set;}    
        global List<DetailCode> serviceDetails {get;set;}   // serviceTypeDetailDn
    }
    
    global class DetailCode {
        global String code {get;set;}
        global String description {get;set;}
    }
    
    global class EconomicSummary {
        global String currencyType {get;set;}       // 'currency' is reserved
        global Double price {get;set;}
        global Double discount {get;set;}
        global Double total {get;set;}
    }
    
    global class Financing {
        global String financialCompanyCode {get;set;} //antes sin code
        global String tariffCode {get;set;} //antes sin code
        global String tariffDescription {get;set;}
        global String currencyType {get;set;}
        global Double amount {get;set;}
    }
    
    global class Intermediary {
        global TaxIdentification taxIdentification {get;set;}
    }

    global class TaxIdentification {
        global String numberTax {get;set;} 
        global String typeTax {get;set;} 
    }

    //falta test drive
    /*
    global class TestDrive {
        global String testDriveId {get;set;}
        global String creationDate {get;set;}
        global String scheduledDate {get;set;}
        global String deliveryDate {get;set;}
        global String endingDate {get;set;}
        global String vin {get;set;}
    }
    */
    //falta needsDetection
    /*
    global class NeedsDetection {
        global String question {get;set;}
        global String answer {get;set;}
    }
    */
}