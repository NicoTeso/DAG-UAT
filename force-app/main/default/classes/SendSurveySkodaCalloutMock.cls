@isTest
public class SendSurveySkodaCalloutMock {
    public static HttpResponse respond(String result) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(!String.isBlank(result) && result == 'OK'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"resultType": "' + result + '","message": "Imported events: 1"}');
            res.setStatus('OK');
            res.setStatusCode(200);
        }else if(!String.isBlank(result) && result == 'KO'){
            res.setHeader('Content-Type', 'application/json');
            res.setStatus(null);
            res.setStatusCode(0);
        }
        System.debug('Bajas_Tranfederencias_CalloutMock.respond res ' + res + ' body ' + res.getBody());
        return res;
    }
}