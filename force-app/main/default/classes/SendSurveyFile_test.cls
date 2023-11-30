@isTest
public class SendSurveyFile_test {
    @testSetup
    static void setup() {

        String dateTitle = String.valueOf(Datetime.now().year());
        Integer mes = Datetime.now().month();
        Integer dia = Datetime.now().day();
        Integer horas = Datetime.now().hour();
        Integer minutos = Datetime.now().minute();
        dateTitle += mes<10?'0'+String.valueOf(mes):String.valueOf(mes);
        dateTitle += dia<10?'0'+String.valueOf(dia)+'_':String.valueOf(dia)+'_';
        dateTitle += horas<10?'0'+String.valueOf(horas):String.valueOf(horas);
        dateTitle += minutos<10?'0'+String.valueOf(minutos)+'00':String.valueOf(minutos)+'00';
            
        Blob csvHeaderASBlob = blob.valueOf('columna1;columna2\n');
                
        String title = 'CEM_'+ date.today().year() + '_IC_' + dateTitle + '_Test';

        Encuesta__c regEnvioFabrica = new Encuesta__c();
    
        regEnvioFabrica.Brand__c = 'HYUNDAI';
        regEnvioFabrica.Tipo_de_Operacion__c = 'Pase de Taller';
        regEnvioFabrica.Enviado_a_fabrica__c = false;
        regEnvioFabrica.Fecha_envio_a_fabrica__c = date.today();
        regEnvioFabrica.RecordTypeId = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName().get('Envio_a_fabrica').getRecordTypeId();
                
        insert regEnvioFabrica;
                
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = title + '.'+'csv';
        cv.ContentLocation ='S';
        cv.VersionData = csvHeaderASBlob;
        insert cv;
                
        ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
                
        ContentDocumentLink cdlink = new ContentDocumentLink();
        cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
        cdLink.LinkedEntityId = regEnvioFabrica.id;
        cdLink.Visibility = 'AllUsers';
        insert cdLink;
        
    }

    @isTest 
    static void testEnvioPepeCar() {
        Test.startTest();
        SendSurveyFile.SendSurveyFile();
        test.stopTest();
        
    }    

}