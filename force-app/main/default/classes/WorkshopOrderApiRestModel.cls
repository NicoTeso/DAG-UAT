global class WorkshopOrderApiRestModel {
	global String eventType{get;set;}
    global PayLoad payload {get;set;}
    
    global class PayLoad {
        global String companyCode {get;set;}
        global String centerCode {get;set;}
        global String workshopOrderId {get;set;}
        global String serviceAdviserName {get;set;}
        global String serviceAdviserPhone {get;set;}
        global String serviceAdviserEmail {get;set;}
        global String workshopCode {get;set;} 
        global String creationDate {get;set;} 
        global String receptionDate {get;set;} 
        global String deliveryDate {get;set;}
        global String cancelDate {get;set;}
        global String vin {get;set;}
        global Double mileage {get;set;} //son los kms 
        global String customerDepositaryId {get;set;}
        global String customerId {get;set;}
        global String customerOwnerId {get;set;}
        global String brand {get;set;} //antes cource
        global String model {get;set;} //antes motive
        global String modelCode {get;set;}
        global String version {get;set;}
        global String engine {get;set;}
        global String modelYear {get;set;}
        global Integer power {get;set;}
        global Integer engineCapacity{get;set;}
        global String fuelCode {get;set;}
        global String transmission {get;set;}
        global String engineLetter {get;set;}
        global String engineNumber {get;set;}
        global String engineCode {get;set;}
        global String registrationPlate {get;set;}
        global String registrationPlateDate {get;set;}
        global String warrantyStartDate {get;set;}
        global String warrantyEndDate {get;set;}
        global String warrantyExtensionStartDate {get;set;}
        global String warrantyExtensionEndDate {get;set;}
        global String UsedVehicleWarrantyStartDate {get;set;}
        global String UsedVehicleWarrantyEndDate {get;set;}
        global String gearBox {get;set;}
        global String technicalVehicleClassification {get;set;}
        global String appointmentDate {get;set;}
        global String appointmentId {get;set;}
        
        global List<Service> services{get;set;}
        global EconomicSummary economicSummary {get;set;}
    }
    
    global class Service {
        global String serviceType {get;set;}
        global String serviceTypeCode {get;set;}
        global String serviceOrigin {get;set;}
        global String serviceOriginCode {get;set;}
        global List<PartGroup> partGroups {get;set;}
       
    }
    
    global class PartGroup {
        global String code {get;set;}
        global String description {get;set;}
    }
    
    global class EconomicSummary{
        global String currencyType {get;set;}
        global Double customerAmount {get;set;}
        global Double insuranceAmount {get;set;}
        global Double internalAmount {get;set;}
        global Double warrantyAmount {get;set;}
        global Double deferenceAmount {get;set;}
        global Double campaignAmount {get;set;}
       
    }

}