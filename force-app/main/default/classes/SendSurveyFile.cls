public class SendSurveyFile implements Schedulable {

	public static void SendSurveyFile(){    

        system.debug('Empieza');
        system.debug('0.- cputime: '+limits.getCpuTime());
       
	    Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName();
        String enviadoAFabrica = rtMapByDName.get('Envio_a_fabrica').getRecordTypeId(); 
        
        List<Encuesta__c> lstEnvioFabrica = [SELECT Id, Brand__c, Enviado_a_fabrica__c, Tipo_de_Operacion__c
        				                       FROM Encuesta__c 
                                              WHERE RecordTypeId = :enviadoAFabrica AND
                                       				Enviado_a_fabrica__c = false
                                 		   ORDER BY Brand__c, CreatedDate                  
                                 			  LIMIT 2000];

        system.debug('2.- cputime: '+limits.getCpuTime());
        system.debug('lstTarifaRenting');  
        
        String csvHeader = '';
        String csvData = ''; 

        system.debug('3.- cputime: '+limits.getCpuTime());
        
        if(!lstEnvioFabrica.isEmpty()){

            list<String> idsEnvioFabrica = new list<String>(); 
            for(Encuesta__c EnvioFabrica :lstEnvioFabrica){
                system.debug('EnvioFabrica: '+EnvioFabrica);
                idsEnvioFabrica.add(EnvioFabrica.Id); 
            }
            
            List<ContentDocumentLink> lstcdLink = [SELECT Id, ContentDocumentId, LinkedEntityId
                                 FROM ContentDocumentLink 
                                 WHERE LinkedEntityId IN :idsEnvioFabrica
                                 LIMIT 2000];
            
            list<String> idscdId = new list<String>(); 
            Map <String, String> mapcdLink = New Map <String, String>();

            for(ContentDocumentLink cdLink :lstcdLink){
                system.debug('cdLink: '+cdLink);
                idscdId.add(cdLink.ContentDocumentId);
                mapcdLink.put(cdLink.ContentDocumentId, cdLink.LinkedEntityId);

            }
            
            List<ContentVersion> lstcv = [SELECT Id, ContentDocumentId, title, PathOnClient, VersionData
                                 FROM ContentVersion 
                                 WHERE ContentDocumentId IN :idscdId
                                 LIMIT 2000];
             
            Map<String, ContentVersion> mapcv = New Map<String, ContentVersion>();
            for(ContentVersion cv :lstcv){
                mapcv.put(mapcdLink.get(cv.ContentDocumentId), cv);
                system.debug('cv: '+cv);
                system.debug('mapcv: '+mapcv);
            }

            for(Encuesta__c EnvioFabrica :lstEnvioFabrica){
                system.debug('EnvioFabrica: '+EnvioFabrica);

                ContentVersion cv = mapcv.get(EnvioFabrica.Id);

	            SendSurveyFileModel req = new SendSurveyFileModel();
                string tipoOperacion = '';
                if (EnvioFabrica.Brand__c.equalsIgnoreCase('HYUNDAI')) {
	                tipoOperacion = EnvioFabrica.Tipo_de_Operacion__c.equalsIgnoreCase('Venta')? '_SALES':'_AFTERSALES';
                }
                string destination = 'CEM_'+ EnvioFabrica.Brand__c + tipoOperacion;

                if ((EnvioFabrica.Brand__c.equalsIgnoreCase('HYUNDAI') &&  date.today() >= Date.parse(Label.startNewCem)) || 
                    !EnvioFabrica.Brand__c.equalsIgnoreCase('HYUNDAI')) {
	                SendSurveyFileFuture(cv.VersionData, destination, cv.title, EnvioFabrica.Id);    
                }
            }
	    }
    }
        
    @future(callout=true)
	public static void SendSurveyFileFuture(blob csvBlob, string destination, string title, string survey){    

	    SendSurveyFileModel req = new SendSurveyFileModel();

        req.contentType = 'CSV';
        req.formatType = 'ftp';
        req.destination = destination;
        req.nameFile =  title;
        req.body = EncodingUtil.base64Encode(csvBlob); 
        
        ResponseApi responseCallout = SendSurveyFileController.getSendSurveyFile(req);
            
        if (responseCallout.Status.equalsIgnoreCase('OK')) {
            Encuesta__c EnvioFabrica = [SELECT Id, Enviado_a_fabrica__c
        				                       FROM Encuesta__c 
                                              WHERE Id = :survey];
            EnvioFabrica.Enviado_a_fabrica__c = true;
            update EnvioFabrica;
            system.debug('responseCallout OK:'+ responseCallout);
        } else {
            system.debug('responseCallout KO:'+ responseCallout);
        }

    }   

    // Scheduler
    public void execute(SchedulableContext sc) {
       SendSurveyFile();
    }    
    
}