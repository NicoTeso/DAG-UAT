public class ExternalCustomerServiceCallout {
    /*
    public Static ResponseApi createLeadApiCallout(ExternalLeadApiModel.LeadApi externalApi){
        ResponseApi respuesta = new ResponseApi();
        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse(); 
        	String JSONrequest = JSON.serialize(externalApi);
        	system.debug('JSON:'+ JSONrequest);
        	//llamar la url
        	system.debug('url de salida:'+ api.ApiCreateLead__c);
        	request.setEndpoint(api.ApiCreateLead__c);
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
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
        	//llamar la url
			system.debug('JSON:'+ JSONrequest);        
        	request.setEndpoint('https://com-dag-exp-sf-dev.de-c1.cloudhub.io/api/v1/customers');
        	//llamada a la url correspondiente de crear cuenta realizar asignacion correcta del setEndpoint
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
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
    }*/
}