public class ExternalService {
    @AuraEnabled
    public static String createAndSendJSON(String recordId) {
        // Case ID from Aura button
        system.debug('recordId: ' + recordId );
        String respuesta = '';
        List<Case> listCase = [SELECT Id, AccountId, Lead__c, Centro__c, Vehiculo__c, CreatedById, Es_LEAD__c,Campana__c,RecordTypeId, RecordType.DeveloperName,
                                    Marca__c,Intencion_de_compra__c,Error_Mulesoft__c, EnvioMulesoft__c, ContactId,IsClosed, SuppliedEmail, SuppliedPhone, CaseNumber,
                                    Modelo__c, Preferencia_de_contacto__c, Horario_de_contacto__c, Fecha_Hora_de_cita__c, Comments, Description, Origin, VIN__c, descmodel__c,
                                    colorCar__c, insideCar__c, equipaments__c, packages__c, urlConfiguration__c, Aplazamiento_Financiacion__c, Cuota_Financiacion__c, Entrada_Financiacion__c, 
                                    sendAdditionalEmail__c, Lead_Score__c, RecommendById__c
                         	   FROM Case
                         	   WHERE Id = :recordId];
        Map<String, Gestion_Lead__c> mapGLeadById = CacheUtil.getGestionLeadMap();
        Centro__c centro; 
        
        if (!mapGLeadById.isEmpty() && !listCase.isEmpty()) {
            Gestion_Lead__c gLead;
            Case caso = listCase[0];
            
            if (caso.AccountId == null && caso.Lead__c == null ) {
                respuesta = 'Este caso no tiene cliente o candidato relacionado'; 
            }
            else if (caso.IsClosed) {
                respuesta = 'Este caso esta cerrado';
            }
            else if (!caso.IsClosed) {
                centro = caso.Centro__c!= null? CentroGateway.getCenterById(caso.Centro__c):null;
                if(Label.RtCaseGestionLeadVO.equalsIgnoreCase(caso.RecordType.DeveloperName)){
                    for (Gestion_Lead__c gestionLead :mapGLeadById.values()) {
                		if (Label.RtGLeadVO.equalsIgnoreCase(gestionLead.RecordType.DeveloperName)
                        	&& gestionLead.Centro__c == caso.Centro__c 
                        	&& caso.Intencion_de_compra__c.contains(gestionLead.Intencion_de_compra__c) && caso.Origin == gestionLead.Origen__c) {
                    			gLead = gestionLead;
                				break;
                		}
          			}
                	if (gLead != null) {
                		respuesta = ExternalServiceController.sendExternalLeadOrAccountVOSec(JSON.serialize(caso),JSON.serialize(gLead));
                	}
                	else {
                   	 	respuesta ='No existe gestion de lead complementada con la información del caso';
                	}
                }
                else if(Label.RtCaseGestionLead.equalsIgnoreCase(caso.RecordType.DeveloperName)){
                    for (Gestion_Lead__c gestionLead :mapGLeadById.values()) {
                		if (Label.RtGLeadVN.equalsIgnoreCase(gestionLead.RecordType.DeveloperName)
                        	&& gestionLead.Centro__c == caso.Centro__c && caso.Marca__c.equalsIgnoreCase(gestionLead.Marca__c)
                        	&& caso.Intencion_de_compra__c.contains(gestionLead.Intencion_de_compra__c) && caso.Origin == gestionLead.Origen__c) {
                    		gLead = gestionLead;
                			break;
                		}
          			}
                	if (gLead != null && centro.Concesionario__r.Es_SIMA__c) {
                	respuesta = ExternalServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(caso),JSON.serialize(gLead));
            		//respuesta ='Operación realizada';
                }
                	else if (gLead != null && !centro.Concesionario__r.Es_SIMA__c) {
                    respuesta = ExternalServiceController.sendExternalLedOrAccountEmailSec(JSON.serialize(caso),JSON.serialize(gLead));
                }
                	else {
                    respuesta ='No existe gestion de lead complementada con la información del caso';
                }
                }
            }
      	}
        
        return respuesta;
	}
}