public class LC_targetClosedController {
    
    @AuraEnabled
    public static String getListClosedServices(String recordId) {
        LC_targetClosedController.Response response = new LC_targetClosedController.Response();
        List<LC_targetClosedController.Objeto> listServices = new List<LC_targetClosedController.Objeto>();
        
        if (!String.isBlank(recordId)){
            List<Planificacion_Servicio__c> pServicios = [Select id, Vehiculo__c, Fecha_Mantenimiento__c, Name, Edad_Vehiculo__c,Estado__c, Motivo_de_cierre__c, Submotivo_de_cierre__c,
                                        							Fecha_Aviso_SMS__c, Fecha_Aviso_Email__c , Fecha_Aviso_Llamada__c,
                                        							Enviado_SMS__c, Enviado_Email__c, Numero_de_llamadas__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, 
                                                                    FourthCallDate__c, FifthCallDate__c,Precio__c, LastModifiedDate, Comentario__c
                                        							From Planificacion_Servicio__c 
                                                                    where Vehiculo__c=:recordId and (Estado__c ='Cerrado'or Estado__c ='No aplica') order by  LastModifiedDate  desc  ];
           
            for(Integer i = 0; i<pServicios.size() && i<10;i++){
                LC_targetClosedController.Objeto objeto = new LC_targetClosedController.Objeto();
                Planificacion_Servicio__c pServicio = pServicios[i];
                objeto.fMantenimiento = pServicio.Fecha_Mantenimiento__c;
                objeto.Name = pServicio.Name;
                objeto.Id = pServicio.Id;
                objeto.Link = '/' + pServicio.Id;
                objeto.estado = pServicio.Estado__c;
                objeto.motivo = pServicio.Motivo_de_cierre__c;
                objeto.subMotivo = pServicio.Submotivo_de_cierre__c;
                objeto.comentario = pServicio.Comentario__c;
                objeto.intentos = !String.isBlank(pServicio.Numero_de_llamadas__c)? Integer.valueOf(pServicio.Numero_de_llamadas__c):0;
                switch on pServicio.Numero_de_llamadas__c {
                    	when '1' {
                        	objeto.ultLlamada = pServicio.FirstCallDate__c != null ? Date.newInstance(pServicio.FirstCallDate__c.Year(), pServicio.FirstCallDate__c.Month(), pServicio.FirstCallDate__c.Day()) : null;
                        }
                        when '2' {
                          	objeto.ultLlamada = pServicio.SecondCallDate__c != null ? Date.newInstance(pServicio.SecondCallDate__c.Year(), pServicio.SecondCallDate__c.Month(), pServicio.SecondCallDate__c.Day()) : null;
                        }
                        when '3' {
                        	objeto.ultLlamada = pServicio.ThirdCallDate__c != null ? Date.newInstance(pServicio.ThirdCallDate__c.Year(), pServicio.ThirdCallDate__c.Month(), pServicio.ThirdCallDate__c.Day()) : null;
                        }
                        when '4' {
                     		objeto.ultLlamada = pServicio.FourthCallDate__c != null ? Date.newInstance(pServicio.FourthCallDate__c.Year(), pServicio.FourthCallDate__c.Month(), pServicio.FourthCallDate__c.Day()) : null; 
                        }
                        when '5' {
                        	objeto.ultLlamada = pServicio.FifthCallDate__c != null ? Date.newInstance(pServicio.FifthCallDate__c.Year(), pServicio.FifthCallDate__c.Month(), pServicio.FifthCallDate__c.Day()) : null;
                        }
                        when else {
                        	objeto.ultLlamada = null;
                        }
                   	}
                listServices.add(objeto);
            }
            response.servicios = listServices;
            response.respuesta =  'OK';
            response.finalCount = pServicios.size();
            response.count = 10 <= response.finalCount ? 10 :response.finalCount;
            
        }
        String JSONServicio = JSON.serialize(response);
        return JSONServicio;
       
	}
    
