@isTest
public class SetDataSurveyApiRestService_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        insert concess;
        
        Account accP = CreaObjetos.creaCuentaPersonal('test', 'prueba');
        Account accE = CreaObjetos.creaCuentaEmpresa('test1');
        List<Account> cuentas = new List<Account>{accP,accE};
        insert cuentas;
        
        
        Detalle_venta__c dv = new Detalle_venta__c();
        dv.Concesionario__c = concess.Id;
        dv.Fecha_de_entrega__c = Datetime.now();
        dv.Comprador__c = accP.Id;
        dv.Propietario__c = accP.Id;
       
        Gestion_encuesta__c surveyManag = new Gestion_encuesta__c();
        surveyManag.Brand__c = 'VOLKSWAGEN';
        surveyManag.Code__c = 'TestCode';
        surveyMAnag.Concesionario_encuesta__c = concess.Id;
        insert surveyManag;
        
        Encuesta__c survey = new Encuesta__c();
        survey.Cliente__c = accP.Id;
        survey.Gestion_encuesta__c = surveyManag.Id;
        survey.vin__c = 'VIN02';
        survey.Fecha_fin_respuesta__c= System.now().addDays(20);
        survey.Detalle_venta__c = dv.Id;
        survey.Tipo_de_Operacion__c = 'Venta';
        survey.Brand__c = 'VOLKSWAGEN';
        insert survey;
        
        Parametros_Voice_Of_Client__c pVOC1 = new Parametros_Voice_Of_Client__c();
        pVOC1.Etiqueta_01__c = 'P2=1';
        pVOC1.Etiqueta_02__c = 'P2=3';  
        pVOC1.Etiqueta_03__c = 'P2=3'; 
        pVOC1.Etiqueta_04__c = 'P2=4'; 
        pVOC1.Etiqueta_05__c = 'P2=5'; 
        pVOC1.Valor_01__c = -15;
        pVOC1.Valor_02__c = -10; 
        pVOC1.Valor_04__c = 0; 
        pVOC1.Valor_03__c = 10; 
        pVOC1.Valor_05__c = 15;
        pVOC1.Marca__c = 'VOLKSWAGEN';
        pVOC1.Peso__c = 10;
        pVOC1.Nivel__c = 'Marca';
        pVOC1.Tipo_de_iteracion__c = 'CEM Venta';
        insert pVOC1;    

        Parametros_Voice_Of_Client__c pVOC2 = new Parametros_Voice_Of_Client__c();
        pVOC2.Etiqueta_01__c = 'Media (Q1,Q3) < 2';
        pVOC2.Etiqueta_02__c = 'Media (Q1,Q3) >= 2 y < 3';  
        pVOC2.Etiqueta_03__c = 'Media (Q1,Q3) >= 3 y < 4'; 
        pVOC2.Etiqueta_04__c = 'Media (Q1,Q3) > 4'; 
        pVOC2.Valor_01__c = -15;
        pVOC2.Valor_02__c = -10; 
        pVOC2.Valor_04__c = 5; 
        pVOC2.Valor_03__c = 15; 
        pVOC2.Marca__c = 'VOLKSWAGEN';
        pVOC2.Peso__c = 10;
        pVOC2.Nivel__c = 'Asesor';
        pVOC2.Tipo_de_iteracion__c = 'CEM Venta';
        insert pVOC2;    

        Parametros_Voice_Of_Client__c pVOC3 = new Parametros_Voice_Of_Client__c();
        pVOC3.Etiqueta_01__c = 'Media (Q1,Q2,Q3) < 2';
        pVOC3.Etiqueta_02__c = 'Media (Q1,Q2,Q3) >= 2 y < 3';  
        pVOC3.Etiqueta_03__c = 'Media (Q1,Q2,Q3) >= 3 y < 4'; 
        pVOC3.Etiqueta_04__c = 'Media (Q1,Q2,Q3) > 4'; 
        pVOC3.Etiqueta_05__c = 'Q4=1'; 
        pVOC3.Etiqueta_06__c = 'Q4=2'; 
        pVOC3.Etiqueta_07__c = 'Q4=3'; 
        pVOC3.Etiqueta_08__c = 'Q4=4'; 
        pVOC3.Etiqueta_09__c = 'Q4=5'; 
        pVOC3.Valor_01__c = -10;
        pVOC3.Valor_02__c = -7; 
        pVOC3.Valor_04__c = 7; 
        pVOC3.Valor_03__c = 10; 
        pVOC3.Valor_05__c = -5;
        pVOC3.Valor_06__c = -3; 
        pVOC3.Valor_07__c = -1; 
        pVOC3.Valor_08__c = 0; 
        pVOC3.Valor_09__c = 5; 
        pVOC3.Marca__c = 'VOLKSWAGEN';
        pVOC3.Peso__c = 10;
        pVOC3.Nivel__c = 'CCS';
        pVOC3.Tipo_de_iteracion__c = 'CEM Venta';
        insert pVOC3;    

        Parametros_Voice_Of_Client__c pVOC4 = new Parametros_Voice_Of_Client__c();
        pVOC4.Etiqueta_01__c = 'Media (Q1,Q2,Q3) < 2';
        pVOC4.Etiqueta_02__c = 'Media (Q1,Q2,Q3) >= 2 y < 3';  
        pVOC4.Etiqueta_03__c = 'Media (Q1,Q2,Q3) >= 3 y < 4'; 
        pVOC4.Etiqueta_04__c = 'Media (Q1,Q2,Q3) > 4'; 
        pVOC4.Etiqueta_05__c = 'Q4=1'; 
        pVOC4.Etiqueta_06__c = 'Q4=2'; 
        pVOC4.Etiqueta_07__c = 'Q4=3'; 
        pVOC4.Etiqueta_08__c = 'Q4=4'; 
        pVOC4.Etiqueta_09__c = 'Q4=5'; 
        pVOC4.Valor_01__c = -10;
        pVOC4.Valor_02__c = -7; 
        pVOC4.Valor_04__c = 7; 
        pVOC4.Valor_03__c = 10; 
        pVOC4.Valor_05__c = -5;
        pVOC4.Valor_06__c = -3; 
        pVOC4.Valor_07__c = -1; 
        pVOC4.Valor_08__c = 0; 
        pVOC4.Valor_09__c = 5; 
        pVOC4.Marca__c = 'VOLKSWAGEN';
        pVOC4.Peso__c = 10;
        pVOC4.Nivel__c = 'DAG';
        pVOC4.Tipo_de_iteracion__c = 'CEM Venta';
        insert pVOC4;    
        
    }
    
    @isTest
    static void InvalidJSONTest() {
        Test.startTest();
        ResponseApi res = testDoPost('{}');
        Test.stopTest();
    }
    
    @isTest
    static void InvalidSidTest() {
        Test.startTest();
        ResponseApi res = testDoPost(getStaticResourceData('JSONSetDataSurveyApiInvalidSid'));
        Test.stopTest();
    }
    
    @isTest
    static void PostTest() {
        Encuesta__c survey = [SELECT Id FROM Encuesta__c LIMIT 1];
        SetDataSurveyApiRestModel req = new SetDataSurveyApiRestModel();
        req.encuesta = new SetDataSurveyApiRestModel.Encuesta();
        req.encuesta.identificador = survey.Id;
        req.encuesta.fechaRespuesta = '2020-01-01T09:00:00Z';
        req.encuesta.preguntas = new List<SetDataSurveyApiRestModel.Pregunta>();
        SetDataSurveyApiRestModel.Pregunta q1 = new SetDataSurveyApiRestModel.Pregunta();
        q1.codigoPregunta = 'Q1';
        q1.pregunta = 'Wut?';
        q1.respuesta = '4';
        q1.codigoRespuesta = '4';
        q1.titulo = 'q001';
        req.encuesta.preguntas.add(q1);
        SetDataSurveyApiRestModel.Pregunta q2 = new SetDataSurveyApiRestModel.Pregunta();
        q2.codigoPregunta = 'Q2a';
        q2.pregunta = 'Wut?';
        q2.respuesta = 'Tuw';
        q2.codigoRespuesta = '1';
        q2.titulo = 'NonAnonymous';
        req.encuesta.preguntas.add(q2);
        
        SetDataSurveyApiRestModel.Pregunta q3 = new SetDataSurveyApiRestModel.Pregunta();
        q3.codigoPregunta = 'Q2';
        q3.pregunta = 'Wut?';
        q3.respuesta = 'Tuw';
        q3.codigoRespuesta = '1';
        q3.titulo = 'q002';
        req.encuesta.preguntas.add(q3);

        SetDataSurveyApiRestModel.Pregunta q4 = new SetDataSurveyApiRestModel.Pregunta();
        q4.codigoPregunta = 'Q3';
        q4.pregunta = 'Wut?';
        q4.respuesta = 'Tuw';
        q4.codigoRespuesta = '3';
        q4.titulo = 'q003';
        req.encuesta.preguntas.add(q4);

        SetDataSurveyApiRestModel.Pregunta q5 = new SetDataSurveyApiRestModel.Pregunta();
        q5.codigoPregunta = 'QP2';
        q5.pregunta = 'Wut?';
        q5.respuesta = 'Tuw';
        q5.codigoRespuesta = '3';
        q5.titulo = 'qp002';
        req.encuesta.preguntas.add(q5);

        SetDataSurveyApiRestModel.Pregunta q6 = new SetDataSurveyApiRestModel.Pregunta();
        q6.codigoPregunta = 'Q4';
        q6.pregunta = 'Wut?';
        q6.respuesta = 'Tuw';
        q6.codigoRespuesta = '1';
        q6.titulo = 'q004';
        req.encuesta.preguntas.add(q6);
        
        Test.startTest();
        ResponseApi res = testDoPost(JSON.serialize(req));
        ResponseApi res2 = testDoPost(JSON.serialize(req));
        Test.stopTest();
    }
    
    private static ResponseApi testDoPost(String json) {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/setDataSurvey';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
        System.debug('requestBody: ' + req.requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        return SetDataSurveyApiRestService.setDataSurvey();
    }
    
    private static String getStaticResourceData(String staticresource) {
        List<StaticResource> docs = [SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticresource];
        StaticResource sr = docs.get(0);
        
        return sr.Body.toString();  
    }

    @isTest
    static void PostTest1() {
        //encuesta ya vencida
        Account cliente = CreaObjetos.creaCuentaPersonal('pruebaAudi', 'pruebaAudi');
        insert cliente;
        Concesionario__c conce = CreaObjetos.creaConcesionario('169-test');
        insert conce;
        Centro__c centro = CreaObjetos.creaCentro(conce.Id);
        Gestion_encuesta__c gEncuesta = CreaObjetos.creaGestionEncuesta('AUDI', centro.Id, conce.Id);
        insert gEncuesta;
        Encuesta__c survey1  = CreaObjetos.creaEncuesta('1', 'AUDI', cliente.Id, conce.Id, null, gEncuesta.id, 'CEM');
        survey1.Respondido__c = false;
        survey1.Fecha_fin_respuesta__c = datetime.now().addDays(-7);
        insert survey1;
        SetDataSurveyApiRestModel req = new SetDataSurveyApiRestModel();
        req.encuesta = new SetDataSurveyApiRestModel.Encuesta();
        req.encuesta.identificador = survey1.Id;
        req.encuesta.fechaRespuesta = String.valueOf(datetime.now());
        req.encuesta.preguntas = new List<SetDataSurveyApiRestModel.Pregunta>();
        SetDataSurveyApiRestModel.Pregunta q1 = new SetDataSurveyApiRestModel.Pregunta();
        q1.codigoPregunta = 'Q1';
        q1.pregunta = 'Wut?';
        q1.respuesta = 'Tuw';
        q1.codigoRespuesta = 'A1';
        q1.titulo = 'Test Q1';
        req.encuesta.preguntas.add(q1);
        SetDataSurveyApiRestModel.Pregunta q2 = new SetDataSurveyApiRestModel.Pregunta();
        q2.codigoPregunta = 'Q1';
        q2.pregunta = 'Wut?';
        q2.respuesta = 'Tuw';
        q2.codigoRespuesta = '1';
        q2.titulo = 'NonAnonymous';
        req.encuesta.preguntas.add(q2);
        
        Test.startTest();
        ResponseApi res = testDoPost(JSON.serialize(req));
        ResponseApi res2 = testDoPost(JSON.serialize(req));
        Test.stopTest();
    }
}