public class ExternalServiceCallout {
    public Static ResponseApi createLeadApiCallout(ExternalLeadApiModel.LeadApi externalApi){
        ResponseApi respuesta = new ResponseApi();
        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse(); 
        	String JSONrequest = JSON.serialize(externalApi);
        	system.debug('JSON:'+ JSONrequest);
        	system.debug('url de salida:'+ api.ApiCreateLead__c);
        	request.setEndpoint(api.ApiCreateLead__c);
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', api.ApiClient_id__c);
			request.setHeader('client_secret', api.ApiClient_secret__c );
			system.debug('toString:'+ request.toString());
			// Set the body as a JSON object
			request.setBody(JSONrequest);
            request.setTimeout(30000);
			response = http.send(request);
        	system.debug('respuesta'+ respuesta);
        	system.debug('responsestatusbody:'+ response.getBody());
        	system.debug('responsestatusbody:'+ response.getBodyAsBlob());
            respuesta.ErrorCode = String.valueOf(response.getStatusCode());
        	respuesta.Status = response.getStatus() ;
        	respuesta.Message = response.getBody();
        }catch(Exception e){
        	respuesta.ErrorCode = '511';
        	respuesta.Status = 'Error' ;
        	respuesta.Message = e.getMessage();
        	
        }
        
        
        //system.debug('response.status:'+ response.getStatusCode());
        //system.debug('response:'+ response.getStatusCode());
        
        return respuesta;
    }

    public Static ResponseApi createLeadApiCalloutNew(ExternalLeadApiNewModel.LeadApi externalApi){
        ResponseApi respuesta = new ResponseApi();
        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse(); 
        	String JSONrequest = JSON.serialize(externalApi);
        	system.debug('JSON:'+ JSONrequest);
        	system.debug('url de salida:'+ api.ApiCreateLead__c);
        	request.setEndpoint(api.ApiCreateLead__c);
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', api.ApiClient_id__c);
			request.setHeader('client_secret', api.ApiClient_secret__c );
			system.debug('toString:'+ request.toString());
			// Set the body as a JSON object
			request.setBody(JSONrequest);
            request.setTimeout(30000);
			response = http.send(request);
        	system.debug('respuesta'+ respuesta);
        	system.debug('responsestatusbody:'+ response.getBody());
        	system.debug('responsestatusbody:'+ response.getBodyAsBlob());
            respuesta.ErrorCode = String.valueOf(response.getStatusCode());
        	respuesta.Status = response.getStatus() ;
        	respuesta.Message = response.getBody();
        }catch(Exception e){
        	respuesta.ErrorCode = '511';
        	respuesta.Status = 'Error' ;
        	respuesta.Message = e.getMessage();
        	
        }
        
        
        //system.debug('response.status:'+ response.getStatusCode());
        //system.debug('response:'+ response.getStatusCode());
        
        return respuesta;
    }
    
    public Static ResponseApi createAccountApiCallout(externalCustomerApiModel.CustomerApi externalApi){
        ResponseApi respuesta = new ResponseApi();
        try {
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse(); 
        	String JSONrequest = JSON.serialize(externalApi,true);
            system.debug('JSON:'+ JSONrequest);
        	system.debug('url de salida:'+ api.ApiCreateCustomer__c);
        	request.setEndpoint(api.ApiCreateCustomer__c);
			//llamada a la url correspondiente de crear cuenta realizar asignacion correcta del setEndpoint
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', api.ApiClient_id__c);
			request.setHeader('client_secret', api.ApiClient_secret__c );
			// Set the body as a JSON object
			request.setBody(JSONrequest);
            request.setTimeout(30000);
        	system.debug('request:'+ request);
			response = http.send(request);
            system.debug('response:'+response.getStatus());
        	respuesta.ErrorCode = String.valueOf(response.getStatusCode());
        	respuesta.Status = response.getStatus();
        	respuesta.Message = response.getBody();
        	system.debug('respuesta:body:'+respuesta.Message);
        }catch(Exception e){
            respuesta.ErrorCode = '511';
        	respuesta.Status = 'Error';
        	respuesta.Message = e.getMessage();
            system.debug('MensajeError:'+ e.getMessage());
                
        }
        
        return respuesta;
    }
    
    public Static ResponseApi sendConsentimientoApiCallout(ExternalConsentimientoApiModel.ConsentimientoApi externalApi){
        ResponseApi respuesta = new ResponseApi();
        try {
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse(); 
        	String JSONrequest = JSON.serialize(externalApi,true);
            system.debug('JSON:'+ JSONrequest);
        	system.debug('url de salida:'+ api.ApiConsentimiento__c);
        	request.setEndpoint(api.ApiConsentimiento__c);
			//llamada a la url correspondiente de crear cuenta realizar asignacion correcta del setEndpoint
			request.setMethod('PUT');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', api.ApiClient_id__c);
			request.setHeader('client_secret', api.ApiClient_secret__c );
			// Set the body as a JSON object
			request.setBody(JSONrequest);
            request.setTimeout(30000);
        	system.debug('request:'+ request);
			response = http.send(request);
        	respuesta.ErrorCode = String.valueOf(response.getStatusCode());
        	respuesta.Status = response.getStatus();
        	respuesta.Message = response.getBody();
        	system.debug('respuesta:body:'+respuesta.Message);
        }catch(Exception e){
            respuesta.ErrorCode = '511';
        	respuesta.Status = 'Error';
        	respuesta.Message = e.getMessage();
        }
        
        return respuesta;
    }
}