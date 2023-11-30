global class SendSurveyCEMBatch implements Database.Batchable<sObject>, Schedulable {
    private String queryBrand;
    private String queryBrand1;
    private String queryTime;
    
    global SendSurveyCEMBatch(String brand, String tiempo) {
        queryBrand = brand.toUpperCase();
        queryTime = tiempo.toUpperCase();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('queryBrand: '+queryBrand);
        System.debug('queryTime: '+queryTime);
        
        queryBrand1 = queryBrand;
        if (queryBrand.equalsIgnoreCase('HYUNDAI1')) {
            queryBrand1 = 'HYUNDAI';    
        }
        System.debug('queryBrand1: '+queryBrand1);

        Date auxFecDesde;
        Date auxFecHasta;
        Datetime fecDesde;
        Datetime fecHasta;
        if(queryTime.equalsIgnoreCase('CUSTOM')){
            auxFecDesde = date.parse(label.startSurveyCustom);
            auxFecHasta = date.parse(label.endSurveyCustom);
            fecDesde = auxFecDesde;
            fecHasta = auxFecHasta;
        }

        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName();
        List<String> RTList = new List<String>();
        if (queryBrand.equalsIgnoreCase('HYUNDAI1')) {
	        RTList.add(rtMapByDName.get('Externa').getRecordTypeId());
	        RTList.add(rtMapByDName.get('Externa_Manuales').getRecordTypeId());
        } else {
	        RTList.add(rtMapByDName.get('CEM').getRecordTypeId());
	        RTList.add(rtMapByDName.get('CEM_Manuales').getRecordTypeId());
        }   
        
        if(queryTime.equalsIgnoreCase('CUSTOM')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c >= :fecDesde AND Fecha_respuesta_encuesta__c < :fecHasta
                                            AND Anonymous__c != null
                                            AND EnvioFabrica__c = true  
                                            AND Brand__c = :queryBrand1
                                            AND RecordTypeId IN :RTList]);
        }
        else {
            return Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = YESTERDAY
                                            AND Anonymous__c != null
                                            AND EnvioFabrica__c = true  
                                            AND Brand__c = :queryBrand1
                                            AND RecordTypeId IN :RTList]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Encuesta__c> lstSurveys) {
        Map<String, Map<String, Respuesta_encuesta__c>> mapSurveyToQA = new Map<String, Map<String, Respuesta_encuesta__c>>();
        Map<String, List<String>> mapOppToColumnAnswers = new Map<String, List<String>>();
        Map<String, List<String>> mapOppToColumnHeaders = new Map<String, List<String>>();
        Map<String,Account> mapClienteById = new Map<String,Account>();
        Map<String,Gestion_encuesta__c> mapGEncuestaById = new Map<String,Gestion_encuesta__c>();
        Map<String,Concesionario__c> mapConcesionarioById = new Map<String,Concesionario__c>();
		Map<String, Map<String,Consentimientos__c>> mapConsenEnuestaById = new Map<String,Map<String,Consentimientos__c>>();
        List<Id> encuestaIds = new List<Id>();
        List<String> accountIds = new List<String>();
        List<String> gEncuestaIds = new List<String>();
        List<String> concesionarioIds = new List<String>();
        SurveyAux csvHeaderAS = new SurveyAux();
        csvHeaderAS.SurveyAux();
        SurveyAux csvHeaderSA = new SurveyAux();
        csvHeaderSA.SurveyAux();
        SurveyAux csvResultAS = new SurveyAux();
        csvResultAS.SurveyAux();
        SurveyAux csvResultSA = new SurveyAux();
        csvResultSA.SurveyAux();
        if(!lstSurveys.isEmpty()){
            for(Encuesta__c survey :lstSurveys){
            encuestaIds.add(survey.Id);
            if(survey.Cliente__c != null){
                accountIds.add(survey.Cliente__c);
            }
            if(survey.Gestion_encuesta__c != null){
                gEncuestaIds.add(survey.Gestion_encuesta__c);
            }
            if(survey.Concesionario__c != null){
                concesionarioIds.add(survey.Concesionario__c);
            }
            if(survey.Gestion_encuesta__r.Concesionario_encuesta__c != null){
                concesionarioIds.add(survey.Gestion_encuesta__r.Concesionario_encuesta__c);
            }
        }
        
        if(!accountIds.isEmpty()){
            mapClienteById = AccountGateway.getAccountById(accountIds);
            mapConsenEnuestaById = ConsentimientosGateway.getConsentimientosEncuestaByAccountId(accountIds);
        }
        if(!gEncuestaIds.isEmpty()){
            mapGEncuestaById = GestionEncuestaGateway.getGestionEncuestaById(gEncuestaIds);
        }
        if(!concesionarioIds.isEmpty()){
            mapConcesionarioById = ConcesionarioGateway.getConcessionaireById(concesionarioIds);
        }
        for (Respuesta_encuesta__c qa : [SELECT Encuesta__c, Encuesta__r.Tipo_de_Operacion__c, Titulo__c, Codigo_de_pregunta__c, Codigo_de_la_respuesta__c, Respuesta__c
                                         FROM Respuesta_encuesta__c
                                         WHERE Encuesta__c IN :encuestaIds]) {
                Map<String, Respuesta_encuesta__c> mapTitleToAnswer = mapSurveyToQA.containsKey(qa.Encuesta__c) ?mapSurveyToQA.get(qa.Encuesta__c):new Map<String, Respuesta_encuesta__c>() ;
                mapTitleToAnswer.put(qa.Titulo__c, qa);
                mapSurveyToQA.put(qa.Encuesta__c, mapTitleToAnswer);
        }
        for (AnswersColumnSurvey__mdt sca : [SELECT Label,Brand__c, OperationType__c, Columns__c, Email_envio__c FROM AnswersColumnSurvey__mdt
                                           WHERE Brand__c = :queryBrand]) {
            List<String> headers = sca.Columns__c.split(';');
            for(Integer i = 0; i<headers.size();i++){
                String head = headers[i];
                if(sca.OperationType__c.equalsIgnoreCase(Label.tipoOperacionTaller)){
                    csvResultAS.csvHeader += '\"' + head;
                    csvResultAS.subject = sca.Label;
                    csvResultAS.emailEnvio = sca.Email_envio__c;
                    if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                        csvResultAS.csvHeader += i+1<headers.size()? '\"\t':'\"';
                    } else {
                        csvResultAS.csvHeader += i+1<headers.size()? '\";':'\"';
                    }     
                }
                else{
                    csvResultSA.csvHeader += '\"' + head;
                    csvResultSA.subject = sca.Label;
                    csvResultSA.emailEnvio = sca.Email_envio__c;
                    if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                        csvResultSA.csvHeader += i+1<headers.size()? '\"\t':'\"';
                    } else {
                        csvResultSA.csvHeader += i+1<headers.size()? '\";':'\"';
                    }     
                }
            }                                 
             mapOppToColumnAnswers.put(sca.OperationType__c, headers);
        }
        for (HeaderColumnSurvey__mdt bca : [SELECT Label, Brand__c, OperationType__c, Columns__c, ColumnsFich__c, Email_envio__c, emailDesde__c FROM HeaderColumnSurvey__mdt
                                           WHERE Brand__c = :queryBrand]) {
                                               
                List<String> headers;
                List<String> headersCox;                               
                if(bca.ColumnsFich__c != null){
                 headersCox = bca.Columns__c.split(';');
                 headers = bca.ColumnsFich__c.split(';');
                 mapOppToColumnHeaders.put(bca.OperationType__c, headersCox);
                }
                else{
                    headers = bca.Columns__c.split(';'); 
                    mapOppToColumnHeaders.put(bca.OperationType__c, headers);
                }
                for(Integer i = 0; i<headers.size();i++){
                    String head = headers[i];
                    if(bca.OperationType__c.equalsIgnoreCase(Label.tipoOperacionTaller)){
                        csvHeaderAS.csvHeader += '\"' + head;
                        csvHeaderAS.subject = bca.Label;
                        csvHeaderAS.emailEnvio = bca.Email_envio__c;
                        csvHeaderAS.emailDesde = bca.emailDesde__c;
                        if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                            csvHeaderAS.csvHeader += i+1<headers.size()? '\"\t':'\"';
                        } else {
                            csvHeaderAS.csvHeader += i+1<headers.size()? '\";':'\"';
                        }     
                    }
                    else{
                        csvHeaderSA.csvHeader += '\"' + head;
                        csvHeaderSA.subject = bca.Label;
                        csvHeaderSA.emailEnvio = bca.Email_envio__c;
                        csvHeaderSA.emailDesde = bca.emailDesde__c;
                        if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                            csvHeaderSA.csvHeader += i+1<headers.size()? '\"\t':'\"';
                        } else {
                            csvHeaderSA.csvHeader += i+1<headers.size()? '\";':'\"';
                        }     
                    }
                }   
        }

            Integer nEncuesta = 1;
            Integer nEncuestaVenta = 1;
            Integer nEncuestaPTaller = 1;
        
            for (Encuesta__c survey : lstSurveys) {
                Account cuenta = mapClienteById.containsKey(survey.Cliente__c)?mapClienteById.get(survey.Cliente__c):null;
                Gestion_encuesta__c gEncuesta = mapGEncuestaById.containsKey(survey.Gestion_encuesta__c)? mapGEncuestaById.get(survey.Gestion_encuesta__c): null;
                Concesionario__c concesionario = mapConcesionarioById.containsKey(survey.Concesionario__c)?mapConcesionarioById.get(survey.Concesionario__c):null;
                Concesionario__c concesionarioGE = mapConcesionarioById.containsKey(survey.Gestion_encuesta__r.Concesionario_encuesta__c)?mapConcesionarioById.get(survey.Gestion_encuesta__r.Concesionario_encuesta__c):null;
                Map<String, Respuesta_encuesta__c> mapTitleToAnswer = mapSurveyToQA.containsKey(survey.Id)? mapSurveyToQA.get(survey.Id):new  Map<String, Respuesta_encuesta__c>();
                List<String> HeadAnswers = mapOppToColumnAnswers.containsKey(survey.Tipo_de_Operacion__c)? mapOppToColumnAnswers.get(survey.Tipo_de_Operacion__c): new List<String>();
                List<String> HeadHeaders = mapOppToColumnHeaders.containsKey(survey.Tipo_de_Operacion__c)? mapOppToColumnHeaders.get(survey.Tipo_de_Operacion__c): new List<String>();

                boolean AplicaEncuesta = true;   
                if (queryBrand.equalsIgnoreCase('HYUNDAI1')) {
                    Map<String,Consentimientos__c> mapConsenEnuesta = mapConsenEnuestaById.containsKey(survey.Cliente__c)?mapConsenEnuestaById.get(survey.Cliente__c): new Map<String,Consentimientos__c>();
                    Consentimientos__c consen = mapConsenEnuesta.containsKey(survey.Concesionario__c)?mapConsenEnuesta.get(survey.Concesionario__c):null;
                    if (consen != null && ((consen.CustomerSatisfactionSales__c == 'Deny' && survey.Tipo_de_Operacion__c.equalsIgnoreCase('Venta'))|| 
                       (consen.CustomerSatisfactionAfterSales__c == 'Deny' && survey.Tipo_de_Operacion__c.equalsIgnoreCase('Pase de taller')))) {
                        AplicaEncuesta = false;
                    }
                }    
                    
                if ((AplicaEncuesta && queryBrand.equalsIgnoreCase('HYUNDAI1') && 
                   (((cuenta != null) && !String.isBlank(cuenta.PersonEmail)) ||
                    ((cuenta == null) && !String.isBlank(survey.Email__c)))) ||
                     queryBrand.equalsIgnoreCase('AUDI') || 
                     queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                    if(survey.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)){
    
                        // Survey Column Anwers (Result)
                        for(Integer i = 0; i< HeadAnswers.size();i++){
                            String head = HeadAnswers[i];
                            Respuesta_encuesta__c ans =mapTitleToAnswer.containsKey(head)? mapTitleToAnswer.get(head): null;
                            csvResultAS.csvData += '\"';
                            if (ans != null) {
                                csvResultAS.csvData += ans.Codigo_de_la_respuesta__c;
                            }
                            else if(head.equalsIgnoreCase('InterviewID')){
                                csvResultAS.csvData += survey.InterviewID__c;
                            }
                            
                            if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                                csvResultAS.csvData += i+1<HeadAnswers.size()? '\"\t':'\"';
                            } else {
                                csvResultAS.csvData += i+1<HeadAnswers.size()? '\";':'\"';
                            }     
                        }
                        
                             // Survey Column Header (Case)
                        for(Integer i =0 ; i<HeadHeaders.size();i++){
                            String head = HeadHeaders[i];
                            String response = getHeadResponse(head,survey,gEncuesta,cuenta, mapTitleToAnswer, nEncuestaPTaller, concesionario, concesionarioGE);
                            csvHeaderAS.csvData += response;
                            if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                                csvHeaderAS.csvData += i+1<HeadHeaders.size()? '\"\t':'\"';
                            } else {
                                csvHeaderAS.csvData += i+1<HeadHeaders.size()? '\";':'\"';
                            }     
                        }
                        csvResultAS.csvData += '\n';   
                        csvHeaderAS.csvData +='\n';
                        nEncuestaPTaller++;
                    }
                    else {
                        // Survey Column Anwers (Result)
                        for(Integer i = 0; i<HeadAnswers.size();i++){
                            String head = HeadAnswers[i];
                            Respuesta_encuesta__c ans = mapTitleToAnswer.get(head);
                            csvResultSA.csvData += '\"';
                            if (ans != null) {
                                csvResultSA.csvData += ans.Codigo_de_la_respuesta__c;
                            }
                            else if(head.equalsIgnoreCase('InterviewID')){
                                csvResultSA.csvData += survey.InterviewID__c;
                            }
                            if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                                csvResultSA.csvData += i+1<HeadAnswers.size()? '\"\t':'\"';
                            } else {
                                csvResultSA.csvData += i+1<HeadAnswers.size()? '\";':'\"';
                            }     
                        }
                    
                        // Survey Column Header (Case)
                        for(Integer i = 0; i<HeadHeaders.size();i++){
                            String head = HeadHeaders[i];
                            String response = getHeadResponse(head,survey,gEncuesta,cuenta, mapTitleToAnswer, nEncuestaVenta, concesionario, concesionarioGE);
                            csvHeaderSA.csvData += response;
                            if (queryBrand.equalsIgnoreCase('AUDI') || queryBrand.equalsIgnoreCase('VOLKSWAGEN')) {
                                csvHeaderSA.csvData += i+1<HeadHeaders.size()? '\"\t':'\"';
                            } else {
                                csvHeaderSA.csvData += i+1<HeadHeaders.size()? '\";':'\"';
                            }     
                        }
                            
                        csvResultSA.csvData += '\n';
                        csvHeaderSA.csvData +='\n';
                        nEncuestaVenta++;
                    }

	            }  
            }  

	        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName();
        
        	String enviadoAFabrica = rtMapByDName.get('Envio_a_fabrica').getRecordTypeId(); 

            String brandTitle;
            switch on queryBrand {
                when 'AUDI'{brandTitle = '2';}
                when 'VOLKSWAGEN'{brandTitle = '1';}
                when else {brandTitle = '3';}
            }
            
            String dateTitle = String.valueOf(Datetime.now().year());
            Integer mes = Datetime.now().month();
            Integer dia = Datetime.now().day();
            Integer horas = Datetime.now().hour();
            Integer minutos = Datetime.now().minute();
            dateTitle += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
            dateTitle += dia<10?'0'+String.valueOf(dia)+'_':String.valueOf(dia)+'_';
            dateTitle += horas<10?'0'+String.valueOf(horas):String.valueOf(horas);
            dateTitle += minutos<10?'0'+String.valueOf(minutos)+'00':String.valueOf(minutos)+'00';
            
