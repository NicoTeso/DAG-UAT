public class VehiculoGateway {
    
	public static Vehiculo__c getVehicleById(String id) {
        Vehiculo__c vehicle;
        
        if (!String.isBlank(id)) {
            Map<String, Vehiculo__c> mapIdToVehicle = getVehicleById(new List<String>{id});
            
            if (!mapIdToVehicle.isEmpty()) {
                vehicle = mapIdToVehicle.get(id);
            }
        }
        
        return vehicle;
    }
    
    public static Map<String, Vehiculo__c> getVehicleById(List<String> lstId) {
        Map<String, Vehiculo__c> mapIdToVehicle = new Map<String, Vehiculo__c>();
        
        if (!lstId.isEmpty()) {
            List<Vehiculo__c> lstVehicles = [SELECT Id,
												   	Name,
                                             		Concesionario__c,
                                             		Propietario__c,
                                             		MarcaString__c,
												   	VIN__c,
                                             	   	Comprador__c,
                                             		ModeloString__c,
                                             		modelDescription__c,
                                             		Combustible__c,
                                                    Letra_Motor__c,
                                                    kms__c,
                                                    kms_diarios__c,
                                                    Fecha_actualizacion_kms__c,
                                                    Fecha_primera_matriculacion__c,
                                                    Fecha_fin_extension_garantia__c,
                                                    Fecha_fin_garantia__c,
                                                    Fecha_fin_garantia_VO__c,
                                                    Transmision__c,
                                                    Cilindrada__c,
                                                    Homologacion__c,
                                                    Caja_de_cambios__c,
                                                    Ano_Modelo__c,
                                             		Concesionario_Taller__c,
                                             		Centro__c,
                                             		Centro_Taller__c,
                                                    Fecha_fin_regalo__c,
                                                    Fecha_comunicacion_regalo__c,
                                                    Tipo_de_venta__c,
                                                    Fecha_inicio_regalo__c,
                                                    Contrato_modalidad__c
                                     	  	FROM Vehiculo__c
                                    	  	WHERE Id in :lstId
                                    	  	LIMIT 2000];
            
            for (Vehiculo__c vehicle : lstVehicles) {
                mapIdToVehicle.put(vehicle.Id, vehicle);
            }
        }
        
        return mapIdToVehicle;
    }
    
    public static Vehiculo__c getVehicleByVin(String vin) {
        Vehiculo__c vehicle;
        
        if (!String.isBlank(vin)) {
            Map<String, Vehiculo__c> mapVinToVehicle = VehiculoGateway.getVehicleByVin(new List<String>{vin});
            vehicle = mapVinToVehicle.containsKey(vin) ? mapVinToVehicle.get(vin) : null;            
        }
        
        return vehicle;
    }

    public static Map<String, Vehiculo__c> getVehicleByVin(List<String> lstVin) {
        Map<String, Vehiculo__c> mapVinToVehicle = new Map<String, Vehiculo__c>();
        
        if (!lstVin.isEmpty()) {
            for (Vehiculo__c vehicle : [SELECT Id,
                                               Name,
                                               VIN__c,
                                               MarcaString__c,
                                               ModeloString__c,
                                               Propietario__c,
                                               kms__c,
                                               Fecha_inicio_extension_garantia__c,
                                               Fecha_fin_extension_garantia__c,
                                               Fecha_fin_garantia__c,
                                        	   modelDescription__c,
                                        	   Combustible__c,
                                               Fecha_primera_matriculacion__c,
                                               Fecha_actualizacion_kms__c,
                                               Dias_actualizacion_kms__c,
                                               kms_diarios__c,
                                               Fecha_fin_regalo__c,
                                               Fecha_comunicacion_regalo__c, 
                                        	   Depositario__c,
                                               Codigo_de_modelo__c,
                                         	   Version__c,
                                        	   Ano_Modelo__c,
                                        	   Potencia__c,
                                               Cilindrada__c,
                                               Transmision__c, 
                                               Letra_Motor__c, 
                                               Numero_de_Motor__c, 
                                               Codigo_Motor__c,
                                               Fecha_inicio_garantia__c, 
                                               Con_cita_o_en_taller__c,
                                               Fecha_inicio_regalo__c,
                                               Contrato_modalidad__c
                                        FROM Vehiculo__c
                                        WHERE VIN__c in :lstVin
                                        LIMIT 2000]) {
                String vin = vehicle.VIN__c.toUpperCase();
                mapVinToVehicle.put(vin, vehicle);
            }
        }
        
        return mapVinToVehicle;
    }

    public static Vehiculo__c getVehicleByName(String name) {
        Vehiculo__c vehicle;
        
        if (!String.isBlank(name)) {
            Map<String, Vehiculo__c> mapNameToVehicle = VehiculoGateway.getVehicleByName(new List<String>{name});
            vehicle = mapNameToVehicle.containsKey(name) ? mapNameToVehicle.get(name) : null;            
        }
        
        return vehicle;
    }

    public static Map<String, Vehiculo__c> getVehicleByName(List<String> lstName) {
        Map<String, Vehiculo__c> mapNameToVehicle = new Map<String, Vehiculo__c>();
        
        if (!lstName.isEmpty()) {
            for (Vehiculo__c vehicle : [SELECT Id,
                                               Name,
                                               VIN__c,
                                               MarcaString__c,
                                               ModeloString__c,
                                               Propietario__c,
                                               kms__c,
                                               Fecha_inicio_extension_garantia__c,
                                               Fecha_fin_extension_garantia__c,
                                               Fecha_fin_garantia__c,
                                        	   modelDescription__c,
                                        	   Combustible__c,
                                               Fecha_primera_matriculacion__c,
                                               Fecha_actualizacion_kms__c,
                                               Dias_actualizacion_kms__c,
                                               kms_diarios__c,
                                               Fecha_fin_regalo__c,
                                               Fecha_comunicacion_regalo__c, 
                                               Depositario__c,
                                               Codigo_de_modelo__c,
                                         	   Version__c,
                                        	   Ano_Modelo__c,
                                        	   Potencia__c,
                                               Cilindrada__c,
                                               Transmision__c, 
                                               Letra_Motor__c, 
                                               Numero_de_Motor__c, 
                                               Codigo_Motor__c,
                                               Fecha_inicio_garantia__c, 
                                               Con_cita_o_en_taller__c,
                                               Fecha_inicio_regalo__c,
                                               Contrato_modalidad__c
                                        FROM Vehiculo__c
                                        WHERE Name in :lstName OR VIN__c in :lstName 
                                        LIMIT 2000]) {
                mapNameToVehicle.put(vehicle.Name, vehicle);
            }
        }
        
        return mapNameToVehicle;
    }
}