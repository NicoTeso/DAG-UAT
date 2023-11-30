public class GenderByNameController {
    public static GenderByNameModel getGenderByName(String name) {
        return getGenderByName(name, 'ES'); 
    }
    public static GenderByNameModel getGenderByName(String name,String country) {
        HttpResponse response;
        GenderByNameModel respuesta;
        response = GenderByNameCallout.getGenderByNameCallout(name, country);

        System.debug('GenderByNameController.getGenderByName response ' + response + 'getStatus ' + response.getStatus());
        System.debug('GenderByNameController.getGenderByName response body ' + response.getBody());
        if (!String.isBlank(response.getStatus()) && response.getStatus().equalsIgnoreCase('OK')) {
        	respuesta = (GenderByNameModel) JSON.deserialize(response.getBody(), GenderByNameModel.class);
            respuesta.remaining = String.isBlank(response.getHeader('X-Rate-Limit-Remaining')) ? null : Integer.valueOf(response.getHeader('X-Rate-Limit-Remaining'));            
        }else {
            System.debug('GenderByNameController.getGenderByName else no OK');
        	Exception__c exc = new Exception__c ();
         	exc.idObjetos__c = name + '/' + country;
         	exc.Exception__c = 'Error code: ' + response.getStatusCode() + ' // Mensaje de error: '+ response.getBody();
         	exc.Linea__c = 13;
         	exc.Clase_Metodo__c = 'GenderByNameController.getGenderByName';
            if(Exception__c.SObjectType.getDescribe().isCreateable()){
                insert exc;
            }
     	}
        system.debug('GenderByNameController.getGenderByName respuesta:'+ respuesta);   
        return respuesta;
    }
}