// Cabecera PostVenta		
            Blob csvHeaderASBlob = blob.valueOf(csvHeaderAS.csvHeader + '\n' +csvHeaderAS.csvData);
            if (csvHeaderAS.csvData != null && !String.isBlank(csvHeaderAS.csvData) && !String.isEmpty(csvHeaderAS.csvData)) {
                
                String title = 'CEM_'+ date.today().year() + '_IC_' + dateTitle + '_' + brandTitle + '_AS_C';

                Encuesta__c regEnvioFabrica = new Encuesta__c();
    
                regEnvioFabrica.Brand__c = queryBrand.equalsIgnoreCase('HYUNDAI1')? 'HYUNDAI': queryBrand;
                regEnvioFabrica.Tipo_de_Operacion__c = 'Pase de Taller';
                regEnvioFabrica.Enviado_a_fabrica__c = false;
                regEnvioFabrica.Fecha_envio_a_fabrica__c = date.today();
                regEnvioFabrica.RecordTypeId = enviadoAFabrica;
                
                insert regEnvioFabrica;
                
                ContentVersion cv = new ContentVersion();
                cv.Title = title;
                cv.PathOnClient = title + '.'+'csv';
                cv.ContentLocation ='S';
                cv.VersionData = csvHeaderASBlob;
                insert cv;
                
                ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
                
                ContentDocumentLink cdlink = new ContentDocumentLink();
                cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
                cdLink.LinkedEntityId = regEnvioFabrica.id;
                cdLink.Visibility = 'AllUsers';
                insert cdLink;
            }
            
