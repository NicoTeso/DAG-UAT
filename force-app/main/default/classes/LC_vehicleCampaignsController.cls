public class LC_vehicleCampaignsController {

    @AuraEnabled
    public static String getCampaignsByVehicle(String recordId){
        List<LC_vehicleCampaignsController.vehicleCampaign> response = new List<LC_vehicleCampaignsController.vehicleCampaign>();
        if(!String.isBlank(recordId)){
            List<Campania_Vehiculo__c> campanias = [Select Id, Name, LastModifiedDate, Vehiculo__c, Codigo__c, Tipo__c, Descripcion__c, Concesionario__c, Owner.Name,
                         							Centro__c, Tipo_de_venta__c, Enviado_Email__c, Enviado_SMS__c, Estado__c, Fecha_Aviso_Email__c, Fecha_Aviso_Llamada__c,
                         							Fecha_Aviso_SMS__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, FourthCallDate__c, FifthCallDate__c, Motivo_de_cierre__c,
                         							Numero_de_llamadas__c, Orden_SIMA__c, Submotivo_de_cierre__c, Vehiculo__r.Propietario__r.PersonContactId, Vehiculo__r.Depositario__r.PersonContactId, Comentario__c
                         							From Campania_Vehiculo__c where Vehiculo__c = :recordId  and Estado__c !='Cerrado' and Estado__c !='No aplica' ];
            for(Campania_Vehiculo__c campania : campanias){
                vehicleCampaign vehCam = new vehicleCampaign();
                vehCam.Id = campania.Id;
                vehCam.Link = '/' + campania.Id;
                vehCam.Name = campania.Name;
                vehCam.Codigo = campania.Codigo__c;
                vehCam.Tipo = campania.Tipo__c;
                vehCam.Descripcion = campania.Descripcion__c;
                vehCam.fechaAvisoEmail = campania.Fecha_Aviso_Email__c != null ? campania.Fecha_Aviso_Email__c : null;
                vehCam.fechaEmail = campania.Enviado_Email__c != null ? Date.newInstance(campania.Enviado_Email__c.Year(), campania.Enviado_Email__c.Month(), campania.Enviado_Email__c.Day()) : null;
                vehCam.fechaAvisoSMS = campania.Fecha_Aviso_SMS__c != null ? campania.Fecha_Aviso_Email__c : null;
                vehCam.fechaSMS = campania.Enviado_SMS__c != null ? Date.newInstance(campania.Enviado_SMS__c.Year(), campania.Enviado_SMS__c.Month(), campania.Enviado_SMS__c.Day()) : null;
                vehCam.fechaAvisoLlamada = campania.Fecha_Aviso_Llamada__c != null ? campania.Fecha_Aviso_Llamada__c : null;
        		vehCam.intentos = !String.isBlank(campania.Numero_de_llamadas__c)? Integer.valueOf(campania.Numero_de_llamadas__c):0;
    			vehCam.estado = campania.Estado__c;
                vehCam.asignado = campania.Owner.Name;
                vehCam.propietario = campania.Vehiculo__r.Depositario__r.PersonContactId;
                vehCam.depositario = campania.Vehiculo__r.Propietario__r.PersonContactId;
                vehCam.comentario = campania.Comentario__c;
                switch on campania.Numero_de_llamadas__c {
                    	when '1' {
                        	vehCam.fechaLlamada = campania.FirstCallDate__c != null ? Date.newInstance(campania.FirstCallDate__c.Year(), campania.FirstCallDate__c.Month(), campania.FirstCallDate__c.Day()) : null;
                        }
                        when '2' {
                          	vehCam.fechaLlamada = campania.SecondCallDate__c != null ? Date.newInstance(campania.SecondCallDate__c.Year(), campania.SecondCallDate__c.Month(), campania.SecondCallDate__c.Day()) : null;
                        }
                        when '3' {
                        	vehCam.fechaLlamada = campania.ThirdCallDate__c != null ? Date.newInstance(campania.ThirdCallDate__c.Year(), campania.ThirdCallDate__c.Month(), campania.ThirdCallDate__c.Day()) : null;
                        }
                        when '4' {
                     		vehCam.fechaLlamada = campania.FourthCallDate__c != null ? Date.newInstance(campania.FourthCallDate__c.Year(), campania.FourthCallDate__c.Month(), campania.FourthCallDate__c.Day()) : null; 
                        }
                        when '5' {
                        	vehCam.fechaLlamada = campania.FifthCallDate__c != null ? Date.newInstance(campania.FifthCallDate__c.Year(), campania.FifthCallDate__c.Month(), campania.FifthCallDate__c.Day()) : null;
                        }
                        when else {
                        	vehCam.fechaLlamada = null;
                        }
                   	}
                response.add(vehCam);
            }
        }
        return JSON.serialize(response);
    }
    
     @AuraEnabled
    public static Boolean autoAsignarCampaign(String recordId){
        Boolean response;
        if(!String.isBlank(recordId)){
            Campania_Vehiculo__c campaignVeh = new Campania_Vehiculo__c();
        	campaignVeh.Id=recordId;
        	campaignVeh.OwnerId = UserInfo.getUserId();
        	campaignVeh.Estado__c ='Asignado';
        	try{
        		upsert campaignVeh;
        	    system.debug('actualizado');
                response = true;
        	}catch(Exception e){
        	    system.debug('excepcion:'+ e.getMessage() + 'Linea: '+ e.getLineNumber());
                response = false;
        	}
        
        }
        return response;
        
    }
    
    @AuraEnabled
    public static Boolean insertaTarea(String  tareaJson){
        Task tarea = (Task)	JSON.deserialize(tareaJson, Task.class);
        tarea.IsReminderSet = true;
        system.debug('tarea:'+ tarea);
        insert tarea;
        return true;
    }
   
    @AuraEnabled
    public static String getListClosedCampaigns(String recordId) {
        LC_vehicleCampaignsController.Response response = new LC_vehicleCampaignsController.Response();
        List<LC_vehicleCampaignsController.vehicleCampaign> listCampanias = new List<LC_vehicleCampaignsController.vehicleCampaign>();
        
        if (!String.isBlank(recordId)){
            List<Campania_Vehiculo__c> campanias = [Select Id, Name, LastModifiedDate, Vehiculo__c, Codigo__c, Tipo__c, Descripcion__c, Concesionario__c, Owner.Name,
                         							Centro__c, Tipo_de_venta__c, Enviado_Email__c, Enviado_SMS__c, Estado__c, Fecha_Aviso_Email__c, Fecha_Aviso_Llamada__c,
                         							Fecha_Aviso_SMS__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, FourthCallDate__c, FifthCallDate__c, Motivo_de_cierre__c,
                         							Numero_de_llamadas__c, Orden_SIMA__c, Submotivo_de_cierre__c, Vehiculo__r.Propietario__r.PersonContactId, Vehiculo__r.Depositario__r.PersonContactId, Comentario__c
                         							From Campania_Vehiculo__c where Vehiculo__c = :recordId and (Estado__c ='Cerrado' OR Estado__c ='No aplica')  order by  LastModifiedDate  desc ]; 
           
            for(Integer i = 0; i<campanias.size() && i<10;i++){
                vehicleCampaign vehCam = new vehicleCampaign();
                Campania_Vehiculo__c campania = campanias[i];
                vehCam.Id = campania.Id;
                vehCam.Link = '/' + campania.Id;
                vehCam.Name = campania.Name;
                vehCam.Codigo = campania.Codigo__c;
                vehCam.Tipo = campania.Tipo__c;
                vehCam.Descripcion = campania.Descripcion__c;
                vehCam.fechaAvisoEmail = campania.Fecha_Aviso_Email__c != null ? campania.Fecha_Aviso_Email__c : null;
                vehCam.fechaEmail = campania.Enviado_Email__c != null ? Date.newInstance(campania.Enviado_Email__c.Year(), campania.Enviado_Email__c.Month(), campania.Enviado_Email__c.Day()) : null;
                vehCam.fechaAvisoSMS = campania.Fecha_Aviso_SMS__c != null ? campania.Fecha_Aviso_Email__c : null;
                vehCam.fechaSMS = campania.Enviado_SMS__c != null ? Date.newInstance(campania.Enviado_SMS__c.Year(), campania.Enviado_SMS__c.Month(), campania.Enviado_SMS__c.Day()) : null;
                vehCam.fechaAvisoLlamada = campania.Fecha_Aviso_Llamada__c != null ? campania.Fecha_Aviso_Llamada__c : null;
        		vehCam.intentos = !String.isBlank(campania.Numero_de_llamadas__c)? Integer.valueOf(campania.Numero_de_llamadas__c):0;
    			vehCam.estado = campania.Estado__c;
                vehCam.asignado = campania.Owner.Name;
                vehCam.propietario = campania.Vehiculo__r.Depositario__r.PersonContactId;
                vehCam.depositario = campania.Vehiculo__r.Propietario__r.PersonContactId;
                vehCam.motivo = campania.Motivo_de_cierre__c;
                vehCam.submotivo = campania.Submotivo_de_cierre__c;
                vehCam.comentario = campania.Comentario__c;
                switch on campania.Numero_de_llamadas__c {
                    	when '1' {
                        	vehCam.fechaLlamada = campania.FirstCallDate__c != null ? Date.newInstance(campania.FirstCallDate__c.Year(), campania.FirstCallDate__c.Month(), campania.FirstCallDate__c.Day()) : null;
                        }
                        when '2' {
                          	vehCam.fechaLlamada = campania.SecondCallDate__c != null ? Date.newInstance(campania.SecondCallDate__c.Year(), campania.SecondCallDate__c.Month(), campania.SecondCallDate__c.Day()) : null;
                        }
                        when '3' {
                        	vehCam.fechaLlamada = campania.ThirdCallDate__c != null ? Date.newInstance(campania.ThirdCallDate__c.Year(), campania.ThirdCallDate__c.Month(), campania.ThirdCallDate__c.Day()) : null;
                        }
                        when '4' {
                     		vehCam.fechaLlamada = campania.FourthCallDate__c != null ? Date.newInstance(campania.FourthCallDate__c.Year(), campania.FourthCallDate__c.Month(), campania.FourthCallDate__c.Day()) : null; 
                        }
                        when '5' {
                        	vehCam.fechaLlamada = campania.FifthCallDate__c != null ? Date.newInstance(campania.FifthCallDate__c.Year(), campania.FifthCallDate__c.Month(), campania.FifthCallDate__c.Day()) : null;
                        }
                        when else {
                        	vehCam.fechaLlamada = null;
                        }
                   	}
                listCampanias.add(vehCam);
            }
            response.campanias = listCampanias;
            response.respuesta =  'OK';
            response.finalCount = campanias.size();
            response.count = 10 <= response.finalCount ? 10 :response.finalCount;
            
        }
        String JSONServicio = JSON.serialize(response);
        return JSONServicio;
       
	}
    @AuraEnabled
    public static String loadMoreCampaigns(String recordId, Integer intOffSet){
      	LC_vehicleCampaignsController.Response response = new LC_vehicleCampaignsController.Response();
        List<LC_vehicleCampaignsController.vehicleCampaign> listCampanias = new List<LC_vehicleCampaignsController.vehicleCampaign>();
        
         
        if(!String.isBlank(recordId)){
            List<Campania_Vehiculo__c> campanias = [Select Id, Name, LastModifiedDate, Vehiculo__c, Codigo__c, Tipo__c, Descripcion__c, Concesionario__c, Owner.Name,
                         							Centro__c, Tipo_de_venta__c, Enviado_Email__c, Enviado_SMS__c, Estado__c, Fecha_Aviso_Email__c, Fecha_Aviso_Llamada__c,
                         							Fecha_Aviso_SMS__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, FourthCallDate__c, FifthCallDate__c, Motivo_de_cierre__c,
                         							Numero_de_llamadas__c, Orden_SIMA__c, Submotivo_de_cierre__c, Vehiculo__r.Propietario__r.PersonContactId, Vehiculo__r.Depositario__r.PersonContactId, Comentario__c
                         							From Campania_Vehiculo__c where Vehiculo__c = :recordId and (Estado__c ='Cerrado' or Estado__c ='No aplica') order by  LastModifiedDate  desc Limit 10 OFFSET : Integer.valueOf(intOffSet) ];  
           
             for(Integer i = 0; i<campanias.size();i++){
                vehicleCampaign vehCam = new vehicleCampaign();
                Campania_Vehiculo__c campania = campanias[i];
                vehCam.Id = campania.Id;
                vehCam.Link = '/'+campania.Id;
                vehCam.Name = campania.Name;
                vehCam.Codigo = campania.Codigo__c;
                vehCam.Tipo = campania.Tipo__c;
                vehCam.Descripcion = campania.Descripcion__c;
                vehCam.fechaAvisoEmail = campania.Fecha_Aviso_Email__c != null ? campania.Fecha_Aviso_Email__c : null;
                vehCam.fechaEmail = campania.Enviado_Email__c != null ? Date.newInstance(campania.Enviado_Email__c.Year(), campania.Enviado_Email__c.Month(), campania.Enviado_Email__c.Day()) : null;
                vehCam.fechaAvisoSMS = campania.Fecha_Aviso_SMS__c != null ? campania.Fecha_Aviso_Email__c : null;
                vehCam.fechaSMS = campania.Enviado_SMS__c != null ? Date.newInstance(campania.Enviado_SMS__c.Year(), campania.Enviado_SMS__c.Month(), campania.Enviado_SMS__c.Day()) : null;
                vehCam.fechaAvisoLlamada = campania.Fecha_Aviso_Llamada__c != null ? campania.Fecha_Aviso_Llamada__c : null;
        		vehCam.intentos = !String.isBlank(campania.Numero_de_llamadas__c)? Integer.valueOf(campania.Numero_de_llamadas__c):0;
    			vehCam.estado = campania.Estado__c;
                vehCam.asignado = campania.Owner.Name;
                vehCam.propietario = campania.Vehiculo__r.Depositario__r.PersonContactId;
                vehCam.depositario = campania.Vehiculo__r.Propietario__r.PersonContactId;
                vehCam.motivo = campania.Motivo_de_cierre__c;
                vehCam.submotivo = campania.Submotivo_de_cierre__c;
                vehCam.comentario = campania.Comentario__c;
                switch on campania.Numero_de_llamadas__c {
                    	when '1' {
                        	vehCam.fechaLlamada = campania.FirstCallDate__c != null ? Date.newInstance(campania.FirstCallDate__c.Year(), campania.FirstCallDate__c.Month(), campania.FirstCallDate__c.Day()) : null;
                        }
                        when '2' {
                          	vehCam.fechaLlamada = campania.SecondCallDate__c != null ? Date.newInstance(campania.SecondCallDate__c.Year(), campania.SecondCallDate__c.Month(), campania.SecondCallDate__c.Day()) : null;
                        }
                        when '3' {
                        	vehCam.fechaLlamada = campania.ThirdCallDate__c != null ? Date.newInstance(campania.ThirdCallDate__c.Year(), campania.ThirdCallDate__c.Month(), campania.ThirdCallDate__c.Day()) : null;
                        }
                        when '4' {
                     		vehCam.fechaLlamada = campania.FourthCallDate__c != null ? Date.newInstance(campania.FourthCallDate__c.Year(), campania.FourthCallDate__c.Month(), campania.FourthCallDate__c.Day()) : null; 
                        }
                        when '5' {
                        	vehCam.fechaLlamada = campania.FifthCallDate__c != null ? Date.newInstance(campania.FifthCallDate__c.Year(), campania.FifthCallDate__c.Month(), campania.FifthCallDate__c.Day()) : null;
                        }
                        when else {
                        	vehCam.fechaLlamada = null;
                        }
                   	}
                listCampanias.add(vehCam);
            }
            response.campanias = listCampanias;
            response.respuesta =  'OK';
        }
        String JSONServicio = JSON.serialize(response);
      	return JSONServicio;
    }
   
    public class Response {
        public String respuesta {get;set;}
        public List<LC_vehicleCampaignsController.vehicleCampaign> campanias {get;set;}
        public Double count {get;set;}
        public Double finalCount {get;set;}
    }
    
    public class vehicleCampaign{
        public String Id {get;set;}
        public String Link {get;set;}
        public String Name {get;set;}
        public String Codigo {get;set;}
        public String Tipo {get;set;}
        public String Descripcion {get;set;}
   		public Date fechaAvisoEmail {get;set;}
    	public Date fechaAvisoSMS {get;set;}
   		public Date fechaAvisoLlamada {get;set;}
    	public Date fechaEmail {get;set;}
    	public Date fechaSMS {get;set;}
    	public Date fechaLlamada {get;set;}
    	public Integer intentos {get;set;}
    	public String estado  {get;set;}
    	public String asignado {get;set;}
        public String propietario {get;set;}
        public String depositario {get;set;}
        public String motivo {get;set;}
        public String submotivo {get;set;}
        public String comentario {get;set;}
    
    }
}