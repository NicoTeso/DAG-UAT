public with sharing class vehiclesAvailableVOCallout {
    public static ResponseApi getvehiclesAvailableVOCallout() {
        ResponseApi respuesta = new ResponseApi();
        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse(); 
            String url = api.ApiVehiclesAvailableVO__c;
        	system.debug('url de salida:'+ url);
        	request.setEndpoint(url);
			request.setMethod('GET');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('client_id', api.ApiClient_id__c);
			request.setHeader('client_secret', api.ApiClient_secret__c );
			system.debug('toString:'+ request.toString());
			// Set the body as a JSON object
			request.setTimeout(120000);
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
        return respuesta;
    }
}