// Respuestas PostVenta		
            Blob csvResultASBlob = blob.valueOf(csvResultAS.csvHeader + '\n'+csvResultAS.csvData);
            SYSTEM.debug('csvResultAS.csvData: '+csvResultAS.csvData);
            if (csvResultAS.csvData != null && !String.isBlank(csvResultAS.csvData) && !String.isEmpty(csvResultAS.csvData)) {

                String title = 'CEM_'+ date.today().year() + '_IC_' + dateTitle + '_' + brandTitle + '_AS_R';
                
                Encuesta__c regEnvioFabrica = new Encuesta__c();
    
                regEnvioFabrica.Brand__c = queryBrand.equalsIgnoreCase('HYUNDAI1')? 'HYUNDAI': queryBrand;
                regEnvioFabrica.Tipo_de_Operacion__c = 'Pase de Taller';
                regEnvioFabrica.Enviado_a_fabrica__c = false;
                regEnvioFabrica.Fecha_envio_a_fabrica__c = date.today();
                regEnvioFabrica.RecordTypeId = enviadoAFabrica;
                
                insert regEnvioFabrica;
                
                ContentVersion cv = new ContentVersion();
                cv.Title = title;
                cv.PathOnClient = title + '.'+'csv';
                cv.ContentLocation ='S';
                cv.VersionData = csvResultASBlob;
                insert cv;
                
                ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
                
                ContentDocumentLink cdlink = new ContentDocumentLink();
                cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
                cdLink.LinkedEntityId = regEnvioFabrica.id;
                cdLink.Visibility = 'AllUsers';
                insert cdLink;
            }
            