    @AuraEnabled
    public static String loadMoreServices(String recordId, Integer intOffSet){
      	LC_targetClosedController.Response response = new LC_targetClosedController.Response();
        List<LC_targetClosedController.Objeto> listServices = new List<LC_targetClosedController.Objeto>();
         
        if(!String.isBlank(recordId)){
            List<Planificacion_Servicio__c> pServicios = [Select id, Vehiculo__c, Fecha_Mantenimiento__c, Name, Edad_Vehiculo__c,Estado__c, Motivo_de_cierre__c, Submotivo_de_cierre__c,
                                        							Fecha_Aviso_SMS__c, Fecha_Aviso_Email__c , Fecha_Aviso_Llamada__c,
                                        							Enviado_SMS__c, Enviado_Email__c, Numero_de_llamadas__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, FourthCallDate__c, FifthCallDate__c,Precio__c, LastModifiedDate, Comentario__c
                                        							From Planificacion_Servicio__c 
                                                                    where Vehiculo__c=:recordId and (Estado__c ='Cerrado'or Estado__c ='No aplica') order by  LastModifiedDate  desc Limit 10 OFFSET : Integer.valueOf(intOffSet)];
           	for(Integer i = 0; i<pServicios.size() && i<10;i++){
            	LC_targetClosedController.Objeto objeto = new LC_targetClosedController.Objeto();
                Planificacion_Servicio__c pServicio = pServicios[i];
                objeto.fMantenimiento = pServicio.Fecha_Mantenimiento__c;
                objeto.Name = pServicio.Name;
                objeto.Id = pServicio.Id;
                objeto.Link = '/' + pServicio.Id;
                objeto.estado = pServicio.Estado__c;
                objeto.motivo = pServicio.Motivo_de_cierre__c;
                objeto.subMotivo = pServicio.Submotivo_de_cierre__c;
                objeto.comentario = pServicio.Comentario__c;
                objeto.intentos = !String.isBlank(pServicio.Numero_de_llamadas__c)? Integer.valueOf(pServicio.Numero_de_llamadas__c):0;
                switch on pServicio.Numero_de_llamadas__c {
                    	when '1' {
                        	objeto.ultLlamada = pServicio.FirstCallDate__c != null ? Date.newInstance(pServicio.FirstCallDate__c.Year(), pServicio.FirstCallDate__c.Month(), pServicio.FirstCallDate__c.Day()) : null;
                        }
                        when '2' {
                          	objeto.ultLlamada = pServicio.SecondCallDate__c != null ? Date.newInstance(pServicio.SecondCallDate__c.Year(), pServicio.SecondCallDate__c.Month(), pServicio.SecondCallDate__c.Day()) : null;
                        }
                        when '3' {
                        	objeto.ultLlamada = pServicio.ThirdCallDate__c != null ? Date.newInstance(pServicio.ThirdCallDate__c.Year(), pServicio.ThirdCallDate__c.Month(), pServicio.ThirdCallDate__c.Day()) : null;
                        }
                        when '4' {
                     		objeto.ultLlamada = pServicio.FourthCallDate__c != null ? Date.newInstance(pServicio.FourthCallDate__c.Year(), pServicio.FourthCallDate__c.Month(), pServicio.FourthCallDate__c.Day()) : null; 
                        }
                        when '5' {
                        	objeto.ultLlamada = pServicio.FifthCallDate__c != null ? Date.newInstance(pServicio.FifthCallDate__c.Year(), pServicio.FifthCallDate__c.Month(), pServicio.FifthCallDate__c.Day()) : null;
                        }
                        when else {
                        	objeto.ultLlamada = null;
                        }
                   	}
                listServices.add(objeto);
            }   
            response.servicios = listServices;
            response.respuesta =  'OK';
        }
        String JSONServicio = JSON.serialize(response);
      	return JSONServicio;
    }
   
    public class Response {
        public String respuesta {get;set;}
        public List<LC_targetClosedController.Objeto> servicios {get;set;}
        public Double count {get;set;}
        public Double finalCount {get;set;}
    }
    public class Objeto {
       public String Id {get;set;}
       public String Link {get;set;}
       public String Name {get;set;}
       public Date fMantenimiento {get;set;}
       public Date ultLlamada {get;set;}
       public String motivo {get;set;}
       public String subMotivo {get;set;}
       public Integer intentos {get;set;}
       public String estado  {get;set;}
       public String comentario {get;set;}
  	}
}