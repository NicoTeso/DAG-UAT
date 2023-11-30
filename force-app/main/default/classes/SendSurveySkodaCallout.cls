public with sharing class SendSurveySkodaCallout {
    public static HttpResponse getSurveySkodaCallout(List<SendSurveySkodaModel> currentRequest, String queryType) {
        // ResponseApi respuesta = new ResponseApi();
        HttpResponse response = new HttpResponse(); 
        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	//HttpResponse response = new HttpResponse();
            String url = queryType.equalsIgnoreCase('SALES')? api.SendSurveySkodaSales__c:api.SendSurveySkodaAftersales__c;
        	system.debug('SendSurveySkodaCallout.getSurveySkodaCallout url de salida:'+ url);

            String username = api.SendSurveySkoda_Username__c;
            String password = api.SendSurveySkoda_Password__c;
        
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
        	
            request.setEndpoint(url);
			request.setMethod('GET');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // request.setHeader('apikey', api.ApiInvalidPhoneKey__c);
			system.debug('SendSurveySkodaCallout.getSurveySkodaCallout toString: '+ JSON.serialize(currentRequest));
			// Set the body as a JSON object
			request.setTimeout(30000);
            request.setBody(JSON.serialize(currentRequest));
            if(!Test.isRunningTest()){
                response = http.send(request);
            }else{
                //response = GenderByNameCalloutMock.respond(request, !String.isBlank(phone) ? 'OK' : 'KO', phone);
            }
			
        	system.debug('SendSurveySkodaCallout.getSurveySkodaCallout response body: '+ response.getBody());
            // System.debug('SendSurveySkodaCallout.getSurveySkodaCallout remaining today ' + response.getHeader('X-Rate-Limit-Remaining'));
        }catch(Exception e){
            system.debug('SendSurveySkodaCallout.getSurveySkodaCallout exception response ' + response + ' body: '+ response.getBody());
            response.setStatus('Error Exception');
            response.setBody(e.getStackTraceString());
        }
        system.debug('SendSurveySkodaCallout.getSurveySkodaCallout response '+ response);
        return response;
    }
}