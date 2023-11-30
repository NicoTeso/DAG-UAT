public class CaseGateway {

    private static Map<String, String> mapHorarioDeContactoLabels;
    private static Map<String, String> mapPreferenciaDeContactoLabels; 
    private static Map<String, String> mapIntencionDeCompraLabels;
    private static Map<String, String> mapModeloLabels;
    
    public static String getPreferenciaContactoLabel(String preferencia){
        System.debug('preferencia:'+ preferencia);
        if(mapPreferenciaDeContactoLabels == null){
            mapPreferenciaDeContactoLabels = new Map<String,String>();
            Schema.DescribeFieldResult fieldPreferenciaDeContacto = Case.Preferencia_de_contacto__c.getDescribe();
            for (Schema.PicklistEntry ple : fieldPreferenciaDeContacto.getPicklistValues()) {
            	mapPreferenciaDeContactoLabels.put(ple.getValue(), ple.getLabel());
        	}
        }
        System.debug('mapPreferenciaDeContactoLabels:'+ mapPreferenciaDeContactoLabels);
        String preferenciaValue = mapPreferenciaDeContactoLabels.get(preferencia);
        return preferenciaValue;
    }
    
    public static String getHorarioContactoLabel(String horario){
        system.debug('Horario;'+ horario);
        if(mapHorarioDeContactoLabels == null){
            mapHorarioDeContactoLabels = new Map<String,String>();
            Schema.DescribeFieldResult fieldHorarioDeContacto = Case.Horario_de_contacto__c.getDescribe();
            for (Schema.PicklistEntry ple : fieldHorarioDeContacto.getPicklistValues()) {
            	mapHorarioDeContactoLabels.put(ple.getValue(), ple.getLabel());
        	}
            
        }
        system.debug('mapHorarioDeContactoLabels;'+ mapHorarioDeContactoLabels);
        String horarioValue = mapHorarioDeContactoLabels.get(horario);
        return horarioValue;
    }
    
    public static String getIntencionCompraLabel(String intencion){
        if(mapIntencionDeCompraLabels == null){
            mapIntencionDeCompraLabels = new Map<String,String>();
            Schema.DescribeFieldResult fieldIntencionDeCompra = Case.Intencion_de_compra__c.getDescribe();
            for (Schema.PicklistEntry ple : fieldIntencionDeCompra.getPicklistValues()) {
            	mapIntencionDeCompraLabels.put(ple.getValue(), ple.getLabel());
        	}
        }
        String intencionValue = mapIntencionDeCompraLabels.get(intencion);
        return intencionValue;
    }
    
    public static String getModeloLabel(String modelo){
        System.debug('modelo: '+ modelo);
        if(mapModeloLabels == null){
            mapModeloLabels = new Map<String,String>();
            Schema.DescribeFieldResult fieldModelo = Case.Modelo__c.getDescribe();
            for (Schema.PicklistEntry ple : fieldModelo.getPicklistValues()) {
            	mapModeloLabels.put(ple.getValue(), ple.getLabel());
        	}
        }
        system.debug('mapModeloLabels:' + mapModeloLabels);
        String modeloValue = mapModeloLabels.get(modelo);
        return modeloValue;
    }
    
     public static Case getCaseById(String id) {
        Case caso;
        
        if (!String.isBlank(id)) {
            Map<String, Case> mapIdToCase = getCaseById(new List<String>{id});
            
            if (!mapIdToCase.isEmpty()) {
                caso = mapIdToCase.get(id);
            }
        }
        
        return caso;
    }

    public static Map<String, Case> getCaseById(List<String> lstId) {
        Map<String, Case> mapIdToCase = new Map<String, Case>();
        
        if (!lstId.isEmpty()) {
            List<Case> lstCases = [SELECT Id,CaseNumber, ContactId, AccountId,Comments, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, Language, Subject, Priority, Description, ClosedDate,  OwnerId, CreatedDate, ContactPhone, ContactMobile, ContactEmail, ContactFax,
                                   Marca__c, acceptPolicy__c, Lead__c, Isla__c, Codigo_Postal__c, Preferencia_de_contacto__c, Horario_de_contacto__c, Intencion_de_compra__c, CustomerName__c, Telefono__c, Movil__c, Correo_electronico__c, Motivo_de_cierre__c, Contactado__c, SalesProduct__c, Es_LEAD__c, Centro__c, Concesionario__c, Segmento_Combustion__c, CustomerEmail__c,
                                   Medio__c, Soporte__c, Fecha_Hora_de_contacto_c__c, AfterSales__c, Detalle_motivo_cierre__c, EventInvitation__c, MarketReresearch__c, CustomerSatisfaction__c, Vehiculo__c, Campana__c, Modelo__c, acceptPolicyDAG__c, UTM_CAMPAIGN__c, Accion_de_marketing__c, TermsAndConditions__c, CustomerProblem__c, Consentimiento__c, Fecha_Hora_de_cita__c,
                                   ProblemDescription__c, ActualizadoEnCampana__c, EnvioMulesoft__c, Error_Mulesoft__c, Documento__c, descmodel__c, colorCar__c, insideCar__c, equipaments__c, packages__c, Fecha_de_cita__c, Horario_de_cita__c, ErrorMulesoft__c, VIN__c, Contactado_Email__c, acceptBookingConditions__c, homeDelivery__c, registrationPlate__c, priceInitial__c, priceFinal__c,
                                   monthsWarranty__c, availabilityDate__c, accountingSituation__c, descOffer1__c, descOffer2__c, descOffer3__c, descOffer4__c, amountOffer1__c, amountOffer2__c, amountOffer3__c, amountOffer4__c, Propietario_Vehiculo__c, brandVO__c, modelVO__c, Buzon__c, Address__c, Birthdate__c, seniority__c, urlPhotosBuyVO__c, urlAdvertVO__c, power__c, engineCapacy__c, kms__c,
                                   fuel__c, Numero_de_llamadas__c, bookingStatus__c, CustomerProblemBrand__c, CustomerProblemEcom__c, CustomerProblemVO__c, CustomerProblemMoto__c, CustomerProblemDAG__c, homeDeliveryTXT__c, CustomerProblemAVIS__c, CustomerPhone__c, WorkingCreatedDate__c, Reenganche__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, Devuelve_llamada__c, creationTimeSection__c,
                                   rentContractSigned__c, rentContractSigned_TXT__c, Opportunity__c, Contactado_Whatsapp__c, urlConfiguration__c, Estado_Oportunidad__c, FourthCallDate__c, FifthCallDate__c, Contactado_Chat__c, SixthCallDate__c, Category__c, EndAdvertisingImpact__c, DeletedDate__c, TypeOfAppointment__c, VehicleType__c, RentingType__c, ExpectedKms__c, RentingCompany__c, OwnerCompany__c,
                                   PurchasePriority__c, Price__c, AdvertisingCommunications__c, Duration__c, EndDateAdvertising__c, MarketingCode__c, RecommendBy__c, RecommendByPT__c, RecommendByName__c, Referencia_Email__c, Aplazamiento_Financiacion__c, Cuota_Financiacion__c, Entrada_Financiacion__c, sendAdditionalEmail__c, SacEmail__c, Lead_Score__c, RecommendById__c 
                                   From case WHERE Id in :lstId ];
            for (Case caso : lstCases) {
                mapIdToCase.put(caso.Id, caso);
            }
        }
        
        return mapIdToCase;
    }
    
   
    
    public static List<Case> getCaseByLead(String leadId){
        List<Case> cases = new List<Case>();
        if(!String.isBlank(leadId)){
            Map<String,List<Case>> mapLeadToCases = CaseGateway.getCaseByLead(new List<String>{leadId});
            if(!mapLeadToCases.isEmpty()){
                cases = mapLeadToCases.get(leadId);
            }
        }
        
        return cases;
    }
    
    public static Map<String,List<Case>> getCaseByLead(List<String> leadIds){
        Map<String,List<Case>> mapLeadToCases = new Map<String,List<Case>>();
        if(!leadIds.isEmpty()){
            for(Case caso :[select id, Lead__c, AccountId,ContactId,Error_Mulesoft__c, ErrorMulesoft__c, OwnerId, Unidad_de_negocio__c, Owner.IsActive, Lead_Score__c from Case where Lead__c in :leadIds]){
                List<Case> listCase = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c):new List<Case>();
                listCase.add(caso);
                mapLeadToCases.put(caso.Lead__c, listCase);
            }
        }
        
        return mapLeadToCases;
    }
    
    public static List<Case> getCasebySalesProcessExtId(String externalId){
        List<Case> listCasos = new List<Case>();
        if(!String.isBlank(externalId)){
            listCasos = [select id, ErrorMulesoft__c, Error_Mulesoft__c, Campana__c, CreatedDate, RecommendBy__c, RecommendByPT__c, RecommendByName__c, Lead_Score__c FROM case
                         WHERE Error_Mulesoft__c  = :externalId AND Error_Mulesoft__c != null 
                         ORDER by CreatedDate asc Limit 10];
        }
        return listCasos;
        
    }

    public static List<Case> getCasebySalesProcessId(String salesId){
        List<Case> listCasos = new List<Case>();
        if(!String.isBlank(salesId)){
            listCasos = [select id, Opportunity__c, Estado_Oportunidad_TXT__c FROM case
                         WHERE Opportunity__c  = :salesId 
                         ORDER by CreatedDate asc Limit 100];
        }
        return listCasos;
        
    }
    
}