// Cabecera Venta		
            Blob csvHeaderSABlob = blob.valueOf(csvHeaderSA.csvHeader + '\n' +csvHeaderSA.csvData);
            if (csvHeaderSA.csvData != null && !String.isBlank(csvHeaderSA.csvData) && !String.isEmpty(csvHeaderSA.csvData)) {

                String title = 'CEM_'+ date.today().year() + '_IC_' + dateTitle + '_' + brandTitle + '_SA_C';
                
                Encuesta__c regEnvioFabrica = new Encuesta__c();
    
                regEnvioFabrica.Brand__c = queryBrand.equalsIgnoreCase('HYUNDAI1')? 'HYUNDAI': queryBrand;
                regEnvioFabrica.Tipo_de_Operacion__c = 'Venta';
                regEnvioFabrica.Enviado_a_fabrica__c = false;
                regEnvioFabrica.Fecha_envio_a_fabrica__c = date.today();
                regEnvioFabrica.RecordTypeId = enviadoAFabrica;
                
                insert regEnvioFabrica;
                
                ContentVersion cv = new ContentVersion();
                cv.Title = title;
                cv.PathOnClient = title + '.'+'csv';
                cv.ContentLocation ='S';
                cv.VersionData = csvHeaderSABlob;
                insert cv;
                
                ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
                
                ContentDocumentLink cdlink = new ContentDocumentLink();
                cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
                cdLink.LinkedEntityId = regEnvioFabrica.id;
                cdLink.Visibility = 'AllUsers';
                insert cdLink;
            }
            
