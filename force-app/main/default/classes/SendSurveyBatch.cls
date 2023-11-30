global class SendSurveyBatch implements Database.Batchable<sObject>, Schedulable {
    private String queryBrand;
    private String queryBrand1;
    private String queryTime;
    
    global SendSurveyBatch(String brand, String tiempo) {
        queryBrand = brand.toUpperCase();
        queryTime = tiempo.toUpperCase();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('queryBrand: '+queryBrand);
        System.debug('queryTime: '+queryTime);
        
        queryBrand1 = queryBrand;
        if (queryBrand.equalsIgnoreCase('AUDI1')) {
            queryBrand1 = 'AUDI';    
        }
        if (queryBrand.equalsIgnoreCase('VOLKSWAGEN1')) {
            queryBrand1 = 'VOLKSWAGEN';    
        }
        if (queryBrand.equalsIgnoreCase('AUDI2')) {
            queryBrand1 = 'AUDI';    
        }
        if (queryBrand.equalsIgnoreCase('VOLKSWAGEN2')) {
            queryBrand1 = 'VOLKSWAGEN';    
        }
        System.debug('queryBrand1: '+queryBrand1);

        Datetime fecDesde;
        Datetime fecHasta;

        if(queryTime.equalsIgnoreCase('CUSTOM')){
            fecDesde = datetime.parse(label.startSurveyCustom);
            fecHasta = datetime.parse(label.endSurveyCustom);
        }
        if(queryTime.equalsIgnoreCase('LAST MONTH HY')){
           queryTime = 'CUSTOM';
           fecDesde = datetime.now().addMonths(-1);
           fecHasta = datetime.now(); 
           system.debug('fecDesde: '+fecDesde); 
           system.debug('fecHasta: '+fecHasta); 
        }

        List<boolean> EnvioFabrica = new List<boolean>();
        if (queryBrand.equalsIgnoreCase('AUDI2') || queryBrand.equalsIgnoreCase('VOLKSWAGEN2')) {
            EnvioFabrica.add(false);
        } else {
            EnvioFabrica.add(true);
            EnvioFabrica.add(false);
    	}
        
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName();
        List<String> RTList = new List<String>();
        if (queryBrand.equalsIgnoreCase('HYUNDAI')) {
	        RTList.add(rtMapByDName.get('Telefonica').getRecordTypeId());
        } else {
	        RTList.add(rtMapByDName.get('CEM').getRecordTypeId());
	        RTList.add(rtMapByDName.get('CEM_Manuales').getRecordTypeId());
        }   
        
        if(queryTime.equalsIgnoreCase('LAST WEEK')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = LAST_N_WEEKS:1 AND Fecha_respuesta_encuesta__c < LAST_N_WEEKS:0
                                            AND  Anonymous__c != null
                                            AND EnvioFabrica__c IN :EnvioFabrica  
                                            AND Brand__c = :queryBrand1
                                            AND RecordTypeId IN :RTList]);
        }
        else {
        if(queryTime.equalsIgnoreCase('CUSTOM')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c >= :fecDesde AND Fecha_respuesta_encuesta__c < :fecHasta
                                            AND  Anonymous__c != null
                                            AND EnvioFabrica__c IN :EnvioFabrica  
                                            AND Brand__c = :queryBrand1
                                            AND RecordTypeId IN :RTList]);
        }
        else {
        if(queryTime.equalsIgnoreCase('LAST MONTH')){
            return  Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = LAST_N_MONTHS:1 AND Fecha_respuesta_encuesta__c < LAST_N_MONTHS:0
                                            AND  Anonymous__c != null
                                            AND EnvioFabrica__c IN :EnvioFabrica  
                                            AND Brand__c = :queryBrand1
                                            AND RecordTypeId IN :RTList]);
        }
        else {
            return Database.getQueryLocator([SELECT Id, Anonymous__c, Brand__c, Canal_de_envio_2__c, Cliente__c, Codigo_de_operacion__c, Concesionario__c, Detalle_venta__c, Email__c, Fecha_documento__c, Fecha_fin_respuesta__c, Fecha_primer_envio_real__c, Fecha_primer_envio_requerido__c,
                                         Fecha_requerida_segundo_envio__c, Fecha_respuesta_encuesta__c, Fecha_segundo_envio_real__c, Gestion_encuesta__c, MobilePhone__c, ModeloString__c, Name, Nombre_Cliente__c, Apellido_Cliente__c, Respondido__c, RecordTypeId, Resultado__c, Tipo_de_Operacion__c,
                                         Tipo_de_respuesta__c, Tipo_Encuesta__c, URL__c, vin__c, Combustible__c, InterviewID__c, DriveTechnologyExtended__c, ServiceAdvisor__c, Gestion_encuesta__r.Concesionario_encuesta__c
                                         FROM Encuesta__c
                                         WHERE Fecha_respuesta_encuesta__c = YESTERDAY
                                            AND  Anonymous__c != null
                                            AND EnvioFabrica__c IN :EnvioFabrica  
                                            AND Brand__c = :queryBrand1
                                            AND RecordTypeId IN :RTList]);
        }
        }
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Encuesta__c> lstSurveys) {
        Map<String, Map<String, Respuesta_encuesta__c>> mapSurveyToQA = new Map<String, Map<String, Respuesta_encuesta__c>>();
        Map<String, List<String>> mapOppToColumnAnswers = new Map<String, List<String>>();
        Map<String, List<String>> mapOppToColumnHeaders = new Map<String, List<String>>();
        Map<String,Account> mapClienteById = new Map<String,Account>();
        Map<String,Gestion_encuesta__c> mapGEncuestaById = new Map<String,Gestion_encuesta__c>();
        Map<String,Concesionario__c> mapConcesionarioById = new Map<String,Concesionario__c>();
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
        
            Blob csvResultASBlob = blob.valueOf(csvResultAS.csvHeader + '\n'+csvResultAS.csvData);
            Blob csvHeaderASBlob = blob.valueOf(csvHeaderAS.csvHeader + '\n' +csvHeaderAS.csvData);
            Blob csvResultSABlob = blob.valueOf(csvResultSA.csvHeader + '\n' +csvResultSA.csvData);
            Blob csvHeaderSABlob = blob.valueOf(csvHeaderSA.csvHeader + '\n' +csvHeaderSA.csvData);
            
            Messaging.EmailFileAttachment csvAttachmentResultAS = new Messaging.EmailFileAttachment();   
            Messaging.EmailFileAttachment csvAttachmentHeaderAS = new Messaging.EmailFileAttachment();                
            Messaging.EmailFileAttachment csvAttachmentResultSA = new Messaging.EmailFileAttachment();                
            Messaging.EmailFileAttachment csvAttachmentHeaderSA = new Messaging.EmailFileAttachment();                
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toAddress = csvHeaderAS.emailEnvio.split(';');
            email.setToAddresses(toAddress);
            email.setOrgWideEmailAddressId(csvHeaderAS.emailDesde);
            if(queryBrand.equalsIgnoreCase('AUDI1')||queryBrand.equalsIgnoreCase('VOLKSWAGEN1')){
                if(queryBrand.equalsIgnoreCase('AUDI1')) {
                   String subject = 'Encuestas por Asesor AUDI ' + Datetime.now();
                   email.setSubject(subject);
                } else {
                   String subject = 'Encuestas por Asesor VOLKSWAGEN ' + Datetime.now();
                   email.setSubject(subject);
                }
                email.setPlainTextBody('Adjuntamos archivos de informe encuesta');
            } else if(queryBrand.equalsIgnoreCase('AUDI2')||queryBrand.equalsIgnoreCase('VOLKSWAGEN2')){
                if(queryBrand.equalsIgnoreCase('AUDI2')) {
                   String subject = 'Encuestas mala calidad AUDI ' + Datetime.now();
                   email.setSubject(subject);
                } else {
                   String subject = 'Encuestas mala calidad VOLKSWAGEN ' + Datetime.now();
                   email.setSubject(subject);
                }
                email.setPlainTextBody('Adjuntamos archivos de informe encuesta');
            } else {
                String subject = 'Survey ' + queryBrand +  ' ' + Datetime.now();
                email.setSubject(subject);
                email.setPlainTextBody('Adjuntamos archivos de encuesta');
            }       
            
            if(queryBrand.equalsIgnoreCase('SKODA')||queryBrand.equalsIgnoreCase('HYUNDAI')||
               queryBrand.equalsIgnoreCase('CITROËN')||queryBrand.equalsIgnoreCase('AUDI1')||
               queryBrand.equalsIgnoreCase('VOLKSWAGEN1') ||queryBrand.equalsIgnoreCase('AUDI2')||
               queryBrand.equalsIgnoreCase('VOLKSWAGEN2')){
                csvAttachmentHeaderAS.setFileName(csvHeaderAS.subject+' '+ Datetime.now()+'.csv');
                csvAttachmentHeaderAS.setBody(csvHeaderASBlob);
                csvAttachmentHeaderAS.setContentType('text/csv');
                
                csvAttachmentHeaderSA.setFileName(csvHeaderSA.subject+' '+Datetime.now()+'.csv');
                csvAttachmentHeaderSA.setBody(csvHeaderSABlob);
                csvAttachmentHeaderSA.setContentType('text/csv');
            
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachmentHeaderAS, csvAttachmentHeaderSA});
            
            }
            else{
                csvAttachmentResultAS.setFileName(csvResultAS.subject+' '+Datetime.now()+'.csv');
                csvAttachmentResultAS.setBody(csvResultASBlob);
                csvAttachmentResultAS.setContentType('text/csv');
        
                csvAttachmentHeaderAS.setFileName(csvHeaderAS.subject+' '+Datetime.now()+'.csv');
                csvAttachmentHeaderAS.setBody(csvHeaderASBlob);
                csvAttachmentHeaderAS.setContentType('text/csv');
            
                csvAttachmentResultSA.setFileName(csvResultSA.subject+' '+Datetime.now()+'.csv');
                csvAttachmentResultSA.setBody(csvResultSABlob);
                csvAttachmentResultSA.setContentType('text/csv');
            
                csvAttachmentHeaderSA.setFileName(csvHeaderSA.subject+' '+Datetime.now()+'.csv');
                csvAttachmentHeaderSA.setBody(csvHeaderSABlob);
                csvAttachmentHeaderSA.setContentType('text/csv');
                
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachmentResultAS, csvAttachmentHeaderAS, csvAttachmentResultSA, csvAttachmentHeaderSA});
            }
            
            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    
            //System.debug('CSV FILE AS Header:\n' + csvHeaderAS);
            //System.debug('CSV FILE SA Header:\n' + csvHeaderSA);
            //System.debug('CSV FILE AS Result:\n' + csvResultAS);
            //System.debug('CSV FILE SA Result:\n' + csvResultSA);
            System.debug('emailSent: ' + emailSent);
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
            when 'NO'{ 
                response += nEncuesta;
            }
            when 'InterviewID' {
                response += encuesta.InterviewID__c;
            }
            when 'Country' {
                response += gEncuesta.Country__c;
            }
            when 'DealerCountryCode'{
                response += gEncuesta.Country__c;
            }
            when 'CustomerCountry'{
                response += gEncuesta.Country__c;
            }
            when 'Brand' {
                response += gEncuesta.BrandCode__c;
            }
            when 'Study' {
                response += encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)?'2':'1';
            }    
            when 'StudyC' {
                response += encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)?'Service':'Sales';
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
            when 'EventDateDay' {
                response += String.valueOf(encuesta.Fecha_documento__c.day());
            }
            when 'EventDateMonth' {
                response += String.valueOf(encuesta.Fecha_documento__c.month());
            }
            when 'EventDateYear' {
                response += String.valueOf(encuesta.Fecha_documento__c.year());
            }
            when 'InterviewDate' {
                String respuesta=String.valueOf(encuesta.Fecha_respuesta_encuesta__c.year());
                Integer mes = encuesta.Fecha_respuesta_encuesta__c.month();
                Integer dia = encuesta.Fecha_respuesta_encuesta__c.day();
                respuesta += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
                respuesta += dia<10?'0'+String.valueOf(dia):String.valueOf(dia);
                response += respuesta;
            }
