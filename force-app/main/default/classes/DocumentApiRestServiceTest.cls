@isTest
public class DocumentApiRestServiceTest {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();

        Account account = CreaObjetos.creaCuentaPersonal('pruebaName', 'pruebaLastname');
        insert account;
        Case cas = CreaObjetos.creaCasoWithCuenta('Gestion_de_Lead', account.Id, null, null, '666666666', 'prueba@prueba.com');
        insert cas;
	}

    @isTest static void testOK(){
        Test.startTest();
        ResponseApi res = creaDocumentoOK();
        System.debug('DocumentApiRestServiceTest.testOK res ' + res);
        Test.stopTest();
        System.assertEquals(null, res.ErrorCode);
    }

    @isTest static void testKO(){
        Test.startTest();
        ResponseApi res = creaDocumentoKO();
        System.debug('DocumentApiRestServiceTest.testKO res ' + res);
        Test.stopTest();
        System.assertEquals('500', res.ErrorCode);
    }
    private static ResponseApi creaDocumentoOK(){

        Case cas = [SELECT Id FROM Case LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/documentApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf(formatRequest(cas.Id));
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;

        return DocumentApiRestService.document();
    }

    private static ResponseApi creaDocumentoKO(){

        //Case caso = [SELECT Id FROM Case LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/documentApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf(formatRequest(null));
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;

        return DocumentApiRestService.document();
    }

    private static String formatRequest(Id parentId){
        
        DocumentApiRestModel model = new DocumentApiRestModel();
        model.documentInfo = new DocumentApiRestModel.DocumentInfo();

        model.documentInfo.contentType = 'PNG';
        model.documentInfo.body = 'prueba body';
        model.documentInfo.title = 'prueba titulo';
        model.documentInfo.parentId = parentId;

        System.debug('DocumentApiRestServiceTest.formatRequest model ' + model);
        System.debug('DocumentApiRestServiceTest.formatRequest JSON.serialize(model) ' + JSON.serialize(model));
        return JSON.serialize(model);
    }
}