// Respuestas Venta		
            Blob csvResultSABlob = blob.valueOf(csvResultSA.csvHeader + '\n' +csvResultSA.csvData);
            if (csvResultSA.csvData != null && !String.isBlank(csvResultSA.csvData) && !String.isEmpty(csvResultSA.csvData)) {

                String title = 'CEM_'+ date.today().year() + '_IC_' + dateTitle + '_' + brandTitle + '_SA_R';
                
                Encuesta__c regEnvioFabrica = new Encuesta__c();
    
                regEnvioFabrica.Brand__c = queryBrand.equalsIgnoreCase('HYUNDAI1')? 'HYUNDAI': queryBrand;
                regEnvioFabrica.Tipo_de_Operacion__c = 'Venta';
                regEnvioFabrica.Enviado_a_fabrica__c = false;
                regEnvioFabrica.Fecha_envio_a_fabrica__c = date.today();
                regEnvioFabrica.RecordTypeId = enviadoAFabrica;
                
                insert regEnvioFabrica;
                
                ContentVersion cv = new ContentVersion();
                cv.Title = title;
                cv.PathOnClient = title + '.'+'csv';
                cv.ContentLocation ='S';
                cv.VersionData = csvResultSABlob;
                insert cv;
                
                ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
                
                ContentDocumentLink cdlink = new ContentDocumentLink();
                cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
                cdLink.LinkedEntityId = regEnvioFabrica.id;
                cdLink.Visibility = 'AllUsers';
                insert cdLink;
            }
            
         }
       
    }   
    
    public static String  getHeadResponse(String head, Encuesta__c encuesta, Gestion_encuesta__c gEncuesta, Account cuenta,Map<String,Respuesta_encuesta__c> mapTitleToAnswer, Integer nEncuesta, Concesionario__c concesionario, Concesionario__c concesionarioGE ){
        String response='\"';
        switch on head {
            when 'Qversion' {
                // year año de fecha documento 
                // divison lo mismo que study
                response += gEncuesta.Project__c+'_'+ gEncuesta.Country__c + gEncuesta.BrandCode__c+
                    String.valueOf(encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)?'2':'1') + 
                    String.valueOf(encuesta.Fecha_documento__c.year()) +gEncuesta.Serial_number__c;
            }
            when 'Num'{ 
                response += nEncuesta;
            }

            when 'InterviewID' {
                response += encuesta.InterviewID__c;
            }
            when 'Country' {
                response += gEncuesta.Country__c;
            }
            when 'Brand' {
                response += gEncuesta.BrandCode__c;
            }
            when 'Study' {
                response += encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)?'2':'1';
            }    
            when 'SurveyTech' {
                response += gEncuesta.SurveyTech__c;
            }
            when 'Language' {
                response += gEncuesta.Language__c;
            }
            when 'IntType' {
                response += gEncuesta.IntType__c;
            }
            when 'AddressDate' {
                if(encuesta.Fecha_respuesta_encuesta__c>= encuesta.Fecha_segundo_envio_real__c){
                    String respuesta=String.valueOf(encuesta.Fecha_segundo_envio_real__c.year());
                    Integer mes = encuesta.Fecha_segundo_envio_real__c.month();
                    Integer dia = encuesta.Fecha_segundo_envio_real__c.day();
                    respuesta += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
                    respuesta += dia<10?'0'+String.valueOf(dia):String.valueOf(dia);
                    response += respuesta;
                }
                else{
                    String respuesta=String.valueOf( encuesta.Fecha_primer_envio_requerido__c.year());
                    Integer mes = encuesta.Fecha_primer_envio_requerido__c.month();
                    Integer dia = encuesta.Fecha_primer_envio_requerido__c.day();
                    respuesta += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
                    respuesta += dia<10?'0'+String.valueOf(dia):String.valueOf(dia);
                    response += respuesta;
                }
            }
            when 'EventDate' {
                String respuesta=String.valueOf( encuesta.Fecha_documento__c.year());
                Integer mes = encuesta.Fecha_documento__c.month();
                Integer dia = encuesta.Fecha_documento__c.day();
                respuesta += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
                respuesta += dia<10?'0'+String.valueOf(dia):String.valueOf(dia);
                response += respuesta;
            }
            when 'EventDateHY' {
                response += encuesta.Fecha_documento__c;
            }
            when 'Reg.Date' {
                response += encuesta.Fecha_respuesta_encuesta__c;
            }
	        when 'InterviewDate' {
                String respuesta=String.valueOf(encuesta.Fecha_respuesta_encuesta__c.year());
                Integer mes = encuesta.Fecha_respuesta_encuesta__c.month();
                Integer dia = encuesta.Fecha_respuesta_encuesta__c.day();
                respuesta += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
                respuesta += dia<10?'0'+String.valueOf(dia):String.valueOf(dia);
                response += respuesta;
            }
            when 'JobType' {
                    /* Solo esta en postventa: 
                       0= Job Type not in adress 
                       1= Guarantee 
                       3= Mobility 
                       4= Normal/Neither guarantee nor goodwill
                   completar correctamente cuando tengamos postventa
                */ 
                response += '0';
            }
            when 'Code' {
                response += gEncuesta.Code__c;
            }