/*            when 'LastServiceDate' {
                Date mesMenosUno = date.today().addMonths(-1);
                If (encuesta.Fecha_documento__c.month() != mesMenosUno.month()){
                    encuesta.Fecha_documento__c = mesMenosUno.toStartOfMonth();
                    system.debug('modificamoa a inicio mes encuesta.Fecha_documento__c: '+encuesta.Fecha_documento__c);
                }
                String respuesta=String.valueOf( encuesta.Fecha_documento__c.day());
                Map<Integer,String> monthNameMap=new Map<Integer,String>{1=>' Enero, ',
                                                                         2=>' Febrero, ',
                                                                         3=>' Marzo, ',
                                                                         4=>' Abril, ',
                                                                         5=>' Mayo, ',
                                                                         6=>' Junio, ',
                                                                         7=>' Julio, ',
                                                                         8=>' Agosto, ',
                                                                         9=>' Septiembre, ',
                                                                         10=>' Octubre, ',
                                                                         11=>' Noviembre, ',
                                                                         12=>' Diciembre, '};
                respuesta += monthNameMap.get(encuesta.Fecha_documento__c.month());
                respuesta += String.valueOf( encuesta.Fecha_documento__c.year());
                response += respuesta;
            } */
            when 'LastServiceDateY' {
                Date mesMenosUno = date.today().addMonths(-1);
                If (encuesta.Fecha_documento__c.month() != mesMenosUno.month()){
                    encuesta.Fecha_documento__c = mesMenosUno.toStartOfMonth();
                    system.debug('modificamoa a inicio mes encuesta.Fecha_documento__c: '+encuesta.Fecha_documento__c);
                }
                response += String.valueOf( encuesta.Fecha_documento__c.year());
            }
            when 'LastServiceDateM' {
                Integer mes = encuesta.Fecha_documento__c.month();
                response += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
            }    
            when 'LastServiceDateD' {
                Integer dia = encuesta.Fecha_documento__c.day();
                response += dia<10?'0'+String.valueOf(dia):String.valueOf(dia);
            }    
            when 'FechaOperacion' {
                response += String.valueOf( encuesta.Fecha_documento__c.date());
            }
            when 'FechaRespuesta' {
                response += String.valueOf( encuesta.Fecha_respuesta_encuesta__c.date());
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
            when 'DealerId' {
                response += gEncuesta.Code__c; 
            }
            when 'VIN' {
                if(encuesta.Anonymous__c == '1'){
                    response += encuesta.vin__c;
                }
                else if(encuesta.Anonymous__c == '2'||encuesta.Anonymous__c == '0'){
                    response += encuesta.vin__c.left(encuesta.vin__c.length()-5) +'XXXXX';
                }
            }
            when 'CarVIN' {
                response += encuesta.vin__c;
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
            when 'TypeDesCode' {
                response += gEncuesta.TypeDesCode__c != null? gEncuesta.TypeDesCode__c:'';
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
            when 'CustomerSalutation'{
                response += cuenta != null && !String.isBlank(cuenta.Salutation)? cuenta.Salutation:'';
            }
            when 'CustomerName'{
                if (cuenta != null){                
                    response += !String.isBlank(cuenta.FirstName)? cuenta.FirstName:'';
                } else {
                    response += !String.isBlank(encuesta.Nombre_Cliente__c)? encuesta.Nombre_Cliente__c:'';
                }
            }     
			when 'CustomerSurname' {
                if (cuenta != null){                
                    response += !String.isBlank(cuenta.LastName)? cuenta.LastName:'';
                } else {
                    response += !String.isBlank(encuesta.Apellido_Cliente__c)? encuesta.Apellido_Cliente__c:'';
                }
            }
            when 'OriginalTel' {
                if(encuesta.Anonymous__c =='1'){
                    response += cuenta != null? cuenta.PersonMobilePhone:encuesta.MobilePhone__c;
                } else {
                    response+= '';
                }
            }
            when 'TelefonoFijo' {
                if(encuesta.Anonymous__c =='1'){
                    response += cuenta != null? cuenta.Phone:'';
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
            when 'CustomerPhone' {
                if (cuenta != null) {
                    if (!String.isBlank(cuenta.PersonMobilePhone)) {
	                	response += cuenta.PersonMobilePhone.remove('+');
                    } else if (!String.isBlank(cuenta.Phone)) {
	                	response += cuenta.Phone.remove('+');
                    } else {
                        response+= '';
                    }
                } else {
                	response += !String.isBlank(encuesta.MobilePhone__c)? encuesta.MobilePhone__c.remove('+'): '';
                }    
            }
            when 'Street' {
                //vacio
            }
            when 'CustomerAddress' {
                response += cuenta != null? cuenta.BillingStreet + ' ' +
                                            cuenta.BillingPostalCode + ' ' +
                                            cuenta.BillingCity + ' ' +
                                            cuenta.BillingState + ' ' +
                                            cuenta.BillingCountry: '';
            }
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
            when 'ServiceAdvisor' {
                response += !String.isBlank(encuesta.ServiceAdvisor__c)? encuesta.ServiceAdvisor__c:'';
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
            
            when 'Concesionario' {
               response+= concesionario != null? concesionario.Name:'';
            }
            when 'NPS' {
                if(mapTitleTOAnswer.containsKey('NPS')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('NPS');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Facility' {
                if(mapTitleTOAnswer.containsKey('Facility')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Facility');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Weak_area' {
                if(mapTitleTOAnswer.containsKey('Weak_area')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Weak_area');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Test_drive_Y' {
                if(mapTitleTOAnswer.containsKey('Test_drive_Y')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Test_drive_Y');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Weak_area_1' {
                if(mapTitleTOAnswer.containsKey('Weak_area_1')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Weak_area_1');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Test_drive_N' {
                if(mapTitleTOAnswer.containsKey('Test_drive_N')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Test_drive_N');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Others' {
                if(mapTitleTOAnswer.containsKey('Others')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Others');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Sales_consultant' {
                if(mapTitleTOAnswer.containsKey('Sales_consultant')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Sales_consultant');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Weak_area_2' {
                if(mapTitleTOAnswer.containsKey('Weak_area_2')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Weak_area_2');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Contract' {
                if(mapTitleTOAnswer.containsKey('Contract')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Contract');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Weak_area_3' {
                if(mapTitleTOAnswer.containsKey('Weak_area_3')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Weak_area_3');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Hand_Over' {
                if(mapTitleTOAnswer.containsKey('Hand_Over')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Hand_Over');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Weak_area_4' {
                if(mapTitleTOAnswer.containsKey('Weak_area_3')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Weak_area_3');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Booking' {
                if(mapTitleTOAnswer.containsKey('Booking')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Booking');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Timeliness' {
                if(mapTitleTOAnswer.containsKey('Timeliness')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Timeliness');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Communication' {
                if(mapTitleTOAnswer.containsKey('Communication')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Communication');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Quality' {
                if(mapTitleTOAnswer.containsKey('Quality')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Quality');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Value' {
                if(mapTitleTOAnswer.containsKey('Value')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Value');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Visit_1' {
                if(mapTitleTOAnswer.containsKey('Visit_1')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Visit_1');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Visit_2' {
                if(mapTitleTOAnswer.containsKey('Visit_2')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Visit_2');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Reason' {
                if(mapTitleTOAnswer.containsKey('Reason')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('Reason');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P01' {
                if(mapTitleTOAnswer.containsKey('P01')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P01');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P02' {
                if(mapTitleTOAnswer.containsKey('P02')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P02');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P021' {
                if(mapTitleTOAnswer.containsKey('P021')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P021');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P03' {
                if(mapTitleTOAnswer.containsKey('P03')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P03');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P031' {
                if(mapTitleTOAnswer.containsKey('P031')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P031');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P04' {
                if(mapTitleTOAnswer.containsKey('P04')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P04');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P05' {
                if(mapTitleTOAnswer.containsKey('P05')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P05');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P06' {
                if(mapTitleTOAnswer.containsKey('P06')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P06');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P07' {
                if(mapTitleTOAnswer.containsKey('P07')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P07');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'P08' {
                if(mapTitleTOAnswer.containsKey('P08')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('P08');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'Marca' {
                response += encuesta.Brand__c;
            }
            when 'Concesionario1' {
               response+= concesionarioGE != null? concesionarioGE.Name:'';
            }
            when 'ConcesionarioEncuesta' {
               response+= concesionario != null? concesionario.Name:'';
            }
            when 'AsesorServicios' {
                response += !String.isBlank(encuesta.ServiceAdvisor__c)? encuesta.ServiceAdvisor__c:'';
            }
            when 'Bastidor' {
                response += encuesta.Tipo_Encuesta__c.equalsIgnoreCase('SIMA')?encuesta.vin__c:'';
            }
            when 'BastidorExterno' {
                response += encuesta.Tipo_Encuesta__c.equalsIgnoreCase('Externo')?encuesta.vin__c:'';
            }
            when 'Modelo' {
                response += encuesta.ModeloString__c;
            }
            when 'FechaCreacion' {
                if(encuesta.Fecha_respuesta_encuesta__c>= encuesta.Fecha_segundo_envio_real__c){
                    response += String.valueOf(encuesta.Fecha_segundo_envio_real__c);
                }
                else{
                    response += String.valueOf(encuesta.Fecha_primer_envio_requerido__c);
                }
            }
            when 'FechaDocumento' {
                response += String.valueOf(encuesta.Fecha_documento__c);
            }
            when 'FechaRespuesta1' {
                response += String.valueOf(encuesta.Fecha_respuesta_encuesta__c);
            }
            when 'Encuesta' {
                response += encuesta.Id;
            }
            when 'q001' {
                if(mapTitleTOAnswer.containsKey('q001')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q001');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q001a' {
                if(mapTitleTOAnswer.containsKey('q001a')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q001a');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q001a_na' {
                if(mapTitleTOAnswer.containsKey('q001a_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q001a_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q001a_coded' {
                if(mapTitleTOAnswer.containsKey('q001a_coded')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q001a_coded');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q002' {
                if(mapTitleTOAnswer.containsKey('q002')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q002');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q002a' {
                if(mapTitleTOAnswer.containsKey('q002a')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q002a');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q002a_na' {
                if(mapTitleTOAnswer.containsKey('q002a_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q002a_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q002a_coded' {
                if(mapTitleTOAnswer.containsKey('q002a_coded')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q002a_coded');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q003' {
                if(mapTitleTOAnswer.containsKey('q003')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q003');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q003a' {
                if(mapTitleTOAnswer.containsKey('q003a')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q003a');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q003a_na' {
                if(mapTitleTOAnswer.containsKey('q003a_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q003a_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q003a_coded' {
                if(mapTitleTOAnswer.containsKey('q003a_coded')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q003a_coded');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004' {
                if(mapTitleTOAnswer.containsKey('q004')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004a' {
                if(mapTitleTOAnswer.containsKey('q004a')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004a');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004a_na' {
                if(mapTitleTOAnswer.containsKey('q004a_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004a_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004a_coded' {
                if(mapTitleTOAnswer.containsKey('q004a_coded')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004a_coded');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004b' {
                if(mapTitleTOAnswer.containsKey('q004b')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004b');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004b_na' {
                if(mapTitleTOAnswer.containsKey('q004b_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004b_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q004b_coded' {
                if(mapTitleTOAnswer.containsKey('q004b_coded')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q004b_coded');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q005' {
                if(mapTitleTOAnswer.containsKey('q005')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q005');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'q006' {
                if(mapTitleTOAnswer.containsKey('q006')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('q006');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'9';
                }
            }
            when 's001' {
                if(mapTitleTOAnswer.containsKey('s001')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('s001');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 's002' {
                if(mapTitleTOAnswer.containsKey('s002')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('s002');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 's003' {
                if(mapTitleTOAnswer.containsKey('s003')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('s003');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 's003_na' {
                if(mapTitleTOAnswer.containsKey('s003_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('s003_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 's004' {
                if(mapTitleTOAnswer.containsKey('s004')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('s004');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp001' {
                if(mapTitleTOAnswer.containsKey('qp001')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp001');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp002' {
                if(mapTitleTOAnswer.containsKey('qp002')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp002');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp003' {
                if(mapTitleTOAnswer.containsKey('qp003')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp003');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp003_coded' {
                if(mapTitleTOAnswer.containsKey('qp003_coded')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp003_coded');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp003_na' {
                if(mapTitleTOAnswer.containsKey('qp003_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp003_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 's001_na' {
                if(mapTitleTOAnswer.containsKey('s001_na')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('s001_na');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp0041' {
                if(mapTitleTOAnswer.containsKey('qp0041')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp0041');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp0042' {
                if(mapTitleTOAnswer.containsKey('qp0042')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp0042');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp0043' {
                if(mapTitleTOAnswer.containsKey('qp0043')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp0043');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qp0044' {
                if(mapTitleTOAnswer.containsKey('qp0044')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qp0044');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
            }
            when 'qcs004' {
                if(mapTitleTOAnswer.containsKey('qcs004')){
                        Respuesta_encuesta__c rEncuesta = mapTitleTOAnswer.get('qcs004');
                        response += !String.isBlank(rEncuesta.Codigo_de_la_respuesta__c)? rEncuesta.Codigo_de_la_respuesta__c:'';
                }
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
        Database.executeBatch(new SendSurveyBatch(this.queryBrand,this.queryTime));
    }

}