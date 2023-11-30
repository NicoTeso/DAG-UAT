public class SendSurveyFileController {
    
    public static ResponseApi getSendSurveyFile(SendSurveyFileModel req) {
        return getSendSurveyFile(req, true);
    }
    public static ResponseApi getSendSurveyFile(SendSurveyFileModel req, Boolean createError) {
		ResponseApi responseCallout;
        responseCallout = SendSurveyFileCallout.getSendSurveyFileCallout(req);
        System.debug('SendSurveyFileController.getSendSurveyFileCallout responseCallout ' + responseCallout);
        if (responseCallout.Status.equalsIgnoreCase('OK')) {
            system.debug('responseCallout:'+ responseCallout);
        }
        else if(createError){
        	Exception__c exc = new Exception__c ();
         	exc.Exception__c = responseCallout.ErrorCode + '//'+ responseCallout.Message;
         	exc.Linea__c = 8;
         	exc.Clase_Metodo__c = 'SendSurveyFileController.getSendSurveyFileCallout';
            if (Exception__c.SObjectType.getDescribe().isCreateable()){
                insert exc;
            }
     	}   
        return responseCallout;
    }
}