/*            when 'DealerId' {
                response += gEncuesta.Code__c; 
            }
*/
            when 'VIN' {
                if(encuesta.Anonymous__c == '1'){
                    response += encuesta.vin__c;
                }
                else if(encuesta.Anonymous__c == '2'||encuesta.Anonymous__c == '0'){
                    response += encuesta.vin__c.left(encuesta.vin__c.length()-5) +'XXXXX';
                }
            }
            when 'Model' {
                response += encuesta.ModeloString__c;
            }
            when 'OriginalCarModel' {
                response += encuesta.ModeloString__c;
            }
            when 'OriginalCarModelChange' {
                response += '0';
            }
            when 'CarModel' {
                response += encuesta.ModeloString__c;
            }
            When 'OutletCode' {
                response += gEncuesta.Code__c != null? gEncuesta.SurveyTech__c+gEncuesta.Code__c:'';
            }
            when 'TypeDesCode' {
                response += gEncuesta.TypeDesCode__c != null? gEncuesta.TypeDesCode__c:'';
            }
            when 'CustomerName' {
                response+= cuenta != null? cuenta.Name:encuesta.Nombre_Cliente__c;
            }    
            when 'OriginalNameTP' {
                if(encuesta.Anonymous__c == '1'){
                    response+= cuenta != null? cuenta.Name:encuesta.Nombre_Cliente__c;
                } else {
                    response+= '';
                }
                    
            }
            when 'ChangeTP' {
                if(encuesta.Anonymous__c == '1'){
                    response +=mapTitleTOAnswer.containsKey('e1c')?'1':'0';
                } else {
                    response+= '';
                }
            }
            when 'NameTP' {
                if(encuesta.Anonymous__c == '1'){
                    if(mapTitleTOAnswer.containsKey('e1c')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('e1c');
                        response += rEncuesta.Respuesta__c;
                    }
                    else {
                        response += cuenta != null? cuenta.Name:encuesta.Nombre_Cliente__c;
                    }
                }
            }
            when 'CustomerTelno' {
                if (cuenta != null) {
                	response += !String.isBlank(cuenta.PersonMobilePhone)? cuenta.PersonMobilePhone: '';
                } else {
                	response += !String.isBlank(encuesta.MobilePhone__c)? encuesta.MobilePhone__c: '';
                }    
            }
            when 'OriginalTel' {
                if(encuesta.Anonymous__c =='1'){
                    response += cuenta != null? cuenta.PersonMobilePhone:encuesta.MobilePhone__c;
                } else {
                    response+= '';
                }
            }
            when 'OriginalTelChange' {
                if(encuesta.Anonymous__c == '1'){
                    response += '0';
                } else {
                    response+= '';
                }
            }
            when 'Telephone' {
                 if(encuesta.Anonymous__c =='1'){
                    response += cuenta != null? cuenta.PersonMobilePhone:encuesta.MobilePhone__c;
                } else {
                    response+= '';
                }
            }
            when 'Street' {
                //vacio
            }
