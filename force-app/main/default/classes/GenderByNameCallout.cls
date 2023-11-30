public class GenderByNameCallout {

    public static HttpResponse getGenderByNameCallout(String name, String country) {
        // ResponseApi respuesta = new ResponseApi();
        HttpResponse response = new HttpResponse(); 
        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	//HttpResponse response = new HttpResponse(); 
            String url = api.ApiGetGenderByNameHost__c + (!String.isBlank(name) ? 'name=' + name : '') + 
                                                      (!String.isBlank(country) ? '&country_id=' + country : '');
        	system.debug('GenderByNameCallout.getGenderByNameCallout url de salida:'+ url);
        	
            request.setEndpoint(url);
			request.setMethod('GET');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
			system.debug('GenderByNameCallout.getGenderByNameCallout toString: '+ request.toString());
			// Set the body as a JSON object
			request.setTimeout(30000);

            if(!Test.isRunningTest()){
                response = http.send(request);
            }else{
                response = GenderByNameCalloutMock.respond(request, !String.isBlank(name) ? 'OK' : 'KO', name);
            }
			
        	system.debug('GenderByNameCallout.getGenderByNameCallout response body: '+ response.getBody());
            // System.debug('GenderByNameCallout.getGenderByNameCallout remaining today ' + response.getHeader('X-Rate-Limit-Remaining'));
        }catch(Exception e){
            system.debug('GenderByNameCallout.getGenderByNameCallout exception response ' + response + ' body: '+ response.getBody());
            response.setStatus('Error Exception');
            response.setBody(e.getStackTraceString());
        }
        system.debug('GenderByNameCallout.getGenderByNameCallout response '+ response);
        return response;
    }
}