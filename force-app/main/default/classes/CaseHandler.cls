public class CaseHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    public Map<Id, Schema.RecordTypeInfo> rtMapById = new Map<Id, Schema.RecordTypeInfo>(); 
        
    public Map<String, Gestion_Lead__c> mapGLeadById = new Map<String, Gestion_Lead__c>();
    public Map<String, BusinessHours> mapBusinessHoursByName = new Map<String, BusinessHours>();
    public User Usuario = new User();

    public Map<String, Detalle_venta__c> mapDetalleVentaByOpportunityId = new Map<String, Detalle_venta__c>();

    public Map<String, Detalle_venta__c> mapDetalleVentaById = new Map<String, Detalle_venta__c>();
    
    public Map<String, Opportunity> mapOpportunityById = new Map<String, Opportunity>();

    public Map<String, Pase_de_taller__c> mapPaseTallerById = new Map<String, Pase_de_taller__c>();

    public Map<String, Vehiculo__c> mapVehiculoById = new Map<String, Vehiculo__c>();

    public list<Tarifa_Renting__c> listTarifaRenting = new list<Tarifa_Renting__c>();
    
    public List<SDOC__SDJob__c> jobList = new List<SDOC__SDJob__c> {};
    
    public List<Case> listSendMulesoft = new List<Case>();
    public List<Case> listSendEmail = new List<Case>();
    public List<Case> listSendEmailVO = new List<Case>();
    public List<Case> listSendEmailFeedback = new List<Case>();
    public List<Case> listSendEmailATTCliente = new List<Case>();
    public List<Case> listSendEmailXtravansDiario = new List<Case>();
    public Map<String,Lead> mapLeadActMKT = new Map<String,Lead>();
    public Map<String,Account> mapAccountActMKT = new Map<String,Account>();
    public Gestion_Lead__c gLead = new Gestion_Lead__c();
    public Map<String,Contact> mapContactByAccountId = new Map<String,Contact>();
    public Map<String,Lead> mapLeadByLeadId = new Map<String,Lead>();
    public Map<String,Map<String,Consentimientos__c>> mapConsentimientovalueByAccountId = new Map<String,Map<String,Consentimientos__c>>();
    public Map<String,Map<String,Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String,Map<String,Consentimientos__c>>();
    public Map<String,Map<String,Consentimientos__c>> mapConsentimientovalueByAOrLToUpsert = new Map<String,Map<String,Consentimientos__c>>();
    public Map<String,Map<String,CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String,CampaignMember>>();
    public Map<String,Map<String,CampaignMember>> mapCampaignMemberByCOrLByCampaignIdToInsert = new Map<String,Map<String,CampaignMember>>();
    public Map<String,Campaign> mapCampaignById = new Map<String,Campaign>();
    public Map<String, Centro__c> mapCentroById = new Map<String,Centro__c>();
    public Map<String,Concesionario__c> mapConcesionarioById = new Map<String,Concesionario__c>();
    public Map<String,Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String,Invalid_Emails__c>();
    public Map<String,Contrato_Rent_A_Car__c> mapContratoRentACarById = new Map<String,Contrato_Rent_A_Car__c>();
    public Map<String,Account> mapAccountById = new Map<String,Account>();
    public Map<String,Case> mapParentCaseById = new Map<String,Case>();

    public CaseHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        System.debug('CaseHandler entra bulkBefore Queries-A: ' + Limits.getQueries());
        mapGLeadById.clear();
        mapBusinessHoursByName.clear();
        mapConcesionarioById.clear();
        mapDetalleVentaByOpportunityId.clear();
        mapDetalleVentaById.clear();
        mapOpportunityById.clear();
        mapPaseTallerById.clear();
        listTarifaRenting.clear();
        mapInvalidEmailByEmail.clear();
        mapContratoRentACarById.clear();
        mapAccountById.clear();
        mapVehiculoById.clear();
        mapParentCaseById.clear();
        rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
        System.debug('CaseHandler entra bulkBefore Queries-B0: ' + Limits.getQueries());
    	List<String> concesionarioPropietarioIds = new List<String>(); 
        if (Trigger.new != null) {
            List<String> listOpportunityId = new List<String>();
            List<String> listPaseTallerId = new List<String>();
            List<String> listCampaign = new List<String>();
            List<String> listDetalleVenta = new List<String>();
            List<String> listTipoVehiculo = new List<String>();
            List<String> listTarifaID = new List<String>();
	        List<String> listEmails = new List<String>();
	        List<String> listContratoRentACar = new List<String>();
            List<String> listAccountId = new List<String>();
            List<String> listVehiculo = new List<String>();
            List<String> listParentCase = new List<String>();
            mapBusinessHoursByName = CacheUtil.getBusinessHoursMap();
         System.debug('CaseHandler entra bulkBefore Queries-B1: ' + Limits.getQueries());
            Usuario = CacheUtil.getCurrentUser();
         System.debug('CaseHandler entra bulkBefore Queries-B2: ' + Limits.getQueries());
            boolean recuperaGL = false;
            for(SObject objeto :Trigger.new){
                Case caso = (Case) objeto;
                String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();
                
                if(Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) || 
                   Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName)) {
                   recuperaGL = true;    
                }

                if(!String.isBlank(caso.AccountId) && Label.RtCaseIncidenciaMobility.equalsIgnoreCase(RTDeveloperName)){
                    listAccountId.add(caso.AccountId);
                }  
                if(caso.Propietario_Vehiculo__c != null){
                    concesionarioPropietarioIds.add(caso.Propietario_Vehiculo__c);
                }
                if(!String.isBlank(caso.RecommendBy__c)){
                    listOpportunityId.add(caso.RecommendBy__c);
                }
                if(!String.isBlank(caso.RecommendByPT__c)){
                    listPaseTallerId.add(caso.RecommendByPT__c);
                }
                if(!String.isBlank(caso.AfterSale__c)){
                    listPaseTallerId.add(caso.AfterSale__c);
                }
                if(caso.Campana__c != null){
                    listCampaign.add(caso.Campana__c);
                }
                if(caso.FeedbackSale__c != null){
                    listDetalleVenta.add(caso.FeedbackSale__c);
                }
                if(caso.Sale__c != null){
                    listDetalleVenta.add(caso.Sale__c);
                }
                if(caso.Vehiculo__c != null){
                    listVehiculo.add(caso.Vehiculo__c);
                }
                if(caso.VehicleType__c != null){
                    listTipoVehiculo.add(caso.VehicleType__c);
                }
                if(caso.TarifaID__c != null){
                    listTarifaID.add(caso.TarifaID__c);
                }
                if(caso.SuppliedEmail != null){
                    listEmails.add(caso.SuppliedEmail);
                }
                if(caso.CustomerEmail__c != null && caso.SuppliedEmail == null){
                    listEmails.add(caso.CustomerEmail__c);
                }
                if(caso.Contrato_Rent_A_Car__c != null){
                    listContratoRentACar.add(caso.Contrato_Rent_A_Car__c);
                }
                if (caso.ParentId != null && caso.Opportunity__c == null) {
                    listParentCase.add(caso.ParentId);
                }
            }
            
            if(recuperaGL){
	            mapGLeadById = CacheUtil.getGestionLeadMap();
        System.debug('CaseHandler entra bulkBefore Queries-B3: ' + Limits.getQueries());
            }

            if(!listAccountId.isEmpty()){
              	mapAccountById = AccountGateway.getAccountById(listAccountId);
        System.debug('CaseHandler entra bulkBefore Queries-B4: ' + Limits.getQueries());
            }
            
            if(!concesionarioPropietarioIds.isEmpty()){
                mapConcesionarioById = ConcesionarioGateway.getConcessionaireById(concesionarioPropietarioIds);
        System.debug('CaseHandler entra bulkBefore Queries-B5: ' + Limits.getQueries());
            }
            if(!listOpportunityId.isEmpty()){
                mapDetalleVentaByOpportunityId = DetalleVentaGateway.getDetalleVentaByOpportunityId(listOpportunityId);
                mapOpportunityById = OpportunityGateway.getOppById(listOpportunityId);
        System.debug('CaseHandler entra bulkBefore Queries-B6: ' + Limits.getQueries());
            }
            if(!listPaseTallerId.isEmpty()){
                mapPaseTallerById = PaseTallerGateway.getPaseTallerById(listPaseTallerId);
        System.debug('CaseHandler entra bulkBefore Queries-B7: ' + Limits.getQueries());
            }
            if(!listCampaign.isEmpty()){
                mapCampaignById = CampaignGateway.getCampaignById(listCampaign);
        System.debug('CaseHandler entra bulkBefore Queries-B8: ' + Limits.getQueries());
            }
            if(!listDetalleVenta.isEmpty()){
                mapDetalleVentaById = DetalleVentaGateway.getDetalleVentaById(listDetalleVenta);
        System.debug('CaseHandler entra bulkBefore Queries-B9: ' + Limits.getQueries());
            }
            if(!listVehiculo.isEmpty()){
                mapVehiculoById = VehiculoGateway.getVehicleById(listVehiculo);
        System.debug('CaseHandler entra bulkBefore Queries-B10: ' + Limits.getQueries());
            }
	        if(!listTipoVehiculo.isEmpty() ||
               !listTarifaID.isEmpty()){
    	        listTarifaRenting = TarifaRentingGateway.getTarifaRentingByTipoVehiculo(listTipoVehiculo, listTarifaID);
        System.debug('CaseHandler entra bulkBefore Queries-B11: ' + Limits.getQueries());
        	}
            if(!listEmails.isEmpty()){
                mapInvalidEmailByEmail = InvalidEmailGateway.getInvalidEmailByEmail(listEmails);
        System.debug('CaseHandler entra bulkBefore Queries-B12: ' + Limits.getQueries());
            }   
            if(!listContratoRentACar.isEmpty()){
                mapContratoRentACarById = RentACarGateway.getContratoRentACarById(listContratoRentACar);
        System.debug('CaseHandler entra bulkBefore Queries-B13: ' + Limits.getQueries());
            }
            if (!listParentCase.isEmpty()){
                mapParentCaseById = CaseGateway.getCaseById(listParentCase);
        System.debug('CaseHandler entra bulkBefore Queries-B14: ' + Limits.getQueries());
            }
        }
        System.debug('CaseHandler sale bulkBefore Queries-A: ' + Limits.getQueries());
    }
        
    public void bulkAfter() {
        System.debug('CaseHandler entra bulkAfter Queries-A: ' + Limits.getQueries());
        mapGLeadById.clear();
        mapCentroById.clear();
        mapCOrLToCMByCampaignId.clear();
        rtMapById = Schema.SObjectType.Case.getRecordTypeInfosById();
        System.debug('CaseHandler entra bulkAfter Queries-C0: ' + Limits.getQueries());
        mapConsentimientovalueByAOrLToUpsert.clear();
    	mapCampaignMemberByCOrLByCampaignIdToInsert.clear();
        mapDetalleVentaByOpportunityId.clear();
        mapOpportunityById.clear();
        mapPaseTallerById.clear();
        mapCampaignById.clear();
        listTarifaRenting.clear();
        jobList.clear();
        boolean recuperaGL = false;
        mapLeadActMKT.clear();
        mapAccountActMKT.clear();
        
        if (Trigger.new != null) {
            List<String> listLeadId = new List<String>();
            List<String> listAccountId = new List<String>();
            List<String> listCampaignId = new List<String>();
            List<String> listCentroId = new List<String>();
            List<String> listOpportunityId = new List<String>();
            List<String> listPaseTallerId = new List<String>();
            List<String> listTipoVehiculo = new List<String>();
            List<String> listTarifaID  = new List<String>();
            for (SObject objeto : Trigger.New) {
                Case caso = (Case) objeto;
                String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();
                
                if(Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) || 
                   Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName)) {
                   recuperaGL = true;    
                }
                if(!String.isBlank(caso.Lead__c)){
                    listLeadId.add(caso.Lead__c);
                }
                if(!String.isBlank(caso.AccountId)){
                    listAccountId.add(caso.AccountId);
                }  
                if(!String.isBlank(caso.Campana__c)){
                    listCampaignId.add(caso.Campana__c);
                }
                if(!String.isBlank(caso.Centro__c)){
                    listCentroId.add(caso.Centro__c);
                }
                if(!String.isBlank(caso.RecommendBy__c)){
                    listOpportunityId.add(caso.RecommendBy__c);
                }
                if(!String.isBlank(caso.RecommendByPT__c)){
                    listOpportunityId.add(caso.RecommendByPT__c);
                }
                if(caso.VehicleType__c != null){
                    listTipoVehiculo.add(caso.VehicleType__c);
                }
                if(caso.TarifaID__c != null){
                    listTarifaID.add(caso.TarifaID__c);
                }
            }
            if(recuperaGL){
	            mapGLeadById = CacheUtil.getGestionLeadMap();
        System.debug('CaseHandler entra bulkAfter Queries-C1: ' + Limits.getQueries());
            }

            if(!listAccountId.isEmpty()){
                mapConsentimientovalueByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(listAccountId);
              	mapContactByAccountId = ContactGateway.getContactByAccountId(listAccountId);
        System.debug('CaseHandler entra bulkAfter Queries-C2: ' + Limits.getQueries());
            }
            if(!listLeadId.isEmpty()){
                mapConsentimientovalueByLeadId = ConsentimientosGateway.getConsentimientosByLeadId(listLeadId);
                mapLeadByLeadId = LeadGateway.getLeadIdByIds(listLeadId);
        System.debug('CaseHandler entra bulkAfter Queries-C3: ' + Limits.getQueries());
            }
            if(!listCampaignId.isEmpty()){
                List<String> listContactId = new List<String>();
                for(Contact contacto :mapContactByAccountId.values()){
                    listContactId.add(contacto.Id);
                }
                mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(listCampaignId, listContactId, listLeadId );
                mapCampaignById = CampaignGateway.getCampaignById(listCampaignId);
        System.debug('CaseHandler entra bulkAfter Queries-C4: ' + Limits.getQueries());
            }
            if(!listOpportunityId.isEmpty()){
                mapDetalleVentaByOpportunityId = DetalleVentaGateway.getDetalleVentaByOpportunityId(listOpportunityId);
                mapOpportunityById = OpportunityGateway.getOppById(listOpportunityId);
                for(Detalle_venta__c detV :mapDetalleVentaByOpportunityId.values()){
                    listCentroId.add(detV.Centro__c);
                }
                for(Opportunity proV :mapOpportunityById.values()){
                    listCentroId.add(proV.Centro__c);
                }
        System.debug('CaseHandler entra bulkAfter Queries-C5: ' + Limits.getQueries());
            }
            if(!listPaseTallerId.isEmpty()){
                mapPaseTallerById = PaseTallerGateway.getPaseTallerById(listPaseTallerId);
        System.debug('CaseHandler entra bulkAfter Queries-C6: ' + Limits.getQueries());
            }
            if(!listCentroId.isEmpty() && recuperaGL){
                mapCentroById = CentroGateway.getCenterById(listCentroId);
        System.debug('CaseHandler entra bulkAfter Queries-C7: ' + Limits.getQueries());
            }
	        if(!listTipoVehiculo.isEmpty() ||
               !listTarifaID.isEmpty()){
               listTarifaRenting = TarifaRentingGateway.getTarifaRentingByTipoVehiculo(listTipoVehiculo, listTarifaID);
        System.debug('CaseHandler entra bulkAfter Queries-C8: ' + Limits.getQueries());
        	}
        }
        System.debug('CaseHandler sale bulkAfter Queries-A: ' + Limits.getQueries());
    }
    
    public void beforeInsert(sObject so) {
        System.debug('CaseHandler entra beforeInsert Queries-A: ' + Limits.getQueries());
        Case caso = (Case) so;
        String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();

        boolean EsCasoChat = false;
        if (Label.RTCaseChatHPromiseCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatTuCarMarket.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatDasWeltAutoCanarias.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemVO__c;
            EsCasoChat = true;
        }   
        
        if (Label.RTCaseChatDomingoAlonsoGroup.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatDAPP.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemDAG__c;
            EsCasoChat = true;
        } 

        if (Label.RTCaseChatAudiCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatCitroenCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatHondaCochesCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatHyundaiCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatSkodaCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatVolkswagenCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatVWComerciales.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemBrand__c;
            EsCasoChat = true;
        } 

        if (Label.RTCaseChatDucatiCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatHondaMotosCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatSilenceCanarias.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemMoto__c;
            EsCasoChat = true;
        } 
        
        if (Label.RTCaseChatConfiguradorHyundaiCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatConfiguradorVolkswagenCanarias.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatStockFinderAudi.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemEcom__c;
            EsCasoChat = true;
        } 

        if (Label.RTCaseChatFeriaAVIS.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemAVIS__c;
            EsCasoChat = true;
        }

        if (Label.RTChatLovesharing.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemLovesharing__c;
            EsCasoChat = true;
        }

        if (Label.RTCaseChatmyCARFLIX.equalsIgnoreCase(RTDeveloperName) ||
            Label.RTCaseChatXtravans.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemRenting__c;
            EsCasoChat = true;
        }
        
        if (Label.RTCaseChatPowerSports.equalsIgnoreCase(RTDeveloperName)) {
            caso.CustomerProblem__c = caso.CustomerProblemPowerSports__c;
            EsCasoChat = true;
        } 

        if (EsCasoChat) {
            caso.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get(Label.RTCaseGestionDeChat).getRecordTypeId();
            caso.Description = caso.ProblemDescription__c;
            caso.SuppliedEmail = caso.CustomerEmail__c;
            caso.SuppliedName = caso.CustomerName__c;
            caso.SuppliedPhone = caso.CustomerPhone__c;
        }   
        
        if (caso.Unidad_de_negocio__c == null) {
            caso.Unidad_de_negocio__c = Usuario.Unidad_de_negocio__c;
        }
        if (caso.Unidad_de_negocio__c == null &&
           (Label.RtCaseGestionEmail.equalsIgnoreCase(RTDeveloperName) ||
            Label.RtCaseGestionAtencionCliente.equalsIgnoreCase(RTDeveloperName))) {
            caso.Unidad_de_negocio__c = Label.UnidadNegocioOpportunity;
        }    
        if (caso.Unidad_de_negocio__c == null &&
           (Label.RtCaseGestionEmailMobility.equalsIgnoreCase(RTDeveloperName) ||
            Label.RtCaseGestionEmailInciMobility.equalsIgnoreCase(RTDeveloperName) ||
            Label.RtCaseIncidenciaMobility.equalsIgnoreCase(RTDeveloperName))) {
            caso.Unidad_de_negocio__c = Label.UnidadNegocioMobility;
        }    
        
        BusinessHours bh;
        if (caso.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
	        bh = mapBusinessHoursByName.get('DAG Mobility');
            caso.BusinessHoursId = bh.Id;
        } else if (Label.RtCaseGestionAtencionCliente.equalsIgnoreCase(RTDeveloperName)){
	        bh = mapBusinessHoursByName.get('ATT Importador');
            caso.BusinessHoursId = bh.Id;
        } else {
        	bh = mapBusinessHoursByName.get('DAG Canarias');
        }
        
        if (caso.Fecha_Hora_de_cita__c != null) {
            caso.AppointmentDateTXT__c = caso.Fecha_Hora_de_cita__c.day()+'/'+caso.Fecha_Hora_de_cita__c.month()+'/'+caso.Fecha_Hora_de_cita__c.year();
            caso.AppointmentTimeTXT__c = caso.Fecha_Hora_de_cita__c.minute() < 10?caso.Fecha_Hora_de_cita__c.hour()+':0'+caso.Fecha_Hora_de_cita__c.minute():caso.Fecha_Hora_de_cita__c.hour()+':'+caso.Fecha_Hora_de_cita__c.minute();
        }    
        
        if (Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) || Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName) ||
            Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName)) {
             //validación de campo email vacío diferente a campañas trae Amigo
            if(String.isBlank(caso.SuppliedEmail)){
                 if(caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c)){
            		Campaign campania = mapCampaignById.get(caso.Campana__c);
                    if(!Label.CampaignsAmigo.contains(campania.Name)){
                        caso.addError('Email no informado');
                    } 
                }
            }
        }

        if(!String.isBlank(caso.SuppliedPhone)){
            String CleanPhone = DataValidations.clearPhone(caso.SuppliedPhone);
            caso.SuppliedPhone = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
            caso.CustomerPhone__c = caso.SuppliedPhone;
        }

        if(!String.isBlank(caso.SuppliedEmail) && ((!DataValidations.validateEmail(caso.SuppliedEmail)) || (mapInvalidEmailByEmail.containsKey(caso.SuppliedEmail)))){
            caso.SuppliedEmail = null;
        } 
        
        if (Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName)){
            if( !String.isBlank(caso.Intencion_de_compra__c) &&  caso.Intencion_de_compra__c.contains(Label.IntencionCSorteo)){
                caso.Status = Label.StatusClosed;
                caso.Motivo_de_cierre__c = Label.motivoCierreConcurso; 
            }    
            if( !String.isBlank(caso.Intencion_de_compra__c) &&  caso.Intencion_de_compra__c.contains(Label.IntencionCRRSS)){
                caso.Status = Label.StatusClosed;
                caso.Motivo_de_cierre__c = Label.motivoCierreParticipaEvento; 
            }    
        }
        
        if(Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName)){
           	Concesionario__c concePropietario = mapConcesionarioById.containsKey(caso.Propietario_Vehiculo__c)? mapConcesionarioById.get(caso.Propietario_Vehiculo__c):null;
            if(concePropietario != null && !concePropietario.Es_SIMA__c){
                caso.Status = Label.StatusClosed;
                caso.Motivo_de_cierre__c = Label.motivoCierreConcesionarioExterno; 
            }
            else if( !String.isBlank(caso.Intencion_de_compra__c) &&  caso.Intencion_de_compra__c.contains(Label.IntencionCReserva)){
                if(!String.isBlank(caso.bookingStatus__c) && caso.bookingStatus__c != Label.StatusRPagoRealizado){
                    caso.Status = Label.StatusClosed;
                    caso.Motivo_de_cierre__c =  Label.motivoCierrreReservaFallida;
                }
            }
            if(!String.isBlank(caso.Intencion_de_compra__c) &&  caso.Intencion_de_compra__c.contains(Label.IntencionCInformacion)){
                 if(!String.isBlank(caso.Origin) && caso.Origin.equalsIgnoreCase(Label.origenFeriaAvis)){
                     caso.Status = Label.StatusClosed;
                     caso.Motivo_de_cierre__c = Label.motivoCierreSoloInformacion;
                 }
              }
        }

        if (Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) && caso.Status != Label.StatusClosed){
            //Si es recomendado lo indicamos en la descripcion
            Gestion_Lead__c gestionLead = new Gestion_Lead__c();
            if (caso.RecommendBy__c != null){
            	Detalle_venta__c DetalleVenta = mapDetalleVentaByOpportunityId.get(caso.RecommendBy__c);
                if (DetalleVenta != null){
                    if ((caso.AccountId == DetalleVenta.Propietario__c) ||
                       ((caso.SuppliedEmail == DetalleVenta.Propietario__r.PersonEmail ||
                         caso.SuppliedEmail == DetalleVenta.Propietario__r.OtherEmail__pc ||
                         caso.SuppliedPhone == DetalleVenta.Propietario__r.PersonMobilePhone ||
                         caso.SuppliedPhone == DetalleVenta.Propietario__r.OtherMobilePhone__pc ||
                         caso.SuppliedPhone == DetalleVenta.Propietario__r.Phone ||
                         caso.SuppliedPhone == DetalleVenta.Propietario__r.PersonOtherPhone) && 
                        (caso.SuppliedName.contains(DetalleVenta.Propietario__r.Name) ||
                         DetalleVenta.Propietario__r.Name.contains(caso.SuppliedName)))){
                        caso.addError('No se permite recomendar a uno mismo');
                    } else {
                        System.debug('DetalleVenta:'+DetalleVenta);
                        if (caso.Description == null){
                            caso.Description = 'Cliente recomendado por el cliente: '+DetalleVenta.Propietario__r.Name;
                        } else {
                            caso.Description += '\r\nCliente recomendado por el cliente: '+DetalleVenta.Propietario__r.Name;
                        }
                        caso.RecommendByName__c = DetalleVenta.Propietario__r.Name;
                        caso.RecommendById__c = DetalleVenta.PropietarioTXT__c;
                        if (caso.Centro__c == null) {
                            if (DetalleVenta.Centro__r.Activo__c && DetalleVenta.Centro__r.Gestiona_LEAD__c) {
                                caso.Centro__c = DetalleVenta.Centro__c;
                            }
                        }
                        System.debug('caso.Description: '+caso.Description);
                        System.debug('caso.Centro__c: '+caso.Centro__c);
                    }
                } else {
                    Opportunity ProcesoVenta = mapOpportunityById.get(caso.RecommendBy__c);
                    if (ProcesoVenta != null){
                        if ((caso.AccountId == ProcesoVenta.AccountId) ||
                           ((caso.SuppliedEmail == ProcesoVenta.Account.PersonEmail ||
                             caso.SuppliedEmail == ProcesoVenta.Account.OtherEmail__pc ||
                             caso.SuppliedPhone == ProcesoVenta.Account.PersonMobilePhone ||
                             caso.SuppliedPhone == ProcesoVenta.Account.OtherMobilePhone__pc ||
                             caso.SuppliedPhone == ProcesoVenta.Account.Phone ||
                             caso.SuppliedPhone == ProcesoVenta.Account.PersonOtherPhone) && 
                            (caso.SuppliedName.contains(ProcesoVenta.Account.Name) ||
                             ProcesoVenta.Account.Name.contains(caso.SuppliedName)))){
                            caso.addError('No se permite recomendar a uno mismo');
                        } else {
                            System.debug('ProcesoVenta:'+ProcesoVenta);
                            if (caso.Description == null){
                                caso.Description = 'Cliente recomendado por el cliente: '+ProcesoVenta.Account.Name;
                            } else {
                                caso.Description += '\r\nCliente recomendado por el cliente: '+ProcesoVenta.Account.Name;
                            }
                            caso.RecommendByName__c = ProcesoVenta.Account.Name;
                            caso.RecommendById__c = ProcesoVenta.CompradorTXT__c;
                            if (caso.Centro__c == null) {
                                if (ProcesoVenta.Centro__r.Activo__c && ProcesoVenta.Centro__r.Gestiona_LEAD__c) {
                                    caso.Centro__c = ProcesoVenta.Centro__c;
                                }
                            }
                            System.debug('caso.Description: '+caso.Description);
                            System.debug('caso.Centro__c: '+caso.Centro__c);
                        }
                    }    
                }   
            }
            if (caso.RecommendByPT__c != null){
            	Pase_de_taller__c PaseTaller = mapPaseTallerById.get(caso.RecommendByPT__c);
                if (PaseTaller != null){
                    if ((caso.AccountId == PaseTaller.customerDepositary__c) ||
                       ((caso.SuppliedEmail == PaseTaller.customerDepositary__r.PersonEmail ||
                         caso.SuppliedEmail == PaseTaller.customerDepositary__r.OtherEmail__pc ||
                         caso.SuppliedPhone == PaseTaller.customerDepositary__r.PersonMobilePhone ||
                         caso.SuppliedPhone == PaseTaller.customerDepositary__r.OtherMobilePhone__pc ||
                         caso.SuppliedPhone == PaseTaller.customerDepositary__r.Phone ||
                         caso.SuppliedPhone == PaseTaller.customerDepositary__r.PersonOtherPhone) && 
                        (caso.SuppliedName.contains(PaseTaller.customerDepositary__r.Name) ||
                         PaseTaller.customerDepositary__r.Name.contains(caso.SuppliedName)))){
                        caso.addError('No se permite recomendar a uno mismo');
                    } else {
                        System.debug('PaseTaller:'+PaseTaller);
                        if (caso.Description == null){
                            caso.Description = 'Cliente recomendado por el cliente: '+PaseTaller.customerDepositary__r.Name;
                        } else {
                            caso.Description += '\r\nCliente recomendado por el cliente: '+PaseTaller.customerDepositary__r.Name;
                        }
                        caso.RecommendByName__c = PaseTaller.customerDepositary__r.Name;
                        caso.RecommendById__c = PaseTaller.customerDepositaryTXT__c;
                        if (caso.Centro__c == null) {
                            if (PaseTaller.Centro__r.Activo__c && PaseTaller.Centro__r.Gestiona_LEAD__c) {
                                caso.Centro__c = PaseTaller.Centro__c;
                            }
                        }
                        System.debug('caso.Description: '+caso.Description);
                        System.debug('caso.Centro__c: '+caso.Centro__c);
	                }
                }
            }
        }

        if (Label.RtCaseIncidenciaMobility.equalsIgnoreCase(RTDeveloperName)) {
            if (caso.Contrato_Rent_A_Car__c != null){
            	Contrato_Rent_A_Car__c ContratoRentACar = mapContratoRentACarById.get(caso.Contrato_Rent_A_Car__c);
                if (ContratoRentACar != null){
                    if (caso.Vehiculo__c == null) {
                    	caso.Vehiculo__c = ContratoRentACar.vehicle__c;
                    }    
                    if (caso.Marca__c == null) {
                    	caso.Marca__c = ContratoRentACar.brand__c;
                    }    
                    if (caso.Centro__c == null) {
	                    caso.Centro__c = ContratoRentACar.pickUpLocation__c;
                    }
                    if (caso.Subject == null) {
	                    caso.Subject = 'Incidencia Mobility contrato: ' + ContratoRentACar.Name + ' ' + datetime.now();
                    }
                    if (ContratoRentACar.driver__c != null && 
                        ContratoRentACar.driver__r.IsPersonAccount == true && 
                        caso.AccountId == null) {
                        if (ContratoRentACar.driver__r.PersonEmail != null && caso.SuppliedEmail == null) {
                            caso.SuppliedEmail = ContratoRentACar.driver__r.PersonEmail;
                        }
                        if (ContratoRentACar.driver__r.PersonMobilePhone != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.PersonMobilePhone;
                        } else if (ContratoRentACar.driver__r.Phone != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.Phone;
                        }
                        caso.SuppliedName = ContratoRentACar.driver__r.Name;
                        caso.AccountId = ContratoRentACar.driver__c;
                        caso.ContactId = ContratoRentACar.driver__r.PersonContactId;
                    } else if (ContratoRentACar.driver__c != null && caso.AccountId == null) {
                        if (ContratoRentACar.driver__r.Email__c != null && caso.SuppliedEmail == null) {
                            caso.SuppliedEmail = ContratoRentACar.driver__r.Email__c;
                        }
                        if (ContratoRentACar.driver__r.Mobile__c != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.Mobile__c;
                        } else if (ContratoRentACar.driver__r.Phone != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.Phone;
                        }
                        caso.SuppliedName = ContratoRentACar.driver__r.Name;
                        caso.AccountId = ContratoRentACar.driver__c;
                    }
                    if (caso.SuppliedName == null && caso.AccountId != null) {
                        Account cuenta = mapAccountById.get(caso.AccountId);
                        if (cuenta != null && cuenta.IsPersonAccount == true) {
                        	if (cuenta.PersonEmail != null && caso.SuppliedEmail == null) {
                            	caso.SuppliedEmail = cuenta.PersonEmail;
                        	}
                        	if (cuenta.PersonMobilePhone != null && caso.SuppliedPhone == null){
                            	caso.SuppliedPhone = cuenta.PersonMobilePhone;
                        	} else if (cuenta.Phone != null && caso.SuppliedPhone == null){
                            	caso.SuppliedPhone = cuenta.Phone;
                        	}
                        	caso.SuppliedName = cuenta.Name;
                        	caso.ContactId = cuenta.PersonContactId;
                        } else if (cuenta != null && cuenta.IsPersonAccount == false) {
                            if (cuenta.Email__c != null && caso.SuppliedEmail == null) {
                                caso.SuppliedEmail = cuenta.Email__c;
                            }
                            if (cuenta.Mobile__c != null && caso.SuppliedPhone == null){
                                caso.SuppliedPhone = cuenta.Mobile__c;
                            } else if (cuenta.Phone != null && caso.SuppliedPhone == null){
                                caso.SuppliedPhone = cuenta.Phone;
                            }
                            caso.SuppliedName = cuenta.Name;
                        }    
                    }
                }
            }    
        }
        
        if (Label.RtCaseFeedbackCliente.equalsIgnoreCase(RTDeveloperName)) {
            if (caso.FeedbackSale__c != null){
            	Detalle_venta__c DetalleVenta = mapDetalleVentaById.get(caso.FeedbackSale__c);
                if (DetalleVenta != null){
                    caso.Vehiculo__c = DetalleVenta.Vehiculo__c;
                    caso.Marca__c = DetalleVenta.Vehiculo__r.MarcaString__c;
                    caso.descmodel__c = DetalleVenta.Vehiculo__r.modelDescription__c;
                    caso.Salesman__c = DetalleVenta.Vendedor__r.Name;
                    If (DetalleVenta.Vehiculo__r.MarcaString__c == 'DUCATI'){
                        if (DetalleVenta.Concesionario__r.Id_Concesionario_Sima__c == '164'){
		                    caso.SalesmanEmail__c = Label.AsesoresDucatiDAG;
                        } else {
		                    caso.SalesmanEmail__c = Label.AsesoresDucatiDAT;
                        }
                    } else {
                        caso.SalesmanEmail__c = DetalleVenta.Vendedor__r.Email__c;
                    } 

                    if (DetalleVenta.Vehiculo__r.MarcaString__c == 'CITROËN') {
                        caso.SacEmail__c = Label.SacCITROEN;
                    } else {
                        caso.SacEmail__c = '';
                    }
                    
                    caso.Centro__c = DetalleVenta.Centro__c;
                    caso.Subject = 'Feedback venta ' + DetalleVenta.Vehiculo__r.MarcaString__c + ' vehículo ' + DetalleVenta.Vehiculo__r.Name;
                    if (DetalleVenta.Propietario__r.PersonEmail != null) {
                        caso.SuppliedEmail = DetalleVenta.Propietario__r.PersonEmail;
                    }
                    if (DetalleVenta.Propietario__r.PersonMobilePhone != null){
                        caso.SuppliedPhone = DetalleVenta.Propietario__r.PersonMobilePhone;
                    } else if (DetalleVenta.Propietario__r.Phone != null){
                        caso.SuppliedPhone = DetalleVenta.Propietario__r.Phone;
                    }
                    caso.SuppliedName = DetalleVenta.Propietario__r.Name;
                    if (caso.FeedbackValue__c == '1' || caso.FeedbackValue__c == '2' ){
                        caso.Priority = 'High';
                    }
                }
            }    
        }
        
        if (Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName)) {
            if (caso.Origen_Renting__c == 'XTRAVANS'){
                caso.Tarifa_Renting__c = null;
                if (caso.VehicleType__c != null && caso.RentingType__c != null && 
                    caso.Cuota_12_meses__c == null &&
                    caso.Cuota_24_meses__c == null &&
                    caso.Cuota_36_meses__c == null &&
                    caso.Cuota_48_meses__c == null &&
                    caso.Cuota_60_meses__c == null &&
                    caso.Cuota_1_a_2_dias__c == null &&
                    caso.Cuota_3_a_6_dias__c == null &&
                    caso.Cuota_7_a_13_dias__c == null &&
                    caso.Cuota_14_a_20_dias__c == null &&
                    caso.Cuota_21_a_30_dias__c == null &&
                    caso.Cuota_31_a_60_dias__c == null &&
                    caso.Cuota_61_a_90_dias__c == null &&
                    caso.Cuota_mas_90_dias__c == null &&
                    caso.Franquicia_Seguro__c == null){
                    for(Tarifa_Renting__c tarifaRenting : listTarifaRenting){
                        system.debug('tarifaRenting: '+tarifaRenting);
                        system.debug('tarifaRenting.RecordType.Name:'+tarifaRenting.RecordType.Name);
                        system.debug(Label.RtTarifaXtravans);
                        if (Label.RtTarifaXtravans.equalsIgnoreCase(tarifaRenting.RecordType.Name)){
                            if (tarifaRenting.Tipo_de_vehiculo__c == caso.VehicleType__c &&
                                tarifaRenting.Tipo_Renting__c == caso.RentingType__c &&
                                caso.RentingType__c == 'Fijo'){
                                if (tarifaRenting.Duracion__c == '14'){caso.Cuota_12_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '15'){caso.Cuota_24_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '16'){caso.Cuota_36_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '17'){caso.Cuota_48_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '18'){caso.Cuota_60_meses__c = tarifaRenting.Importe_Cuota__c;}
                                if (caso.Price__c == null && caso.Duration__c == tarifaRenting.Duracion__c){
                                    caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                }
                                if (caso.Marca__c == null &&
                                    caso.Modelo__c == null &&
                                    caso.descmodel__c == null &&
                                    caso.Valor_del_vehiculo__c == null) {
                                    caso.Valor_del_vehiculo__c = tarifaRenting.Valor_del_vehiculo__c;    
                                    caso.Marca__c = tarifaRenting.Marca__c;
                                    caso.Modelo__c = tarifaRenting.Modelo__c;
                                    caso.descmodel__c = tarifaRenting.modelDescription__c;
                                }    
                                if (caso.Marca__c == tarifaRenting.Marca__c &&
                                    caso.Modelo__c == tarifaRenting.Modelo__c &&
                                    caso.descmodel__c == tarifaRenting.modelDescription__c &&
                                    caso.Valor_del_vehiculo__c == null) {
                                    caso.Valor_del_vehiculo__c = tarifaRenting.Valor_del_vehiculo__c;    
                                }    
                            }
                            if (tarifaRenting.Tipo_de_vehiculo__c == caso.VehicleType__c &&
                                tarifaRenting.Tipo_Renting__c == caso.RentingType__c &&
                                caso.RentingType__c == 'Flexible'){
                                if (tarifaRenting.Duracion__c == '19'){
                                    caso.Cuota_31_a_60_dias__c = tarifaRenting.Importe_Cuota__c;
                                    if (caso.Price__c == null && caso.Duration__c == '3'){
                                        caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                    }
                                }    
                                if (tarifaRenting.Duracion__c == '20'){
                                    caso.Cuota_61_a_90_dias__c = tarifaRenting.Importe_Cuota__c;
                                    if (caso.Price__c == null && (caso.Duration__c == '4' || caso.Duration__c =='5')){
                                        caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                    }
                                }    
                                if (tarifaRenting.Duracion__c == '21'){
                                    caso.Cuota_mas_90_dias__c = tarifaRenting.Importe_Cuota__c;
                                    if (caso.Price__c == null && caso.Duration__c != '3' && caso.Duration__c != '4' && caso.Duration__c != '5'){
                                        caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                    }
                                }    
                            }
                            if (tarifaRenting.Tipo_de_vehiculo__c == caso.VehicleType__c &&
                                tarifaRenting.Tipo_Renting__c == caso.RentingType__c &&
                                caso.RentingType__c == 'Diario'){
                                if (tarifaRenting.Duracion__c == '22'){caso.Cuota_1_a_2_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '23'){caso.Cuota_3_a_6_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '24'){caso.Cuota_7_a_13_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '25'){caso.Cuota_14_a_20_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '26'){caso.Cuota_21_a_30_dias__c = tarifaRenting.Importe_Cuota__c;}
                                if (caso.Franquicia_Seguro__c == null && tarifaRenting.Franquicia_Seguro__c != null){
                                    caso.Franquicia_Seguro__c = tarifaRenting.Franquicia_Seguro__c;    
                                }     
                            }
                        }
                    }    
                }
            }
            else if (caso.Origen_Renting__c == 'MYCARFLIX'){
                caso.Cuota_12_meses__c = null;
                caso.Cuota_24_meses__c = null;
                caso.Cuota_36_meses__c = null;
                caso.Cuota_48_meses__c = null;
                caso.Cuota_60_meses__c = null;
                caso.Cuota_1_a_2_dias__c = null;
                caso.Cuota_3_a_6_dias__c = null;
                caso.Cuota_7_a_13_dias__c = null;
                caso.Cuota_14_a_20_dias__c = null;
                caso.Cuota_21_a_30_dias__c = null;
                caso.Cuota_31_a_60_dias__c = null;
                caso.Cuota_61_a_90_dias__c = null;
                caso.Cuota_mas_90_dias__c = null;
                caso.Franquicia_Seguro__c = null;
                if (caso.TarifaID__c != null){
                    for(Tarifa_Renting__c tarifaRenting : listTarifaRenting){
                        if (Label.RtTarifaMycarflix.equalsIgnoreCase(tarifaRenting.RecordType.Name)){
                            if (tarifaRenting.TarifaID__c == caso.TarifaID__c) {
                                caso.Tarifa_Renting__c = tarifaRenting.Id;
                                caso.Valor_del_vehiculo__c = tarifaRenting.Valor_del_vehiculo__c;
                                if (caso.Duration__c == '5'){caso.Valor_residual__c = tarifaRenting.Valor_residual_3m__c;}
                                if (caso.Duration__c == '8'){caso.Valor_residual__c = tarifaRenting.Valor_residual_6m__c;}
                                if (caso.Duration__c == '14'){caso.Valor_residual__c = tarifaRenting.Valor_residual_12m__c;}
                                if (caso.Duration__c == '15'){caso.Valor_residual__c = tarifaRenting.Valor_residual_24m__c;}
                                if (caso.Duration__c == '16'){caso.Valor_residual__c = tarifaRenting.Valor_residual_36m__c;}
                                if (caso.Duration__c == '17'){caso.Valor_residual__c = tarifaRenting.Valor_residual_48m__c;}
                                if (caso.Duration__c == '18'){caso.Valor_residual__c = tarifaRenting.Valor_residual_60m__c;}
                                caso.descmodel__c = tarifaRenting.modelDescription__c;    
                                if (caso.Price__c == null){
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_3m_800km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_3m_1250km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_3m_1600km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_3m_2000km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_3m_2500km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_6m_800km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_6m_1250km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_6m_1600km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_6m_2000km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_6m_2500km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_12m_800km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_12m_1250km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_12m_1600km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_12m_2000km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_12m_2500km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_24m_800km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_24m_1250km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_24m_1600km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_24m_2000km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_24m_2500km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_36m_800km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_36m_1250km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_36m_1600km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_36m_2000km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_36m_2500km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_48m_800km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_48m_1250km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_48m_1600km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_48m_2000km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_48m_2500km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_60m_800km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_60m_1250km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_60m_1600km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_60m_2000km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_60m_2500km__c;}
                                }    
                                break;    
                            }
                        }
                    } 
                }
            }
        }
        
        if(caso.WorkingCreatedDate1__c == null){
            caso.WorkingCreatedDate1__c = BusinessHours.isWithin(bh.Id, datetime.now())?datetime.now():BusinessHours.nextStartDate(bh.Id, datetime.now());
            caso.DateSecondNotification__c = BusinessHours.add(bh.Id, caso.WorkingCreatedDate1__c, integer.valueof(label.TiempoSegundoAviso));
        }
        
        if (caso.ParentId != null && caso.Opportunity__c == null) {
            case casoParent = mapParentCaseById.get(caso.ParentId);
            caso.Opportunity__c = casoParent.Opportunity__c != null? casoParent.Opportunity__c : null;
        }

        If (caso.Marca__c == 'HONDA') {
            caso.Soporte__c = 'HO_C';
        }
        
        If (caso.Marca__c == 'HONDA MOTOS') {
            caso.Soporte__c = 'HO_M';
        }
        System.debug('CaseHandler sale beforeInsert Queries-A: ' + Limits.getQueries());

    }
    
    public void beforeUpdate(sObject old, sObject so) {
        System.debug('CaseHandler entra beforeUpdate Queries-A: ' + Limits.getQueries());
		Case caso = (Case) so;
        Case casoOld = (Case) old;

        String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();
        BusinessHours bh;

        if (caso.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
	        bh = mapBusinessHoursByName.get('DAG Mobility');
        } else if (Label.RtCaseGestionAtencionCliente.equalsIgnoreCase(RTDeveloperName)){
	        bh = mapBusinessHoursByName.get('ATT Importador');
        } else {
        	bh = mapBusinessHoursByName.get('DAG Canarias');
        } 
        
        if(!String.isBlank(caso.SuppliedPhone)){
            String CleanPhone = DataValidations.clearPhone(caso.SuppliedPhone);
            caso.SuppliedPhone = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
            caso.CustomerPhone__c = caso.SuppliedPhone;
        }

        /*if(!String.isBlank(caso.SuppliedEmail) && !DataValidations.validateEmail(caso.SuppliedEmail)){
            caso.SuppliedEmail = null;
        }*/
        if(!String.isBlank(caso.SuppliedEmail) && ((!DataValidations.validateEmail(caso.SuppliedEmail)) || (mapInvalidEmailByEmail.containsKey(caso.SuppliedEmail))) ){
            caso.SuppliedEmail = null;
        }

        boolean hayerror = false;
        system.debug('casoold.Numero_de_llamadas__c: '+casoold.Numero_de_llamadas__c);	
        system.debug('caso.Numero_de_llamadas__c: '+caso.Numero_de_llamadas__c);	
        if (!caso.HasCallTask__c && (casoold.Numero_de_llamadas__c != caso.Numero_de_llamadas__c) &&
           ((casoold.Numero_de_llamadas__c == '0' && caso.Numero_de_llamadas__c != '1') ||
            (casoold.Numero_de_llamadas__c == '1' && caso.Numero_de_llamadas__c != '2') ||
            (casoold.Numero_de_llamadas__c == '2' && caso.Numero_de_llamadas__c != '3') ||
            (casoold.Numero_de_llamadas__c == '3' && caso.Numero_de_llamadas__c != '4') ||
            (casoold.Numero_de_llamadas__c == '4' && caso.Numero_de_llamadas__c != '5') ||
            (casoold.Numero_de_llamadas__c == '5' && caso.Numero_de_llamadas__c != '6') ||
            (casoold.Numero_de_llamadas__c == '6' && caso.Numero_de_llamadas__c != '7') ||
            (casoold.Numero_de_llamadas__c == '7' && caso.Numero_de_llamadas__c != '8') ||
            (casoold.Numero_de_llamadas__c == '8' && caso.Numero_de_llamadas__c != '9') ||
            (casoold.Numero_de_llamadas__c == '9' && caso.Numero_de_llamadas__c != '10') ||
            (casoold.Numero_de_llamadas__c == '10' && caso.Numero_de_llamadas__c != '11') ||
            (casoold.Numero_de_llamadas__c == '11' && caso.Numero_de_llamadas__c != '12') ||
            (casoold.Numero_de_llamadas__c == '12' && caso.Numero_de_llamadas__c != '13') ||
            (casoold.Numero_de_llamadas__c == '13' && caso.Numero_de_llamadas__c != '14') ||
            (casoold.Numero_de_llamadas__c == '14' && caso.Numero_de_llamadas__c != '15') ||
            (casoold.Numero_de_llamadas__c == '15' && caso.Numero_de_llamadas__c != '16') ||
            (casoold.Numero_de_llamadas__c == '16' && caso.Numero_de_llamadas__c != '17') ||
            (casoold.Numero_de_llamadas__c == '17' && caso.Numero_de_llamadas__c != '18') ||
            (casoold.Numero_de_llamadas__c == '18' && caso.Numero_de_llamadas__c != '19') ||
            (casoold.Numero_de_llamadas__c == '19' && caso.Numero_de_llamadas__c != '20'))) {
            system.debug('entra a error numero de llamada');    
            caso.addError('Número de llamada no consecutivo');
            hayerror = true;
        }
        
        if (!hayerror) {
        if (caso.Fecha_Hora_de_cita__c != null) {
            caso.AppointmentDateTXT__c = caso.Fecha_Hora_de_cita__c.day()+'/'+caso.Fecha_Hora_de_cita__c.month()+'/'+caso.Fecha_Hora_de_cita__c.year();
            caso.AppointmentTimeTXT__c = caso.Fecha_Hora_de_cita__c.minute() < 10?caso.Fecha_Hora_de_cita__c.hour()+':0'+caso.Fecha_Hora_de_cita__c.minute():caso.Fecha_Hora_de_cita__c.hour()+':'+caso.Fecha_Hora_de_cita__c.minute();
        }    
        if (caso.Fecha_Hora_de_contacto_c__c == null && 
           (caso.Contactado__c == true || 
            caso.Contactado_Chat__c == true ||
            caso.Contactado_Email__c == true ||
            caso.Contactado_Whatsapp__c == true ||
            caso.Contactado_formulario__c == true)) {
            caso.Fecha_Hora_de_contacto_c__c = datetime.now();
            caso.ContactTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.CreatedDate, caso.Fecha_Hora_de_contacto_c__c);
            caso.ContactTimeTxt__c = BusinessHoursHelper.diferenciaTiempoTxt(bh, caso.CreatedDate, caso.Fecha_Hora_de_contacto_c__c);
        }

        if (caso.DateFirstClose__c == null && caso.Status == Label.StatusClosed) {
            caso.DateFirstClose__c = datetime.now();
            caso.DateUpdateReasonClose__c = BusinessHours.add(bh.Id, caso.DateFirstClose__c, integer.valueof(label.TiempoCambioMotivo));
            caso.TimeToResolveClaim__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.CreatedDate, caso.DateFirstClose__c);
            caso.TimeToResolveClaimTxt__c = BusinessHoursHelper.diferenciaTiempoTxt(bh, caso.CreatedDate, caso.DateFirstClose__c);
        }
        
        if (caso.FirstCallDate__c == null && caso.Numero_de_llamadas__c == '1'){
            caso.FirstCallDate__c = datetime.now();  
            caso.FirstCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.CreatedDate, caso.FirstCallDate__c);
        }

        if (caso.SecondCallDate__c == null && caso.Numero_de_llamadas__c == '2'){
            caso.SecondCallDate__c = datetime.now();
            caso.SecondCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.FirstCallDate__c, caso.SecondCallDate__c);
        }

        if (caso.ThirdCallDate__c == null && caso.Numero_de_llamadas__c == '3'){
            caso.ThirdCallDate__c = datetime.now();
            caso.ThirdCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.SecondCallDate__c, caso.ThirdCallDate__c);
        }

        if (caso.FourthCallDate__c == null && caso.Numero_de_llamadas__c == '4'){
            caso.FourthCallDate__c = datetime.now();   
            caso.FourthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.ThirdCallDate__c, caso.FourthCallDate__c);
        }

        if (caso.FifthCallDate__c == null && caso.Numero_de_llamadas__c == '5'){
            caso.FifthCallDate__c = datetime.now(); 
            caso.FifthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.FourthCallDate__c, caso.FifthCallDate__c);
        }

        if (caso.SixthCallDate__c == null && caso.Numero_de_llamadas__c == '6'){
            caso.SixthCallDate__c = datetime.now();
            caso.SixthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.FifthCallDate__c, caso.SixthCallDate__c);
        }

        if (caso.SeventhCallDate__c == null && caso.Numero_de_llamadas__c == '7'){
            caso.SeventhCallDate__c = datetime.now();
            caso.SeventhCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.SixthCallDate__c, caso.SeventhCallDate__c);
        }

        if (caso.EighthCallDate__c == null && caso.Numero_de_llamadas__c == '8'){
            caso.EighthCallDate__c = datetime.now();
            caso.EighthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.SeventhCallDate__c, caso.EighthCallDate__c);
        }

        if (caso.NinthCallDate__c == null && caso.Numero_de_llamadas__c == '9'){
            caso.NinthCallDate__c = datetime.now();
            caso.NinthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.EighthCallDate__c, caso.NinthCallDate__c);
        }

        if (caso.TenthCallDate__c == null && caso.Numero_de_llamadas__c == '10'){
            caso.TenthCallDate__c = datetime.now();
            caso.TenthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.NinthCallDate__c, caso.TenthCallDate__c);
        }
        
        if (Label.RtCaseIncidenciaMobility.equalsIgnoreCase(RTDeveloperName)) {
            if (caso.Contrato_Rent_A_Car__c != null){
            	Contrato_Rent_A_Car__c ContratoRentACar = mapContratoRentACarById.get(caso.Contrato_Rent_A_Car__c);
                if (ContratoRentACar != null){
                    if (caso.Vehiculo__c == null) {
                    	caso.Vehiculo__c = ContratoRentACar.vehicle__c;
                    }    
                    if (caso.Marca__c == null) {
                    	caso.Marca__c = ContratoRentACar.brand__c;
                    }    
                    if (caso.Centro__c == null) {
	                    caso.Centro__c = ContratoRentACar.pickUpLocation__c;
                    }
                    if (caso.Subject == null) {
	                    caso.Subject = 'Incidencia Mobility contrato: ' + ContratoRentACar.Name + ' ' + datetime.now();
                    }
                    if (ContratoRentACar.driver__c != null && 
                        ContratoRentACar.driver__r.IsPersonAccount == true && 
                        caso.AccountId == null) {
                        if (ContratoRentACar.driver__r.PersonEmail != null && caso.SuppliedEmail == null) {
                            caso.SuppliedEmail = ContratoRentACar.driver__r.PersonEmail;
                        }
                        if (ContratoRentACar.driver__r.PersonMobilePhone != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.PersonMobilePhone;
                        } else if (ContratoRentACar.driver__r.Phone != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.Phone;
                        }
                        caso.SuppliedName = ContratoRentACar.driver__r.Name;
                        caso.AccountId = ContratoRentACar.driver__c;
                        caso.ContactId = ContratoRentACar.driver__r.PersonContactId;
                    } else if (ContratoRentACar.driver__c != null && caso.AccountId == null) {
                        if (ContratoRentACar.driver__r.Email__c != null && caso.SuppliedEmail == null) {
                            caso.SuppliedEmail = ContratoRentACar.driver__r.Email__c;
                        }
                        if (ContratoRentACar.driver__r.Mobile__c != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.Mobile__c;
                        } else if (ContratoRentACar.driver__r.Phone != null && caso.SuppliedPhone == null){
                            caso.SuppliedPhone = ContratoRentACar.driver__r.Phone;
                        }
                        caso.SuppliedName = ContratoRentACar.driver__r.Name;
                        caso.AccountId = ContratoRentACar.driver__c;
                    }
                    if (caso.SuppliedName == null && caso.AccountId != null) {
                        Account cuenta = mapAccountById.get(caso.AccountId);
                        if (cuenta != null && cuenta.IsPersonAccount == true) {
                        	if (cuenta.PersonEmail != null && caso.SuppliedEmail == null) {
                            	caso.SuppliedEmail = cuenta.PersonEmail;
                        	}
                        	if (cuenta.PersonMobilePhone != null && caso.SuppliedPhone == null){
                            	caso.SuppliedPhone = cuenta.PersonMobilePhone;
                        	} else if (cuenta.Phone != null && caso.SuppliedPhone == null){
                            	caso.SuppliedPhone = cuenta.Phone;
                        	}
                        	caso.SuppliedName = cuenta.Name;
                        	caso.ContactId = cuenta.PersonContactId;
                        } else if (cuenta != null && cuenta.IsPersonAccount == false) {
                            if (cuenta.Email__c != null && caso.SuppliedEmail == null) {
                                caso.SuppliedEmail = cuenta.Email__c;
                            }
                            if (cuenta.Mobile__c != null && caso.SuppliedPhone == null){
                                caso.SuppliedPhone = cuenta.Mobile__c;
                            } else if (cuenta.Phone != null && caso.SuppliedPhone == null){
                                caso.SuppliedPhone = cuenta.Phone;
                            }
                            caso.SuppliedName = cuenta.Name;
                        }    
                    }
                }
            }    
        }
        
        if (Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName)) {
            if (caso.Origen_Renting__c == 'XTRAVANS'){
                caso.Tarifa_Renting__c = null;
                if ((caso.VehicleType__c != casoOld.VehicleType__c) ||  
                    (caso.RentingType__c != casoOld.RentingType__c) ||
                    (caso.Marca__c != casoOld.Marca__c) ||  
                    (caso.Modelo__c != casoOld.Modelo__c) ||
                    (caso.descmodel__c != casoOld.descmodel__c) ||
                    (caso.Duration__c != casoOld.Duration__c)){
                    caso.Cuota_12_meses__c = null;
                    caso.Cuota_24_meses__c = null;
                    caso.Cuota_36_meses__c = null;
                    caso.Cuota_48_meses__c = null;
                    caso.Cuota_60_meses__c = null;
                    caso.Cuota_1_a_2_dias__c = null;
                    caso.Cuota_3_a_6_dias__c = null;
                    caso.Cuota_7_a_13_dias__c = null;
                    caso.Cuota_14_a_20_dias__c = null;
                    caso.Cuota_21_a_30_dias__c = null;
                    caso.Cuota_31_a_60_dias__c = null;
                    caso.Cuota_61_a_90_dias__c = null;
                    caso.Cuota_mas_90_dias__c = null;                   
                    caso.Valor_del_vehiculo__c = null;
                    caso.Price__c = null;
                    caso.Franquicia_Seguro__c = null;    
                }
                if (caso.VehicleType__c != null && caso.RentingType__c != null && 
                    caso.Cuota_12_meses__c == null &&
                    caso.Cuota_24_meses__c == null &&
                    caso.Cuota_36_meses__c == null &&
                    caso.Cuota_48_meses__c == null &&
                    caso.Cuota_60_meses__c == null &&
                    caso.Cuota_1_a_2_dias__c == null &&
                    caso.Cuota_3_a_6_dias__c == null &&
                    caso.Cuota_7_a_13_dias__c == null &&
                    caso.Cuota_14_a_20_dias__c == null &&
                    caso.Cuota_21_a_30_dias__c == null &&
                    caso.Cuota_31_a_60_dias__c == null &&
                    caso.Cuota_61_a_90_dias__c == null &&
                    caso.Cuota_mas_90_dias__c == null &&
                    caso.Franquicia_Seguro__c == null){
                    for(Tarifa_Renting__c tarifaRenting : listTarifaRenting){
                        if (Label.RtTarifaXtravans.equalsIgnoreCase(tarifaRenting.RecordType.Name)){
                            if (tarifaRenting.Tipo_de_vehiculo__c == caso.VehicleType__c &&
                                tarifaRenting.Tipo_Renting__c == caso.RentingType__c &&
                                caso.RentingType__c == 'Fijo'){
                                if (tarifaRenting.Duracion__c == '14'){caso.Cuota_12_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '15'){caso.Cuota_24_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '16'){caso.Cuota_36_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '17'){caso.Cuota_48_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '18'){caso.Cuota_60_meses__c = tarifaRenting.Importe_Cuota__c;}    
                                if (caso.Price__c == null && caso.Duration__c == tarifaRenting.Duracion__c){
                                    caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                }
                                if (caso.Marca__c == null &&
                                    caso.Modelo__c == null &&
                                    caso.descmodel__c == null &&
                                    caso.Valor_del_vehiculo__c == null) {
                                    caso.Valor_del_vehiculo__c = tarifaRenting.Valor_del_vehiculo__c;    
                                    caso.Marca__c = tarifaRenting.Marca__c;
                                    caso.Modelo__c = tarifaRenting.Modelo__c;
                                    caso.descmodel__c = tarifaRenting.modelDescription__c;
                                }    
                                if (caso.Marca__c == tarifaRenting.Marca__c &&
                                    caso.Modelo__c == tarifaRenting.Modelo__c &&
                                    caso.descmodel__c == tarifaRenting.modelDescription__c &&
                                    caso.Valor_del_vehiculo__c == null) {
                                    caso.Valor_del_vehiculo__c = tarifaRenting.Valor_del_vehiculo__c;    
                                }    
                            }
                            if (tarifaRenting.Tipo_de_vehiculo__c == caso.VehicleType__c &&
                                tarifaRenting.Tipo_Renting__c == caso.RentingType__c &&
                                caso.RentingType__c == 'Flexible'){
                                if (tarifaRenting.Duracion__c == '19'){
                                    caso.Cuota_31_a_60_dias__c = tarifaRenting.Importe_Cuota__c;
                                    if (caso.Price__c == null && caso.Duration__c == '3'){
                                        caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                    }
                                }    
                                if (tarifaRenting.Duracion__c == '20'){
                                    caso.Cuota_61_a_90_dias__c = tarifaRenting.Importe_Cuota__c;
                                    if (caso.Price__c == null && (caso.Duration__c == '4' || caso.Duration__c =='5')){
                                        caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                    }
                                }    
                                if (tarifaRenting.Duracion__c == '21'){
                                    caso.Cuota_mas_90_dias__c = tarifaRenting.Importe_Cuota__c;
                                    if (caso.Price__c == null && caso.Duration__c != '3' && caso.Duration__c != '4' && caso.Duration__c != '5'){
                                        caso.Price__c = tarifaRenting.Importe_Cuota__c;
                                    }
                                }
                            }
                            if (tarifaRenting.Tipo_de_vehiculo__c == caso.VehicleType__c &&
                                tarifaRenting.Tipo_Renting__c == caso.RentingType__c &&
                                caso.RentingType__c == 'Diario'){
                                if (tarifaRenting.Duracion__c == '22'){caso.Cuota_1_a_2_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '23'){caso.Cuota_3_a_6_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '24'){caso.Cuota_7_a_13_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '25'){caso.Cuota_14_a_20_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (tarifaRenting.Duracion__c == '26'){caso.Cuota_21_a_30_dias__c = tarifaRenting.Importe_Cuota__c;}    
                                if (caso.Franquicia_Seguro__c == null && tarifaRenting.Franquicia_Seguro__c != null){
                                    caso.Franquicia_Seguro__c = tarifaRenting.Franquicia_Seguro__c;    
                                }     
                            }
                            
                        }
                    }    
                }
            }
            else if (caso.Origen_Renting__c == 'MYCARFLIX'){
                caso.Cuota_12_meses__c = null;
                caso.Cuota_24_meses__c = null;
                caso.Cuota_36_meses__c = null;
                caso.Cuota_48_meses__c = null;
                caso.Cuota_60_meses__c = null;
                caso.Cuota_1_a_2_dias__c = null;
                caso.Cuota_3_a_6_dias__c = null;
                caso.Cuota_7_a_13_dias__c = null;
                caso.Cuota_14_a_20_dias__c = null;
                caso.Cuota_21_a_30_dias__c = null;
                caso.Cuota_31_a_60_dias__c = null;
                caso.Cuota_61_a_90_dias__c = null;
                caso.Cuota_mas_90_dias__c = null;
                caso.Franquicia_Seguro__c = null;    
                if ((caso.Marca__c != casoOld.Marca__c) ||  
                    (caso.Modelo__c != casoOld.Modelo__c) ||
                    (caso.TarifaID__c != casoOld.TarifaID__c) ||
                    (caso.Duration__c != casoOld.Duration__c) ||
                    (caso.ExpectedKms__c != casoOld.ExpectedKms__c)){
                     caso.Tarifa_Renting__c = null;   
                     caso.Valor_del_vehiculo__c = null;
                     caso.Price__c = null;   
                }       
                if (caso.TarifaID__c != null &&
                    caso.Tarifa_Renting__c == null){
                    system.debug('listTarifaRenting: '+listTarifaRenting);    
                    for(Tarifa_Renting__c tarifaRenting : listTarifaRenting){
                        system.debug('tarifaRenting.RecordType.Name: '+tarifaRenting.RecordType.Name);
                        system.debug('tarifaRenting.TarifaID__c: '+tarifaRenting.TarifaID__c);
                        system.debug('caso.TarifaID__c: '+caso.TarifaID__c);
                        if (Label.RtTarifaMycarflix.equalsIgnoreCase(tarifaRenting.RecordType.Name)){
                            if (tarifaRenting.TarifaID__c == caso.TarifaID__c) {
                                caso.Tarifa_Renting__c = tarifaRenting.Id;
                                caso.Valor_del_vehiculo__c = tarifaRenting.Valor_del_vehiculo__c;
                                if (caso.Duration__c == '5'){caso.Valor_residual__c = tarifaRenting.Valor_residual_3m__c;}
                                if (caso.Duration__c == '8'){caso.Valor_residual__c = tarifaRenting.Valor_residual_6m__c;}
                                if (caso.Duration__c == '14'){caso.Valor_residual__c = tarifaRenting.Valor_residual_12m__c;}
                                if (caso.Duration__c == '15'){caso.Valor_residual__c = tarifaRenting.Valor_residual_24m__c;}
                                if (caso.Duration__c == '16'){caso.Valor_residual__c = tarifaRenting.Valor_residual_36m__c;}
                                if (caso.Duration__c == '17'){caso.Valor_residual__c = tarifaRenting.Valor_residual_48m__c;}
                                if (caso.Duration__c == '18'){caso.Valor_residual__c = tarifaRenting.Valor_residual_60m__c;}
                                caso.descmodel__c = tarifaRenting.modelDescription__c;    
                                if (caso.Price__c == null){
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_3m_800km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_3m_1250km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_3m_1600km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_3m_2000km__c;}
                                    if (caso.Duration__c == '5' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_3m_2500km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_6m_800km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_6m_1250km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_6m_1600km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_6m_2000km__c;}
                                    if (caso.Duration__c == '8' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_6m_2500km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_12m_800km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_12m_1250km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_12m_1600km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_12m_2000km__c;}
                                    if (caso.Duration__c == '14' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_12m_2500km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_24m_800km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_24m_1250km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_24m_1600km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_24m_2000km__c;}
                                    if (caso.Duration__c == '15' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_24m_2500km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_36m_800km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_36m_1250km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_36m_1600km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_36m_2000km__c;}
                                    if (caso.Duration__c == '16' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_36m_2500km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_48m_800km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_48m_1250km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_48m_1600km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_48m_2000km__c;}
                                    if (caso.Duration__c == '17' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_48m_2500km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '800'){caso.Price__c = tarifaRenting.Cuota_60m_800km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '1250'){caso.Price__c = tarifaRenting.Cuota_60m_1250km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '1600'){caso.Price__c = tarifaRenting.Cuota_60m_1600km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '2000'){caso.Price__c = tarifaRenting.Cuota_60m_2000km__c;}
                                    if (caso.Duration__c == '18' && caso.ExpectedKms__c == '2500'){caso.Price__c = tarifaRenting.Cuota_60m_2500km__c;}
                                }    
                                break;    
                            }
                        }
                    } 
                }                 
            }
            
            if (caso.Status == Label.StatusGenerarPropuesta){
                caso.fecha_de_propuesta__c = date.today();
                String Plantilla;
                if (caso.Origen_Renting__c == 'XTRAVANS'){
                    if (caso.RentingType__c == null ||
                        caso.VehicleType__c == null){
                        caso.addError('Para poder generar la propuesta de Xtravans, el tipo de renting, y el tipo de vehículo son obligatorios');
                    } else{
                        if (caso.RentingType__c != 'Diario'){
	                    	Plantilla = 'PropuestaXtravans';
                        }    
                    }
                } else if (caso.Origen_Renting__c == 'MYCARFLIX'){
                    if (caso.Marca__c == null ||
                        caso.Modelo__c == null ||
                        caso.descmodel__c == null ||
                        caso.Duration__c == null ||
                        caso.ExpectedKms__c == null ||
                        caso.Price__c == null ){
                        caso.addError('Para poder generar la propuesta de Mycarflix, la marca, el modelo, descripción de modelo, duración, kms previstos y precio son obligatorios');
                    } else{
	                    Plantilla = 'PropuestaMycarflix';
                    }
                }    
                if (Plantilla != null){
                    SDOC__SDJob__c job =
                    new SDOC__SDJob__c(SDOC__Start__c=true,
                              SDOC__Oid__c=caso.Id,
                              SDOC__ObjApiName__c='Case',
                              SDOC__SendEmail__c='0',
                              SDOC__Doclist__c=Plantilla);
                    jobList.add(job);
                    system.debug('jobList:'+jobList);
                    caso.Status = Label.StatusPropuestaGenerada;
                }
            } 
        }                               

        if (Label.RtCaseGestionAtencionCliente.equalsIgnoreCase(RTDeveloperName)) {
            if (caso.Sale__c != null){
            	Detalle_venta__c DetalleVenta = mapDetalleVentaById.get(caso.Sale__c);
                if (DetalleVenta != null){
                    caso.Vehiculo__c = DetalleVenta.Vehiculo__c;
	                caso.registrationPlate__c = DetalleVenta.Vehiculo__r.Name;
	                caso.VIN__c = DetalleVenta.Vehiculo__r.VIN__c;
                    if (!Label.Marcagrupo.contains(DetalleVenta.Vehiculo__r.MarcaString__c)) {
                        caso.Marca__c = 'OTRAS';
                        caso.brandVO__c = DetalleVenta.Vehiculo__r.MarcaString__c;
                    } else {
	                    caso.Marca__c = DetalleVenta.Vehiculo__r.MarcaString__c;
                    }
                    caso.descmodel__c = DetalleVenta.Vehiculo__r.modelDescription__c;
                    if (caso.descmodel__c == null) {
	                    caso.descmodel__c = DetalleVenta.Vehiculo__r.ModeloString__c;
                    }
                    caso.Salesman__c = DetalleVenta.Vendedor__r.Name;
                    caso.SalesmanEmail__c = DetalleVenta.Vendedor__r.Email__c;
                    caso.SalesmanPhone__c = DetalleVenta.Vendedor__r.Phone__c;
                    caso.Centro__c = DetalleVenta.Centro__c;
                }
            }    
            if (caso.AfterSale__c != null){
            	Pase_de_taller__c PaseTaller = mapPaseTallerById.get(caso.AfterSale__c);
                if (PaseTaller != null){
                    caso.Vehiculo__c = PaseTaller.Vehiculo__c;
                    caso.registrationPlate__c = PaseTaller.Vehiculo__r.Name;
                    caso.VIN__c = PaseTaller.Vehiculo__r.VIN__c;
                    if (!Label.Marcagrupo.contains(PaseTaller.Vehiculo__r.MarcaString__c)) {
                        caso.Marca__c = 'OTRAS';
                        caso.brandVO__c = PaseTaller.Vehiculo__r.MarcaString__c;
                    } else {
	                    caso.Marca__c = PaseTaller.Vehiculo__r.MarcaString__c;
                    }
                    caso.descmodel__c = PaseTaller.Vehiculo__r.modelDescription__c;
                    if (caso.descmodel__c == null) {
	                    caso.descmodel__c = PaseTaller.Vehiculo__r.ModeloString__c;
                    }
                    caso.Salesman__c = PaseTaller.serviceAdviser__r.Name;
                    caso.SalesmanEmail__c = PaseTaller.serviceAdviser__r.Email__c;
                    caso.SalesmanPhone__c = PaseTaller.serviceAdviser__r.Phone__c;
                    caso.Centro__c = PaseTaller.Centro__c;
                }
            }
            if (caso.Vehiculo__c != null && caso.Sale__c == null && caso.AfterSale__c == null) {
            	Vehiculo__c Vehiculo = mapVehiculoById.get(caso.Vehiculo__c);
                if (Vehiculo != null){
                    caso.registrationPlate__c = Vehiculo.Name;
                    caso.VIN__c = Vehiculo.VIN__c;
                    if (!Label.Marcagrupo.contains(Vehiculo.MarcaString__c)) {
                        caso.Marca__c = 'OTRAS';
                        caso.brandVO__c = Vehiculo.MarcaString__c;
                    } else {
	                    caso.Marca__c = Vehiculo.MarcaString__c;
                    }
                    caso.descmodel__c = Vehiculo.modelDescription__c;
                    if (caso.descmodel__c == null) {
	                    caso.descmodel__c = Vehiculo.ModeloString__c;
                    }
                }
            }
        }
        }
        
        if (caso.ParentId != null && caso.Opportunity__c == null) {
            case casoParent = mapParentCaseById.get(caso.ParentId);
            caso.Opportunity__c = casoParent.Opportunity__c != null? casoParent.Opportunity__c : null;
        }
        
        If (caso.Marca__c == 'HONDA') {
            caso.Soporte__c = 'HO_C';
        }
        
        If (caso.Marca__c == 'HONDA MOTOS') {
            caso.Soporte__c = 'HO_M';
        }
        System.debug('CaseHandler sale beforeUpdate Queries-A: ' + Limits.getQueries());
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        System.debug('CaseHandler entra afterInsert Queries-A: ' + Limits.getQueries());
        //si estos campos vienen llenos: Centro__c, Marca__c, Intencion_de_compra__c
        Case caso = (Case) so;
        Boolean consentimientoSend = true;
        String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();

        if (Label.RTCaseSyncMKTCloud.contains(RTDeveloperName)){ 
            if (!String.isBlank(caso.Lead__c)){
                Lead relLead = mapLeadByLeadId.get(caso.Lead__c);
	            if (caso.EndAdvertisingImpact__c > date.today()) {
                    if (!relLead.ConCasosMKTImp__c) {
                        if (mapLeadActMKT.containsKey(relLead.id)) {
                            Lead relLead1 = mapLeadActMKT.get(relLead.id);
	                        relLead1.ConCasosMKTImp__c = true;
                            mapLeadActMKT.put(relLead1.id,relLead1); 
                        } else {
	                        Lead relLead1 = new Lead();
	                        relLead1.id = relLead.id;
	                        relLead1.ConCasosMKTImp__c = true;
	                        relLead1.ConCasosMKTNoImp__c = relLead.ConCasosMKTNoImp__c;
                            mapLeadActMKT.put(relLead1.id,relLead1); 
                        }
                    }
                } else {
                    if (!relLead.ConCasosMKTNoImp__c) {
                        if (mapLeadActMKT.containsKey(relLead.id)) {
                            Lead relLead1 = mapLeadActMKT.get(relLead.id);
	                        relLead1.ConCasosMKTNoImp__c = true;
                            mapLeadActMKT.put(relLead1.id,relLead1); 
                        } else {
                            Lead relLead1 = new Lead();
                            relLead1.id = relLead.id;
                            relLead1.ConCasosMKTImp__c = relLead.ConCasosMKTImp__c;
                            relLead1.ConCasosMKTNoImp__c = true;
                            mapLeadActMKT.put(relLead1.id,relLead1);
                        } 
                    }
                }    
            }
            if (!String.isBlank(caso.AccountId)){
                Contact contacto = mapContactByAccountId.get(caso.AccountId);
	            if (caso.EndAdvertisingImpact__c > date.today()) {
	                if (contacto != null && !contacto.Account.ConCasosMKTImp__c && contacto.Account.IsPersonAccount) {
                        if (mapAccountActMKT.containsKey(contacto.AccountId)) {
                            Account relAccount = mapAccountActMKT.get(contacto.AccountId);
                            relAccount.ConCasosMKTImp__c = true;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        } else {
                            Account relAccount = new Account();
                            relAccount.id = contacto.AccountId;
                            relAccount.ConCasosMKTImp__c = true;
                            relAccount.ConCasosMKTNoImp__c = contacto.Account.ConCasosMKTNoImp__c;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        }
                    }
                } else {
	                if (contacto != null && !contacto.Account.ConCasosMKTNoImp__c && contacto.Account.IsPersonAccount) {
                        if (mapAccountActMKT.containsKey(contacto.AccountId)) {
                            Account relAccount = mapAccountActMKT.get(contacto.AccountId);
                            relAccount.ConCasosMKTNoImp__c = true;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        } else {
                            Account relAccount = new Account();
                            relAccount.id = contacto.AccountId;
                            relAccount.ConCasosMKTImp__c = contacto.Account.ConCasosMKTImp__c;
                            relAccount.ConCasosMKTNoImp__c = true;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        }
                    }
                } 
            }  
        }

        System.debug('RTDeveloperName'+RTDeveloperName);
        System.debug('caso: '+caso);
        System.debug('Label.RtCaseGestionLead'+Label.RtCaseGestionLead);
        system.debug('caso.Marca__c: '+caso.Marca__c);
        if (Label.RtCaseFeedbackCliente.equalsIgnoreCase(RTDeveloperName) && (caso.Marca__c == 'DUCATI' || caso.Marca__c == 'CITROËN')) {
            listSendEmailFeedback.add(caso);
            system.debug('listSendEmailFeedback: '+listSendEmailFeedback);    
        }    

        //Gestion Lead
        if (Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) || Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName) ||
            Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName)) {
            //gestion automática Lead envio Mulesoft
            if (Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) && caso.Status != Label.StatusClosed){
                //Si es recomendado lo derivamos al vendedor de la operación desde el que se recomendo, sin intervencion de OPP
                Gestion_Lead__c gestionLead;
                Boolean EnvioGestor = false; 
                if (caso.RecommendBy__c != null){
            	 	Detalle_venta__c DetalleVenta = mapDetalleVentaByOpportunityId.get(caso.RecommendBy__c);
                    if (DetalleVenta != null){
                        if (DetalleVenta.Vendedor__r.Email__c !=null && DetalleVenta.Intermediario__c == null && 
							DetalleVenta.Centro__r.Id_Centro_Sima__c != '444-01' &&
                            DetalleVenta.Centro__r.Id_Centro_Sima__c != '444-02'){
                            System.debug('DetalleVenta:'+DetalleVenta);
                            gestionLead = new Gestion_Lead__c();
                            gestionLead.Centro__c = DetalleVenta.Centro__c;
                            gestionLead.Centro_destino__c = DetalleVenta.Centro__c;
                            gestionLead.Gestor_Lead__c = Label.gestorLeadExposicion;
                            gestionLead.Intencion_de_compra__c = caso.Intencion_de_compra__c;
                            gestionLead.Marca__c = caso.Marca__c;
                            gestionLead.Origen__c = caso.Origin;
                            gestionLead.RecordTypeId = Schema.SObjectType.Gestion_Lead__c.getRecordTypeInfosByDeveloperName().get(Label.RtGLeadVN).getRecordTypeId();
                            gestionLead.EmailAsesor__c = DetalleVenta.Vendedor__r.Email__c;
                            System.debug('gestionLead creado:'+gestionLead);
                        } else {
                            //Para los casos con interemediario o con el gestor sin informar se enviara el lead al gestor de lead del centro
                            //que tiene la venta
                            System.debug('entra por aqui');
                            EnvioGestor = true; 
                        }
                    } else {
                    	Opportunity ProcesoVenta = mapOpportunityById.get(caso.RecommendBy__c);
                        if (ProcesoVenta != null){
                            if (ProcesoVenta.Vendedor__r.Email__c !=null &&
	                            ProcesoVenta.Centro__r.Id_Centro_Sima__c != '444-01' &&
	                            ProcesoVenta.Centro__r.Id_Centro_Sima__c != '444-02'){
                                System.debug('ProcesoVenta:'+ProcesoVenta);
                                gestionLead = new Gestion_Lead__c();
                                gestionLead.Centro__c = ProcesoVenta.Centro__c;
                                gestionLead.Centro_destino__c = ProcesoVenta.Centro__c;
                                gestionLead.Gestor_Lead__c = Label.gestorLeadExposicion;
                                gestionLead.Intencion_de_compra__c = caso.Intencion_de_compra__c;
                                gestionLead.Marca__c = caso.Marca__c;
                                gestionLead.Origen__c = caso.Origin;
                                gestionLead.RecordTypeId = Schema.SObjectType.Gestion_Lead__c.getRecordTypeInfosByDeveloperName().get(Label.RtGLeadVN).getRecordTypeId();
                                gestionLead.EmailAsesor__c = ProcesoVenta.Vendedor__r.Email__c;
                                System.debug('gestionLead creado2:'+gestionLead);
                            } else {
                                //Para los casos con interemediario o con el gestor sin informar se enviara el lead al gestor de lead del centro
                                //que tiene el proceso de venta
                                System.debug('entra por aqui 1');
                                EnvioGestor = true; 
                        	}
                        }
                    }   
                } 

                if (caso.RecommendByPT__c != null){
                    System.debug('entra por aqui 2');
                    EnvioGestor = true; 
                } 

                System.debug('caso.Centro__c:'+caso.Centro__c); 
                System.debug('caso.Marca__c:'+caso.Marca__c); 
                System.debug('caso.Intencion_de_compra__c:'+caso.Intencion_de_compra__c);
                System.debug('caso.Origin:'+caso.Origin);

                // Buscamos la Gestion Lead que corresponde al caso
                if (gestionLead == null &&
                    caso.Centro__c != null && 
                    !String.isBlank(caso.Marca__c) && 
                    !String.isBlank(caso.Intencion_de_compra__c) && 
                    !String.isBlank(caso.Origin) ) {
                    system.debug('Inma Entra a buscar ');    
            	 	for (Gestion_Lead__c gLead  :mapGLeadById.values()) {
                		if (Label.RtGLeadVN.equalsIgnoreCase(gLead.RecordType.DeveloperName)
                            && gLead.Centro__c == caso.Centro__c && caso.Marca__c.equalsIgnoreCase(gLead.Marca__c)
                        	&& caso.Intencion_de_compra__c.contains(gLead.Intencion_de_compra__c)
                        	&& caso.Origin == gLead.Origen__c) {
                    		gestionLead = gLead;
                            System.debug('gLead: '+gLead);    
                    		break;
                		}
            		}
                }
                
                //si la gestión lead es de concesionario, se deriava automáticamente
                if (gestionLead != null && (Label.gestorLeadExposicion.equalsIgnoreCase(gestionLead.Gestor_Lead__c) || EnvioGestor)) {
                    System.debug('entra a envio directo');
                    Centro__c centro = mapCentroById.get(gestionLead.Centro__c);
                    if(!centro.Concesionario__r.Es_SIMA__c){
                       listSendEmail.add(caso);
                    }
                    else{
                      	listSendMulesoft.add(caso);
                    }
                    consentimientoSend=false;
                    gLead = gestionLead;
                }
            }
            else if (Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName) && caso.Status != Label.StatusClosed){
                if (caso.Centro__c != null && !String.isBlank(caso.Intencion_de_compra__c) && !String.isBlank(caso.Origin) ) {
            		Gestion_Lead__c gestionLead;
            		for (Gestion_Lead__c gLead  :mapGLeadById.values()) {
                		if (Label.RtGLeadVO.equalsIgnoreCase(gLead.RecordType.DeveloperName)
                            && gLead.Centro__c == caso.Centro__c 
                        	&& caso.Intencion_de_compra__c.contains(gLead.Intencion_de_compra__c)
                        	&& caso.Origin == gLead.Origen__c
                        	) {
                    		gestionLead = gLead;
                    		break;
                		}
            		}
               		 if (gestionLead != null &&  Label.gestorLeadExposicion.equalsIgnoreCase(gestionLead.Gestor_Lead__c)) {
                    	listSendEmailVO.add(caso);
                   		consentimientoSend=false;
                    	gLead = gestionLead;
                	}
        		}
            }
			
            //Consentimientos 
			Campaign campana = caso.Campana__c != null &&  mapCampaignById.containsKey(caso.Campana__c)?mapCampaignById.get(caso.Campana__c):null;
            if((Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) && campana != null && Label.CampaignsAmigo.contains(campana.Name)) || 
               (Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName) && campana != null && Label.CampaignsPepeCar.contains(campana.Name))){
                //Consentimiento Lead para campaña HY Amigo  y PepeCar
                system.debug('consentimiento pepecar1');
                if(!String.isBlank(caso.Lead__c) && mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)){
                system.debug('consentimiento pepecar2');
                	Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.Lead__c)?mapConsentimientovalueByAOrLToUpsert.get(caso.Lead__c): new Map<String,Consentimientos__c>();
                    Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByLeadId.get(caso.Lead__c);
                    if(!String.isBlank(caso.SuppliedEmail)){
                        String email = caso.SuppliedEmail.toLowerCase();
                        Consentimientos__c consentimientoToUpdate;
                        if(!mapConsentimientoByValue.containsKey(email)){
                            consentimientoToUpdate = CaseHelper.CreateConsentimientoBase(email, caso, Label.channelEmail );
                            consentimientoToUpdate.Lead__c = caso.Lead__c;
                        	consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        	mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate); 
                        }
                       
                    }
                	if(!String.isBlank(caso.SuppliedPhone)){
                        Consentimientos__c consentimientoToUpdate;
                        String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                        if(!mapConsentimientoByValue.containsKey(caso.SuppliedPhone)){
                            consentimientoToUpdate = CaseHelper.createConsentimientoBase(caso.SuppliedPhone, caso, tipo);
                            consentimientoToUpdate.Lead__c = caso.Lead__c;
                        	consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        	mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                        }
                        
                    }
                	if(!mapConsentimietosByValueToUpsert.isEmpty()){
                     	mapConsentimientovalueByAOrLToUpsert.put(caso.Lead__c,mapConsentimietosByValueToUpsert);
                 	}
                    system.debug('1 mapConsentimientovalueByAOrLToUpsert: '+mapConsentimientovalueByAOrLToUpsert);
             }
            	else if(!String.isBlank(caso.Lead__c)){
                system.debug('consentimiento pepecar3');
                    //Son nuevos
                    Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.Lead__c)?mapConsentimientovalueByAOrLToUpsert.get(caso.Lead__c): new Map<String,Consentimientos__c>();
                    if(!String.isBlank(caso.SuppliedEmail)){
                        String email = caso.SuppliedEmail.toLowerCase();
                        Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimientoBase(email, caso, Label.channelEmail );
                        consentimientoToUpdate.Lead__c = caso.Lead__c;
                        consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                    }
                	if(!String.isBlank(caso.SuppliedPhone)){
                        String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                        Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimientoBase(caso.SuppliedPhone, caso, tipo);
                        consentimientoToUpdate.Lead__c = caso.Lead__c;
                        consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                    }
                	if(!mapConsentimietosByValueToUpsert.isEmpty()){
                     	mapConsentimientovalueByAOrLToUpsert.put(caso.Lead__c,mapConsentimietosByValueToUpsert);
                 	}
                    system.debug('2 mapConsentimientovalueByAOrLToUpsert: '+mapConsentimientovalueByAOrLToUpsert);
            }
                
                //Consentimientos Account para campaña HY Amigo
            	system.debug('mapContactByAccountId:'+ mapContactByAccountId);
            	system.debug('mapConsentimientovalueByAccountId:' +mapConsentimientovalueByAccountId);
            	if(!String.isBlank(caso.AccountId) && mapContactByAccountId.containsKey(caso.AccountId) && mapConsentimientovalueByAccountId.containsKey(caso.AccountId)){
                    //buscar o crear consentimientos para cuentas
                    Contact contacto = mapContactByAccountId.get(caso.AccountId);
                    if(contacto.Account.IsPersonAccount){
                        Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.AccountId)?mapConsentimientovalueByAOrLToUpsert.get(caso.AccountId): new Map<String,Consentimientos__c>();
                        Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAccountId.get(caso.AccountId);
                        if(!String.isBlank(caso.SuppliedEmail)){
                            String email = caso.SuppliedEmail.toLowerCase();
                            Consentimientos__c consentimientoToUpdate;
                            if(!mapConsentimientoByValue.containsKey(email)){
                                consentimientoToUpdate = CaseHelper.createConsentimientoBase(email, caso, Label.channelEmail );
                                consentimientoToUpdate.Contact__c = contacto.Id ;
                                consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                                consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                                mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                            }
                        }
                        if(!String.isBlank(caso.SuppliedPhone)){
                            Consentimientos__c consentimientoToUpdate;
                            String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                            if(!mapConsentimientoByValue.containsKey(caso.SuppliedPhone)){
                                consentimientoToUpdate = CaseHelper.createConsentimientoBase(caso.SuppliedPhone, caso, tipo);
                                consentimientoToUpdate.Contact__c = contacto.Id;
                                consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                                consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                                mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                            }
                            
                        }
                        if(!mapConsentimietosByValueToUpsert.isEmpty()){
                            mapConsentimientovalueByAOrLToUpsert.put(caso.AccountId,mapConsentimietosByValueToUpsert);
                        }
                        
                    }
            	}
            	else if(!String.isBlank(caso.AccountId) && mapContactByAccountId.containsKey(caso.AccountId)){
                    //Son nuevos
                    Contact contacto = mapContactByAccountId.get(caso.AccountId);
                    if(contacto.Account.IsPersonAccount){
                        Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.AccountId)?mapConsentimientovalueByAOrLToUpsert.get(caso.AccountId): new Map<String,Consentimientos__c>();
                        //Map<String,Consentimientos__c> mapConsentimientoByValue = new Map<String,Consentimientos__c>();
                        if(!String.isBlank(caso.SuppliedEmail)){
                            String email = caso.SuppliedEmail.toLowerCase();
                            Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimientoBase(email, caso, Label.channelEmail );
                            consentimientoToUpdate.Contact__c = contacto.Id;
                            consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                            consentimientoToUpdate.EnviarAmulesoft__c =false;
                            mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                        }
                        if(!String.isBlank(caso.SuppliedPhone)){
                            String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                            Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimientoBase(caso.SuppliedPhone, caso, tipo);
                            consentimientoToUpdate.Contact__c = contacto.Id;
                            consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                            consentimientoToUpdate.EnviarAmulesoft__c =false;
                            mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                        }
                        if(!mapConsentimietosByValueToUpsert.isEmpty()){
                            mapConsentimientovalueByAOrLToUpsert.put(caso.AccountId,mapConsentimietosByValueToUpsert);
                        }
                    }
                        
            	}
            }
            else {
                //Consentimientos lead genérico
                if(!String.isBlank(caso.Lead__c) && mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)){
                	Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.Lead__c)?mapConsentimientovalueByAOrLToUpsert.get(caso.Lead__c): new Map<String,Consentimientos__c>();
                    Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByLeadId.get(caso.Lead__c);
                    if(!String.isBlank(caso.SuppliedEmail)){
                        String email = caso.SuppliedEmail.toLowerCase();
                        Consentimientos__c consentimientoToUpdate;
                        if(mapConsentimientoByValue.containsKey(email)){
                            consentimientoToUpdate = mapConsentimientoByValue.get(email);
                            consentimientoToUpdate = CaseHelper.AssigmentConsentimientos(consentimientoToUpdate,caso,Label.channelEmail);
                        }
                        else {
                            consentimientoToUpdate = CaseHelper.createConsentimiento(email, caso, Label.channelEmail );
                        }
                        if(consentimientoToUpdate != null){
                            consentimientoToUpdate.Lead__c = caso.Lead__c;
                        	consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        	mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate); 
                        }
                       
                    }
                	if(!String.isBlank(caso.SuppliedPhone)){
                        Consentimientos__c consentimientoToUpdate;
                        String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                        if(mapConsentimientoByValue.containsKey(caso.SuppliedPhone)){
                            consentimientoToUpdate = mapConsentimientoByValue.get(caso.SuppliedPhone);
                            consentimientoToUpdate = CaseHelper.AssigmentConsentimientos(consentimientoToUpdate,caso,tipo);
                     	}
                        else {
                            consentimientoToUpdate = CaseHelper.createConsentimiento(caso.SuppliedPhone, caso, tipo);
                        }
                        if(consentimientoToUpdate != null){
                            consentimientoToUpdate.Lead__c = caso.Lead__c;
                        	consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        	mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                        }
                        
                    }
                	if(!mapConsentimietosByValueToUpsert.isEmpty()){
                     	mapConsentimientovalueByAOrLToUpsert.put(caso.Lead__c,mapConsentimietosByValueToUpsert);
                 	}
             }
            	else if(!String.isBlank(caso.Lead__c)){
                    //Son nuevos
                    Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.Lead__c)?mapConsentimientovalueByAOrLToUpsert.get(caso.Lead__c): new Map<String,Consentimientos__c>();
                    if(!String.isBlank(caso.SuppliedEmail)){
                        String email = caso.SuppliedEmail.toLowerCase();
                        Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimiento(email, caso, Label.channelEmail );
                        consentimientoToUpdate.Lead__c = caso.Lead__c;
                        consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                    }
                	if(!String.isBlank(caso.SuppliedPhone)){
                        String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                        Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimiento(caso.SuppliedPhone, caso, tipo);
                        consentimientoToUpdate.Lead__c = caso.Lead__c;
                        consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                    }
                	if(!mapConsentimietosByValueToUpsert.isEmpty()){
                     	mapConsentimientovalueByAOrLToUpsert.put(caso.Lead__c,mapConsentimietosByValueToUpsert);
                 	}
            }
            
            	//Consentimientos Account genérico
            	system.debug('mapContactByAccountId:'+ mapContactByAccountId);
            	system.debug('mapConsentimientovalueByAccountId:' +mapConsentimientovalueByAccountId);
            	if(!String.isBlank(caso.AccountId) && mapContactByAccountId.containsKey(caso.AccountId) && mapConsentimientovalueByAccountId.containsKey(caso.AccountId)){
                    //buscar o crear consentimientos para cuentas
                    Contact contacto = mapContactByAccountId.get(caso.AccountId);
                    if(contacto.Account.IsPersonAccount){
                        Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.AccountId)?mapConsentimientovalueByAOrLToUpsert.get(caso.AccountId): new Map<String,Consentimientos__c>();
                        Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAccountId.get(caso.AccountId);
                        if(!String.isBlank(caso.SuppliedEmail)){
                            String email = caso.SuppliedEmail.toLowerCase();
                            Consentimientos__c consentimientoToUpdate;
                            if(mapConsentimientoByValue.containsKey(email)){
                                consentimientoToUpdate = mapConsentimientoByValue.get(email);
                                consentimientoToUpdate = CaseHelper.AssigmentConsentimientos(consentimientoToUpdate,caso,Label.channelEmail);
                            }
                            else {
                                consentimientoToUpdate = CaseHelper.createConsentimiento(email, caso, Label.channelEmail );
                            }
                            if(consentimientoToUpdate != null){
                                consentimientoToUpdate.Contact__c = contacto.Id ;
                                consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                                consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                                mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                            }
                            
                        }
                        if(!String.isBlank(caso.SuppliedPhone)){
                            Consentimientos__c consentimientoToUpdate;
                            String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                            if(mapConsentimientoByValue.containsKey(caso.SuppliedPhone)){
                                consentimientoToUpdate = mapConsentimientoByValue.get(caso.SuppliedPhone);
                                consentimientoToUpdate = CaseHelper.AssigmentConsentimientos(consentimientoToUpdate,caso,tipo);
                            }
                            else {
                                consentimientoToUpdate = CaseHelper.createConsentimiento(caso.SuppliedPhone, caso, tipo);
                            }
                            if(consentimientoToUpdate != null){
                                consentimientoToUpdate.Contact__c = contacto.Id;
                                consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                                consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                                mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                            }
                            
                        }
                        if(!mapConsentimietosByValueToUpsert.isEmpty()){
                            mapConsentimientovalueByAOrLToUpsert.put(caso.AccountId,mapConsentimietosByValueToUpsert);
                        }
                        
                    }
            	}
            	else if(!String.isBlank(caso.AccountId) && mapContactByAccountId.containsKey(caso.AccountId)){
                    //Son nuevos
                    Contact contacto = mapContactByAccountId.get(caso.AccountId);
                    if(contacto.Account.IsPersonAccount){
                        Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.AccountId)?mapConsentimientovalueByAOrLToUpsert.get(caso.AccountId): new Map<String,Consentimientos__c>();
                        //Map<String,Consentimientos__c> mapConsentimientoByValue = new Map<String,Consentimientos__c>();
                        if(!String.isBlank(caso.SuppliedEmail)){
                            String email = caso.SuppliedEmail.toLowerCase();
                            Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimiento(email, caso, Label.channelEmail );
                            consentimientoToUpdate.Contact__c = contacto.Id;
                            consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                            consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                            mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                        }
                        if(!String.isBlank(caso.SuppliedPhone)){
                            String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                            Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimiento(caso.SuppliedPhone, caso, tipo);
                            consentimientoToUpdate.Contact__c = contacto.Id;
                            consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                            consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                            mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                        }
                        if(!mapConsentimietosByValueToUpsert.isEmpty()){
                            mapConsentimientovalueByAOrLToUpsert.put(caso.AccountId,mapConsentimietosByValueToUpsert);
                        }
                    }
                        
            	}
            	system.debug('consentimiento to send Mulesoft: '+consentimientoSend);
            
            }
			
            //CampaignMember
            if(!String.isBlank(caso.Campana__c) ){
                Map<String,CampaignMember> mapCOrLToCMB = mapCOrLToCMByCampaignId.containsKey(caso.Campana__c)? mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
                if(!String.isBlank(caso.AccountId) && mapContactByAccountId.containsKey(caso.AccountId)){
                    Contact contacto = mapContactByAccountId.get(caso.AccountId);
                    if(!mapCOrLToCMB.containsKey(contacto.Id)){
                        Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaignIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaignIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
                        if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
                        	CampaignMember cMember = new CampaignMember();
                    		cMember.CampaignId = caso.Campana__c;
                    		cMember.ContactId = contacto.Id;
                    		cMember.Status = Label.StatustResponded;
                    		mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
                            mapCampaignMemberByCOrLByCampaignIdToInsert.put(caso.Campana__c,mapCampaignMemberToInsert);
						}
                    }
                }
                if(!String.isBlank(caso.Lead__c) && !mapCOrLToCMB.containsKey(caso.Lead__c)){
                    Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaignIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaignIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
                        if(!mapCampaignMemberToInsert.containsKey(caso.Lead__c)){
                        	CampaignMember cMember = new CampaignMember();
                    		cMember.CampaignId = caso.Campana__c;
                    		cMember.LeadId = caso.Lead__c;
                    		cMember.Status = Label.StatustResponded;
                    		mapCampaignMemberToInsert.put(cMember.LeadId,cMember);
                            mapCampaignMemberByCOrLByCampaignIdToInsert.put(caso.Campana__c,mapCampaignMemberToInsert);
                            
                        }
                }
            }
            
        }
        System.debug('CaseHandler sale afterInsert Queries-A: ' + Limits.getQueries());
        
    }
    
    public void afterUpdate(sObject old, sObject so) {
        System.debug('CaseHandler entra afterUpdate Queries-A: ' + Limits.getQueries());
        Case caso = (Case) so;
        Case oldCaso = (Case) old;
        Boolean consentimientoSend = system.isBatch() || system.isScheduled() || system.isFuture() ?false:true;
        String RTDeveloperName = rtMapById.get(caso.RecordTypeId).getDeveloperName();

        if (Label.RTCaseSyncMKTCloud.contains(RTDeveloperName)){ 
            if (!String.isBlank(caso.Lead__c)){
                Lead relLead = mapLeadByLeadId.get(caso.Lead__c);
	            if (caso.EndAdvertisingImpact__c > date.today()) {
                    if (!relLead.ConCasosMKTImp__c) {
                        if (mapLeadActMKT.containsKey(relLead.id)) {
                            Lead relLead1 = mapLeadActMKT.get(relLead.id);
	                        relLead1.ConCasosMKTImp__c = true;
                            mapLeadActMKT.put(relLead1.id,relLead1); 
                        } else {
	                        Lead relLead1 = new Lead();
	                        relLead1.id = relLead.id;
	                        relLead1.ConCasosMKTImp__c = true;
	                        relLead1.ConCasosMKTNoImp__c = relLead.ConCasosMKTNoImp__c;
                            mapLeadActMKT.put(relLead1.id,relLead1); 
                        }
                    }
                } else {
                    if (!relLead.ConCasosMKTNoImp__c) {
                        if (mapLeadActMKT.containsKey(relLead.id)) {
                            Lead relLead1 = mapLeadActMKT.get(relLead.id);
	                        relLead1.ConCasosMKTNoImp__c = true;
                            mapLeadActMKT.put(relLead1.id,relLead1); 
                        } else {
                            Lead relLead1 = new Lead();
                            relLead1.id = relLead.id;
                            relLead1.ConCasosMKTImp__c = relLead.ConCasosMKTImp__c;
                            relLead1.ConCasosMKTNoImp__c = true;
                            mapLeadActMKT.put(relLead1.id,relLead1);
                        } 
                    }
                }    
            }
            if (!String.isBlank(caso.AccountId)){
                Contact contacto = mapContactByAccountId.get(caso.AccountId);
	            if (caso.EndAdvertisingImpact__c > date.today()) {
	                if (contacto != null && !contacto.Account.ConCasosMKTImp__c && contacto.Account.IsPersonAccount) {
                        if (mapAccountActMKT.containsKey(contacto.AccountId)) {
                            Account relAccount = mapAccountActMKT.get(contacto.AccountId);
                            relAccount.ConCasosMKTImp__c = true;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        } else {
                            Account relAccount = new Account();
                            relAccount.id = contacto.AccountId;
                            relAccount.ConCasosMKTImp__c = true;
                            relAccount.ConCasosMKTNoImp__c = contacto.Account.ConCasosMKTNoImp__c;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        }
                    }
                } else {
	                if (contacto != null && !contacto.Account.ConCasosMKTNoImp__c && contacto.Account.IsPersonAccount) {
                        if (mapAccountActMKT.containsKey(contacto.AccountId)) {
                            Account relAccount = mapAccountActMKT.get(contacto.AccountId);
                            relAccount.ConCasosMKTNoImp__c = true;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        } else {
                            Account relAccount = new Account();
                            relAccount.id = contacto.AccountId;
                            relAccount.ConCasosMKTImp__c = contacto.Account.ConCasosMKTImp__c;
                            relAccount.ConCasosMKTNoImp__c = true;
                            mapAccountActMKT.put(relAccount.id, relAccount);
                        }
                    }
                } 
            }  
        }
        
        if (Label.RtCaseGestionAtencionCliente.equalsIgnoreCase(RTDeveloperName) && 
            (caso.Marca__c == 'AUDI' || caso.Marca__c == 'SKODA' ||
             caso.Marca__c == 'VOLKSWAGEN' || caso.Marca__c == 'VW COMERCIALES' ||
             caso.Marca__c == 'DUCATI' || caso.Marca__c == 'HYUNDAI') && 
             caso.Origin == 'Email' && 
             caso.DateTimeFirstSend__c == null &&
             Label.ATTClienteAutorespuesta == 'Si' && caso.SuppliedEmail != null) {
            system.debug('entra a enviar');
            listSendEmailATTCliente.add(caso);
            system.debug('listSendEmailATTCliente: '+listSendEmailATTCliente);    
        }    
        
        //Se envía el email con la propuesta para xtravans diario
        if (Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName) &&
            caso.Status == Label.StatusGenerarPropuesta &&
            caso.RentingType__c == 'Diario') {
            listSendEmailXtravansDiario.add(caso);
        }    

        //Gestion Lead
        if (Label.RtCaseGestionLead.equalsIgnoreCase(RTDeveloperName) || Label.RtCaseGestionLeadVO.equalsIgnoreCase(RTDeveloperName) ||
            Label.RtCaseGestionLeadMobility.equalsIgnoreCase(RTDeveloperName)) {
            
            //Consentimientos Account
            if(!String.isBlank(caso.AccountId) && oldCaso.AccountId != caso.AccountId && mapContactByAccountId.containsKey(caso.AccountId) && mapConsentimientovalueByAccountId.containsKey(caso.AccountId)){
                //buscar o crear consentimientos para cuentas
                Contact contacto = mapContactByAccountId.get(caso.AccountId);
                if(contacto.Account.IsPersonAccount){
					Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.AccountId)?mapConsentimientovalueByAOrLToUpsert.get(caso.AccountId): new Map<String,Consentimientos__c>();
                    Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAccountId.get(caso.AccountId);
                	if(!String.isBlank(caso.SuppliedEmail)){
                        String email = caso.SuppliedEmail.toLowerCase();
                        Consentimientos__c consentimientoToUpdate;
                        if(mapConsentimientoByValue.containsKey(email)){
                            consentimientoToUpdate = CaseHelper.AssigmentConsentimientos(mapConsentimientoByValue.get(email),caso,Label.channelEmail);
                        }
                        else {
                            consentimientoToUpdate = CaseHelper.createConsentimiento(email, caso, Label.channelEmail );
                        }
                        if(consentimientoToUpdate !=null){
                        	consentimientoToUpdate.Contact__c = contacto.Id ;
                        	consentimientoToUpdate.Fecha_de_captura__c =caso.CreatedDate;
                        	consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                        	mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                        }
                    }
                	if(!String.isBlank(caso.SuppliedPhone)){
                        Consentimientos__c consentimientoToUpdate;
                        String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                        if(mapConsentimientoByValue.containsKey(caso.SuppliedPhone)){
                            consentimientoToUpdate = CaseHelper.AssigmentConsentimientos(mapConsentimientoByValue.get(caso.SuppliedPhone),caso,tipo);
                        }
                        else {
                            consentimientoToUpdate = CaseHelper.createConsentimiento(caso.SuppliedPhone, caso, tipo);
                        }
                        if(consentimientoToUpdate != null){
                            consentimientoToUpdate.Contact__c = contacto.Id;
                        	consentimientoToUpdate.Fecha_de_captura__c =caso.CreatedDate;
                        	consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                        	mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                        }
                        
                    }
                    if(!mapConsentimietosByValueToUpsert.isEmpty()){
                     	mapConsentimientovalueByAOrLToUpsert.put(caso.AccountId,mapConsentimietosByValueToUpsert);
                 	}
                    
              	}
            }
            else if(!String.isBlank(caso.AccountId)&& oldCaso.AccountId != caso.AccountId  && mapContactByAccountId.containsKey(caso.AccountId)){
                //Son nuevos
                Contact contacto = mapContactByAccountId.get(caso.AccountId);
                if(contacto.Account.IsPersonAccount){
                    Map<String,Consentimientos__c> mapConsentimietosByValueToUpsert = mapConsentimientovalueByAOrLToUpsert.containsKey(caso.AccountId)?mapConsentimientovalueByAOrLToUpsert.get(caso.AccountId): new Map<String,Consentimientos__c>();
                    //Map<String,Consentimientos__c> mapConsentimientoByValue = new Map<String,Consentimientos__c>();
                	if(!String.isBlank(caso.SuppliedEmail)){
                		String email = caso.SuppliedEmail.toLowerCase();
                    	Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimiento(email, caso, Label.channelEmail );
                    	consentimientoToUpdate.Contact__c = contacto.Id;
                        consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                        mapConsentimietosByValueToUpsert.put(email,consentimientoToUpdate);
                    }
                	if(!String.isBlank(caso.SuppliedPhone)){
                        String tipo = DataValidations.isMobile(caso.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                        Consentimientos__c consentimientoToUpdate = CaseHelper.createConsentimiento(caso.SuppliedPhone, caso, tipo);
                        consentimientoToUpdate.Contact__c = contacto.Id;
                        consentimientoToUpdate.Fecha_de_captura__c =Datetime.now();
                        consentimientoToUpdate.EnviarAmulesoft__c =consentimientoSend;
                        mapConsentimietosByValueToUpsert.put(caso.SuppliedPhone,consentimientoToUpdate);
                    }
                	if(!mapConsentimietosByValueToUpsert.isEmpty()){
                     	mapConsentimientovalueByAOrLToUpsert.put(caso.AccountId,mapConsentimietosByValueToUpsert);
                 	}
                }
                	
            }
            system.debug('consentimiento to send Mulesoft: '+consentimientoSend);
            
            //CampaignMember
            if(!String.isBlank(caso.Campana__c) ){
                Map<String,CampaignMember> mapCOrLToCMB = mapCOrLToCMByCampaignId.containsKey(caso.Campana__c)? mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
                if(!String.isBlank(caso.AccountId) && mapContactByAccountId.containsKey(caso.AccountId)){
                    Contact contacto = mapContactByAccountId.get(caso.AccountId);
                    if(!mapCOrLToCMB.containsKey(contacto.Id)){
                        Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaignIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaignIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
                        if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
                        	CampaignMember cMember = new CampaignMember();
                    		cMember.CampaignId = caso.Campana__c;
                    		cMember.ContactId = contacto.Id;
                    		cMember.Status = Label.StatustResponded;
                    		mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
                            mapCampaignMemberByCOrLByCampaignIdToInsert.put(caso.Campana__c,mapCampaignMemberToInsert);
						}
                    }
                }
            }
            
        }
        System.debug('CaseHandler sale afterUpdate Queries-A: ' + Limits.getQueries());
       
    }

    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        System.debug('CaseHandler entra andFinally Queries-A: ' + Limits.getQueries());
        
        if(!mapConsentimientovalueByAOrLToUpsert.isEmpty()){
            List<Consentimientos__c> listToUpsert = new List<Consentimientos__c>();
            for(String stringId :mapConsentimientovalueByAOrLToUpsert.keySet()){
                Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAOrLToUpsert.get(stringId);
                listToUpsert.addAll(mapConsentimientoByValue.values());
            }
            upsert listToUpsert;
            
        }
        system.debug('mapCampaignMemberByCOrLByCampaignIdToInsert:'+ mapCampaignMemberByCOrLByCampaignIdToInsert);

        if(!mapCampaignMemberByCOrLByCampaignIdToInsert.isEmpty()){
            List<CampaignMember> listCampaignMemberToInsert = new List<CampaignMember>();
            for(String campaignId :mapCampaignMemberByCOrLByCampaignIdToInsert.keySet()){
                Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaignIdToInsert.get(campaignId);
            	system.debug('mapCampaignMemberToInsert:'+ mapCampaignMemberToInsert);
                
                listCampaignMemberToInsert.addAll(mapCampaignMemberToInsert.values());
            }
            Upsert listCampaignMemberToInsert;
        }

        if (!mapLeadActMKT.isEmpty()) { update mapLeadActMKT.values();} 

        if (!mapAccountActMKT.isEmpty()) { update mapAccountActMKT.values();} 
        
        
        if (!listSendMulesoft.isEmpty()) {
            system.debug('listSendMulesoft: ' + listSendMulesoft);
            String JSONCases = JSON.serialize(listSendMulesoft);
            String JSONgLead = JSON.serialize(gLead);
            ExternalServiceController.createExternalLeadOrAccountMulesoft(JSONCases, JSONgLead);
            //enviar caso a Mulesoft;
        }
        if (!listSendEmail.isEmpty()) {
            system.debug('listSendEmail: ' + listSendEmail);
            String JSONCases = JSON.serialize(listSendEmail);
            String JSONgLead = JSON.serialize(gLead);
            ExternalServiceController.sendExternalLeadOrAccountEmail(JSONCases, JSONgLead);
            //enviar caso a Mulesoft;
        }
        
        if (!listSendEmailVO.isEmpty()) {
            system.debug('listSendEmailVO: ' + listSendEmailVO);
            String JSONCases = JSON.serialize(listSendEmailVO);
            String JSONgLead = JSON.serialize(gLead);
            ExternalServiceController.sendExternalLeadOrAccountVO(JSONCases, JSONgLead);
            //enviar caso a Mulesoft;
        }

        if (!listSendEmailFeedback.isEmpty()) {
            system.debug('listSendEmailFeedback: ' + listSendEmailFeedback);
            String JSONCases = JSON.serialize(listSendEmailFeedback);
            ExternalServiceController.sendExternalEmailFeedback(JSONCases);
        }

        if (!listSendEmailATTCliente.isEmpty()) {
            system.debug('listSendEmailATTCliente: ' + listSendEmailATTCliente);
            String JSONCases = JSON.serialize(listSendEmailATTCliente);
            ExternalServiceController.sendExternalEmailATTCliente(JSONCases);
        }
        
        if (!listSendEmailXtravansDiario.isEmpty()) {
            system.debug('listSendEmailXtravansDiario: ' + listSendEmailXtravansDiario);
            String JSONCases = JSON.serialize(listSendEmailXtravansDiario);
            ExternalServiceController.sendExternalEmailXtravansDiario(JSONCases);
        }
        
        if (!jobList.isEmpty()) {
            insert jobList;
       }
       System.debug('CaseHandler sale andFinally Queries-A: ' + Limits.getQueries());

    }
}