/*            when 'CustomerAddress' {
                response += cuenta != null? cuenta.BillingStreet + ' ' +
                                            cuenta.BillingPostalCode + ' ' +
                                            cuenta.BillingCity + ' ' +
                                            cuenta.BillingState + ' ' +
                                            cuenta.BillingCountry: '';
            }
*/
            when 'City' {
                //vacio
            }
            
            when 'Email' {
                if(encuesta.Anonymous__c =='1'){
                    response += cuenta != null ? cuenta.PersonEmail : encuesta.Email__c;
                } else {
                    response+= '';
                }
            }
            when 'CustomerEmail' {
                if (cuenta != null) {
                	response += !String.isBlank(cuenta.PersonEmail)? cuenta.PersonEmail: '';
                } else {
                	response += !String.isBlank(encuesta.Email__c)? encuesta.Email__c: '';
                }    
            }

            when 'NonAnonymous' {
                response += encuesta.Anonymous__c;
            }
            when 'UsedCarBrand' {
            //No se usa 
            }
            when 'UsedCarType' {
            //No se usa
            }
            when 'CustomerID' {
                if((cuenta!=null)&&(encuesta.Anonymous__c =='1')){
                    response += cuenta.Id;
                } else {
                    response+= '';
                }
            }
            when 'DriveTechnologyExtended' {
                response += encuesta.DriveTechnologyExtended__c;
            }
            when 'PublicationOnInternet' {
                if(mapTitleTOAnswer.containsKey('PublicationOnInternet')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('PublicationOnInternet');
                        response += rEncuesta.Codigo_de_la_respuesta__c;
                }
            }
            when 'Concesionario1' {
               response+= concesionarioGE != null? concesionarioGE.Name:'';
            }
            when 'ConcesionarioEncuesta' {
               response+= concesionario != null? concesionario.Name:'';
            }
            when 'Sales Person Name' {
               response+= !String.isBlank(encuesta.ServiceAdvisor__c)? encuesta.ServiceAdvisor__c:''; 
            }
            when 'Service Person Name' {
               response+= !String.isBlank(encuesta.ServiceAdvisor__c)? encuesta.ServiceAdvisor__c:''; 
            }
            when else {
                System.debug('S/N');
            }
        }   
        
        return response;
                         
    }
    
    public class SurveyAux{
        public String csvHeader {get;set;}
        public String csvData {get;set;}
        public String subject {get;set;}
        public String emailEnvio {get;set;}
        public String emailDesde {get;set;}
        public void SurveyAux(){
            this.csvHeader ='';
            this.csvData ='';
            this.subject ='';
            this.emailEnvio ='';
            this.emailDesde ='';
        }
    }
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SendSurveyCEMBatch(this.queryBrand,this.queryTime));
    }

}