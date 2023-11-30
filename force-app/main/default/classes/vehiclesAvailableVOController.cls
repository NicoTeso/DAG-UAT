public with sharing class vehiclesAvailableVOController {
    public static vehiclesAvailableVOModel getvehiclesAvailableVOList() {
        vehiclesAvailableVOModel respuesta;
        ResponseApi responseCallout;
        responseCallout = vehiclesAvailableVOCallout.getvehiclesAvailableVOCallout();
/*
        ResponseApi responseCallout = new ResponseApi();
        responseCallout.ErrorCode = '200';
        responseCallout.Status = 'OK' ;
        responseCallout.Message = getStaticResourceData('vehiclesAvailableVO');
*/
        system.debug('responseCallout.Message: '+responseCallout.Message);

        System.debug('vehiclesAvailableVOCallout .getvehiclesAvailableVOCallout responseCallout ' + responseCallout);
        if (responseCallout.Status.equalsIgnoreCase('OK')) {
        	respuesta = (vehiclesAvailableVOModel) JSON.deserialize(responseCallout.Message, vehiclesAvailableVOModel.class);
            system.debug('respuesta:'+ respuesta);
        }
        else {
            System.debug('vehiclesAvailableVOController.getvehiclesAvailableVOList else no OK');
        	Exception__c exc = new Exception__c ();
         	exc.idObjetos__c = '';
         	exc.Exception__c = responseCallout.ErrorCode + '//'+ responseCallout.Message;
         	exc.Linea__c = 10;
         	exc.Clase_Metodo__c = 'vehiclesAvailableVOController.getvehiclesAvailableVOList';
            if(Exception__c.SObjectType.getDescribe().isCreateable()){
                insert exc;
            }
     	}
        system.debug('vehiclesAvailableVOController.getvehiclesAvailableVOList respuesta:'+ respuesta);
        return respuesta;
    }
/*
    private static String getStaticResourceData(String staticresource) {
        List<StaticResource> docs = [SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticresource];
        StaticResource sr = docs.get(0);
        
        return sr.Body.toString();  
    }
*/

}