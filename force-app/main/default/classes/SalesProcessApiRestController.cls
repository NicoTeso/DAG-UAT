public class SalesProcessApiRestController {
    private static Map<String, Schema.RecordTypeInfo> rtMapConsentimientoByName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByName();
    
    public static ResponseApi createProcessSales(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        
        try {
            //buscar la oportunidad
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }
            list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.createProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}

            String centroIdExterno = req.payload.companyCode + '-' + req.payload.centerCode;
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            Centro__c centro = CentroGateway.getCenterByIdCentroSima(centroIdExterno);
            Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                if (req.payload.salesmanName != null) {
                    vendedor.Name = DataValidations.capitalizeString(req.payload.salesmanName);
                } else {
                    vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                }    
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
        
                if(!String.isBlank(req.payload.salesmanMobile)){
            		String CleanPhone = DataValidations.clearPhone(req.payload.salesmanMobile);
            		vendedor.Phone__c = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
        		}
				insert vendedor;
            } else if (vendedor != null) {
                boolean ActualizaVendedor = false;
				if (req.payload.salesmanName != null && vendedor.Name != DataValidations.capitalizeString(req.payload.salesmanName)) {
                    vendedor.Name = DataValidations.capitalizeString(req.payload.salesmanName);
                    ActualizaVendedor = true;
                }    
                if(!String.isBlank(req.payload.salesmanMobile)){
            		String CleanPhone = DataValidations.clearPhone(req.payload.salesmanMobile);
            		String CleanPhone1 = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
                    if (vendedor.Phone__c != CleanPhone1) {
                        vendedor.Phone__c = CleanPhone1;
                        ActualizaVendedor = true;
                    }
        		}
                if (ActualizaVendedor) {update vendedor;}
            } 
            
            if (centro == null) {
                throw new CustomException(Label.errorMessage_centerNotFound);
            }
            
            String externalId = req.payload.customerId + '/' + req.payload.companyCode;
            Cliente_Concesionario__c cConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(externalId);
            
            if (cConcesionario == null) {
                //insertar cliente si no existe igual que el api 
                AuxAccount__c auxAcc = AuxAccountGateway.getAuxAccountByExternalId(externalId);
                if(auxAcc != null){
                    Account cliente;
                    Concesionario__c concesionario = ConcesionarioGateway.getConcessionaireByCompanyId(req.payload.companyCode);
                    String documento = !String.isBlank(auxAcc.taxId_number__c)? auxAcc.taxId_number__c.toUpperCase():'';
                    system.debug('documento:'+ documento);
                    if(!String.isBlank(documento)){
                        cliente = AccountGateway.getAccountByDocumento(documento);
                        system.debug('cliente:'+ cliente);
                        if(cliente !=null){
                    		cliente = upsertCliente(auxAcc, cliente.Id);
                   			cConcesionario = upsertClienteConcesionario(auxAcc, null, cliente, concesionario);
                    	}
                        else {
                            cliente = upsertCliente(auxAcc, '');
                            cConcesionario = upsertClienteConcesionario(auxAcc, null, cliente,concesionario);
                        }
                }
                	else {
                    	cliente = upsertCliente(auxAcc,'');
                    	cConcesionario = upsertClienteConcesionario(auxAcc, null, cliente, concesionario);
                	}
                }
                else {
                	throw new CustomException(Label.errorMessage_clientNotFound);
                }
            }
            
            if (opp == null) {
                opp = new Opportunity();
                opp.ID_Oportunidad_DMS__c = req.payload.salesProcessId;
                opp.Centro__c = centro.Id;
                opp.AccountId = cConcesionario.Cliente__c;
                opp.Concesionario__c = cConcesionario.Concesionario__c;
                Date fecha = !String.isBlank(req.payload.creationDate) ? Date.valueOf(req.payload.creationDate.replace('T', ' ')) : Date.today();
                opp.CloseDate = fecha.addMonths(1);
                //opp.Name = req.payload.salesProcessId;
                opp.Name =centro != null ?centro.Concesionario__r.Nombre_Comercial__c+'/'+centro.Name:req.payload.salesProcessId;
                opp.StageName = 'Qualification';
            }
            
            Case caso = new case();
            if (req.payload.salesForceId != null) {
                caso = CaseGateway.getCaseById(req.payload.salesForceId);
            } else {
                caso = null;
            }
            
            opp.CompradorTXT__c = externalId;
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;
            opp.Fecha_de_creacion__c = !String.isBlank(req.payload.creationDate) ? Datetime.valueOf(req.payload.creationDate.replace('T', ' ')) : Date.today();
            opp.Motivo__c = req.payload.motiveCode; 
            opp.Type = req.payload.salesType;  // Valor 1, 6, 13, calcular promedio; e.o.c. el sumatorio, para calcular el Amount
            opp.Origen__c = req.payload.sourceCode;
            if(opp.CampaignId == null){
                if (req.payload.salesForceId != null) {
                    if (caso != null && caso.campana__c != null){
                        opp.CampaignId = caso.campana__c;
                    }
                } else {
                    List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
                    if(!listCasos.isEmpty()){
                        opp.CampaignId = listCasos[0].campana__c;
                    }
                }    
            }
            
            upsert opp;
            
            if (caso != null){
                caso.Opportunity__c = opp.id;
                caso.Status = Label.StatusClosed;
                caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
                caso.Error_Mulesoft__c = req.payload.salesProcessId;
                update caso;
            }
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_centerNotFound)) {
                response.ErrorCode = '502'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_clientNotFound)) {
                response.ErrorCode = '503'; 
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.createProcessSales';
            
            insert exc;
            
        }
        
        return response;
    }
    
    public static ResponseApi upsertProcessSales(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        
        try {

            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }
            
            list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.upsertProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            
            if (opp == null) {
                throw new CustomException(Label.errorMessage_opportunityNotFound);
            }

            Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
                insert vendedor;
            }
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;
           
            opp.Fecha_de_entrega__c = !String.isBlank(req.payload.deliveryDate) ? Datetime.valueOf(req.payload.deliveryDate.replace('T', ' ')) : Date.today();
            opp.Dias_de_vencimiento__c = req.payload.expirationDays;
            opp.StageName = 'Proposal';
            Datetime closeDate = opp.Fecha_de_entrega__c != null && opp.Dias_de_vencimiento__c != null
                ? opp.Fecha_de_entrega__c.addDays(opp.Dias_de_vencimiento__c.intValue()) : opp.Fecha_de_entrega__c;            
            opp.CloseDate = Date.newInstance(closeDate.year(), closeDate.month(), closeDate.day());
            if(opp.CampaignId == null){
                List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
                if(!listCasos.isEmpty()){
                    opp.CampaignId = listCasos[0].campana__c;
                }
            }
            opp.AdvertisingCommunications__c = true;
            opp.EndDateAdvertising__c = null;

            upsert opp;
            
            // Borrar ofertas anteriores
            List<Detalle_Oferta__c> listDetalleOferta = DetalleOfertaGateway.getDOfertaByOppId(opp.Id);
            if (listDetalleOferta != null && !listDetalleOferta.isEmpty()) {
                delete listDetalleOferta;
            }
            
            //Insertar ofertas nuevas
            List<Detalle_Oferta__c> listDetalleOfertaToInsert = new List<Detalle_Oferta__c>();
            Double amount = 0;
            String MarcaOferta = '';
            
            System.debug('===>req.payload.offers' + req.payload.offers);

            for (SalesProcessApiRestModel.Offer offer : req.payload.offers) {
                String services = '';
                Integer i = 1;
                Detalle_Oferta__c oferta = createDetalleOferta(offer); 
                oferta.Opportunity__c = opp.Id;
                amount += offer.economicSummary.total;
                MarcaOferta = offer.vehicle.brandCode; 
                listDetalleOfertaToInsert.add(oferta);
            }
            
            if (!listDetalleOfertaToInsert.isEmpty()) {
                insert listDetalleOfertaToInsert;
            }
            
            opp.Amount = amount;
            
            if (opp.Type == '1' || opp.Type == '6' || opp.Type == '13') {
                if (req.payload.offers.size() != 0) {
	                opp.Amount = amount / req.payload.offers.size();
                }
            }
            
            System.debug('===>opp.Amount ' + opp.Amount);

            if (opp.Marca__c == null && !String.isBlank(MarcaOferta)) {
               opp.Marca__c = MarcaOferta.toUpperCase(); 
            } 
            
            update opp;
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.upsertProcessSales';
            
            insert exc;

        }
        
        return response;
    }
    
    public static ResponseApi failureProcessSales(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        //fracaso 
        try {
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }

            list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.failureProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException('No existe la oportunidad');
            }
            
            Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
                insert vendedor;
            }
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;
           
            opp.Fecha_de_Fracaso__c = !String.isBlank(req.payload.rejectionDate) ? Datetime.valueOf(req.payload.rejectionDate.replace('T', ' ')) : null;
            opp.Loss_Reason__c = req.payload.rejectionReasonCode;
            opp.StageName = 'Closed Lost';
            
             if(opp.CampaignId == null){
                List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
                if(!listCasos.isEmpty()){
                    opp.CampaignId = listCasos[0].campana__c;
                }
            }

            upsert opp;
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.failureProcessSales';
            
            insert exc;
            
        }
        
        return response;
    }
    
    public static ResponseApi successProcessSales(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        //exito actualizar fecha de exito succesDate, stageName -> closed Won 
        try {
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }

            list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.successProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException('No existe la oportunidad');
            }
            
            Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
                insert vendedor;
            }
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;

            if (req.payload.customerId != null) {
	            String externalId = req.payload.customerId + '/' + req.payload.companyCode;
	            Cliente_Concesionario__c cConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(externalId);
                if (cConcesionario != null) {
	                opp.AccountId = cConcesionario.Cliente__c;
                    opp.CompradorTXT__c = externalId;
                }
            }
            
            opp.Fecha_de_exito__c = !String.isBlank(req.payload.successDate) ? Datetime.valueOf(req.payload.successDate.replace('T', ' ')) : null;
            opp.StageName = opp.Fecha_de_completado__c== null?'Negotiation':opp.StageName;
            
            if(opp.CampaignId == null){
                List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
                if(!listCasos.isEmpty()){
                    opp.CampaignId = listCasos[0].campana__c;
                }
            }
            
            // Borrar ofertas anteriores
            List<Detalle_Oferta__c> listDetalleOferta =  DetalleOfertaGateway.getDOfertaByOppId(opp.Id);
            
            if (listDetalleOferta != null && !listDetalleOferta.isEmpty()) {
                delete listDetalleOferta;
            }
            
            //Insertar ofertas nuevas
            List<Detalle_Oferta__c> listDetalleOfertaToInsert = new List<Detalle_Oferta__c>();
            Double amount = 0;
            String MarcaOferta = '';
            String Modalidad = '';
            
            for (SalesProcessApiRestModel.Offer offer : req.payload.offers) {
                Integer i = 1;
                Detalle_Oferta__c oferta = createDetalleOferta(offer); 
                oferta.Opportunity__c = opp.Id;
                amount += offer.economicSummary.total;
                MarcaOferta = offer.vehicle.brandCode;
                Modalidad = offer.vehicle.modality;
                listDetalleOfertaToInsert.add(oferta);
            }

            if (opp.Marca__c == null && !String.isBlank(MarcaOferta)) {
               opp.Marca__c = MarcaOferta.toUpperCase(); 
            } 
           
            if (opp.DateBringFriend__c == null && !String.isBlank(MarcaOferta) &&  
                Label.BrandBringFriend.contains(MarcaOferta.toUpperCase()) &&
                Modalidad.equalsIgnoreCase('NewVehicle') &&
                ((!String.isBlank(opp.Campaign.Name) && !Label.CampaignsAmigo.contains(opp.Campaign.Name)) || String.isBlank(opp.Campaign.Name))) {
                Map<String, Consentimientos__c> mapConsents = ConsentimientosGateway.getConsentimientosValueByAccountId(opp.AccountId);
                    
                for (Consentimientos__c consen : mapConsents.values()) {
                     if (consen.Medio_de_contacto__c == 'Email' && 
                        (consen.AfterSales__c == 'Allow' || consen.ProductSale__c == 'Allow')) {
                         opp.DateBringFriend__c = Datetime.now(); 
                     }
                }    
            }    

            opp.Amount = amount;
            upsert opp;

            Account cliente = AccountGateway.getAccountById(opp.AccountId);
            Concesionario__c infoConce = ConcesionarioGateway.getConcessionaireById(opp.Concesionario__c);
            
            if (cliente != null) {
                boolean UpdateCliente = false;
                if (infoConce.Es_propio__c) { 
	                if (!cliente.Cliente_Propio__c){
		                cliente.Cliente_Propio__c = true;	
	                    cliente.Fecha_Limite_Cliente_Propio__c = date.today().addDays(90);
                        UpdateCliente = true;
	                } else if (cliente.Cliente_Propio__c && cliente.Fecha_Limite_Cliente_Propio__c != null){
	                    cliente.Fecha_Limite_Cliente_Propio__c = date.today().addDays(90);
                        UpdateCliente = true;
	                }    
                }    
                if (opp.DateBringFriend__c != null && !cliente.ConTUA__c) {
                    cliente.ConTUA__c = true;
                    UpdateCliente = true;
                }

            	if (!cliente.ConOportunidad__c && !String.isBlank(MarcaOferta) &&  
                    Label.BrandBringFriend.contains(MarcaOferta.toUpperCase()) &&
                    Modalidad.equalsIgnoreCase('NewVehicle')) {
                    cliente.ConOportunidad__c = true;
                    UpdateCliente = true;
                }
                
                if (UpdateCliente) {update cliente;}
            }
            
            if (!listDetalleOfertaToInsert.isEmpty()) {
                insert listDetalleOfertaToInsert;
            }

            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.successProcessSales';
            
            insert exc;
            
        }
        
        return response;
    }
    
    public static ResponseApi completedProcessSales(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        
        try {
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }

            list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.completedProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException('No existe la oportunidad');
            }
            
            Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
                insert vendedor;
            }
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;
            
            opp.Fecha_de_completado__c = !String.isBlank(req.payload.saleCompletedDate) ? Datetime.valueOf(req.payload.saleCompletedDate.replace('T', ' ')) : null;
            opp.StageName = !opp.StageName.equalsIgnoreCase('Closed Won')?'Completed':opp.StageName;
            
             if(opp.CampaignId == null){
                List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
                if(!listCasos.isEmpty()){
                    opp.CampaignId = listCasos[0].campana__c;
                }
            }
                        
            // Borrar ofertas anteriores
            List<Detalle_Oferta__c> listDetalleOferta =  DetalleOfertaGateway.getDOfertaByOppId(opp.Id);
            
            if (listDetalleOferta != null && !listDetalleOferta.isEmpty()) {
                delete listDetalleOferta;
            }
            
            //Insertar ofertas nuevas
            List<Detalle_Oferta__c> listDetalleOfertaToInsert = new List<Detalle_Oferta__c>();
            Double amount = 0;
            String MarcaOferta = '';
            String Modalidad = '';
            
            for (SalesProcessApiRestModel.Offer offer : req.payload.offers) {
                Integer i = 1;
                Detalle_Oferta__c oferta = createDetalleOferta(offer); 
                oferta.Opportunity__c = opp.Id;
                amount += offer.economicSummary.total;
                MarcaOferta = offer.vehicle.brandCode; 
                Modalidad = offer.vehicle.modality;
                
                listDetalleOfertaToInsert.add(oferta);
            }
            
            if (opp.Marca__c == null && !String.isBlank(MarcaOferta)) {
               opp.Marca__c = MarcaOferta.toUpperCase(); 
            } 
            
            if (opp.DateBringFriend__c == null && !String.isBlank(MarcaOferta) && 
                Label.BrandBringFriend.contains(MarcaOferta.toUpperCase()) &&
                Modalidad.equalsIgnoreCase('NewVehicle') &&
                ((!String.isBlank(opp.Campaign.Name) && !Label.CampaignsAmigo.contains(opp.Campaign.Name)) || String.isBlank(opp.Campaign.Name))) {
                Map<String, Consentimientos__c> mapConsents = ConsentimientosGateway.getConsentimientosValueByAccountId(opp.AccountId);
                    
                for (Consentimientos__c consen : mapConsents.values()) {
                     if (consen.Medio_de_contacto__c == 'Email' && 
                        (consen.AfterSales__c == 'Allow' || consen.ProductSale__c == 'Allow')) {
                         opp.DateBringFriend__c = Datetime.now(); 
                     }
                }    
            }    

            opp.Amount = amount;
            upsert opp;

            Account cliente = AccountGateway.getAccountById(opp.AccountId);
            Concesionario__c infoConce = ConcesionarioGateway.getConcessionaireById(opp.Concesionario__c);
            
            if (cliente != null) {
                boolean UpdateCliente = false;
                if (infoConce.Es_propio__c) { 
	                if (!cliente.Cliente_Propio__c){
		                cliente.Cliente_Propio__c = true;	
	                    cliente.Fecha_Limite_Cliente_Propio__c = date.today().addDays(90);
                        UpdateCliente = true;
	                } else if (cliente.Cliente_Propio__c && cliente.Fecha_Limite_Cliente_Propio__c != null){
	                    cliente.Fecha_Limite_Cliente_Propio__c = date.today().addDays(90);
                        UpdateCliente = true;
	                }    
                }    
                if (opp.DateBringFriend__c != null && !cliente.ConTUA__c) {
                    cliente.ConTUA__c = true;
                    UpdateCliente = true;
                }
            	if (!cliente.ConOportunidad__c && !String.isBlank(MarcaOferta) &&  
                    Label.BrandBringFriend.contains(MarcaOferta.toUpperCase()) &&
                    Modalidad.equalsIgnoreCase('NewVehicle')) {
                    cliente.ConOportunidad__c = true;
                    UpdateCliente = true;
                }
                if (UpdateCliente) {update cliente;}
            }
            
            if (!listDetalleOfertaToInsert.isEmpty()) {
                insert listDetalleOfertaToInsert;
            }
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }
            
            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.completedProcessSales';
            
            insert exc;
            
        }
        
        return response;
    }
     
    public static ResponseApi vehicleDeliveredProcessSales(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        
        try {
            if (!String.isBlank(req.payload.brand) && req.payload.brand.toUpperCase() == 'CITROEN') {
                req.payload.brand = 'CITROËN';
            } else if (!String.isBlank(req.payload.brand) && req.payload.brand.toUpperCase() == 'HONDA MOTO') {
                req.payload.brand = 'HONDA MOTOS';
            } 

            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }
            if (String.isBlank(req.payload.vin)){
                    throw new CustomException('Error no VIN');
            }

            List<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.vehicleDeliveredProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            String vin = req.payload.vin.toUpperCase();
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException(Label.errorMessage_opportunityNotFound);
            }
            
            Map<String,Detalle_Oferta__c> mapDetalleOfertaByOpp = DetalleOfertaGateway.getDOfertaVinByOppId(opp.Id);
            Detalle_Oferta__c dOferta =  mapDetalleOfertaByOpp.containsKey(vin)? mapDetalleOfertaByOpp.get(vin):null;
            String externalId = req.payload.salesProcessId + '/'+ vin;
            Detalle_venta__c dSale = DetalleVentaGateway.getDetalleVentaByExternalId(externalId);
            Boolean AgenteConTaller = false;
            if (dSale == null) {
                dSale = new Detalle_Venta__c();
                dSale.Comprador__c = opp.AccountId;
                dSale.CompradorTXT__c = opp.CompradorTXT__c;
                dSale.External_Id__c = externalId;
                dSale.Opportunity__c = opp.Id;
                dSale.Modalidad__c = dOferta != null ? dOferta.Modalidad__c:null;
                String centroIdExterno = req.payload.companyCode + '-' + req.payload.centerCode;
                Centro__c center = CentroGateway.getCenterByIdCentroSima(centroIdExterno);
                if (center == null) {
                    response.ErrorCode = '501';
                    response.Status = Label.errorStatus_Error;
                    response.Message = Label.responseMessage_Error + ' No existe el centro ; ';
                    return response;
                }
                dSale.Centro__c = center.Id;
                System.debug('CENTER: ' + center);
                dSale.Concesionario__c = center.Concesionario__c;
                Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()) : null;
                //creo el vendedor  si no existe 
                if (vendedor == null && !String.isBlank(req.payload.salesmanEmail)) {
                    vendedor = new Salesman__c();
                    vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                    vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
                    insert vendedor;
                }
                dSale.Vendedor__c = vendedor != null ? vendedor.Id : null;
                dSale.Name = center.Concesionario__r.Nombre_Comercial__c +'/'+center.Id_Centro_Sima__c +'/'+req.payload.brand.toUpperCase() +'/'+ vin;
                
            }
            if(req.payload.intermediary != null && dSale.Intermediario__c == null){
                SalesProcessApiRestModel.Intermediary intermediario = req.payload.intermediary ;
                Concesionario__c concesionario = ConcesionarioGateway.getConcessionaireByCIF(intermediario.taxIdentification.numberTax);
                if (concesionario != null) {
                    dSale.Intermediario__c = concesionario.Id;
                    AgenteConTaller = concesionario.Agente_con_taller__c;
                }
            }
            
            dSale.Fecha_de_entrega__c =!String.isBlank(req.payload.deliveryDate) ? Datetime.valueOf(req.payload.deliveryDate.replace('T', ' ')) : null;
           
            Vehiculo__c vehicle = VehiculoGateway.getVehicleByVin(vin);
            String idExterno = req.payload.customerOwnerId + '/' + req.payload.companyCode;
            Cliente_Concesionario__c cConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(idExterno);
            if (cConcesionario == null) {
                throw new CustomException(Label.errorMessage_ownerNotFound);
            }
            Account cliente = AccountGateway.getAccountById(cConcesionario.Cliente__c);
            dSale.Propietario__c = cConcesionario.Cliente__c;
            dSale.PropietarioTXT__c = idExterno;
            if (vehicle != null) {
                vehicle.Propietario__c = cConcesionario.Cliente__c;
                vehicle.PropietarioTXT__c = idExterno;
                vehicle.Comprador__c   = dSale.Comprador__c;
                vehicle.CompradorTXT__c   = dSale.CompradorTXT__c;
                vehicle.Depositario__c = null;
                if (dSale.Intermediario__c != null && AgenteConTaller){
                    vehicle.Concesionario__c = dSale.Intermediario__c;
                }
                else {
                    vehicle.Concesionario__c = dSale.Concesionario__c;
                    vehicle.Centro__c = dSale.Centro__c;
                }
                vehicle.Name = req.payload.registrationPlate;
                if (req.payload.registrationPlate == null) {
                    vehicle.Actualizar_Sima__c = true;
                }
                Double kms = req.payload.kms;
    
                if (kms != null && vehicle.kms__c < kms) {
                    vehicle.kms__c = kms;
                }

                vehicle.VIN__c = vin;
                vehicle.MarcaString__c = !String.isBlank(req.payload.brand) ? req.payload.brand.toUpperCase() : vehicle.MarcaString__c;
                vehicle.ModeloString__c = !String.isBlank(req.payload.model)? req.payload.model.toUpperCase() : vehicle.ModeloString__c;
                vehicle.Codigo_de_modelo__c = !String.isBlank(req.payload.modelCode) ? req.payload.modelCode:vehicle.Codigo_de_modelo__c;
                vehicle.Version__c = !String.isBlank(req.payload.version) ? req.payload.version : vehicle.Version__c;
                vehicle.modelDescription__c = !String.isBlank(req.payload.engine) ? req.payload.engine : vehicle.modelDescription__c;
                vehicle.Ano_Modelo__c = !String.isBlank(req.payload.modelYear) ? req.payload.modelYear : vehicle.Ano_Modelo__c;
                vehicle.Potencia__c = req.payload.power != null ? req.payload.power : vehicle.Potencia__c;
                vehicle.Cilindrada__c = req.payload.enginecapacity != null ? req.payload.enginecapacity : vehicle.Cilindrada__c;
                vehicle.Combustible__c = !String.isBlank(req.payload.fuel) ? req.payload.fuel : vehicle.Combustible__c;
                vehicle.Transmision__c = !String.isBlank(req.payload.transmission) ? req.payload.transmission : vehicle.Transmision__c;
                vehicle.Letra_Motor__c = !String.isBlank(req.payload.engineLetter) ? req.payload.engineLetter : vehicle.Letra_Motor__c;
                vehicle.Numero_de_Motor__c = !String.isBlank(req.payload.engineNumber) ? req.payload.engineNumber : vehicle.Numero_de_Motor__c;
                vehicle.Codigo_Motor__c = !String.isBlank(req.payload.engineCode) ? req.payload.engineCode : vehicle.Codigo_Motor__c;
                
                vehicle.Fecha_desde__c = !String.isBlank(req.payload.deliveryDate) ? Datetime.valueOf(req.payload.deliveryDate.replace('T', ' ')) : null;
                vehicle.Fecha_inicio_garantia__c = !String.isBlank(req.payload.warrantyStartDate) ? Datetime.valueOf(req.payload.warrantyStartDate.replace('T', ' ')) : null;
                vehicle.Fecha_fin_garantia__c = !String.isBlank(req.payload.warrantyEndDate) ? Datetime.valueOf(req.payload.warrantyEndDate.replace('T', ' ')) : null;
                
                Datetime inicioExGarantia = !String.isBlank(req.payload.warrantyExtensionStartDate) ? Datetime.valueOf(req.payload.warrantyExtensionStartDate.replace('T', ' ')) : null;
                if (vehicle.Fecha_fin_garantia__c != null && inicioExGarantia != null && inicioExGarantia >= vehicle.Fecha_fin_garantia__c) {
                    vehicle.Fecha_inicio_extension_garantia__c = inicioExGarantia;
                }
                Datetime finExGarantia = !String.isBlank(req.payload.warrantyExtensionEndDate) ? Datetime.valueOf(req.payload.warrantyExtensionEndDate.replace('T', ' ')) : null;
                if (inicioExGarantia != null && finExGarantia != null && inicioExGarantia <= finExGarantia) {
                    vehicle.Fecha_fin_extension_garantia__c = finExGarantia;
                }
                
                vehicle.Fecha_inicio_garantia_VO__c = !String.isBlank(req.payload.usedVehicleWarrantyStartDate) ? Datetime.valueOf(req.payload.UsedVehicleWarrantyStartDate.replace('T', ' ')) : null;
            	vehicle.Fecha_fin_garantia_VO__c = !String.isBlank(req.payload.usedVehicleWarrantyEndDate) ? Datetime.valueOf(req.payload.UsedVehicleWarrantyEndDate.replace('T', ' ')) : null;
				vehicle.Clasificacion__c = req.payload.technicalVehicleClassification;
                vehicle.Caja_de_cambios__c = req.payload.gearBox;
				
                vehicle.Fecha_primera_matriculacion__c = !String.isBlank(req.payload.registrationPlateDate) ? Datetime.valueOf(req.payload.registrationPlateDate.replace('T', ' ')) : null;

                if(dOferta != null){
                    vehicle.Accesories__c = dOferta.Accessories__c;
                    vehicle.equipments__c = dOferta.Equipment__c;
                    vehicle.Services__c = dOferta.Services__c;
                    vehicle.Codigo_de_color__c     = dOferta.Codigo_de_color__c;
                    vehicle.colorDescription__c    = dOferta.colorDescription__c;
                    vehicle.Codigo_de_Interior__c  = dOferta.Codigo_de_Interior__c;
                    vehicle.interiorDescription__c = dOferta.interiorDescription__c;

                }

                if (!String.isBlank(req.payload.brand) && req.payload.brand.equalsIgnoreCase('HYUNDAI')) {
                    vehicle.Fecha_cumpleanos__c =  vehicle.Fecha_inicio_garantia__c != null ? vehicle.Fecha_inicio_garantia__c.date().addYears(1) : null;
                	vehicle.Numero_de_cumpleanos__c = 1;
                }
                
                if (opp.Type != null){
                    vehicle.Tipo_de_venta__c = opp.Type;
                }
                
            }
            else {
                vehicle = new Vehiculo__c();
                vehicle.Propietario__c = cConcesionario.Cliente__c;
                vehicle.PropietarioTXT__c = idExterno;
                vehicle.Comprador__c   = dSale.Comprador__c;
                vehicle.CompradorTXT__c   = dSale.CompradorTXT__c;
                if (dSale.Intermediario__c != null && AgenteConTaller){
                    vehicle.Concesionario__c = dSale.Intermediario__c;
                } else {
                    vehicle.Concesionario__c = dSale.Concesionario__c;
                    vehicle.Centro__c = dSale.Centro__c;
                }
                vehicle.Name = req.payload.registrationPlate;
                if (req.payload.registrationPlate == null) {
                    vehicle.Actualizar_Sima__c = true;
                }
                vehicle.VIN__c = vin;
                vehicle.MarcaString__c = !String.isBlank(req.payload.brand) ? req.payload.brand.toUpperCase() : null;
                vehicle.ModeloString__c = !String.isBlank(req.payload.model)? req.payload.model.toUpperCase() : null;
                vehicle.Codigo_de_modelo__c = !String.isBlank(req.payload.modelCode) ? req.payload.modelCode:null;
                vehicle.Version__c = req.payload.version;
                vehicle.modelDescription__c = req.payload.engine;
                vehicle.Ano_Modelo__c = req.payload.modelYear;
                vehicle.Potencia__c = req.payload.power;
                vehicle.Cilindrada__c = req.payload.enginecapacity;
                vehicle.Combustible__c = req.payload.fuel;
                vehicle.Transmision__c = req.payload.transmission;
                vehicle.Letra_Motor__c = req.payload.engineLetter;
                vehicle.Numero_de_Motor__c = req.payload.engineNumber;
                vehicle.Codigo_Motor__c = req.payload.engineCode;
                vehicle.kms__c = req.payload.kms;
                vehicle.Fecha_primera_matriculacion__c = !String.isBlank(req.payload.registrationPlateDate) ? Datetime.valueOf(req.payload.registrationPlateDate.replace('T', ' ')) : null;
                vehicle.Fecha_desde__c = !String.isBlank(req.payload.deliveryDate) ? Datetime.valueOf(req.payload.deliveryDate.replace('T', ' ')) : null;
                vehicle.Fecha_inicio_garantia__c = !String.isBlank(req.payload.warrantyStartDate) ? Datetime.valueOf(req.payload.warrantyStartDate.replace('T', ' ')) : null;
                vehicle.Fecha_fin_garantia__c = !String.isBlank(req.payload.warrantyEndDate) ? Datetime.valueOf(req.payload.warrantyEndDate.replace('T', ' ')) : null;
                
                Datetime inicioExGarantia = !String.isBlank(req.payload.warrantyExtensionStartDate) ? Datetime.valueOf(req.payload.warrantyExtensionStartDate.replace('T', ' ')) : null;
                if (vehicle.Fecha_fin_garantia__c != null && inicioExGarantia != null && inicioExGarantia >= vehicle.Fecha_fin_garantia__c) {
                    vehicle.Fecha_inicio_extension_garantia__c = inicioExGarantia;
                }
                Datetime finExGarantia = !String.isBlank(req.payload.warrantyExtensionEndDate) ? Datetime.valueOf(req.payload.warrantyExtensionEndDate.replace('T', ' ')):null;
                if (inicioExGarantia != null && finExGarantia != null && inicioExGarantia <= finExGarantia) {
                    vehicle.Fecha_fin_extension_garantia__c = finExGarantia;
                }
                //fechas used
                vehicle.Fecha_inicio_garantia_VO__c = !String.isBlank(req.payload.usedVehicleWarrantyStartDate) ? Datetime.valueOf(req.payload.UsedVehicleWarrantyStartDate.replace('T', ' ')) : null;
            	vehicle.Fecha_fin_garantia_VO__c = !String.isBlank(req.payload.usedVehicleWarrantyEndDate) ? Datetime.valueOf(req.payload.UsedVehicleWarrantyEndDate.replace('T', ' ')) : null;
				vehicle.Clasificacion__c = req.payload.technicalVehicleClassification;
                vehicle.Caja_de_cambios__c = req.payload.gearBox;
				//gearBox
                        
                if(dOferta != null){
                    vehicle.Accesories__c = dOferta.Accessories__c;
                    vehicle.equipments__c = dOferta.Equipment__c;
                    vehicle.Services__c = dOferta.Services__c;
                    vehicle.Codigo_de_color__c     = dOferta.Codigo_de_color__c;
                    vehicle.colorDescription__c    = dOferta.colorDescription__c;
                    vehicle.Codigo_de_Interior__c  = dOferta.Codigo_de_Interior__c;
                    vehicle.interiorDescription__c = dOferta.interiorDescription__c;

                }

                if (!String.isBlank(req.payload.brand) && req.payload.brand.equalsIgnoreCase('HYUNDAI')) {
                    vehicle.Fecha_cumpleanos__c =  vehicle.Fecha_inicio_garantia__c != null ? vehicle.Fecha_inicio_garantia__c.date().addYears(1) : null;
                	vehicle.Numero_de_cumpleanos__c = 1;
                }

                if (opp.Type != null){
                    vehicle.Tipo_de_venta__c = opp.Type;
                }

            }
            upsert vehicle;
            
            dSale.Vehiculo__c = vehicle.Id;
            upsert dSale;

            if (opp.Marca__c == null && !String.isBlank(vehicle.MarcaString__c)) {
               opp.Marca__c = vehicle.MarcaString__c.toUpperCase(); 
            } 
            
            if (opp.DateBringFriend__c == null && !String.isBlank(vehicle.MarcaString__c) &&
                Label.BrandBringFriend.contains(vehicle.MarcaString__c.toUpperCase()) &&
                dOferta != null && dOferta.Modalidad__c.equalsIgnoreCase('NewVehicle')) {
                Map<String, Consentimientos__c> mapConsents = ConsentimientosGateway.getConsentimientosValueByAccountId(opp.AccountId);
                    
                for (Consentimientos__c consen : mapConsents.values()) {
                     if (consen.Medio_de_contacto__c == 'Email' && 
                        (consen.AfterSales__c == 'Allow' || consen.ProductSale__c == 'Allow')) {
                         opp.DateBringFriend__c = Datetime.now(); 
                     }
                }    
            }    

            opp.StageName = 'Closed Won';
            opp.AdvertisingCommunications__c = false;

            System.debug('req.payload.salesProcessId:'+req.payload.salesProcessId);
            List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
            System.debug('listCasos: '+listCasos);
            
            if(opp.CampaignId == null){
                if(!listCasos.isEmpty()){
                    opp.CampaignId = listCasos[0].campana__c;
                }
            }
            
            update opp;

            Concesionario__c infoConce = ConcesionarioGateway.getConcessionaireById(dSale.Concesionario__c);
            
            if (dOferta != null && dOferta.Modalidad__c.equalsIgnoreCase('UsedVehicle')){
                cliente.Importe_VO__c = cliente.Importe_VO__c== null?0:cliente.Importe_VO__c;
                cliente.Importe_VO__c +=dOferta != null &&  dOferta.Total__c != null?dOferta.Total__c:0;
                cliente.Fecha_primera_compra_VO__c = cliente.Fecha_primera_compra_VO__c ==null?dSale.Fecha_de_entrega__c: cliente.Fecha_primera_compra_VO__c;
                cliente.Fecha_ultima_compra_VO__c = dSale.Fecha_de_entrega__c;
                cliente.Cliente_VO__c = true;
	            if (infoConce.Es_propio__c == true) {
	                cliente.Cliente_Propio__c = true;
                    cliente.Fecha_Limite_Cliente_Propio__c = null;
                }    
                cliente.n_ventas_VO_3_ultimos_anos__c = cliente.n_ventas_VO_3_ultimos_anos__c==null? 1 : cliente.n_ventas_VO_3_ultimos_anos__c + 1;
            } else {
                cliente.Importe_VN__c = cliente.Importe_VN__c== null?0:cliente.Importe_VN__c;
                cliente.Importe_VN__c +=dOferta != null &&  dOferta.Total__c != null?dOferta.Total__c:0;
                cliente.Fecha_primera_compra_VN__c = cliente.Fecha_primera_compra_VN__c ==null?dSale.Fecha_de_entrega__c: cliente.Fecha_primera_compra_VN__c;
                cliente.Fecha_ultima_compra_VN__c = dSale.Fecha_de_entrega__c;
                cliente.Cliente_VN__c = true;
	            if (infoConce.Es_propio__c == true) {
	                cliente.Cliente_Propio__c = true;
                    cliente.Fecha_Limite_Cliente_Propio__c = null;
                }    
            }

            string MarcaAux = vehicle.MarcaString__c;
            if (!Label.Marcagrupo.contains(vehicle.MarcaString__c)) {
                MarcaAux = 'OTRAS';
            }
            
            if (cliente.Marca__c == null){
                cliente.Marca__c = MarcaAux;
            } else if (!cliente.Marca__c.contains(MarcaAux) ) {
                cliente.Marca__c += '; '+MarcaAux;
            }
            
            if (opp.DateBringFriend__c != null && !cliente.ConTUA__c && dSale.Propietario__c == dSale.Comprador__c) {
                cliente.ConTUA__c = true;
            }
            cliente.ConVehiculo__c = true;

            update cliente;

            if (dSale.Propietario__c != dSale.Comprador__c) {
                boolean UpdateCliente = false;
	            Account cliente1 = AccountGateway.getAccountById(dSale.Comprador__c);
                if (opp.DateBringFriend__c != null && !cliente1.ConTUA__c) {
                    cliente1.ConTUA__c = true;
                    UpdateCliente = true;
                }
                if (!cliente1.ConVehiculo__c) {
	                cliente1.ConVehiculo__c = true;
                    UpdateCliente = true;
                }
                if (UpdateCliente) {update cliente1;}
            }
            
            if (cliente.IsPersonAccount == true  && infoConce.Es_propio__c){
                //Interés Legítimo
                List<Consentimientos__c> lisInteresLegitimo = ConsentimientosGateway.getConsentimientosInteresLegitimoByContactId(cliente.PersonContactId);
                
                Consentimientos__c conInteresLegitimo;
                for (Consentimientos__c consen : lisInteresLegitimo) {
                     if (consen.Concesionario__c == dSale.Concesionario__c && 
                         consen.Marca__c == MarcaAux) {
                         conInteresLegitimo = consen;
                         break;
                     }
                }
                
                if (conInteresLegitimo != null){
                    conInteresLegitimo.EnviarAmulesoft__c = false;
                    conInteresLegitimo.ProductSale__c = Label.ConsentimientoAllow;
                    conInteresLegitimo.AfterSales__c = Label.ConsentimientoAllow;
                    conInteresLegitimo.Call__c = true;
                    conInteresLegitimo.SMS__c = true;
                    conInteresLegitimo.Email__c = true;
                    conInteresLegitimo.WhatsApp__c = true;
                } else{
                    conInteresLegitimo = new Consentimientos__c();
                    Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
                    conInteresLegitimo.RecordTypeId = rtMapByDName.get('Interes_Legitimo_MKT_CCS').getRecordTypeId();        
                    conInteresLegitimo.Contact__c = cliente.PersonContactId;
                    conInteresLegitimo.Concesionario__c = dSale.Concesionario__c;
                    conInteresLegitimo.Marca__c = MarcaAux;
                    conInteresLegitimo.EnviarAmulesoft__c = false;
                    conInteresLegitimo.ProductSale__c = Label.ConsentimientoAllow;
                    conInteresLegitimo.AfterSales__c = Label.ConsentimientoAllow;
                    conInteresLegitimo.Call__c = true;
                    conInteresLegitimo.SMS__c = true;
                    conInteresLegitimo.Email__c = true;
                    conInteresLegitimo.WhatsApp__c = true;
                }
                upsert conInteresLegitimo;
                system.debug('conInteresLegitimo.id: '+conInteresLegitimo.Id);
            
                //Ficha única
                Consentimientos__c conFichaUnica = ConsentimientosGateway.getConsentimientosFichaUnicaByContactId(cliente.PersonContactId);
                if (conFichaUnica != null){
                    if (conFichaUnica.oppositionDate__c != null &&
                        conFichaUnica.oppositionDate__c < Datetime.now().addDays(integer.valueOf(Label.oposicionFUDesde))) {
	                    conFichaUnica.expectedCommunicationDate__c = Datetime.now();
	                    conFichaUnica.EnviarAmulesoft__c = false;
                        conFichaUnica.communicationType__c = Label.comunicacionNoEnFU;
                        conFichaUnica.oppositionDate__c = null;
                        conFichaUnica.realCommunicationDate__c = null;
                        conFichaUnica.entryDate__c = null;
		                conFichaUnica.Marca__c = MarcaAux;
                    } else{
                        if (conFichaUnica.realCommunicationDate__c == null){
		                    conFichaUnica.expectedCommunicationDate__c = Datetime.now();
		                    conFichaUnica.EnviarAmulesoft__c = false;
                            conFichaUnica.communicationType__c = Label.comunicacionInicial;
			                conFichaUnica.Marca__c = MarcaAux;
                        }
                    }
                } else{
                    conFichaUnica = new Consentimientos__c();
                    Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
                    conFichaUnica.RecordTypeId = rtMapByDName.get('Ficha_unica').getRecordTypeId();        
                    conFichaUnica.Contact__c = cliente.PersonContactId;
                    conFichaUnica.Concesionario__c = Label.concesionarioFichaUnica;
                    conFichaUnica.communicationType__c = Label.comunicacionInicial;
                    conFichaUnica.expectedCommunicationDate__c = Datetime.now();
                    conFichaUnica.EnviarAmulesoft__c = false;
		            conFichaUnica.Marca__c = MarcaAux;
                }
                upsert conFichaUnica;
            }
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            
             // Encuesta
            system.debug('encuesta');
            Encuesta__c encuesta = EncuestaGateway.getEncuestaByDetalleVenta(dSale.Id);
            if(encuesta == null && !String.isBlank(vehicle.MarcaString__c) && Label.BrandSurvey.contains(vehicle.MarcaString__c.toUpperCase()) ){
                if(dOferta != null){
                    if (dOferta.Modalidad__c.equalsIgnoreCase('NewVehicle')) {
                        system.debug('inicia el Manage Survey');
                        ManageSurvey.manage(dSale.Id);
                    }
                }
                else {
                   String surveyRT ='';
                  if (vehicle.MarcaString__c.equalsIgnoreCase('VOLKSWAGEN') || vehicle.MarcaString__c.equalsIgnoreCase('AUDI')) {
            		surveyRT = 'CEM';
      			  }
        		  else if (vehicle.MarcaString__c.equalsIgnoreCase('SKODA') || 
                          (vehicle.MarcaString__c.equalsIgnoreCase('HYUNDAI') &&  date.today() >= Date.parse(Label.startNewCem))) {
            		surveyRT = 'Externa';
       			 }
        		 else {
            		surveyRT = 'Telefonica';
            	}
                 encuesta = new Encuesta__c();
                 encuesta.Brand__c = vehicle.MarcaString__c;
                 encuesta.Detalle_venta__c = dSale.Id;
                 encuesta.Cliente__c = vehicle.Propietario__c;
                 encuesta.Resultado__c = 'No se ha podido confirmar la modalidad';
                 encuesta.ModeloString__c = vehicle.modelDescription__c;
                 encuesta.Tipo_Encuesta__c = 'SIMA';
                 encuesta.RecordTypeId = EncuestaGateway.getRecordTypeIdByDeveloperName(surveyRT);
                 encuesta.vin__c = vehicle.VIN__c;
                 encuesta.Fecha_documento__c = dSale.Fecha_de_entrega__c;
                 encuesta.Tipo_de_Operacion__c = 'Venta';
                 insert encuesta;
                }
                
            }
            
            if(!listCasos.isEmpty()){
                
               for(Case CasoRecomendado : listCasos){
                   System.debug('CasoRecomendado: '+CasoRecomendado);
                   System.debug('CasoRecomendado.RecommendBy__c: '+CasoRecomendado.RecommendBy__c);
                   if (CasoRecomendado.RecommendBy__c != null){
                       Detalle_venta__c DetalleVentaOri = DetalleVentaGateway.getDetalleVentaByOpportunityId(CasoRecomendado.RecommendBy__c);
                       System.debug('DetalleVentaOri: '+DetalleVentaOri);   
                       if (DetalleVentaOri != null){
                           Vehiculo__c vehicle1 = VehiculoGateway.getVehicleById(DetalleVentaOri.Vehiculo__c);
                           System.debug('vehicle1: '+vehicle1);
                           if (vehicle1 != null){
                               if (vehicle1.Fecha_comunicacion_regalo__c == null){
                                   Datetime dt = Datetime.now().addDays(2);
                                   String dayOfWeek = dt.format('EEEE');
                                   if (dayOfWeek.equalsIgnoreCase('Saturday')) {
                                       dt=dt.addDays(2);
                                   } else if (dayOfWeek.equalsIgnoreCase('Sunday')) {
                                       dt=dt.addDays(1);
                                   }
                                   vehicle1.Fecha_comunicacion_regalo__c = dt;
                                   Integer yearContratoN = 0;
                                   if (vehicle1.MarcaString__c == 'HYUNDAI' && 
                                       vehicle1.Contrato_modalidad__c != null &&
                                       vehicle1.Contrato_modalidad__c .length() == 3 ){
                                       String yearContratoS = vehicle1.Contrato_modalidad__c.substring(2, 3);
                                       yearContratoN = yearContratoS.isNumeric()? integer.valueOf(yearContratoS):0;    
                                   }
                                   vehicle1.Fecha_inicio_regalo__c = dt.date().addYears(yearContratoN);
                                   vehicle1.Fecha_fin_regalo__c = Date.today().addYears(yearContratoN+1);
                                   vehicle1.Amigo_Regalo__c = cliente.Name;
                                   update vehicle1;
                               }
                               break;
                           } 
                       }    
                   }
                   if (CasoRecomendado.RecommendByPT__c != null){
                       Pase_de_taller__c PaseTallerOri = PaseTallerGateway.getPaseTallerById(CasoRecomendado.RecommendByPT__c);
                       System.debug('PaseTallerOri: '+PaseTallerOri);   
                       if (PaseTallerOri != null){
                           Vehiculo__c vehicle1 = VehiculoGateway.getVehicleById(PaseTallerOri.Vehiculo__c);
                           System.debug('vehicle1: '+vehicle1);
                           if (vehicle1 != null){
                               if (vehicle1.Fecha_comunicacion_regalo__c == null){
                                   Datetime dt = Datetime.now().addDays(2);
                                   String dayOfWeek = dt.format('EEEE');
                                   if (dayOfWeek.equalsIgnoreCase('Saturday')) {
                                       dt=dt.addDays(2);
                                   } else if (dayOfWeek.equalsIgnoreCase('Sunday')) {
                                       dt=dt.addDays(1);
                                   }
                                   vehicle1.Fecha_comunicacion_regalo__c = dt;
                                   if (vehicle1.Contrato_modalidad__c == 'CM3' && vehicle1.MarcaString__c == 'HYUNDAI') {
                                       vehicle1.Fecha_inicio_regalo__c = dt.date().addYears(3);
                                       vehicle1.Fecha_fin_regalo__c = Date.today().addYears(4);
                                   } else if (vehicle1.Contrato_modalidad__c == 'CM5' && vehicle1.MarcaString__c == 'HYUNDAI') {
                                       vehicle1.Fecha_inicio_regalo__c = dt.date().addYears(5);
                                       vehicle1.Fecha_fin_regalo__c = Date.today().addYears(6);
                                   } else {
                                       vehicle1.Fecha_inicio_regalo__c = dt.date();
                                       vehicle1.Fecha_fin_regalo__c = Date.today().addYears(1);
                                   }    
                                   vehicle1.Amigo_Regalo__c = cliente.Name;
                                   update vehicle1;
                               }
                               break;
                           } 
                       }    
                   }
               } 
            }
           
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            System.debug('Linea ' + e.getLineNumber() + ': ' + response.Message);
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_ownerNotFound)) {
                response.ErrorCode = '505';
            }
            /*else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_brandNotFound)) {
                response.ErrorCode = '506';
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_modelNotFound)) {
                response.ErrorCode = '507';
            }*/

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.vehicleDeliveredProcessSales';
            
            insert exc;

        }
        
        return response;
    }
    
    public static ResponseApi cancelCompletedProcessSales(SalesProcessApiRestModel req){
        ResponseApi response = new ResponseApi();
        
        try {
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException('No existe la oportunidad');
            }

            List<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.cancelCompletedProcessSales');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            String vin = req.payload.vin.toUpperCase();

            String externalId= req.payload.salesProcessId+'/'+vin;
            Detalle_venta__c dSale = DetalleVentaGateway.getDetalleVentaByExternalId(externalId);
            if (dSale == null) {
            	throw new CustomException('No existe la venta');
            }
            Map<String,Detalle_Oferta__c> mapDetalleOfertaByOpp = DetalleOfertaGateway.getDOfertaVinByOppId(opp.Id);
            Detalle_Oferta__c dOferta =  mapDetalleOfertaByOpp.containsKey(vin)? mapDetalleOfertaByOpp.get(vin):null;
            
            Account cliente = AccountGateway.getAccountById(dSale.Propietario__c);
            if(cliente != null){
                if (dOferta != null && dOferta.Modalidad__c.equalsIgnoreCase('UsedVehicle')){
                    cliente.Importe_VO__c -=dOferta != null && dOferta.Total__c!= null && cliente.Importe_VO__c>=dOferta.Total__c?dOferta.Total__c:0;
                    if(cliente.Importe_VO__c == 0){
                        cliente.Fecha_ultima_compra_VO__c = null;
                        cliente.Fecha_primera_compra_VO__c = null;
                        cliente.Cliente_VO__c = false;   
                    }
                	cliente.n_ventas_VO_3_ultimos_anos__c -= cliente.n_ventas_VO_3_ultimos_anos__c>1 && cliente.n_ventas_VO_3_ultimos_anos__c != null ?1:0;
                } else {
                    cliente.Importe_VN__c -=dOferta != null && dOferta.Total__c!= null && cliente.Importe_VN__c>=dOferta.Total__c?dOferta.Total__c:0;
                    if(cliente.Importe_VN__c == 0){
                        cliente.Fecha_ultima_compra_VN__c = null;
                        cliente.Fecha_primera_compra_VN__c = null;
                        cliente.Cliente_VN__c = false;   
                    }
                }
                upsert cliente;
            }

            Encuesta__c encuesta = EncuestaGateway.getEncuestaByDetalleVenta(dSale.Id);
            if(encuesta != null && (!encuesta.Respondido__c || encuesta.Fecha_respuesta_encuesta__c > Date.today())){
                delete encuesta;
            }
            
            Vehiculo__c vehiculo = VehiculoGateway.getVehicleByVin(vin);
            if(vehiculo != null){
                vehiculo.Propietario__c = null;
                vehiculo.Comprador__c = null;
                vehiculo.Fecha_desde__c = null;
                    
                update vehiculo;
            }
            
            delete dSale;
            opp.StageName= opp.Fecha_de_completado__c != null?'Completed':'Negotiation';
            upsert opp;

            System.debug('req.payload.salesProcessId:'+req.payload.salesProcessId);
            List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
            System.debug('listCasos: '+listCasos);

            if(!listCasos.isEmpty()){
                
               for(Case CasoRecomendado : listCasos){
                   System.debug('CasoRecomendado: '+CasoRecomendado);
                   System.debug('CasoRecomendado.RecommendBy__c: '+CasoRecomendado.RecommendBy__c);
                   if (CasoRecomendado.RecommendBy__c != null){
                       Detalle_venta__c DetalleVentaOri = DetalleVentaGateway.getDetalleVentaByOpportunityId(CasoRecomendado.RecommendBy__c);
                       System.debug('DetalleVentaOri: '+DetalleVentaOri);   
                       if (DetalleVentaOri != null){
                           Vehiculo__c vehicle1 = VehiculoGateway.getVehicleById(DetalleVentaOri.Vehiculo__c);
                           System.debug('vehicle1: '+vehicle1);
                           if (vehicle1 != null){
                               if (vehicle1.Fecha_comunicacion_regalo__c != null){
                                   vehicle1.Fecha_fin_regalo__c = null;
                                   vehicle1.Fecha_comunicacion_regalo__c = null;
                                   update vehicle1;
                               }
                               break;
                           } 
                       }    
                   }
               } 
            }

            
            
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.cancelCompletedProcessSales';
            
            insert exc;
            
        }
        
        return response;
    }
    
    public static ResponseApi cancelProcessSalesCancelled(SalesProcessApiRestModel req){
         ResponseApi response = new ResponseApi();
        
        try {
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }

            List<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.cancelCompletedProcessSales1');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException('No existe la oportunidad');
            }
            
             Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
                insert vendedor;
            }
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;
           
            opp.Fecha_de_Fracaso__c = !String.isBlank(req.payload.cancellationDate) ? Datetime.valueOf(req.payload.cancellationDate.replace('T', ' ')) : null;
            opp.Loss_Reason__c = req.payload.cancellationReasonCode;
            opp.StageName = 'Closed Lost';
            
             if(opp.CampaignId == null){
                List<Case> listCasos = CaseGateway.getCasebySalesProcessExtId(req.payload.salesProcessId);
                if(!listCasos.isEmpty()){
                    opp.CampaignId = listCasos[0].campana__c;
                }
            }

            upsert opp;
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.cancelCompletedProcessSales1';
            
            insert exc;
            
        }
        
        return response;
    }

    /*
    private static TestDrive__c createTestDrive(SalesProcessApiRestModel.TestDrive testD, String idOpp){
        TestDrive__c testDrive= new TestDrive__c();
        testDrive.testDriveId__c = testD.testDriveId;
        testDrive.Opportunity__c = idOpp;
        testDrive.DeliveryDate__c = !String.isBlank(testD.deliveryDate) ? Datetime.valueOf(testD.deliveryDate) : null; 
        testDrive.CreationDateExt__c = !String.isBlank(testD.creationDate) ? Datetime.valueOf(testD.creationDate) : null; 
        testDrive.EndingDate__c = !String.isBlank(testD.endingDate) ? Datetime.valueOf(testD.endingDate) : null; 
        testDrive.ScheduledDate__c = !String.isBlank(testD.scheduledDate) ? Datetime.valueOf(testD.scheduledDate) : null; 
        testDrive.Vin__c = !String.isBlank(testD.vin) ? testD.vin : null; 
        return testDrive;
    }
    */
    private static Detalle_Oferta__c createDetalleOferta (SalesProcessApiRestModel.Offer offer) {
        Detalle_Oferta__c oferta = new Detalle_Oferta__c();
        oferta.Name = offer.vehicle.brandCode+ '/' + offer.vehicle.modelGroup;
        if (offer.vehicle.vin !=null) {
            oferta.vin__c = offer.vehicle.vin.toUpperCase();
        }
        oferta.Modalidad__c = offer.vehicle.modality;
        oferta.Marca__c = offer.vehicle.brandCode;
        oferta.Codigo_de_modelo__c = offer.vehicle.modelCode;
        oferta.Ano_modelo__c = offer.vehicle.modelYear;
        oferta.extendedModelVersionKey__c = offer.vehicle.extendedModelVersionKey;
        oferta.modelGroup__c = offer.vehicle.modelGroup;
        oferta.modelDescription__c = offer.vehicle.modelDescription;
        oferta.modelGroupCode__c = offer.vehicle.modelGroupCode;
        oferta.fuelCode__c = offer.vehicle.fuelCode;
        oferta.power__c = offer.vehicle.power;
        oferta.engineCapacity__c = offer.vehicle.engineCapacity;
        oferta.Codigo_de_color__c = offer.vehicle.colorCode;
        oferta.colorDescription__c = offer.vehicle.colorDescription;
        oferta.Codigo_de_Interior__c = offer.vehicle.interiorCode;
        oferta.interiorDescription__c = offer.vehicle.interiorDescription;
        oferta.Equipment__c = '';
        
        if (offer.vehicle.equipments != null) {
            for (Integer i = 0; i < offer.vehicle.equipments.size(); i++) {
                if (i + 1 == offer.vehicle.equipments.size()) {
                    oferta.Equipment__c += offer.vehicle.equipments[i].code + ' - ' + offer.vehicle.equipments[i].description;
                }
                else {
                   oferta.Equipment__c += offer.vehicle.equipments[i].code + ' - ' + offer.vehicle.equipments[i].description + '\n'; 
                }
            }
        }
        
        oferta.Accessories__c = '';
        
        if (offer.vehicle.accessories != null) {
            for (Integer i = 0; i < offer.vehicle.accessories.size(); i++) {
                if (i + 1 == offer.vehicle.accessories.size()) {
                    oferta.Accessories__c += offer.vehicle.accessories[i].code + ' - ' + offer.vehicle.accessories[i].description;
                }
                else {
                   oferta.Accessories__c += offer.vehicle.accessories[i].code + ' - ' + offer.vehicle.accessories[i].description + '\n '; 
                }
            }
        }
        
        oferta.Services__c = '';
        
        if (offer.vehicle.services != null) {
            for (Integer i = 0; i < offer.vehicle.services.size(); i++) {
                Integer index = i + 1;
                
                if (index == offer.vehicle.services.size()) {
                    oferta.Services__c += 'Servicio ' + index + ': ' + offer.vehicle.services[i].description + '\n';
                    
                    if (!offer.vehicle.services[i].serviceDetails.isEmpty()) {
                        //oferta.Services__c += '';
                        
                        for (SalesProcessApiRestModel.DetailCode detail : offer.vehicle.services[i].serviceDetails) {
                            oferta.Services__c += detail.description + '\n';
                        }
                        
                        oferta.Services__c += '\n';
                    }
                }
                else {
                    oferta.Services__c += 'Servicio ' + index + ': ' + offer.vehicle.services[i].description + '\n';
                    
                    if (!offer.vehicle.services[i].serviceDetails.isEmpty()) {
                        //oferta.Services__c += '';
                        
                        for (SalesProcessApiRestModel.DetailCode detail : offer.vehicle.services[i].serviceDetails) {
                            oferta.Services__c += detail.description + '\n';
                        }
                        
                        oferta.Services__c += '\n';
                    }
                    
                    oferta.Services__c +=  '\n ';
                }
            }
        }
        
        oferta.currencyType__c = offer.economicSummary.currencyType;
        oferta.Precio__c = offer.economicSummary.price;
        oferta.Descuento__c = offer.economicSummary.discount;
        oferta.Total__c = offer.economicSummary.total;
        oferta.Financings__c = '';
        
        if(offer.financings != null){
            for (Integer i = 0; i < offer.financings.size(); i++) {
                oferta.Financings__c += 'Financiación ' + i + ': ' + offer.financings[i].tariffCode
                    + ' ' + offer.financings[i].tariffDescription + '/' + offer.financings[i].amount
                    + ' '+ offer.financings[i].currencyType + '\n';
            }
        }
        //oferta.Descripcion_servicio__c
        //oferta.Tipo_de_datalle__c
        //oferta.Tipo_de_servicio__c
        
        return oferta;
    }
    
    // Crea o actualiza registro cliente y consentimientos
    private static Account upsertCliente(AuxAccount__c auxiliar, String idCliente) {
        
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Map<String, Contact> mapAccountIdContacts = new Map<String, Contact>();
        Map<String, Consentimientos__c> mapConsentsByMethodValue = new Map<String, Consentimientos__c>();
        Map<String, Consentimientos__c> mapConsentsByMethoValueToUpsert = new Map<String, Consentimientos__c>();
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
       	
        String name='';
        String lastname='';
        
        Account cliente = new Account();
        //preguntar los country
        List<String> lstCountries = new List<String>{auxiliar.countryIso31661__c, auxiliar.Delivering_addresses_countryIso31661__c, auxiliar.Invoicing_addresses_countryIso31661__c};
		Map<String, Pais__c> mapCountries = PaisGateway.getPaisByAlfa2(lstCountries);
        Pais__c pais = mapCountries.get(auxiliar.countryIso31661__c);
        Pais__c billingCountry = mapCountries.get(auxiliar.Delivering_addresses_countryIso31661__c);
        Pais__c shippingCountry = mapCountries.get(auxiliar.Invoicing_addresses_countryIso31661__c);
        
        Boolean duplicado = false;
        if (idCliente == '') {
            // Nuevo cliente
            String idRecordType = auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson') ? 
                rtMapByDName.get('PersonAccount').getRecordTypeId() : rtMapByDName.get('Cliente_Empresa').getRecordTypeId();
            cliente.RecordTypeId = idRecordType;
		}
        else {
            cliente.Id = idCliente;
            List<Consentimientos__c> lstConsentsByContact = [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId
                                                         	 FROM Consentimientos__c
                                                         	 WHERE Contact__c IN
                                                         		(SELECT Id FROM Contact WHERE AccountId = :idCliente)];
            
        	for (Consentimientos__c consent : lstConsentsByContact) {
            	mapConsentsByMethodValue.put(consent.ChannelValue__c, consent);
        	}
        }
        // Limpiar valor del telefono
        auxiliar.Phone__c = !String.isBlank(auxiliar.Phone__c) ?DataValidations.clearPhone(auxiliar.phone__c):'';
        auxiliar.OtherPhone__c =!String.isBlank(auxiliar.OtherPhone__c)?DataValidations.clearPhone(auxiliar.otherphone__c):'';
        auxiliar.Mobile__c = !String.isBlank(auxiliar.Mobile__c)?DataValidations.clearPhone(auxiliar.mobile__c):'';
        auxiliar.OtherMobile__c =!String.isBlank(auxiliar.OtherMobile__c)? DataValidations.clearPhone(auxiliar.othermobile__c):'';
          
        
        if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){ //es persona
            name = auxiliar.name__c;
            if(String.isBlank(auxiliar.firstSurname__c) && String.isBlank(auxiliar.secondSurname__c) ){
                lastname = name;
            }
            else if (String.isBlank(auxiliar.secondSurname__c)){
                lastname = auxiliar.firstSurname__c;
            }
            else if(String.isBlank(auxiliar.firstSurname__c)){
                lastname = auxiliar.secondSurname__c;
            }
            else{
				lastname = auxiliar.firstSurname__c + ' '+ auxiliar.secondSurname__c;             
           }
            cliente.Tipo_de_documento_cuenta_personal__c = Label.docType_VATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                || Label.docType_VATIdForForeigners.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                || Label.docType_Passport.equalsIgnoreCase(auxiliar.taxId_documentType__c) 
                || Label.docType_OtherCountryVATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                ? auxiliar.taxId_documentType__c : null;
            cliente.Salutation = auxiliar.title__c;
           	cliente.FirstName = name;
            cliente.LastName = lastname;
        	cliente.PersonBirthdate = auxiliar.birthdate__c;
            cliente.ChildrenCount__pc =!string.isBlank(auxiliar.numberOfChildren__c)? Double.valueOf(auxiliar.numberOfChildren__c):null;
            cliente.gender__pc = auxiliar.gender__c;
            cliente.Occupation__pc = !String.isBlank(auxiliar.occupationId__c)?auxiliar.companyId__c+'-'+auxiliar.occupationId__c:null;
            cliente.position__pc =auxiliar.positionId__c;
            cliente.incomes__pc = auxiliar.incomes__c;
            cliente.maritalStatus__pc = auxiliar.maritalStatusId__c;
            cliente.economicSector__pc = !String.isBlank(auxiliar.economicSectorId__c)?auxiliar.companyId__c+'-'+auxiliar.economicSectorId__c:null;
     	}
        else{
            name = auxiliar.fiscalName__c;
            cliente.Tipo_de_documento_empresa__c = Label.docType_VATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                || Label.docType_OtherCountryVATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                ? auxiliar.taxId_documentType__c : null;
            cliente.Name = name;
            cliente.Marca_registrada__c = auxiliar.tradeName__c;
        }
        String documento = !String.isBlank(auxiliar.taxId_number__c) ? auxiliar.taxId_number__c.toUpperCase():'';
        cliente.Documento__c = documento;
        cliente.Pais__c = pais != null ? pais.Id : null;
        
        if (billingCountry != null) {
            cliente.BillingAddressId__c = auxiliar.Invoicing_addresses_id__c;
            cliente.BillingStreet = auxiliar.Invoicing_addresses_street__c; 
        	cliente.BillingCity = auxiliar.Invoicing_addresses_department__c;
        	cliente.BillingCountry = auxiliar.Invoicing_addresses_CountryIso31661__c;
        	cliente.BillingPostalCode = auxiliar.Invoicing_addresses_PostalCode__c;
        	cliente.BillingState = auxiliar.Invoicing_addresses_region__c;
        }
        
        if (shippingCountry != null) {
            cliente.ShippingAddressId__c = auxiliar.Delivering_addresses_id__c;
            cliente.ShippingStreet = auxiliar.Delivering_addresses_street__c; 
        	cliente.ShippingCity = auxiliar.Delivering_addresses_department__c;
        	cliente.ShippingCountry = auxiliar.Delivering_addresses_CountryIso31661__c;
        	cliente.ShippingPostalCode = auxiliar.Delivering_addresses_PostalCode__c;
        	cliente.ShippingState = auxiliar.Delivering_addresses_region__c;
       
        }
     
        cliente.Fecha_Alta_Sima__c = auxiliar.creationDate__c;
        cliente.ultima_modificacion_DMS__c = auxiliar.ultima_actualizacion__c;
        
        if (!String.isBlank(auxiliar.Email__c) &&  DataValidations.validateEmail(auxiliar.Email__c)) {
        	if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
            	cliente.Email__c = auxiliar.Email__c.toLowerCase();
             }
             else{
             	cliente.PersonEmail = auxiliar.Email__c.toLowerCase();
                if (!mapConsentsByMethodValue.containsKey(cliente.PersonEmail)) {
                	Consentimientos__c consent = creaConsentimiento(cliente.PersonEmail, Label.channelEmail, 'Email');
                    mapConsentsByMethoValueToUpsert.put(cliente.PersonEmail,consent);
                    
                 }
                else {
                 	Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.PersonEmail);
                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelEmail)) {
                    	consent.Medio_de_contacto__c = Label.channelEmail;
                      	mapConsentsByMethoValueToUpsert.put(cliente.PersonEmail,consent);
                    }
             }
         	}
         }   
        if( !String.isBlank(auxiliar.OtherEmail__c)  && DataValidations.validateEmail(auxiliar.OtherEmail__c)) {
        	if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
            	cliente.Other_Email__c = auxiliar.OtherEmail__c.toLowerCase();
            }
            else{
            	cliente.OtherEmail__pc = auxiliar.OtherEmail__c.toLowerCase();
                if (!mapConsentsByMethodValue.containsKey(cliente.OtherEmail__pc)) {
                	Consentimientos__c consent = creaConsentimiento(cliente.OtherEmail__pc, Label.channelOtherEmail, 'Email');
                    mapConsentsByMethoValueToUpsert.put(cliente.OtherEmail__pc, consent);
                }
                else {
                	//lo tenemos ya creado 
                    Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.OtherEmail__pc);
                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOtherEmail)) {
                   		consent.Medio_de_contacto__c = Label.channelOtherEmail;
                        mapConsentsByMethoValueToUpsert.put(cliente.OtherEmail__pc, consent);
                        }
                    }
                }
          }
        if (!String.isBlank(auxiliar.Phone__c) && DataValidations.validatePhone(auxiliar.Phone__c)) {
        	auxiliar.Phone__c = DataValidations.transformPhone(auxiliar.Phone__c);
            if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
            	cliente.Phone = auxiliar.Phone__c;
            }
            else {
              	cliente.Phone = auxiliar.Phone__c;
                if (!mapConsentsByMethodValue.containsKey(cliente.Phone)) {
                	Consentimientos__c consent = creaConsentimiento(cliente.Phone, Label.channelPhone, 'Teléfono');
                    mapConsentsByMethoValueToUpsert.put(cliente.Phone, consent);
                }
                else {
                	// lo tenemos ya creado 
                    Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.Phone);
                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelPhone)) {
                            	consent.Medio_de_contacto__c = Label.channelPhone;
                                mapConsentsByMethoValueToUpsert.put(cliente.Phone, consent);
                            }
                }
            }
        } 
        if (!String.isBlank(auxiliar.OtherPhone__c) && DataValidations.validatePhone(auxiliar.OtherPhone__c)) {
        	auxiliar.OtherPhone__c = DataValidations.transformPhone(auxiliar.OtherPhone__c);
            if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
            	if (String.isBlank(cliente.Phone)) {
                	cliente.Other_Phone__c = auxiliar.OtherPhone__c;
                }
             }
            else {
             	cliente.PersonOtherPhone = auxiliar.OtherPhone__c;
                if (!mapConsentsByMethodValue.containsKey(cliente.PersonOtherPhone)) {
                	Consentimientos__c consent = creaConsentimiento(cliente.PersonOtherPhone, Label.channelOtherPhone, 'Teléfono');
                    mapConsentsByMethoValueToUpsert.put(cliente.PersonOtherPhone, consent);
                }
                else {
                	// lo tenemos ya creado 
                    Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.PersonOtherPhone);
                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelPhone)) {
                    	consent.Medio_de_contacto__c = Label.channelPhone;
                        mapConsentsByMethoValueToUpsert.put(cliente.PersonOtherPhone, consent);
                     }
               	}
            }
       	}
        if (!String.isBlank(auxiliar.Mobile__c) && DataValidations.validatePhone(auxiliar.Mobile__c)) {
        	auxiliar.Mobile__c = DataValidations.transformPhone(auxiliar.Mobile__c);
            if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
            	if (String.isBlank(cliente.Mobile__c)) {
                	cliente.Mobile__c = auxiliar.Mobile__c;
                }
            }
            else {
            	cliente.PersonMobilePhone = auxiliar.Mobile__c;
                if (!mapConsentsByMethodValue.containsKey(cliente.PersonMobilePhone)) {
                	Consentimientos__c consent = creaConsentimiento(cliente.PersonMobilePhone, Label.channelMobile, 'Móvil');
                    mapConsentsByMethoValueToUpsert.put(cliente.PersonMobilePhone, consent);
                }
                else {
                	Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.PersonMobilePhone);
                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelMobile)) {
                    	consent.Medio_de_contacto__c = Label.channelMobile;
                        mapConsentsByMethoValueToUpsert.put(cliente.PersonMobilePhone, consent);
                    }
                }
            }
        } 
        if (!String.isBlank(auxiliar.OtherMobile__c) && DataValidations.validatePhone(auxiliar.OtherMobile__c)) {
        	auxiliar.OtherMobile__c = DataValidations.transformPhone(auxiliar.OtherMobile__c);
            if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
              	cliente.Other_Mobile__c = auxiliar.OtherMobile__c;
            }
            else {
            	cliente.OtherMobilePhone__pc = auxiliar.OtherMobile__c;
                if (!mapConsentsByMethodValue.containsKey(cliente.OtherMobilePhone__pc)) {
                	Consentimientos__c consent = creaConsentimiento(cliente.OtherMobilePhone__pc, Label.channelOtherMobile, 'Móvil');
                    mapConsentsByMethoValueToUpsert.put(cliente.OtherMobilePhone__pc, consent);
                }
                else {
                	// lo tenemos ya creado 
                    Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.OtherMobilePhone__pc);
                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOtherMobile)) {
                    	consent.Medio_de_contacto__c = Label.channelOtherMobile;
                        mapConsentsByMethoValueToUpsert.put(cliente.OtherMobilePhone__pc, consent);
                   	}
              	}
           	}
        } 
       
        if (cliente.Id != null){
            Account cliente1 = AccountGateway.getAccountById(cliente.Id);
            if (auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                if (cliente.PersonEmail != null && cliente.OtherEmail__pc == null && cliente1.OtherEmail__pc != null && cliente.PersonEmail == cliente1.OtherEmail__pc){
                    cliente.OtherEmail__pc = cliente1.PersonEmail;
                } 
                if (cliente.PersonMobilePhone != null && cliente.OtherMobilePhone__pc == null && cliente1.OtherMobilePhone__pc != null && cliente.PersonMobilePhone == cliente1.OtherMobilePhone__pc){
                    cliente.OtherMobilePhone__pc = cliente1.PersonMobilePhone;
                } 
                if (cliente.Phone != null && cliente.PersonOtherPhone == null && cliente1.PersonOtherPhone != null && cliente.Phone == cliente1.PersonOtherPhone){
                    cliente.PersonOtherPhone = cliente1.Phone;
                } 
            } else {
                if (cliente.Email__c != null && cliente.Other_Email__c == null && cliente1.Other_Email__c != null && cliente.Email__c == cliente1.Other_Email__c){
                    cliente.Other_Email__c = cliente1.Email__c;
                } 
                if (cliente.Mobile__c != null && cliente.Other_Mobile__c == null && cliente1.Other_Mobile__c != null && cliente.Mobile__c == cliente1.Other_Mobile__c){
                    cliente.Other_Mobile__c = cliente1.Mobile__c;
                } 
                if (cliente.Phone != null && cliente.Other_Phone__c == null && cliente1.Other_Phone__c != null && cliente.Phone == cliente1.Other_Phone__c){
                    cliente.Other_Phone__c = cliente1.Phone;
                } 
            }   
        }    
        
        if (cliente.Id == null){
            // Find duplicates
            List<Account> lstDuplicates = new List<Account>();
            lstDuplicates.add(cliente);
            //Cambiamos de lugar los telefonos/emails o completamos el otro para tener un mayor exito en la busqueda de duplicados
            Account cliente1 = new Account(); 
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                cliente1.RecordTypeId = cliente.RecordTypeId;
                cliente1.FirstName = cliente.FirstName;
        	    cliente1.LastName = cliente.LastName; 
                if (cliente.OtherEmail__pc == null && cliente.PersonEmail != null) {
                    cliente1.OtherEmail__pc = cliente.PersonEmail;
                } 
                else if (cliente.OtherEmail__pc != null && cliente.PersonEmail != null){
                    cliente1.OtherEmail__pc = cliente.PersonEmail;
                    cliente1.PersonEmail = cliente.OtherEmail__pc;
                }
                if (cliente.OtherMobilePhone__pc == null && cliente.PersonMobilePhone != null) {
                    cliente1.OtherMobilePhone__pc = cliente.PersonMobilePhone;
                } 
                else if (cliente.OtherMobilePhone__pc != null && cliente.PersonMobilePhone != null){
                    cliente1.OtherMobilePhone__pc = cliente.PersonMobilePhone;
                    cliente1.PersonMobilePhone = cliente.OtherMobilePhone__pc;
                }
                if (cliente.PersonOtherPhone == null && cliente.Phone != null) {
                    cliente1.PersonOtherPhone = cliente.Phone;
                } 
                else if (cliente.PersonOtherPhone != null && cliente.Phone != null) {
                    cliente1.PersonOtherPhone = cliente.Phone;
                    cliente1.Phone = cliente.PersonOtherPhone;
                }
            } 
            else {
                cliente1.RecordTypeId = cliente.RecordTypeId;
                cliente1.Name = cliente.Name;
                if (cliente.Other_Email__c == null && cliente.Email__c != null) {
                    cliente1.Other_Email__c = cliente.Email__c;
                } 
                else if (cliente.Other_Email__c != null && cliente.Email__c != null) {
                    cliente1.Other_Email__c = cliente.Email__c;
                    cliente1.Email__c = cliente.Other_Email__c;
                }
                if (cliente.Other_Mobile__c == null && cliente.Mobile__c != null) {
                    cliente1.Other_Mobile__c = cliente.Mobile__c;
                } 
                else if (cliente.Other_Mobile__c != null && cliente.Mobile__c != null) {
                    cliente1.Other_Mobile__c = cliente.Mobile__c;
                    cliente1.Mobile__c = cliente.Other_Mobile__c;
                }
                if (cliente.Other_Phone__c == null && cliente.Phone != null) {
                    cliente1.Other_Phone__c = cliente.Phone;
                } 
                else if (cliente.Other_Phone__c != null && cliente.Phone != null){
                    cliente1.Other_Phone__c = cliente.Phone;
                    cliente1.Phone = cliente.Other_Phone__c;
                }
            }
            lstDuplicates.add(cliente1);
            
            System.debug('=====>LSTDUPS: ' + lstDuplicates);
        
            if (Datacloud.FindDuplicates.findDuplicates(lstDuplicates).size() > 0) {
                for (Datacloud.FindDuplicatesResult resultFindDuplicate: Datacloud.FindDuplicates.findDuplicates(lstDuplicates)){
                    System.debug('=====>LSTDUPSRESULT0: ' + resultFindDuplicate);
                    for (Datacloud.DuplicateResult recordDuplicate: resultFindDuplicate.getDuplicateResults()){
                         System.debug('recordDuplicate:'+recordDuplicate);
                         String ruleDuplicateDN = recordDuplicate.getDuplicateRule();
                         if(!ruleDuplicateDN.equalsIgnoreCase('PAccountLead')){
                            List<Datacloud.MatchRecord> recordListMatch = recordDuplicate.getMatchResults()[0].getMatchRecords();
                            System.debug('=====>RECORDLISTMATCH: ' + recordListMatch);
                            if (!recordListMatch.isEmpty()) {
                                Datacloud.MatchRecord recordMatch = recordListMatch[0];
                                SObject record = recordMatch.getRecord();
                                System.debug('RECORD: ' + record);
                                Account auxAcc = (Account) record;
                        
                                if (auxAcc != null) {
                                    system.debug('auxAcc:'+auxAcc);
                                    cliente.Id = auxAcc.Id;
                                    
                                    if (auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){

                                       cliente.PersonEmail = !String.isBlank(cliente.PersonEmail)?cliente.PersonEmail:auxAcc.PersonEmail;
                                       cliente.OtherEmail__pc = !String.isBlank(cliente.OtherEmail__pc)?cliente.OtherEmail__pc:auxAcc.OtherEmail__pc;
                                       cliente.PersonMobilePhone = !String.isBlank(cliente.PersonMobilePhone)?cliente.PersonMobilePhone:auxAcc.PersonMobilePhone;
                                       cliente.OtherMobilePhone__pc = !String.isBlank(cliente.OtherMobilePhone__pc)?cliente.OtherMobilePhone__pc:auxAcc.OtherMobilePhone__pc;
                                       cliente.Phone = !String.isBlank(cliente.Phone)?cliente.Phone:auxAcc.Phone;
                                       cliente.PersonOtherPhone = !String.isBlank(cliente.PersonOtherPhone)?cliente.PersonOtherPhone:auxAcc.PersonOtherPhone;
                                        
                                       if (cliente.PersonEmail == null && cliente.OtherEmail__pc != null ) {
                                           cliente.PersonEmail = cliente.OtherEmail__pc;
                                           cliente.OtherEmail__pc = null;
                                       }
                                       if (cliente.PersonEmail != null && cliente.OtherEmail__pc != null && cliente.PersonEmail == cliente.OtherEmail__pc){
                                           if (auxAcc.PersonEmail != null && auxAcc.PersonEmail != cliente.OtherEmail__pc) {
                                               cliente.OtherEmail__pc = auxAcc.PersonEmail;
                                           } else {
                                               cliente.OtherEmail__pc = null;
                                           }
                                       }
                                       if (cliente.OtherEmail__pc == null && auxAcc.PersonEmail != null && cliente.PersonEmail != null && auxAcc.PersonEmail != cliente.PersonEmail){
                                           cliente.OtherEmail__pc = auxAcc.PersonEmail;
                                       }
                                        
                                       if (cliente.PersonMobilePhone == null && cliente.OtherMobilePhone__pc != null ) {
                                           cliente.PersonMobilePhone = cliente.OtherMobilePhone__pc;
                                           cliente.OtherMobilePhone__pc = null;
                                       }
                                       if (cliente.PersonMobilePhone != null && cliente.OtherMobilePhone__pc != null && cliente.PersonMobilePhone == cliente.OtherMobilePhone__pc){
                                           if (auxAcc.PersonMobilePhone != null && auxAcc.PersonMobilePhone != cliente.OtherMobilePhone__pc) {
                                               cliente.OtherMobilePhone__pc = auxAcc.PersonMobilePhone;
                                           } else {
                                               cliente.OtherMobilePhone__pc = null;
                                           }
                                       }
                                       if (cliente.OtherMobilePhone__pc == null && auxAcc.PersonMobilePhone != null && cliente.PersonMobilePhone != null && auxAcc.PersonMobilePhone != cliente.PersonMobilePhone){
                                           cliente.OtherMobilePhone__pc = auxAcc.PersonMobilePhone;
                                       }
                                        
                                       if (cliente.Phone == null && cliente.PersonOtherPhone != null ) {
                                           cliente.Phone = cliente.PersonOtherPhone;
                                           cliente.PersonOtherPhone = null;
                                       }
                                       if (cliente.Phone != null && cliente.PersonOtherPhone != null && cliente.Phone == cliente.PersonOtherPhone){
                                           if (auxAcc.Phone != null && auxAcc.Phone != cliente.PersonOtherPhone) {
                                               cliente.PersonOtherPhone = auxAcc.Phone;
                                           } else {
                                               cliente.PersonOtherPhone = null;
                                           }
                                       }
                                       if (cliente.PersonOtherPhone == null && auxAcc.Phone != null && cliente.Phone != null && auxAcc.Phone != cliente.Phone){
                                           cliente.PersonOtherPhone = auxAcc.Phone;
                                       }
                                       if ((cliente.Documento__c == null || string.isBlank(cliente.Documento__c)) && auxAcc.Documento__c != null){
                                       	   cliente.Documento__c = auxAcc.Documento__c;
                                       }    
                                       
                                    }
                                    else {
                                       cliente.Email__c = !String.isBlank(cliente.Email__c)?cliente.Email__c:auxAcc.Email__c;
                                       cliente.Other_Email__c = !String.isBlank(cliente.Other_Email__c)?cliente.Other_Email__c:auxAcc.Other_Email__c;
                                       cliente.Phone = !String.isBlank(cliente.Phone)?cliente.Phone:auxAcc.Phone;
                                       cliente.Other_Phone__c = !String.isBlank(cliente.Other_Phone__c)?cliente.Other_Phone__c:auxAcc.Other_Phone__c;
                                       cliente.Mobile__c = !String.isBlank(cliente.Mobile__c)?cliente.Mobile__c:auxAcc.Mobile__c;
                                       cliente.Other_Mobile__c = !String.isBlank(cliente.Other_Mobile__c)?cliente.Other_Mobile__c:auxAcc.Other_Mobile__c;

                                       if (cliente.Email__c == null && cliente.Other_Email__c != null ) {
                                           cliente.Email__c = cliente.Other_Email__c;
                                           cliente.Other_Email__c = null;
                                       }
                                       if (cliente.Email__c != null && cliente.Other_Email__c != null && cliente.Email__c == cliente.Other_Email__c){
                                           if (auxAcc.Email__c != null && auxAcc.Email__c != cliente.Other_Email__c) {
                                               cliente.Other_Email__c = auxAcc.Email__c;
                                           } else {
                                               cliente.Other_Email__c = null;
                                           }
                                       }
                                       if (cliente.Other_Email__c == null && auxAcc.Email__c != null && cliente.Email__c != null && auxAcc.Email__c != cliente.Email__c){
                                           cliente.Other_Email__c = auxAcc.Email__c;
                                       }
                                        
                                       if (cliente.Mobile__c == null && cliente.Other_Mobile__c != null ) {
                                           cliente.Mobile__c = cliente.Other_Mobile__c;
                                           cliente.Other_Mobile__c = null;
                                       }
                                       if (cliente.Mobile__c != null && cliente.Other_Mobile__c != null && cliente.Mobile__c == cliente.Other_Mobile__c){
                                           if (auxAcc.Mobile__c != null && auxAcc.Mobile__c != cliente.Other_Mobile__c) {
                                               cliente.Other_Mobile__c = auxAcc.Mobile__c;
                                           } else {
                                               cliente.Other_Mobile__c = null;
                                           }
                                       }
                                       if (cliente.Other_Mobile__c == null && auxAcc.Mobile__c != null && cliente.Mobile__c != null && auxAcc.Mobile__c != cliente.Mobile__c){
                                           cliente.Other_Mobile__c = auxAcc.Mobile__c;
                                       }
                                        
                                       if (cliente.Phone == null && cliente.Other_Phone__c != null ) {
                                           cliente.Phone = cliente.Other_Phone__c;
                                           cliente.Other_Phone__c = null;
                                       }
                                       if (cliente.Phone != null && cliente.Other_Phone__c != null && cliente.Phone == cliente.Other_Phone__c){
                                           if (auxAcc.Phone != null && auxAcc.Phone != cliente.Other_Phone__c) {
                                               cliente.Other_Phone__c = auxAcc.Phone;
                                           } else {
                                               cliente.Other_Phone__c = null;
                                           }
                                       }
                                       if (cliente.Other_Phone__c == null && auxAcc.Phone != null && cliente.Phone != null && auxAcc.Phone != cliente.Phone){
                                           cliente.Other_Phone__c = auxAcc.Phone;
                                       }
                                       if ((cliente.Documento__c == null || string.isBlank(cliente.Documento__c)) && auxAcc.Documento__c != null){
                                       	   cliente.Documento__c = auxAcc.Documento__c;
                                       }    

                                    }
                                    duplicado = true;
                                    break; 
                                }
                                else {
                                   new customException('FAIL');
                                }
                            }
                            else {
                               System.debug('NO recordMatch');
                            }
                         } 		
                         else {
                            system.debug('Duplicado con Lead crear registro duplicado: regla:'+ ruleDuplicateDN);
                            system.debug('duplicado:'+  recordDuplicate.getMatchResults()[0].getMatchRecords());
                         }
                    }
                }                                       
            }    
            else {
                System.debug('NO DUPLICATES!');
            }
                
        }

        // Crear o actualizar Cuenta de cliente
       	upsert cliente;
        System.debug('INSERT CLIENTE: ' + cliente);
        
        // Añade el contacto relacionado con el cliente a los consentimientos
        Contact conCliente;
        //Si se ha encontrado por duplicado
         cliente = AccountGateway.getAccountById(cliente.Id);
        if(duplicado && cliente.IsPersonAccount){
              //buscamos nuevamente el contact
            mapAccountIdContacts = ContactGateway.getContactByAccountId(new List<String>{cliente.Id});
            conCliente = mapAccountIdContacts.get(cliente.Id);
            for (Consentimientos__c consent :[SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId,Contact__c
                                              FROM Consentimientos__c
                                              WHERE Contact__c =:conCliente.Id]) {
                if(mapConsentsByMethoValueToUpsert.containsKey(consent.ChannelValue__c)){
                    Consentimientos__c aux = mapConsentsByMethoValueToUpsert.get(consent.ChannelValue__c);
                    aux.Id = consent.Id;
                    aux.contact__c = consent.contact__c;
                    mapConsentsByMethoValueToUpsert.put(consent.ChannelValue__c, aux);
                }
                else {
                    consent.Medio_de_contacto__c = Label.channelOther;
                    mapConsentsByMethoValueToUpsert.put(consent.ChannelValue__c, consent);
        	}
        	}
        }
        else if(mapAccountIdContacts.isEmpty() && cliente.IsPersonAccount){
            mapAccountIdContacts = ContactGateway.getContactByAccountId(new List<String>{cliente.Id});
            conCliente = mapAccountIdContacts.get(cliente.Id);
        }
        else if(cliente.IsPersonAccount){
             conCliente = mapAccountIdContacts.get(cliente.Id);
        }
          
        //Ponemos a los consentimientos la relacion con el contacto y el tipo de medio de contacto correcto
        for(String value :mapConsentsByMethoValueToUpsert.keySet()){
            Consentimientos__c consent = mapConsentsByMethoValueToUpsert.get(value);
            if (cliente.PersonEmail != null && consent.ChannelValue__c == cliente.PersonEmail){
                consent.Medio_de_contacto__c = Label.channelEmail;
            }
            if (cliente.OtherEmail__pc != null && consent.ChannelValue__c == cliente.OtherEmail__pc){
                consent.Medio_de_contacto__c = Label.channelOtherEmail;
            }
            if (cliente.PersonMobilePhone != null && consent.ChannelValue__c == cliente.PersonMobilePhone){
                consent.Medio_de_contacto__c = Label.channelMobile;
            }
            if (cliente.OtherMobilePhone__pc != null && consent.ChannelValue__c == cliente.OtherMobilePhone__pc){
                consent.Medio_de_contacto__c = Label.channelOtherMobile;
            }
            if (cliente.Phone != null && consent.ChannelValue__c == cliente.Phone){
                consent.Medio_de_contacto__c = Label.channelPhone;
            }
            if (cliente.PersonOtherPhone != null && consent.ChannelValue__c == cliente.PersonOtherPhone){
                consent.Medio_de_contacto__c = Label.channelOtherPhone;
            }
            consent.contact__c = conCliente.Id;
            mapConsentsByMethoValueToUpsert.put(value,consent);
        }
        if (!mapConsentsByMethoValueToUpsert.isEmpty()) {
         	upsert mapConsentsByMethoValueToUpsert.values();
        }
      	system.debug('cliente:devuelto:'+cliente);
        return cliente;
    }

    // Crea o actualiza registro "Cliente_Concesionario"
    private static Cliente_Concesionario__c upsertClienteConcesionario(AuxAccount__c auxiliar, Cliente_Concesionario__c clienteConcesionario,Account cliente, Concesionario__c concesionario) {
        List<Cliente_Concesionario__c> cConcesionarioToUpsert = new List<Cliente_Concesionario__c>();
        List<Cliente_Concesionario__c> cConcesionarios = ClienteConcesionarioGateway.searchClienteConcesionariosByAccountId(cliente.Id);
        system.debug('auxiliar:'+ auxiliar);
        system.debug('cliente:'+ cliente);
        system.debug('concesionario:'+ concesionario);
        system.debug('clienteConcesionario:'+ clienteConcesionario);
        if (clienteConcesionario == null) {
        	clienteConcesionario = new Cliente_Concesionario__c();
            clienteConcesionario.Concesionario__c = concesionario.Id;
            clienteConcesionario.Cliente__c = cliente.Id;
        }
        
        clienteConcesionario.Documento__c = !String.isBlank(auxiliar.taxId_number__c) ? auxiliar.taxId_number__c.toUpperCase() : cliente.Documento__c;
        clienteConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;		// y falla aqui ya que no esta declarado el clienteConcesionario
        clienteConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
        clienteConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        clienteConcesionario.External_Id__c = auxiliar.External_Id__c;
        if (!String.isEmpty(auxiliar.Email__c)) {
        	clienteConcesionario.ID_Email__c = auxiliar.ID_Email__c;
            clienteConcesionario.Email__c = auxiliar.Email__c.toLowerCase();
       	}
        if (!String.isEmpty(auxiliar.OtherEmail__c)){
        	clienteConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
            clienteConcesionario.OtherEmail__c = auxiliar.OtherEmail__c.toLowerCase();
        }
        if (!String.isEmpty(auxiliar.Phone__c)) {
        	clienteConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
            clienteConcesionario.Phone__c = auxiliar.Phone__c;
        }
        if (!String.isEmpty(auxiliar.OtherPhone__c)) {
            clienteConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
        	clienteConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
        }
        if (!String.isEmpty(auxiliar.Mobile__c)) {
            clienteConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
            clienteConcesionario.Mobile__c = auxiliar.Mobile__c;
        }
        if (!String.isEmpty(auxiliar.OtherMobile__c)) {
       		clienteConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
            clienteConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
        }
        clienteConcesionario.Origen__c = 'SIMA';
       
        cConcesionarioToUpsert.add(clienteConcesionario);
        
        // Actualizar clienteConcesionarios relacionados con el cliente con el documento
        if (!cConcesionarios.isEmpty()) {
            for (Cliente_Concesionario__c cConcesionario : cConcesionarios) {
                if (!String.isBlank(auxiliar.taxId_number__c) && cConcesionario.Id != clienteConcesionario.Id ) {
                    cConcesionario.Documento__c = auxiliar.taxId_number__c; 
                    cConcesionarioToUpsert.add(cConcesionario);
                }
            }
        }
        List<Cliente_Concesionario__c> cConcesionarioExternal = new List<Cliente_Concesionario__c>();
        List<Cliente_Concesionario__c> cConcesionarioNotExternal = new List<Cliente_Concesionario__c>();
        if (!cConcesionarioToUpsert.isEmpty()) {
            for(Cliente_Concesionario__c cConcesionario : cConcesionarioToUpsert) {
                if(!String.isBlank(cConcesionario.External_Id__c)){
                    cConcesionarioExternal.add(cConcesionario);
                }
                else {
                    cConcesionarioNotExternal.add(cConcesionario);
                }
                
            }  

            if(!cConcesionarioExternal.isEmpty()){
//                upsert cConcesionarioExternal External_Id__c;
                Schema.SObjectField f = Cliente_Concesionario__c.Fields.External_Id__c;
                Database.UpsertResult [] cr = Database.upsert(cConcesionarioExternal, f); 
                for (Database.UpsertResult sr: cr) {
                     if (sr.isSuccess()) {
                         System.debug('Actualiza CConcesionario OK'+ sr.getId());
                     }
                    else {
                         for(Database.Error err : sr.getErrors()) {
                             System.debug('Actualiza CConcesionario ERROR');
                             System.debug(err.getStatusCode() + ': ' + err.getMessage());
                             System.debug('Campos: ' + err.getFields());
                             
                             Exception__c exc = new Exception__c ();
                             exc.idObjetos__c = auxiliar.External_Id__c;
                             exc.Exception__c = err.getStatusCode() + '// ' + err.getMessage();
                             exc.Linea__c = 820;
                             exc.Clase_Metodo__c = 'SalesProcessApiRestController.upsertClienteConcesionario';
                        
                             insert exc;
                         }
                     }       
                }
            }    
            
            if(!cConcesionarioNotExternal.isEmpty()){
                upsert cConcesionarioNotExternal;
            }
        }
        
        return clienteConcesionario;
    }
    
    // Crea instancia de  un consentimiento
    private static Consentimientos__c creaConsentimiento(String valor, String channel, String recordTypeName) {
        Consentimientos__c consent = new Consentimientos__c();
		consent.ChannelValue__c = valor;
		consent.Medio_de_contacto__c = channel;
		System.debug('recordtype: ' + rtMapConsentimientoByName);
		System.debug('recordtypeN :  ' + recordTypeName);

		consent.RecordTypeId = rtMapConsentimientoByName.get(recordTypeName).getRecordTypeId();
		consent.CustomerSatisfaction__c = 'Unknown';
		consent.MarketResearch__c = 'Unknown';
		consent.EventInvitation__c = 'Unknown';
		consent.AfterSales__c = 'Unknown';
		consent.ProductSale__c = 'Unknown';
		consent.CustomerSatisfactionSMS__c = 'Unknown';
		consent.MarketResearchSMS__c = 'Unknown';
		consent.AfterSalesSMS__c = 'Unknown';
		consent.ProductSaleSMS__c = 'Unknown';
		consent.EventInvitationSMS__c = 'Unknown';
        consent.EnviarAmulesoft__c = false;
        
        return consent;
    }

    public static ResponseApi SalesProcessAnonymized(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        //eliminamos proceso de venta por anonimización 
        try {
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }

            List<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.SalesProcessAnonymized');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            
            if (opp != null) {
    	        List<Case> listCasosToUpdate = new List<Case>();
    	        List<Case> listCasos = CaseGateway.getCasebySalesProcessId(opp.Id);
        	    if(!listCasos.isEmpty()){
                    for (case caso : listCasos) {
                        Case casoToUpdate = new Case();
                       	casoToUpdate.id = caso.id;  
                       	casoToUpdate.Estado_Oportunidad_TXT__c = opp.StageName;
                        listCasosToUpdate.add(casoToUpdate);
                    }
            	}

        	    if(!listCasosToUpdate.isEmpty()){
                	update listCasosToUpdate;
            	}
                
	            delete opp;
            }
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
            //response.ErrorCode = '200';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            system.debug('linea:'+ e.getLineNumber());
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_opportunityNotFound)) {
                response.ErrorCode = '504';
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.SalesProcessAnonymized';
            
            insert exc;
            
        }
        
        return response;
    }
    
    public static ResponseApi SalesmanOwnerChanged(SalesProcessApiRestModel req) {
        ResponseApi response = new ResponseApi();
        
        try {
            //buscar la oportunidad
            if (String.isBlank(req.payload.salesProcessId)) {
                throw new CustomException(Label.errorMessage_salesProcessId);
            }

            List<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(req.payload.salesProcessId, 'SalesProcessApiRestController.salesmanOwnerChanged');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            String centroIdExterno = req.payload.companyCode + '-' + req.payload.centerCode;
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(req.payload.salesProcessId);
            if (opp == null) {
                throw new CustomException(Label.errorMessage_opportunityNotFound);
            }
            Salesman__c vendedor = !String.isBlank(req.payload.salesmanEmail) ? SalesmanGateway.getSalesmanByEmail(req.payload.salesmanEmail.toLowerCase()):null;
            //creo el vendedor  si no existe 
            if (vendedor == null && !String.isBlank(req.payload.salesmanEmail) ) {
                vendedor = new Salesman__c();
                if (req.payload.salesmanName != null) {
                    vendedor.Name = DataValidations.capitalizeString(req.payload.salesmanName);
                } else {
                    vendedor.Name = req.payload.salesmanEmail.toLowerCase();
                }    
                vendedor.Email__c = req.payload.salesmanEmail.toLowerCase();
        
                if(!String.isBlank(req.payload.salesmanMobile)){
            		String CleanPhone = DataValidations.clearPhone(req.payload.salesmanMobile);
            		vendedor.Phone__c = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
        		}
				insert vendedor;
            } else if (vendedor != null) {
                boolean ActualizaVendedor = false;
				if (req.payload.salesmanName != null && vendedor.Name != DataValidations.capitalizeString(req.payload.salesmanName)) {
                    vendedor.Name = DataValidations.capitalizeString(req.payload.salesmanName);
                    ActualizaVendedor = true;
                }    
                if(!String.isBlank(req.payload.salesmanMobile)){
            		String CleanPhone = DataValidations.clearPhone(req.payload.salesmanMobile);
            		String CleanPhone1 = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
                    if (vendedor.Phone__c != CleanPhone1) {
                        vendedor.Phone__c = CleanPhone1;
                        ActualizaVendedor = true;
                    }
        		}
                if (ActualizaVendedor) {update vendedor;}
            } 
           
            opp.Vendedor__c = vendedor != null?vendedor.Id:null;
            
            upsert opp;
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            
            if (e.getMessage().equalsIgnoreCase(Label.errorMessage_salesProcessId)) {   
                response.ErrorCode = '501'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_centerNotFound)) {
                response.ErrorCode = '502'; 
            }
            else if (e.getMessage().equalsIgnoreCase(Label.errorMessage_clientNotFound)) {
                response.ErrorCode = '503'; 
            }

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.payload.salesProcessId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'SalesProcessApiRestController.salesmanOwnerChanged';
            
            insert exc;
            
        }
        
        return response;
    }
    
}