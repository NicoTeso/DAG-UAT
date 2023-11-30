public class RentACarGateway {
    public static Contrato_Rent_A_Car__c getContratoRentACarById(String id) {
        Contrato_Rent_A_Car__c contratoRentACar;
        
        if (!String.isBlank(id)) {
            Map<String, Contrato_Rent_A_Car__c> mapIdToContratoRentACar = getContratoRentACarById(new List<String>{id});
            contratoRentACar = mapIdToContratoRentACar.containsKey(id) ? mapIdToContratoRentACar.get(id) : null;
        }
        
        return contratoRentACar;
    }
    
    public static Map<String, Contrato_Rent_A_Car__c> getContratoRentACarById(List<String> lstIds) {
        Map<String, Contrato_Rent_A_Car__c> mapIdToContratoRentACar = new Map<String, Contrato_Rent_A_Car__c>();
        
        if (!lstIds.isEmpty()) {
            for (Contrato_Rent_A_Car__c contratoRentACar : [SELECT  Id, Name, company__c, uuid__c, statusCA__c, estimatedPickUpDat__c, estimatedReturnDate__c, pickUpLocation__c,
                        returnLocation__c, vehicleGroup__c, rateCode__c, rateName__c, periodUnit__c, brand__c, distributionChannel__c, 
                        channel__c, customer__c, driver__c, account__c, language__c, voucherNumber__c, voucherType__c, actualPickupDate__c, 
                        initKms__c, initFuel__c, employeePickup__c, actualReturnDate__c, finalKms__c, finalFuel__c, employeeReturn__c, vehicleGroupName__c,
                        sippCode__c, vehicle__c, pickUpZone__c, pickUpArea__c, returnArea__c, returnZone__c, Logo__c, vehicleGroupName1__c, vehicleGroup1__c, 
                        sippCode1__c, model__c, version__c, brandLogo__c, customerTXT__c, driverTXT__c, accountTXT__c, JSON_Entrada__c, 
                        totalAmountCustomer__c,	totalAmountDriver__c, totalAmountAccount__c, driver__r.PersonEmail, driver__r.PersonMobilePhone,
                        driver__r.Phone, driver__r.Name, driver__r.PersonContactId, driver__r.IsPersonAccount, driver__r.Email__c, driver__r.Mobile__c                                  
                								 FROM Contrato_Rent_A_Car__c 
                                                WHERE Id in :lstIds LIMIT 2000]) {
                
                mapIdToContratoRentACar.put(contratoRentACar.Id, contratoRentACar);
            }
        }
        
        return mapIdToContratoRentACar;
    }

}