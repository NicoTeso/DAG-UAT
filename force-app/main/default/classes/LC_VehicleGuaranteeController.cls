public class LC_VehicleGuaranteeController {
    
    @AuraEnabled
    public static String getShow(String recordId){
       responseGuarantee response = new responseGuarantee();
        if(!String.isBlank(recordId)){
            List<Vehiculo__c> lstVehicles = [SELECT Id,Name,Concesionario__c,Propietario__c, MarcaString__c, VIN__c,kms__c,PR_Number__c,
                                             Kms_contrato_prestacion__c,Fecha_contrato_fin_e_garantia__c, Fecha_contrato_inicio_e_garantia__c,
                                             Fecha_fin_garantia__c, Fecha_inicio_garantia__c, Fecha_inicio_garantia_VO__c, Fecha_fin_garantia_VO__c
                                     	  	FROM Vehiculo__c
                                    	  	WHERE Id = :recordId];
            if(!lstVehicles.isEmpty()){
                Vehiculo__c vehiculo = lstVehicles[0];
                response.respuesta = true;
                if(vehiculo.Fecha_inicio_garantia__c != null && vehiculo.Fecha_fin_garantia__c != null && vehiculo.Fecha_fin_garantia__c >= Datetime.now()){
                    response.showGarantia = true;
                	response.FechaFinGarantia = vehiculo.Fecha_fin_garantia__c != null ? Date.newInstance(vehiculo.Fecha_fin_garantia__c.Year(),vehiculo.Fecha_fin_garantia__c.Month(), vehiculo.Fecha_fin_garantia__c.Day()):null;
        			response.FechaInicioGarantia = vehiculo.Fecha_inicio_garantia__c != null ? Date.newInstance(vehiculo.Fecha_inicio_garantia__c.Year(),vehiculo.Fecha_inicio_garantia__c.Month(), vehiculo.Fecha_inicio_garantia__c.Day()):null;
        			   
                }
                else {response.showGarantia = false;}
                if(vehiculo.Fecha_inicio_garantia_VO__c != null && vehiculo.Fecha_fin_garantia_VO__c != null && vehiculo.Fecha_fin_garantia_VO__c >= Datetime.now()){
                       response.showGarantiaVO = true;
                    	response.FechaInicioGarantiaVO = vehiculo.Fecha_inicio_garantia_VO__c != null ? Date.newInstance(vehiculo.Fecha_inicio_garantia_VO__c.Year(),vehiculo.Fecha_inicio_garantia_VO__c.Month(), vehiculo.Fecha_inicio_garantia_VO__c.Day()):null;
                       response.FechaFinGarantiaVO = vehiculo.Fecha_fin_garantia_VO__c != null ? Date.newInstance(vehiculo.Fecha_fin_garantia_VO__c.Year(),vehiculo.Fecha_fin_garantia_VO__c.Month(), vehiculo.Fecha_fin_garantia_VO__c.Day()):null;
                }
                else {response.showGarantiaVO = false;}
                response.showCardGarantia = response.showGarantia || response.showGarantiaVO ?true:false;
                if(vehiculo.Fecha_contrato_inicio_e_garantia__c != null && vehiculo.Fecha_contrato_fin_e_garantia__c!= null && vehiculo.Fecha_contrato_fin_e_garantia__c>= Datetime.now()){
                    response.FechaContratoFin = Date.newInstance(vehiculo.Fecha_contrato_fin_e_garantia__c.Year(),vehiculo.Fecha_contrato_fin_e_garantia__c.Month(), vehiculo.Fecha_contrato_fin_e_garantia__c.Day());
        			response.FechaContratoInicio = Date.newInstance(vehiculo.Fecha_contrato_inicio_e_garantia__c.Year(),vehiculo.Fecha_contrato_inicio_e_garantia__c.Month(), vehiculo.Fecha_contrato_inicio_e_garantia__c.Day());
        			response.showExtGarantia = true;
 
        
                }
                else {
                    response.showExtGarantia = false;
                }
                response.kmsContratados = vehiculo.Kms_contrato_prestacion__c;
                response.PRNumber = vehiculo.PR_Number__c;
            }
            else {
                response.respuesta = false;
            }
        }
        else {
            response.respuesta = false;
        }
        String responseJson = JSON.serialize(response);
        return responseJson;
   }  
    
    public class responseGuarantee{
        public boolean respuesta {get;set;}
        public boolean showCardGarantia {get;set;}
        public boolean showGarantia {get;set;}
        public boolean showExtGarantia {get;set;}
        public boolean showGarantiaVO {get;set;}
        public date FechaContratoFin {get;set;}
        public date FechaContratoInicio{get;set;}
        public date FechaFinGarantia {get;set;}
        public date FechaInicioGarantia {get;set;}
        public date FechaInicioGarantiaVO {get;set;}
        public date FechaFinGarantiaVO {get;set;}
        public double kmsContratados {get;set;}
        public String PRNumber {get;set;}
        
    }
}