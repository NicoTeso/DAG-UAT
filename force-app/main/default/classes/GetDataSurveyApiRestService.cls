@RestResource(urlMapping='/getDataSurvey/*')
global with sharing class GetDataSurveyApiRestService {
     @HttpGet
     global static ResponseApiSurvey getDataSurvey() {
         ResponseApiSurvey response = new ResponseApiSurvey();
         Id sid = RestContext.request.params.get('Sid');
         System.debug('SID: ' + sid);
         RestRequest req = RestContext.request;
         // RestResponse res = Restcontext.response;
         //String ssid = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
         Encuesta__c encuesta = EncuestaGateway.getEncuestaBySid(sid);
         System.debug('ENCUESTA: ' + encuesta);
         
         if (encuesta != null) {
             if (encuesta.Respondido__c == true) {
                        response.Status = Label.errorStatus_Error;
                        response.ErrorCode = '@CRM103';
                        response.Message = 'La encuesta ya ha sido respondida anteriormente.';
                     
                 }
             else {    
                 if(encuesta.Fecha_fin_respuesta__c >= system.now()){
                    response.Encuesta = new ResponseApiSurvey.Encuesta();
                    response.Encuesta.Encuesta = encuesta.Name;
                    response.Encuesta.Contacto = encuesta.Cliente__r.Name;
                    response.Encuesta.Email = encuesta.Cliente__r.isPersonAccount ? encuesta.Cliente__r.PersonEmail : encuesta.Cliente__r.Email__c;
                    response.Encuesta.Marca = encuesta.Gestion_encuesta__r.Brand__c;
                    response.Encuesta.Concesionario = encuesta.Gestion_encuesta__r.Concesionario__r.Name;
                    response.Encuesta.ServicioOficial = encuesta.Gestion_encuesta__r.Code__c;
                    response.Encuesta.Bastidor = encuesta.vin__c;
                    response.Encuesta.FechaEntrega = String.valueOf(encuesta.Fecha_documento__c);
                    response.Encuesta.Modelo = encuesta.ModeloString__c;
                    //response.Encuesta.sid = sid;
                
                    response.Status = Label.errorStatus_Success;
                    //response.ErrorCode ='200';
                    response.Message = Label.responseMessage_Success;
                     
                 }
                 
                 else {
                    response.Status = Label.errorStatus_Error;
                    response.ErrorCode ='@CRM102';
                    response.Message = Label.errorMessage_exceededDate;
                 }
             
             }
         }    
         else {
            response.Status = Label.errorStatus_Error;
            response.ErrorCode ='@CRM104';
            response.Message = Label.errorMessage_SidNotFound;
         }
         
         return response;
     }
}