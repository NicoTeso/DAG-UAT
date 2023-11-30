public class LC_showPersonVehicleController {
    
    @AuraEnabled
    public static String getInfoClient(String recordId, String tipo){
        String respuesta;
        LC_showPersonVehicleController.Response response;
        Planificacion_Servicio__c pServicio;
        Vehiculo__c vehiculo;
        Map<String,Consentimientos__c> mapConsentimientoByValue = new Map<String,Consentimientos__c>();
        if(!String.isBlank(recordId)){
             List<Vehiculo__c> vehiculos = [Select Id, Propietario__r.Name, Propietario__c, Propietario__r.Documento__c, Propietario__r.PersonEmail, Propietario__r.Email__c, Propietario__r.Phone, Propietario__r.PersonMobilePhone,Propietario__r.Mobile__c, Propietario__r.RecordType.DeveloperName, Propietario__r.BillingCity, Propietario__r.BillingStreet, Propietario__r.BillingState, Propietario__r.BillingCountry, Propietario__r.BillingPostalCode, Propietario__r.isFichaUnica__c,
            								   Depositario__c, Depositario__r.Name, Depositario__r.Documento__c, Depositario__r.PersonEmail, Depositario__r.Email__c, Depositario__r.Phone, Depositario__r.PersonMobilePhone,Depositario__r.Mobile__c, Depositario__r.RecordType.DeveloperName, Depositario__r.BillingCity, Depositario__r.BillingStreet, Depositario__r.BillingState, Depositario__r.BillingCountry, Depositario__r.BillingPostalCode, Depositario__r.isFichaUnica__c
                                               From Vehiculo__c where Id =: recordId ];
            //List<Planificacion_Servicio__c> pServicios = [Select id, Vehiculo__c from Planificacion_Servicio__c where Id =: recordId];
            //if(!pServicios.isEmpty()){
            //    pServicio = pServicios[0];
            //    List<Vehiculo__c> vehiculos = [Select Id, Propietario__r.Name, Propietario__c, Propietario__r.Documento__c, Propietario__r.PersonEmail, Propietario__r.Email__c, Propietario__r.Phone, Propietario__r.PersonMobilePhone,Propietario__r.RecordType.DeveloperName, Propietario__r.BillingCity, Propietario__r.BillingStreet, Propietario__r.BillingState, Propietario__r.BillingCountry, Propietario__r.BillingPostalCode,
            // 								   Depositario__c, Depositario__r.Name, Depositario__r.Documento__c, Depositario__r.PersonEmail, Depositario__r.Email__c, Depositario__r.Phone, Depositario__r.PersonMobilePhone,Depositario__r.RecordType.DeveloperName, Depositario__r.BillingCity, Depositario__r.BillingStreet, Depositario__r.BillingState, Depositario__r.BillingCountry, Depositario__r.BillingPostalCode
            //                                   From Vehiculo__c where Id =: pServicio.Vehiculo__c ];
            if(!vehiculos.isEmpty()){
                vehiculo = vehiculos[0];
                if((tipo.equalsIgnoreCase('Propietario') || tipo.equalsIgnoreCase('Propietario/Depositario')) && !String.isBlank(vehiculo.Propietario__c)){
                    response = new LC_showPersonVehicleController.Response();
                    response.vehiculos = new List<LC_showPersonVehicleController.vehiculosResponse>();
                    AggregateResult results =[Select count(id) total from Vehiculo__c where Propietario__c = : vehiculo.Propietario__c];
                    response.total = (Integer)results.get('total');
                    List<Vehiculo__c> vehiculoProp = [Select id,Name, MarcaString__c, Propietario__c from Vehiculo__c where Propietario__c = : vehiculo.Propietario__c Limit 5 OFFSET : 0 ];
                    for(Vehiculo__c veh :vehiculoProp){
                    	String marca = !String.isBlank(veh.MarcaString__c)?veh.MarcaString__c.toLowerCase():null;
                		if (marca != null) {
                    		if (marca == 'vw comerciales') {marca = 'vwcomerciales';}
                    		if (marca == 'citroën') {marca = 'citroen';}
                    		if (marca == 'honda motos') {marca = 'hondamotos';}
                    		if (marca == 'man autobus') {marca = 'manautobus';}
                    		if (marca == 'land rover') {marca = 'landrover';}
                    		if (marca == 'alfa romeo') {marca = 'alfaromeo';}
                		}                           
                        LC_showPersonVehicleController.vehiculosResponse vehResponse = new LC_showPersonVehicleController.vehiculosResponse();
                        vehResponse.identificador ='/'+ veh.Id;
                        vehResponse.marca = marca;
                        vehResponse.matricula = veh.Name;
                        response.vehiculos.add(vehResponse);
                    }
                    if('Cliente_Empresa'.equalsIgnoreCase(vehiculo.Propietario__r.RecordType.DeveloperName)){
                        response.email = vehiculo.Propietario__r.Email__c;
                        response.mobilePhone = vehiculo.Propietario__r.Mobile__c;
                        response.tipo = 'Empresa';
                    }
                    else {
                        response.fichaUnica = vehiculo.propietario__r.isFichaUnica__c;
                        mapConsentimientoByValue = ConsentimientosGateway.getConsentimientosValueByAccountIdLabels(vehiculo.Propietario__c);
                        response.email = vehiculo.Propietario__r.PersonEmail;
                        if(!String.isBlank(response.email)){
                        	response.consenemail =mapConsentimientoByValue.containsKey(response.email)?mapConsentimientoByValue.get(response.email).AfterSales__c:'Desconocido';
                            if(Label.ConsentimientoAllow.equalsIgnoreCase(response.consenemail) || 'Permitido'.equalsIgnoreCase(response.consenemail)){
                                response.consenEmailIcon = Label.LabelIconAllow;
                            }
                            else if(Label.ConsentimientosDeny.equalsIgnoreCase(response.consenemail) || 'Denegado'.equalsIgnoreCase(response.consenemail)){
                                response.consenEmailIcon = Label.LabelIconDeny;
                            }
                            else {
                                response.consenEmailIcon = Label.LabelIconUnknown;
                            }
                        }
                        response.mobilePhone = vehiculo.Propietario__r.PersonMobilePhone;
                        if(!String.isBlank(response.mobilePhone)){
                        	response.consenmobilePhone = mapConsentimientoByValue.containsKey(response.mobilePhone)?mapConsentimientoByValue.get(response.mobilePhone).AfterSales__c:'Desconocido';
                       		if(Label.ConsentimientoAllow.equalsIgnoreCase(response.consenmobilePhone) || 'Permitido'.equalsIgnoreCase(response.consenmobilePhone)){
                                response.consenMobilePhoneIcon = Label.LabelIconAllow;
                            }
                            else if(Label.ConsentimientosDeny.equalsIgnoreCase(response.consenmobilePhone) || 'Denegado'.equalsIgnoreCase(response.consenmobilePhone)){
                                response.consenMobilePhoneIcon = Label.LabelIconDeny;
                            }
                            else {
                                response.consenMobilePhoneIcon = Label.LabelIconUnknown;
                            }
                        }
                        if(!String.isBlank(vehiculo.Propietario__r.Phone)){
                        	response.consenphone = mapConsentimientoByValue.containsKey(vehiculo.Propietario__r.Phone)?mapConsentimientoByValue.get(vehiculo.Propietario__r.Phone).AfterSales__c:'Desconocido';
                        	if(Label.ConsentimientoAllow.equalsIgnoreCase(response.consenphone) || 'Permitido'.equalsIgnoreCase(response.consenphone)){
                                response.consenPhoneIcon = Label.LabelIconAllow;
                            }
                            else if(Label.ConsentimientosDeny.equalsIgnoreCase(response.consenphone) || 'Denegado'.equalsIgnoreCase(response.consenphone)){
                                response.consenPhoneIcon = Label.LabelIconDeny;
                            }
                            else {
                                response.consenPhoneIcon = Label.LabelIconUnknown;
                            }
                        }
                        response.tipo ='Persona';
                    }
                    response.documento = vehiculo.Propietario__r.Documento__c;
                    response.identificacion = vehiculo.Propietario__c;
                    response.name = vehiculo.Propietario__r.Name;
                    response.phone = vehiculo.Propietario__r.Phone;
                    response.street =  vehiculo.Propietario__r.BillingStreet;
                    response.city =  vehiculo.Propietario__r.BillingCity;
                    response.province =  vehiculo.Propietario__r.BillingState;
                    response.postCode =  vehiculo.Propietario__r.BillingPostalCode;
                    response.country =  vehiculo.Propietario__r.BillingCountry;
                }
                else if(tipo.equalsIgnoreCase('Depositario') && !String.isBlank(vehiculo.Depositario__c)){
                    response = new LC_showPersonVehicleController.Response();
                    response.vehiculos = new List<LC_showPersonVehicleController.vehiculosResponse>();
                     AggregateResult results =[Select count(id) total from Vehiculo__c where Propietario__c = : vehiculo.Propietario__c];
                    response.total = (Integer)results.get('total');
                    
                    List<Vehiculo__c> vehiculoProp = [Select id,Name, MarcaString__c, Propietario__c from Vehiculo__c where Propietario__c = : vehiculo.Propietario__c LIMIT 5 OFFSET : 0 ];
                    for(Vehiculo__c veh :vehiculoProp){
                    	String marca = !String.isBlank(veh.MarcaString__c)?veh.MarcaString__c.toLowerCase():null;
                		if (marca != null) {
                    		if (marca == 'vw comerciales') {marca = 'vwcomerciales';}
                    		if (marca == 'citroën') {marca = 'citroen';}
                    		if (marca == 'honda motos') {marca = 'hondamotos';}
                    		if (marca == 'man autobus') {marca = 'manautobus';}
                    		if (marca == 'land rover') {marca = 'landrover';}
                    		if (marca == 'alfa romeo') {marca = 'alfaromeo';}
                		}                           
                        LC_showPersonVehicleController.vehiculosResponse vehResponse = new LC_showPersonVehicleController.vehiculosResponse();
                        vehResponse.identificador ='/'+ veh.Id;
                        vehResponse.marca = marca;
                        vehResponse.matricula = veh.Name;
                        response.vehiculos.add(vehResponse);
                    }
                    if('Cliente_Empresa'.equalsIgnoreCase(vehiculo.Depositario__r.RecordType.DeveloperName)){
                        response.email = vehiculo.Depositario__r.Email__c;
                        response.mobilePhone = vehiculo.Depositario__r.Mobile__c;
                        response.tipo = 'Empresa';
                    }
                    else {
                        response.fichaUnica = vehiculo.Depositario__r.isFichaUnica__c;
                        mapConsentimientoByValue = ConsentimientosGateway.getConsentimientosValueByAccountIdLabels(vehiculo.Depositario__c);
                        response.email = vehiculo.Depositario__r.PersonEmail;
                        if(!String.isBlank(response.email)){
                        	response.consenemail = mapConsentimientoByValue.containsKey(response.email)?mapConsentimientoByValue.get(response.email).AfterSales__c:'Desconocido';
                            if(Label.ConsentimientoAllow.equalsIgnoreCase(response.consenemail) || 'Permitido'.equalsIgnoreCase(response.consenemail)){
                                response.consenEmailIcon = Label.LabelIconAllow;
                            }
                            else if(Label.ConsentimientosDeny.equalsIgnoreCase(response.consenemail) || 'Denegado'.equalsIgnoreCase(response.consenemail)){
                                response.consenEmailIcon = Label.LabelIconDeny;
                            }
                            else {
                                response.consenEmailIcon = Label.LabelIconUnknown;
                            }
                        }
                        response.mobilePhone = vehiculo.Depositario__r.PersonMobilePhone;
                        if(!String.isBlank(response.mobilePhone)){
                        	response.consenmobilePhone =mapConsentimientoByValue.containsKey(response.mobilePhone)?mapConsentimientoByValue.get(response.mobilePhone).AfterSales__c:'Desconocido';
                            if(Label.ConsentimientoAllow.equalsIgnoreCase(response.consenmobilePhone) || 'Permitido'.equalsIgnoreCase(response.consenmobilePhone)){
                                response.consenMobilePhoneIcon = Label.LabelIconAllow;
                            }
                            else if(Label.ConsentimientosDeny.equalsIgnoreCase(response.consenmobilePhone) || 'Denegado'.equalsIgnoreCase(response.consenmobilePhone)){
                                response.consenMobilePhoneIcon = Label.LabelIconDeny;
                            }
                            else {
                                response.consenMobilePhoneIcon = Label.LabelIconUnknown;
                            }
                        }
                        if(!String.isBlank(vehiculo.Depositario__r.Phone)){
                        	response.consenphone = mapConsentimientoByValue.containsKey(vehiculo.Propietario__r.Phone)?mapConsentimientoByValue.get(vehiculo.Propietario__r.Phone).AfterSales__c:'Desconocido';
                            if(Label.ConsentimientoAllow.equalsIgnoreCase(response.consenphone) || 'Permitido'.equalsIgnoreCase(response.consenphone)){
                                response.consenPhoneIcon = Label.LabelIconAllow;
                            }
                            else if(Label.ConsentimientosDeny.equalsIgnoreCase(response.consenphone) || 'Denegado'.equalsIgnoreCase(response.consenphone)){
                                response.consenPhoneIcon = Label.LabelIconDeny;
                            }
                            else {
                                response.consenPhoneIcon = Label.LabelIconUnknown;
                            }
                        }
                        response.tipo ='Persona';
                    }
                    response.documento = vehiculo.Depositario__r.Documento__c;
                    response.identificacion = vehiculo.Depositario__c;
                    response.name = vehiculo.Depositario__r.Name;
                    response.phone = vehiculo.Depositario__r.Phone;
                    response.street =  vehiculo.Depositario__r.BillingStreet;
                    response.city =  vehiculo.Depositario__r.BillingCity;
                    response.province =  vehiculo.Depositario__r.BillingState;
                    response.postCode =  vehiculo.Depositario__r.BillingPostalCode;
                    response.country =  vehiculo.Depositario__r.BillingCountry;
               }
            }
        //}
            
        }
        if(response != null){
            respuesta = JSON.serialize(response);
        }
        else {
            respuesta ='KO';
        }
        return respuesta;
    }
    
    @AuraEnabled
    public static String loadMore(String recordId, String tipo, Integer intOffSet){
        system.debug('empieza load More');
        List<Vehiculo__c> vehiculos;
        List<LC_showPersonVehicleController.vehiculosResponse> vehiculosResponse = new List<LC_showPersonVehicleController.vehiculosResponse>();
        if(tipo.equalsIgnoreCase('Propietario')){
        	vehiculos = [Select id,Name, MarcaString__c, Propietario__c from Vehiculo__c where Propietario__c = : recordId limit 5 OFFSET : Integer.valueOf(intOffSet) ];
        }
        else if (tipo.equalsIgnoreCase('Depositario')){
           	vehiculos = [Select id,Name, MarcaString__c, Depositario__c from Vehiculo__c where Depositario__c = : recordId limit 5 OFFSET : Integer.valueOf(intOffSet) ];
        }
        for(Vehiculo__c veh :vehiculos){
        	String marca = !String.isBlank(veh.MarcaString__c)?veh.MarcaString__c.toLowerCase():null;
            if (marca != null) {
            	if (marca == 'vw comerciales') {marca = 'vwcomerciales';}
                if (marca == 'citroën') {marca = 'citroen';}
                if (marca == 'honda motos') {marca = 'hondamotos';}
                if (marca == 'man autobus') {marca = 'manautobus';}
                if (marca == 'land rover') {marca = 'landrover';}
                if (marca == 'alfa romeo') {marca = 'alfaromeo';}
             }                           
             LC_showPersonVehicleController.vehiculosResponse vehResponse = new LC_showPersonVehicleController.vehiculosResponse();
             	vehResponse.identificador ='/'+ veh.Id;
                vehResponse.marca = marca;
                vehResponse.matricula = veh.Name;
                vehiculosResponse.add(vehResponse);
         }
        return JSON.serialize(vehiculosResponse);
        
    }
    
    public class Response {
        public String identificacion {get;set;}
        public String name {get;set;}
        public String documento {get;set;}
        public String email {get;set;}
        public String consenemail{get;set;}
        public String consenEmailIcon{get;set;}
        public String phone {get;set;}
        public String consenphone{get;set;}
        public String consenPhoneIcon{get;set;}
        public String mobilePhone {get;set;}
        public String consenmobilePhone {get;set;}
        public String consenMobilePhoneIcon{get;set;}
        public String tipo {get;set;}
        public Integer total {get;set;}
        public String street {get;set;}
        public String city {get;set;}
        public String province {get;set;}
        public String postCode {get;set;}
        public String country {get;set;}
        public Boolean fichaUnica {get;set;}
        public List<vehiculosResponse> vehiculos {get;set;}
        
    }
    public class vehiculosResponse{
        public String identificador {get;set;}
        public String matricula {get;set;}
        public String marca {get;set;}
    }

}