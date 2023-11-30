public class Bajas_Transferencias_Callout {

    public static HttpResponse getVehiclesCallout(String operationType, String initialDate, String finalDate) {
        return getVehiclesCallout(operationType, initialDate, finalDate, null);
    }    
    public static HttpResponse getVehiclesCallout(String operationType, String initialDate, String finalDate, String vin) {
        // ResponseApi respuesta = new ResponseApi();
        HttpResponse response = new HttpResponse(); 

        try{
        	ApiConnect__c api = ApiConnect__c.getInstance();
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
            
        	//HttpResponse response = new HttpResponse(); 
            String url = api.ApiVehicleDGT__c;// + (!String.isBlank(operationType) ? operationType + '/' : '') ;
        	system.debug('Bajas_Transferencias_Callout.getVehiclesCallout url de salida:'+ url);

            //bajas y transferencias
            if(String.isBlank(vin)){
                url += (!String.isBlank(operationType) ? operationType + '/' : '');
                request.setMethod('POST');
                request.setBody(formatBody(initialDate, finalDate));
            }//check status
            else{
                url += vin + '/status/';
                request.setMethod('GET');
            }
        	
            request.setEndpoint(url);
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Ocp-Apim-Subscription-Key', !String.isBlank(api.ApiVehicleDGT_SubscriptionKey__c) ? api.ApiVehicleDGT_SubscriptionKey__c : '');
			System.debug('Bajas_Transferencias_Callout.getVehiclesCallout method: '+ request.getMethod());
            System.debug('Bajas_Transferencias_Callout.getVehiclesCallout toString: '+ request.toString());
            // Set the body as a JSON object
			request.setTimeout(120000);

            if(!Test.isRunningTest()){
                response = http.send(request);
            }else{
                response = Bajas_Transferencias_CalloutMock.respond(operationType, initialDate, finalDate);
            }
			
        	system.debug('Bajas_Transferencias_Callout.getVehiclesCallout response body: '+ response.getBody());
        }catch(Exception e){
            system.debug('Bajas_Transferencias_Callout.getVehiclesCallout exception response ' + response + ' body: '+ response.getBody());
            response.setStatus('Error Exception');
            response.setBody(e.getStackTraceString());
        }
        system.debug('Bajas_Transferencias_Callout.getVehiclesCallout response '+ response);
        system.debug('Bajas_Transferencias_Callout.getVehiclesCallout response body '+ response.getBody());
        return response;
    }

    //fechas en formato mm-dd-aaaa
    public static String formatBody(String initialDate, String finalDate){
        String formattedBody = '{';
        //{ "datestart": "01-01-2021", "dateend": "01-10-2021"}
        formattedBody += '\"datestart\": \"' + initialDate + '\", '; 
        formattedBody += '\"dateend\": \"' + finalDate + '\"}';
        system.debug('Bajas_Transferencias_Callout.formatBody formattedBody '+ formattedBody);
        return formattedBody;
    }
}