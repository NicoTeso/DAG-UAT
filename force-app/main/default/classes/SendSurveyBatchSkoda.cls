global class SendSurveyBatchSkoda implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
	

    private List<SendSurveySkodaModel> allRequest;
    private List<Exception__c> listExceptions;
    private String queryType;
    private String queryTime;
    global SendSurveyBatchSkoda(String tipo, String tiempo) {
        queryType = tipo.toUpperCase();
        queryTime = tiempo.toUpperCase();
        allRequest = new List<SendSurveySkodaModel>();
        listExceptions = new List<Exception__c>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryBrand = 'SKODA';
        System.debug('queryType: '+queryType);
        System.debug('queryTime: '+queryTime);
        
        String TipoOperacion = queryType.equalsIgnoreCase('SALES')? 'Venta':'Pase de taller';
        
        Datetime fecDesde;
        Datetime fecHasta;
        if(queryTime.equalsIgnoreCase('CUSTOM')){
            fecDesde = datetime.parse(label.startSurveyCustom);
            fecHasta = datetime.parse(label.endSurveyCustom);
        }
        
        if(queryTime.equalsIgnoreCase('LAST WEEK')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = LAST_N_WEEKS:1 AND Fecha_respuesta_encuesta__c < LAST_N_WEEKS:0
                                            AND  Anonymous__c != null
                                            AND Brand__c = :queryBrand
                                            AND Tipo_de_Operacion__c = :TipoOperacion]);
        }
        else {
        if(queryTime.equalsIgnoreCase('CUSTOM')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c >= :fecDesde AND Fecha_respuesta_encuesta__c < :fecHasta
                                            AND  Anonymous__c != null
                                            AND Brand__c = :queryBrand
                                            AND Tipo_de_Operacion__c = :TipoOperacion]);
        }
        else {
        if(queryTime.equalsIgnoreCase('LAST MONTH')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = LAST_N_MONTHS:1 AND Fecha_respuesta_encuesta__c < LAST_N_MONTHS:0
                                            AND  Anonymous__c != null
                                            AND Brand__c = :queryBrand
                                            AND Tipo_de_Operacion__c = :TipoOperacion]);
        }
        else {
            return Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = YESTERDAY
                                            AND  Anonymous__c != null
                                            AND Brand__c = :queryBrand
                                            AND Tipo_de_Operacion__c = :TipoOperacion]);
        }
        }
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Encuesta__c> lstSurveys) {
    	
        try {
            if(!lstSurveys.isEmpty()){
                
                system.debug('lstSurveys: '+lstSurveys);
            
                Set<Id> encuestaIds = new Set<Id>();
                List<String> accountIds = new List<String>();
                List<String> gEncuestaIds = new List<String>();
                
                Map<String,Account> mapClienteById = new Map<String,Account>();
                Map<String,Gestion_encuesta__c> mapGEncuestaById = new Map<String,Gestion_encuesta__c>();
                SendSurveySkodaModel currentRequest;
                
                for(Encuesta__c survey :lstSurveys){
                    encuestaIds.add(survey.Id);
                    if(survey.Cliente__c != null){
                        accountIds.add(survey.Cliente__c);
                    }
                    if(survey.Gestion_encuesta__c != null){
                        gEncuestaIds.add(survey.Gestion_encuesta__c);
                    }
                }
                
                if(!accountIds.isEmpty()){
                    mapClienteById = AccountGateway.getAccountById(accountIds);
                }
                if(!gEncuestaIds.isEmpty()){
                    mapGEncuestaById = GestionEncuestaGateway.getGestionEncuestaById(gEncuestaIds);
                }
                
                for(Encuesta__c survey :lstSurveys){
                    Account cuenta = mapClienteById.containsKey(survey.Cliente__c)?mapClienteById.get(survey.Cliente__c):null;
                    Gestion_encuesta__c gEncuesta = mapGEncuestaById.containsKey(survey.Gestion_encuesta__c)? mapGEncuestaById.get(survey.Gestion_encuesta__c): null;
                    if(gEncuesta != null){
                        allRequest.add(formatSurvey(survey, cuenta, gEncuesta));
                    }
                }
            }
        } catch (Exception e) {
            Exception__c exc = new Exception__c ();
            //exc.idObjetos__c = '';
            exc.Exception__c = e.getStackTraceString();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'SendSurveyBatchSkoda.execute';
            listExceptions.add(exc);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        try {
            System.debug('SendSurveyBatchSkoda.finish allRequest ' + allRequest);
            if(allRequest != null && !allRequest.isEmpty()){
                SendSurveySkodaCallout.getSurveySkodaCallout(allRequest, queryType);
            }
        } catch (Exception e) {
            System.debug('SendSurveyBatchSkoda.finish exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            //exc.idObjetos__c = '';
            exc.Exception__c = e.getStackTraceString();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'SendSurveyBatchSkoda.finish';
            listExceptions.add(exc);
            // insert exc;
        }

        if(listExceptions != null && !listExceptions.isEmpty()){
            insert listExceptions;
        }
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SendSurveyBatchSkoda(this.queryType,this.queryTime));
    }
    
    public SendSurveySkodaModel formatSurvey(Encuesta__c poll, Account cuenta, Gestion_encuesta__c gEncuesta){
    	
        System.debug('SendSurveyBatchSkoda.formatSurvey poll ' + json.serialize(poll));
        System.debug('SendSurveyBatchSkoda.formatSurvey cuenta ' + json.serialize(cuenta));
        System.debug('SendSurveyBatchSkoda.formatSurvey gEncuesta ' + json.serialize(gEncuesta));
        SendSurveySkodaModel request = new SendSurveySkodaModel();
        request.eventDate = Date.today();
        
        request.car = new SendSurveySkodaModel.CarModel();
        request.customer = new SendSurveySkodaModel.CustomerModel();
        request.dealer = new SendSurveySkodaModel.DealerModel();
        
        //CarModel
        request.car.carModel = poll.ModeloString__c;
        request.car.carVin = poll.vin__c;
        //request.car.additionalCarInfo = poll.;
        // request.car.carAge = poll.;
        // request.car.carMotorType = poll.;
        // request.car.carTrimLevel = poll.;
        
        //CustomerModel
        request.customer.address = (cuenta != null? cuenta.BillingStreet + ' ' +
        cuenta.BillingPostalCode + ' ' +
        cuenta.BillingCity + ' ' +
        cuenta.BillingState + ' ' +
        cuenta.BillingCountry: '');

        request.customer.country = gEncuesta.Country__c;
        if (cuenta != null) {
            request.customer.email = !String.isBlank(cuenta.PersonEmail)? cuenta.PersonEmail: '';
        } else {
            request.customer.email = !String.isBlank(poll.Email__c)? poll.Email__c: '';
        }    
        
        if (cuenta != null) {
            if (!String.isBlank(cuenta.PersonMobilePhone)) {
	            request.customer.phone = cuenta.PersonMobilePhone;
            } else if (!String.isBlank(cuenta.Phone)) {
	            request.customer.phone = cuenta.Phone;
            } else {
                request.customer.phone = '';
            }
        } else {
            request.customer.phone = !String.isBlank(poll.MobilePhone__c)? poll.MobilePhone__c: '';
        }    

        request.customer.salutation = cuenta != null && String.isNotBlank(cuenta.Salutation)? cuenta.Salutation:'';
        
        if (cuenta != null){                
            request.customer.firstName = !String.isBlank(cuenta.FirstName)? cuenta.FirstName:'';
        } else {
            request.customer.firstName = !String.isBlank(poll.Nombre_Cliente__c)? poll.Nombre_Cliente__c:'';
        }

        if (cuenta != null){                
            request.customer.surname = !String.isBlank(cuenta.LastName)? cuenta.LastName:'';
        } else {
            request.customer.surname = !String.isBlank(poll.Apellido_Cliente__c)? poll.Apellido_Cliente__c:'';
        }
        
        if (cuenta != null) {	
	        request.customer.id = String.isNotBlank(poll.Anonymous__c) && poll.Anonymous__c =='1' ? cuenta.Id : '';
        } else {
	        request.customer.id = '';
        }
        //request.customer.additionalCustomerInfo = poll.adsdas;
        request.customer.invoiceAmount = 0;
        // request.customer.orderType = poll.adsdas;
        // request.customer.wayOfOrdering = poll.adsdas;

        //DealerModel
        request.dealer.countryCode = gEncuesta.Country__c;
        request.dealer.id = gEncuesta.Code__c;
        request.dealer.serviceAdvisor = String.isNotBlank(poll.ServiceAdvisor__c)? poll.ServiceAdvisor__c:'';
        
        System.debug('SendSurveyBatchSkoda.SendSurveyBatchSkoda request ' + json.serialize(request));
        return request;
    }
}