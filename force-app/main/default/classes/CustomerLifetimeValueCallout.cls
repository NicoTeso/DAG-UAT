public class CustomerLifetimeValueCallout {

    public static HttpResponse getCustomerLifetimeValueCallout(String block) {
        // ResponseApi respuesta = new ResponseApi();
        HttpResponse response = new HttpResponse(); 

        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	//HttpResponse response = new HttpResponse(); 
            String url = api.ApiCustomerLifetimeValue__c + block + '/';
        	system.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout:'+ url);
            request.setMethod('GET');
        	
            request.setEndpoint(url);
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Ocp-Apim-Subscription-Key', !String.isBlank(api.ApiCLV_SubscriptionKey__c) ? api.ApiCLV_SubscriptionKey__c : '');
			System.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout method: '+ request.getMethod());
            System.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout toString: '+ request.toString());
            // Set the body as a JSON object
			request.setTimeout(120000);

            if(!Test.isRunningTest()){
                response = http.send(request);
            }else{
                response = CustomerLifetimeValueCalloutMock.respond(block);
            }
			
        	system.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout response body: '+ response.getBody());
        }catch(Exception e){
            system.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout exception response ' + response + ' body: '+ response.getBody());
            response.setStatus('Error Exception');
            response.setBody(e.getStackTraceString());
        }
        system.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout response '+ response);
        system.debug('CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout response body '+ response.getBody());
        return response;
    }
//
//fechas en formato mm-dd-aaaa
//    public static String formatBody(String initialDate, String finalDate){
//        String formattedBody = '{';
//        //{ "datestart": "01-01-2021", "dateend": "01-10-2021"}
//        formattedBody += '\"datestart\": \"' + initialDate + '\", '; 
//        formattedBody += '\"dateend\": \"' + finalDate + '\"}';
//        system.debug('Bajas_Transferencias_Callout.formatBody formattedBody '+ formattedBody);
//        return formattedBody;
//    }
}