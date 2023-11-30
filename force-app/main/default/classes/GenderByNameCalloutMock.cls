@isTest
public class GenderByNameCalloutMock implements HttpCalloutMock{

    public static HttpResponse respond(HttpRequest r){
        return respond(r, 'OK','random12345');
    }
    public static HttpResponse respond(HttpRequest r, String status, String name) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(!String.isBlank(status) && status == 'OK'){
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('X-Rate-Limit-Remaining', '999');
            res.setBody('{"name":' + (String.isBlank(name) ? '"david"' : '"' + name + '"') + ',"gender":"male","probability":0.99,"count":154461,"country_id":"ES"}');
            res.setStatus(status);
            res.setStatusCode(200);
        }else if(!String.isBlank(status) && status != 'OK'){
            res.setHeader('Content-Type', 'application/json');
            res.setStatus(null);
            res.setStatusCode(0);
        }
        System.debug('GenderByNameCalloutMock.respond res ' + res + ' body ' + res.getBody());
        return res;
    }
}