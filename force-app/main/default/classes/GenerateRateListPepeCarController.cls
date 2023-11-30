public class GenerateRateListPepeCarController {
    
    public static ResponseApi getGenerateRateListPepeCar(GenerateRateListPepeCarModel req) {
        return getGenerateRateListPepeCar(req, true);
    }
    public static ResponseApi getGenerateRateListPepeCar(GenerateRateListPepeCarModel req, Boolean createError) {
		ResponseApi responseCallout;
        responseCallout = GenerateRateListPepeCarCallout.getGenerateRateListPepeCarCallout(req);
        System.debug('GenerateRateListPepeCarController.getGenerateRateListPepeCarCallout responseCallout ' + responseCallout);
        if (responseCallout.Status.equalsIgnoreCase('OK')) {
            system.debug('responseCallout:'+ responseCallout);
        }
        else if(createError){
        	Exception__c exc = new Exception__c ();
         	exc.Exception__c = responseCallout.ErrorCode + '//'+ responseCallout.Message;
         	exc.Linea__c = 8;
         	exc.Clase_Metodo__c = 'GenerateRateListPepeCarController.getGenerateRateListPepeCarCallout';
            if (Exception__c.SObjectType.getDescribe().isCreateable()){
                insert exc;
            }
     	}   
        return responseCallout;
    }
}