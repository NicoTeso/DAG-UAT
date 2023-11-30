public with sharing class AuxHeaderSalesProcessHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    public Map<String, Cliente_Concesionario__c> mapCConcesionarioByExternalId = new Map<String, Cliente_Concesionario__c>();
    public Map<String, Salesman__c> mapSalesmanByExternalId = new Map<String, Salesman__c>();
    public Map<String, Salesman__c> mapSalesmanToInsert = new Map<String, Salesman__c>();
    public Map<String, Opportunity> mapOpportunityToInsertByIdProcess = new Map<String, Opportunity>();
    public Map<String, String> mapIdProccessToSalesman = new Map<String, String>();
    public Map<String, Centro__c>  mapIdToCenter = new Map<String,Centro__c>();
    

    
    public AuxHeaderSalesProcessHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {}
    
    public void bulkAfter() {
         if (Trigger.new != null) {
             mapCConcesionarioByExternalId.clear();
             mapSalesmanByExternalId.clear();
             List<String> listIdExternalCustomer = new List<String>();
             List<String> listVendedorExt = new List<String>();
             List<String> listCenterCodes = new List<String>();
             
             for (SObject objeto : Trigger.New) {
                 AuxHeaderSalesProcess__c aux = (AuxHeaderSalesProcess__c) objeto;
                 if (!String.isEmpty(aux.CompanyCode__c) &&  !String.isEmpty(aux.CustomerId__c)) {
                     String auxIdExt = aux.CustomerId__c + '/' + aux.CompanyCode__c;
                     listIdExternalCustomer.add(auxIdExt);
                 }
                 
                 if (!String.isEmpty(aux.salesmanEmail__c)) {
                     listVendedorExt.add(aux.salesmanEmail__c.toLowerCase());
                 }
                 if(!String.isEmpty(aux.CenterCode__c) && !String.isEmpty(aux.CompanyCode__c)) {
                     listCenterCodes.add(aux.CompanyCode__c + '-' + aux.CenterCode__c);
                 }
        	}
             
         	mapCConcesionarioByExternalId = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(listIdExternalCustomer);
        	mapSalesmanByExternalId = SalesmanGateway.getSalesmanByEmail(listVendedorExt);
			mapIdToCenter = CentroGateway.getCenterByIdCentroSima(listCenterCodes);            
         }
    }
    
    public void beforeInsert(sObject so) {}
    
    public void beforeUpdate(sObject old, sObject so) {}
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        AuxHeaderSalesProcess__c auxHeader = (AuxHeaderSalesProcess__c) so;
        Opportunity opp = new Opportunity();
        opp.ID_Oportunidad_DMS__c = auxHeader.SalesProcessId__c;
        String idExternoCentro = auxHeader.CompanyCode__c + '-' + auxHeader.CenterCode__c;
        opp.centro__r = new Centro__c(Id_Centro_Sima__c = idExternoCentro);
        opp.Concesionario__r = new Concesionario__c(Id_Concesionario_Sima__c = auxHeader.CompanyCode__c);
        String idExternalCustomer = auxHeader.CustomerId__c + '/' + auxHeader.CompanyCode__c;

        if(mapIdToCenter.containsKey(idExternoCentro)){
            Centro__c centro = mapIdToCenter.get(idExternoCentro);
            opp.Name = centro.concesionario__r.Nombre_Comercial__c+'/'+centro.Name+'/';
        }
        else{
            opp.Name =auxHeader.Name;
        }
        if (mapCConcesionarioByExternalId.containsKey(idExternalCustomer)) {
        	opp.AccountId = mapCConcesionarioByExternalId.get(idExternalCustomer).Cliente__c;
        }
        
        if (!string.isBlank( auxHeader.salesmanEmail__c) && mapSalesmanByExternalId.containsKey(auxHeader.salesmanEmail__c.toLowerCase())) {
        	opp.Vendedor__c = mapSalesmanByExternalId.get(auxHeader.salesmanEmail__c.toLowerCase()).Id;
        }
        else if ( !string.isBlank( auxHeader.salesmanEmail__c) && mapSalesmanToInsert.containsKey(auxHeader.salesmanEmail__c.toLowerCase())) {
        	mapIdProccessToSalesman.put(opp.ID_Oportunidad_DMS__c, auxHeader.salesmanEmail__c.toLowerCase());
        }
        else if (!String.isBlank(auxHeader.salesmanEmail__c)) {
        	Salesman__c vendedor = new Salesman__c();
        	String email = auxHeader.salesmanEmail__c.toLowerCase();
        	vendedor.Email__c = email;
        	vendedor.Name = email;
        	mapSalesmanToInsert.put(email, vendedor);
        	mapIdProccessToSalesman.put(opp.ID_Oportunidad_DMS__c, email);
        }

        opp.Fecha_de_entrega__c = auxHeader.deliveryDate__c;
        opp.Fecha_de_creacion__c = auxHeader.CreationDate__c;
        opp.Motivo__c = auxHeader.MotiveCode__c;
        opp.Origen__c = auxHeader.SourceCode__c;
        //opp.Name = auxHeader.Name;
        opp.Type = auxHeader.salesType__c;
            
        if (Label.eventSalesProcessCreate.equalsIgnoreCase(auxHeader.eventype__c)){
            //opp.CloseDate = Date.valueOf(opp.Fecha_de_entrega__c).addMonths(1);
            if (opp.Fecha_de_creacion__c != null) {
	            opp.CloseDate = Date.valueOf(opp.Fecha_de_creacion__c).addMonths(1);
            } else {
                opp.CloseDate = Date.today();
            }
            opp.StageName = 'Qualification';
        }
        else if (Label.eventSalesProcessDelivered.equalsIgnoreCase(auxHeader.eventype__c)) {
             Date fechaEntrega = date.today();
             if (auxHeader.deliveryDate__c != null) {
	             fechaEntrega = Date.valueOf(auxHeader.deliveryDate__c);
             }
             if (auxHeader.ExpirationDate__c != null) {
	             opp.CloseDate = Date.valueOf(auxHeader.ExpirationDate__c);
             } else {
                opp.CloseDate = Date.today();
             }   
             opp.Dias_de_vencimiento__c = fechaEntrega.daysBetween(opp.CloseDate);
             opp.StageName = 'Proposal';
        }
        else if (Label.eventSalesProcessSuccess.equalsIgnoreCase(auxHeader.eventype__c)) {
            opp.Fecha_de_exito__c = auxHeader.successDate__c;
            opp.StageName ='Negotiation';
            if (auxHeader.successDate__c != null) {
	            opp.CloseDate = Date.valueOf(auxHeader.successDate__c);
             } else {
                opp.CloseDate = Date.today();
             }   
        }
        else if (Label.eventSalesProcessFailure.equalsIgnoreCase(auxHeader.eventype__c)) {
            opp.Fecha_de_Fracaso__c = auxHeader.rejectionDate__c;
            opp.Loss_Reason__c = auxHeader.rejectionReasonCode__c;
            opp.StageName = 'Closed Lost';
            if (auxHeader.rejectionDate__c != null) {
	            opp.CloseDate = Date.valueOf(auxHeader.rejectionDate__c);
             } else {
                opp.CloseDate = Date.today();
             }   
        }
        else if (Label.eventSalesProcessVehicleDelivered.equalsIgnoreCase(auxHeader.eventype__c)) {
            
        }
        else if (Label.eventSalesProcessSaleCompleted.equalsIgnoreCase(auxHeader.eventype__c)){
            opp.Fecha_de_completado__c = auxHeader.CompletedDate__c;
            opp.StageName = 'Closed Won';
            if (auxHeader.CompletedDate__c != null) {
	            opp.CloseDate = Date.valueOf(auxHeader.CompletedDate__c);
             } else {
                opp.CloseDate = Date.today();
             }   
        }
        
        mapOpportunityToInsertByIdProcess.put(opp.ID_Oportunidad_DMS__c , opp);
    }
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        if (!mapSalesmanToInsert.isEmpty()) {
            upsert mapSalesmanToInsert.values();
        }
        
        if (!mapIdProccessToSalesman.isEmpty()) {
            for (String idProcess: mapIdProccessToSalesman.keySet()) {
                Opportunity opp = mapOpportunityToInsertByIdProcess.get(idProcess);
                String email = mapIdProccessToSalesman.get(idProcess);
                opp.Vendedor__r = new Salesman__c(Email__c = email);
                mapOpportunityToInsertByIdProcess.put(idProcess, opp);
            }
        }
        
        if (!mapOpportunityToInsertByIdProcess.isEmpty()) {
            Schema.SObjectField f = Opportunity.Fields.ID_Oportunidad_DMS__c;
			Database.UpsertResult [] cr = Database.upsert(mapOpportunityToInsertByIdProcess.values(), f);
          
        }
    }
}