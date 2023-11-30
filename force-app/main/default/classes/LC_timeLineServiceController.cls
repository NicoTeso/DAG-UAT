public class LC_timeLineServiceController {
    
     @AuraEnabled
    public static String getServices(String recordId, Date fechaIni, Date fechaEnd){
        String respuesta;
        LC_timeLineServiceController.Response response = new LC_timeLineServiceController.Response() ;
        Map<String, String> ResponseMap = new Map<String,String>();
        fechaIni = fechaIni != null? fechaIni : Date.today().addYears(-2);
        fechaEnd = fechaEnd != null? fechaEnd : Date.today().addYears(1);
        Pase_de_taller__c pTaller;
        Pase_de_taller__c pTallerCita;
        Pase_de_taller__c pTallerEnTaller;
        Planificacion_Servicio__c pServicio;
        Vehiculo__c vehiculo;
        List<ActivityServiceTimeLineModel> services = new List<ActivityServiceTimeLineModel>();
        if(!String.isBlank(recordId)){
            List<Vehiculo__c> vehiculos = [SELECT Id,Name,Concesionario__c,Propietario__c, Propietario__r.PersonContactId,MarcaString__c,VIN__c,Comprador__c,ModeloString__c,modelDescription__c,Combustible__c,Letra_Motor__c,kms__c,kms_diarios__c,Fecha_actualizacion_kms__c,
                        					Fecha_primera_matriculacion__c,Fecha_fin_extension_garantia__c,Fecha_fin_garantia__c,Fecha_fin_garantia_VO__c,Transmision__c,Cilindrada__c,Homologacion__c,Caja_de_cambios__c,Ano_Modelo__c,Concesionario_Taller__c,
                        					Centro__c,Centro_Taller__c,Fecha_fin_regalo__c,Fecha_comunicacion_regalo__c,Tipo_de_venta__c, Estimacion_actual_kms__c, Edad__c, Depositario__c, Depositario__r.PersonContactId
                        					FROM Vehiculo__c WHERE Id = :recordId];
            if(!vehiculos.isEmpty()){
                vehiculo = vehiculos[0];
                system.debug('vehiculo:'+ vehiculo);
           
                List<Pase_de_taller__c> pasesTaller = new List<Pase_de_taller__c>([ 
                    SELECT  Id, Name, Estado__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c,Concesionario__r.Name, Centro__c, workshopOrderId__c, creationDate__c, deliveryDate__c, 
                    		Vehiculo__c, customerDepositary__c, customer__c, customerOwner__c, customerAmount__c, insuranceAmount__c, internalAmount__c, warrantyAmount__c, deferenceAmount__c,
                    		campaignAmount__c, currencyType__c, workshopCode__c, workshopDescription__c, kms__c, receptionDate__c,Edad_Vehiculo__c, serviceAdviser__c, serviceAdviser__r.Name,
                    		appointmentDate__c
                    FROM Pase_de_taller__c 
                    WHERE Vehiculo__c = :vehiculo.Id AND Estado__c IN ('Cita abierta','Vehículo en taller','Vehículo entregado') 
                    ORDER BY deliveryDate__c DESC
                ]);
                system.debug('pasesTaller: ' + pasesTaller.size() + ' - ' + json.serialize(pasesTaller));
                if(!pasesTaller.isEmpty()){
                    
                    if(pasesTaller[0].Estado__c == 'Cita abierta'){pTallerCita = pasesTaller[0];}
                    if(pasesTaller[0].Estado__c == 'Vehículo en taller'){pTallerEnTaller = pasesTaller[0];}
                    
                    //pTaller = pasesTaller[0];
                    for(Pase_de_taller__c pase : pasesTaller){
                        if(pase.Estado__c == 'Vehículo entregado'){
                            pTaller = pase; 
                            break;
                        }
                    }
                    
                    system.debug('pTaller: '+ pTaller);
                    system.debug('pTallerCita: '+ pTallerCita);
                    system.debug('pTallerEnTaller: '+ pTallerEnTaller);
                    List<Servicio_Target__c> serviciosRealizados = [select id, Pase_de_taller__c, Pase_de_taller__r.deliveryDate__c, Pase_de_taller__r.Edad_Vehiculo__c,Name, Codigo_Grupo__c, Pase_de_taller__r.kms__c, Es_target__c
                                                                    FROM Servicio_Target__c 
                                                                    where Pase_de_taller__r.Vehiculo__c = :vehiculo.Id AND Pase_de_taller__r.deliveryDate__c != null AND Pase_de_taller__r.deliveryDate__c>=:fechaIni  AND Es_target__c = true
                                                                    order by Pase_de_taller__r.deliveryDate__c asc];
                    for(Servicio_Target__c servicio : serviciosRealizados){
                    	ActivityServiceTimeLineModel serviceAux = new ActivityServiceTimeLineModel();
                    	serviceAux.name = servicio.Name;
                    	serviceAux.Kms = servicio.Pase_de_taller__r.kms__c;
                    	serviceAux.RecordId = servicio.Pase_de_taller__c;
                    	serviceAux.edad = servicio.Pase_de_taller__r.Edad_Vehiculo__c;
                        serviceAux.propietario = vehiculo.Propietario__r.PersonContactId;
                        serviceAux.depositario = vehiculo.Depositario__r.PersonContactId;
                    	if(servicio.Pase_de_taller__r.deliveryDate__c != null){
                    	    Datetime dT = servicio.Pase_de_taller__r.deliveryDate__c;
                    		serviceAux.fecha = Date.newinstance(dT.year(), dT.month(), dT.day());
                    	}
                    	serviceAux.tiempo ='Before';
                    	services.add(serviceAux);
                	}
                    
                    //Ultimo pase taller
                    if(pTaller != null){
                        List<Servicio__c> servicios = ServicioGateway.getServiciosByPaseTallerId(pTaller.Id);
                        ActivityServiceTimeLineModel serviceLastPD = new ActivityServiceTimeLineModel();
                        serviceLastPD.RecordId=pTaller.Id;
                       
                        serviceLastPD.name =!String.isBlank(pTaller.serviceAdviser__r.Name)?'Último pase de taller - ' + pTaller.serviceAdviser__r.Name:'Último pase de taller' ;
                        serviceLastPD.estado = pTaller.Estado__c;
                        serviceLastPD.kms = pTaller.kms__c;
                        serviceLastPD.fecha = Date.newInstance(pTaller.deliveryDate__c.year(), pTaller.deliveryDate__c.month(), pTaller.deliveryDate__c.day());
                        serviceLastPD.edad = pTaller.Edad_Vehiculo__c;
                        serviceLastPD.tiempo ='LastPT';
                        serviceLastPD.concesionario = pTaller.Concesionario__r.Id_Concesionario_Sima__c;
                        serviceLastPD.concesionarioName = pTaller.Concesionario__r.Name;
                        serviceLastPD.taller = pTaller.workshopDescription__c;
                        serviceLastPD.propietario = vehiculo.Propietario__r.PersonContactId;
                        serviceLastPD.depositario = vehiculo.Depositario__r.PersonContactId;
                        serviceLastPD.detalleServicios = new List<ActivityServiceTimeLineModel.ServiceDetail>();
                        for (Servicio__c servicio :servicios){
                            ActivityServiceTimeLineModel.ServiceDetail dServicio = new ActivityServiceTimeLineModel.ServiceDetail();
                            dServicio.tipoServicio = servicio.serviceType__c;
                            List<String> pGroups =servicio.partGroups__c!=null? servicio.partGroups__c.split(';'):new List<String>();
                            dServicio.servicios = pGroups;
                            serviceLastPD.detalleServicios.add(dServicio);
                        }
                        services.add(serviceLastPD);
                    }
                    
                    //Cita abierta taller
                    if(pTallerCita != null){
                        List<Servicio__c> servicios = ServicioGateway.getServiciosByPaseTallerId(pTallerCita.Id);
                        ActivityServiceTimeLineModel serviceCitaAbierta = new ActivityServiceTimeLineModel();
                        serviceCitaAbierta.RecordId=pTallerCita.Id;
                       
                        serviceCitaAbierta.name =!String.isBlank(pTallerCita.serviceAdviser__r.Name)?'Cita Abierta - ' + pTallerCita.serviceAdviser__r.Name:'Cita Abierta' ;
                        serviceCitaAbierta.estado = pTallerCita.Estado__c;
                        serviceCitaAbierta.kms = pTallerCita.kms__c;
                        serviceCitaAbierta.fecha = Date.newInstance(pTallerCita.appointmentDate__c.year(), pTallerCita.appointmentDate__c.month(), pTallerCita.appointmentDate__c.day());
                        serviceCitaAbierta.edad = pTallerCita.Edad_Vehiculo__c;
                        serviceCitaAbierta.tiempo ='LastPT';
                        serviceCitaAbierta.concesionario = pTallerCita.Concesionario__r.Id_Concesionario_Sima__c;
                        serviceCitaAbierta.concesionarioName = pTallerCita.Concesionario__r.Name;
                        serviceCitaAbierta.taller = pTallerCita.workshopDescription__c;
                        serviceCitaAbierta.propietario = vehiculo.Propietario__r.PersonContactId;
                        serviceCitaAbierta.depositario = vehiculo.Depositario__r.PersonContactId;
                        serviceCitaAbierta.detalleServicios = new List<ActivityServiceTimeLineModel.ServiceDetail>();
                        for (Servicio__c servicio :servicios){
                            ActivityServiceTimeLineModel.ServiceDetail dServicio = new ActivityServiceTimeLineModel.ServiceDetail();
                            dServicio.tipoServicio = servicio.serviceType__c;
                            List<String> pGroups =servicio.partGroups__c!=null? servicio.partGroups__c.split(';'):new List<String>();
                            dServicio.servicios = pGroups;
                            serviceCitaAbierta.detalleServicios.add(dServicio);
                        }
                        services.add(serviceCitaAbierta);
                    }
                    
                    //Vehiculo en taller
                    if(pTallerEnTaller != null){
                        List<Servicio__c> servicios = ServicioGateway.getServiciosByPaseTallerId(pTallerEnTaller.Id);
                        ActivityServiceTimeLineModel serviceEnTaller = new ActivityServiceTimeLineModel();
                        serviceEnTaller.RecordId=pTallerEnTaller.Id;
                       
                        serviceEnTaller.name =!String.isBlank(pTallerEnTaller.serviceAdviser__r.Name)?'Vehículo en taller - ' + pTallerEnTaller.serviceAdviser__r.Name:'Vehículo taller' ;
                        serviceEnTaller.estado = pTallerEnTaller.Estado__c;
                        serviceEnTaller.kms = pTallerEnTaller.kms__c;
                        serviceEnTaller.fecha = Date.newInstance(pTallerEnTaller.receptionDate__c.year(), pTallerEnTaller.receptionDate__c.month(), pTallerEnTaller.receptionDate__c.day());
                        serviceEnTaller.edad = pTallerEnTaller.Edad_Vehiculo__c;
                        serviceEnTaller.tiempo ='LastPT';
                        serviceEnTaller.concesionario = pTallerEnTaller.Concesionario__r.Id_Concesionario_Sima__c;
                        serviceEnTaller.concesionarioName = pTallerEnTaller.Concesionario__r.Name;
                        serviceEnTaller.taller = pTallerEnTaller.workshopDescription__c;
                        serviceEnTaller.propietario = vehiculo.Propietario__r.PersonContactId;
                        serviceEnTaller.depositario = vehiculo.Depositario__r.PersonContactId;
                        serviceEnTaller.detalleServicios = new List<ActivityServiceTimeLineModel.ServiceDetail>();
                        for (Servicio__c servicio :servicios){
                            ActivityServiceTimeLineModel.ServiceDetail dServicio = new ActivityServiceTimeLineModel.ServiceDetail();
                            dServicio.tipoServicio = servicio.serviceType__c;
                            List<String> pGroups =servicio.partGroups__c!=null? servicio.partGroups__c.split(';'):new List<String>();
                            dServicio.servicios = pGroups;
                            serviceEnTaller.detalleServicios.add(dServicio);
                        }
                        services.add(serviceEnTaller);
                    }
               	}
                
                ActivityServiceTimeLineModel serviceNow = new ActivityServiceTimeLineModel();
                Boolean putServiceNow = false;
                serviceNow.RecordId = vehiculo.Id;
                serviceNow.name = 'Ahora';
                serviceNow.kms = vehiculo.Estimacion_actual_kms__c;
                serviceNow.fecha = Date.today();
                serviceNow.edad = vehiculo.Edad__c;
                serviceNow.tiempo ='Now';
                serviceNow.propietario = vehiculo.Propietario__r.PersonContactId;
                serviceNow.depositario = vehiculo.Depositario__r.PersonContactId;
                List<String> estadosAbiertos = new List<String>{'Sin asignar', 'Asignado'};
                Date hoyMenos1 = Date.today().addYears(-1);
                List<Planificacion_Servicio__c> pSeriviciosFuturo = [Select id, Vehiculo__c, Fecha_Mantenimiento__c, Name, Edad_Vehiculo__c,Estado__c, Motivo_de_cierre__c, Owner.Name,
                                        							Fecha_Aviso_SMS__c, Fecha_Aviso_Email__c , Fecha_Aviso_Llamada__c,
                                        							Enviado_SMS__c, Enviado_Email__c, Numero_de_llamadas__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c, FourthCallDate__c, FifthCallDate__c,Precio__c, Comentario__c, Precio_comunicado__c, Categoria__c
                                        							From Planificacion_Servicio__c 
                                                                    where Fecha_Mantenimiento__c>=:hoyMenos1  and Fecha_Mantenimiento__c<=:fechaEnd and Vehiculo__c=:vehiculo.Id and Estado__c in : estadosAbiertos order by Fecha_Mantenimiento__c  asc  ];
                for(Planificacion_Servicio__c PS : pSeriviciosFuturo){
                    ActivityServiceTimeLineModel serviceAux = new ActivityServiceTimeLineModel();
                	serviceAux.RecordId = PS.Id;
                	serviceAux.name = PS.Name;
                	serviceAux.fecha = PS.Fecha_Mantenimiento__c;
                	serviceAux.edad = PS.Edad_Vehiculo__c;
                    serviceAux.asignado = PS.Owner.Name;
                	serviceAux.tiempo ='After';
                    serviceAux.precio = PS.Precio__c;
                    serviceAux.propietario = vehiculo.Propietario__r.PersonContactId;
                    serviceAux.depositario = vehiculo.Depositario__r.PersonContactId;
                    
                    serviceAux.fechaAvisoEmail = PS.Fecha_Aviso_Email__c != null ? PS.Fecha_Aviso_Email__c : null;
                    serviceAux.fechaEmail = PS.Enviado_Email__c != null ? Date.newInstance(PS.Enviado_Email__c.Year(), PS.Enviado_Email__c.Month(), PS.Enviado_Email__c.Day()) : null;
                    serviceAux.fechaAvisoSMS = PS.Fecha_Aviso_SMS__c != null ? PS.Fecha_Aviso_Email__c : null;
                    serviceAux.fechaSMS = PS.Enviado_SMS__c != null ? Date.newInstance(PS.Enviado_SMS__c.Year(), PS.Enviado_SMS__c.Month(), PS.Enviado_SMS__c.Day()) : null;
                        
                    serviceAux.fechaAvisoLlamada = PS.Fecha_Aviso_Llamada__c != null ? PS.Fecha_Aviso_Llamada__c : null;
                    serviceAux.intentos = PS.Numero_de_llamadas__c != null ? Integer.valueOf(PS.Numero_de_llamadas__c): 0;
                    serviceAux.comentario = PS.Comentario__c;
                    serviceAux.precioComunicado = PS.Precio_comunicado__c;
                    If (PS.Categoria__c == '1') {
                        serviceAux.categoria = true;
                    } else {
                        serviceAux.categoria = false;
                    }
                    If (PS.Fecha_Mantenimiento__c < Date.today()) {
                        serviceAux.vencido = true;
                    } else {
                        serviceAux.vencido = false;
                    }
                    switch on serviceAux.intentos {
                    	when 1 {
                        	serviceAux.fechaLlamada = PS.FirstCallDate__c != null ? Date.newInstance(PS.FirstCallDate__c.Year(), PS.FirstCallDate__c.Month(), PS.FirstCallDate__c.Day()) : null;
                        }
                        when 2 {
                          	serviceAux.fechaLlamada = PS.SecondCallDate__c != null ? Date.newInstance(PS.SecondCallDate__c.Year(), PS.SecondCallDate__c.Month(), PS.SecondCallDate__c.Day()) : null;
                        }
                        when 3 {
                        	serviceAux.fechaLlamada = PS.ThirdCallDate__c != null ? Date.newInstance(PS.ThirdCallDate__c.Year(), PS.ThirdCallDate__c.Month(), PS.ThirdCallDate__c.Day()) : null;
                        }
                        when 4 {
                     		serviceAux.fechaLlamada = PS.FourthCallDate__c != null ? Date.newInstance(PS.FourthCallDate__c.Year(), PS.FourthCallDate__c.Month(), PS.FourthCallDate__c.Day()) : null; 
                        }
                        when 5 {
                        	serviceAux.fechaLlamada = PS.FifthCallDate__c != null ? Date.newInstance(PS.FifthCallDate__c.Year(), PS.FifthCallDate__c.Month(), PS.FifthCallDate__c.Day()) : null;
                        }
                        when else {
                        	serviceAux.fechaLlamada = null;
                        }
                   	}
                    serviceAux.estado = PS.Estado__c;
                    if(serviceAux.fecha > serviceNow.fecha && !putServiceNow ){
                        Services.add(serviceNow);
                        Services.add(serviceAux);
                        putServiceNow = true;
                    }
                    else{
                       Services.add(serviceAux);
               		}
            	}
                if(!putServiceNow){
                	services.add(serviceNow);
                    putServiceNow=true;
                }
           	}  
        }
            
        response.Services = services;
        //response.ServiceNow = serviceNow;
        //response.ServiceAfter = serviceAfter;
        ResponseMap.put('Respuesta', 'OK');
        ResponseMap.put('DateInit', JSON.serialize(fechaIni));
        ResponseMap.put('DateEnd', JSON.serialize(fechaEnd));
        ResponseMap.put('Servicios', JSON.serialize(response) );
        
        respuesta = JSON.serialize(ResponseMap);
        return respuesta;
    }
    
    @AuraEnabled
    public static Boolean autoAsignarService(String recordId){
        Boolean response;
        if(!String.isBlank(recordId)){
            Planificacion_Servicio__c pServicio = new Planificacion_Servicio__c();
        	pServicio.Id=recordId;
        	pServicio.OwnerId = UserInfo.getUserId();
        	pServicio.Estado__c ='Asignado';
        	try{
        		upsert pServicio;
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
    
    public class Response {
        public List<ActivityServiceTimeLineModel>  Services {get;set;}
    }
}