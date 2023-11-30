public class ContratoRentingGateway {

    public static Map<String, Contrato_renting__c> getContratoRentingById(List<String> lstId) {
        Map<String, Contrato_renting__c> mapContratoRentingById = new Map<String, Contrato_renting__c>();
        
        if (!lstId.isEmpty()) {
            List<Contrato_renting__c> lstContratoRenting = [SELECT Id, Contrato_Marco__c, Numero_Vehiculos__c, Forma_de_pago__c, Numero_Cuenta__c, Fecha_envio__c  
                                                    FROM Contrato_renting__c 
                                    				WHERE Id in :lstId ORDER BY Id ];
            
            for (Contrato_renting__c ContratoRenting : lstContratoRenting) {
                 mapContratoRentingById.put(ContratoRenting.Id, ContratoRenting);
            }
        }
        
        return mapContratoRentingById;
    }
    
}