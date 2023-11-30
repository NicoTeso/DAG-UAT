public class AuxAccountGateway {

    public static AuxAccount__c getAuxAccountByExternalId(String externalId) {
        AuxAccount__c auxAcc;
        
        if (!String.isBlank(externalId)) {
            Map<String, AuxAccount__c> mapExtIdToAuxAccount = getAuxAccountByExternalId(new List<String>{externalId});
            
            if (!mapExtIdToAuxAccount.isEmpty()) {
                auxAcc = mapExtIdToAuxAccount.get(externalId);
            }
        }
        
        return auxAcc;
    }

    public static Map<String, AuxAccount__c> getAuxAccountByExternalId(List<String> lstExtId) {
        Map<String, AuxAccount__c> mapExtIdToAuxAccount = new Map<String, AuxAccount__c>();
        
        if (!lstExtId.isEmpty()) {
            List<AuxAccount__c> lstAuxAccounts = [SELECT Id, Name, companyId__c, customerId__c, fiscalName__c, name__c, firstSurname__c, secondSurname__c, tradeName__c, countryIso31661__c, taxId_documentType__c, taxId_number__c, personType__c, title__c, Delivering_addresses_id__c, Delivering_addresses_countryIso31661__c, Delivering_addresses_region__c, Delivering_addresses_department__c, Delivering_addresses_city__c, Delivering_addresses_streetTypeId__c, Delivering_addresses_street__c, Delivering_addresses_postalCode__c, Delivering_addresses_number__c, Delivering_addresses_complement__c, Delivering_addresses_foreignFullAddress__c,
                                            Invoicing_addresses_id__c, Invoicing_addresses_countryIso31661__c, Invoicing_addresses_region__c, Invoicing_addresses_department__c, Invoicing_addresses_city__c, Invoicing_addresses_streetTypeId__c, Invoicing_addresses_street__c, Invoicing_addresses_postalCode__c, Invoicing_addresses_number__c, Invoicing_addresses_complement__c, Invoicing_addresses_foreignFullAddress__c, birthdate__c, numberOfChildren__c, creationDate__c, modificationDate__c, customerId_actual__c, customerType_actual__c, occupationId__c, gender__c, incomes__c, positionId__c, maritalStatusId__c, economicSectorId__c,
                                            Email__c, Mobile__c, Phone__c, OtherEmail__c, OtherMobile__c, OtherPhone__c, Preferencia__c, ID_Email__c, ID_Mobile__c, ID_Phone__c, ID_OtherEmail__c, ID_OtherMobile__c, ID_OtherPhone__c, Tiene_email__c, Tiene_movil__c, Tiene_telefono__c, Tiene_email_2__c, Tiene_movil_2__c, Tiene_telefono_2__c, ultima_actualizacion__c, taxId_number_nuevo__c, taxId_number_nuevo_txt__c, duplicado__c, methodsOfContact_channel__c, methodsOfContact_value__c, External_Id__c
                                     		FROM AuxAccount__c
                                    		WHERE  External_Id__c in :lstExtId
                                    		LIMIT 2000];
            
            for (AuxAccount__c auxAcc : lstAuxAccounts) {
                mapExtIdToAuxAccount.put(auxAcc.External_Id__c, auxAcc);
            }
        }
        
        return mapExtIdToAuxAccount;
    }
    
}