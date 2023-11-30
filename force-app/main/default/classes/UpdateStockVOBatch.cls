global class UpdateStockVOBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        string rtGestionLeadVO = rtMapByDName.get(Label.RtCaseGestionLeadVO).getRecordTypeId();

        return  Database.getQueryLocator([SELECT id, VIN__c, registrationPlate__c, brandVO__c, modelVO__c, Vehiculo_vendido__c, 
                                                 Vehiculo__c, Vehiculo__r.MarcaString__c, Vehiculo__r.ModeloString__c,                                          		 
                                                 Vehiculo_stock_VO_1__c, Vehiculo_stock_VO_2__c, Vehiculo_stock_VO_3__c, 
                                                 baja_de_precio__c, priceInitial__c, 
                                                 Vehiculo_stock_VO_1__r.Activo_stock_VO__c, Vehiculo_stock_VO_2__r.Activo_stock_VO__c, 
                                                 Vehiculo_stock_VO_3__r.Activo_stock_VO__c,
                                          		 Vehiculo_stock_VO_1__r.VIN__c, Vehiculo_stock_VO_2__r.VIN__c, 
                                                 Vehiculo_stock_VO_3__r.VIN__c, EndAdvertisingImpact__c
                                          	FROM CASE 
                                           WHERE RecordTypeId = :rtGestionLeadVO AND 
                                                 Cliente_con_venta_posterior__c = false AND 
                                                 (EndAdvertisingImpact__c > TODAY OR Vehiculo_stock_VO_1__c != null)]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Case> lstCasos) {
        List<Case> listCaseToUpdate =  new List<Case>();
        List<String> listVin =  new List<String>();

        system.debug('lstCasos.size(): '+lstCasos.size());
        for(Case Caso:lstCasos){
            system.debug('caso: '+caso);
            if (caso.VIN__c != null && caso.EndAdvertisingImpact__c > date.today()) {
	            listVin.add(caso.VIN__c);
            }
        }    

        Map<String,Vehiculo__c> MapVehiculosStockVO  = new Map<String,Vehiculo__c>();
        
        for (Vehiculo__c vehicle : [SELECT Id,VIN__c, MarcaString__c, ModeloString__c, Precio__c, Activo_stock_VO__c    
                                      FROM Vehiculo__c
                                     WHERE Activo_stock_VO__c = true OR VIN__c = :listVin
                                    ORDER BY Destacado__c DESC, Novedad__c DESC, Fecha_entrada_stock_VO__c, Precio__c  
                                     LIMIT 2000]) {
             String vin = vehicle.VIN__c.toUpperCase();
             MapVehiculosStockVO.put(vin, vehicle);
        }

        for(Case Caso:lstCasos){
            boolean actualizaCaso = false;
            
            if (caso.EndAdvertisingImpact__c > date.today()) {
                if (!MapVehiculosStockVO.isEmpty()) {
                    boolean buscarRelacionados = false;
                    string MarcaVehiculo;
                    string ModeloVehiculo;
                    
                    if (caso.VIN__c != null && MapVehiculosStockVO.containsKey(caso.VIN__c)){
                        if (caso.Vehiculo__c == null){
                            caso.Vehiculo__c = MapVehiculosStockVO.get(caso.VIN__c).id;
                            MarcaVehiculo = MapVehiculosStockVO.get(caso.VIN__c).MarcaString__c;
                            ModeloVehiculo = MapVehiculosStockVO.get(caso.VIN__c).ModeloString__c;
                            actualizaCaso = true;
                        } else {
                            MarcaVehiculo = caso.Vehiculo__r.MarcaString__c;
                            ModeloVehiculo = caso.Vehiculo__r.ModeloString__c;
                        }
                        if (MapVehiculosStockVO.get(caso.VIN__c).Activo_stock_VO__c) {
                            caso.Vehiculo_vendido__c = false;
                            caso.Vehiculo_stock_VO_1__c = null;
                            caso.Vehiculo_stock_VO_2__c = null;
                            caso.Vehiculo_stock_VO_3__c = null;
                            buscarRelacionados = true;
                            actualizaCaso = true;
                        } else {
                            caso.Vehiculo_vendido__c = true;
                            caso.Vehiculo_stock_VO_1__c = null;
                            caso.Vehiculo_stock_VO_2__c = null;
                            caso.Vehiculo_stock_VO_3__c = null;
                            buscarRelacionados = true;
                            actualizaCaso = true;
                        }
                    } else if (caso.VIN__c != null) {
                        MarcaVehiculo = caso.Vehiculo__r.MarcaString__c;
                        ModeloVehiculo = caso.Vehiculo__r.ModeloString__c;
                        caso.Vehiculo_vendido__c = true;
                        caso.Vehiculo_stock_VO_1__c = null;
                        caso.Vehiculo_stock_VO_2__c = null;
                        caso.Vehiculo_stock_VO_3__c = null;
                        buscarRelacionados = true;
                        actualizaCaso = true;
                    } else if (caso.VIN__c == null) {
                        caso.Vehiculo_stock_VO_1__c = null;
                        caso.Vehiculo_stock_VO_2__c = null;
                        caso.Vehiculo_stock_VO_3__c = null;
                        buscarRelacionados = true;
                        actualizaCaso = true;
                    }
                    
                    if (buscarRelacionados) {
                        // Tenemos tres niveles de relacion
                        // 	1º Coincide marca/Modelo y precio +/- 20%
                        // 	2º Modelos semejantes y precio +/- 20%
                        // 	3º precio +/- 20%
                        
                        RelacionesVO__c RelacionesVO = RelacionesVO__c.getInstance();
                        
                        Decimal ImporteDesde = caso.priceInitial__c != null && caso.priceInitial__c != 0? caso.priceInitial__c - (caso.priceInitial__c * RelacionesVO.Decremento_Precio__c/100) : RelacionesVO.Importe_Desde__c;
                        Decimal ImporteHasta = caso.priceInitial__c != null && caso.priceInitial__c != 0 ? caso.priceInitial__c + (caso.priceInitial__c * RelacionesVO.Incremento_Precio__c/100) : RelacionesVO.Importe_Hasta__c;
                        
                        system.debug('ImporteDesde: '+ImporteDesde);
                        system.debug('ImporteHasta: '+ImporteHasta);
                        
                        List<String> GrupoModelo = new List<String>();
                        string MarcaCaso;
                        string ModeloCaso;
                        boolean grupoSeleccionado = false;
                        
                        if (caso.brandVO__c != null) {
                            MarcaCaso = caso.brandVO__c.toUpperCase();
                        } else if (MarcaVehiculo != null) {
                            MarcaCaso = MarcaVehiculo.toUpperCase();
                        }
                        
                        if (caso.modelVO__c != null){
                            ModeloCaso = caso.modelVO__c.toUpperCase();
                        } else if (ModeloVehiculo != null) {
                            ModeloCaso = ModeloVehiculo.toUpperCase();
                        }
                        
                        if (ModeloCaso != null && !string.isBlank(ModeloCaso)){
                            GrupoModelo = RelacionesVO.Grupo_Modelo_1__c.split(';');
                            for(string Modelo:GrupoModelo){
                                if (ModeloCaso.contains(Modelo)) {
                                    grupoSeleccionado = true;
                                    break;
                                }
                            }        
                            
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_2__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }        
        
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_3__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }        
        
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_4__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }        
        
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_5__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }        
        
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_6__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }        
        
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_7__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }        
        
                            if (!grupoSeleccionado) {
                                GrupoModelo = RelacionesVO.Grupo_Modelo_8__c.split(';');
                                for(string Modelo:GrupoModelo){
                                    if (ModeloCaso.contains(Modelo)) {
                                        grupoSeleccionado = true;
                                        break;
                                    }
                                }        
                            }
                        }    
                        
                        if (!grupoSeleccionado) {
                            GrupoModelo.clear();
                        }        
                            
                        Map<string, string> mapRelacionUno = new Map<string, string>();                    
                        Map<string, string> mapRelacionDos = new Map<string, string>();                    
                        Map<string, string> mapRelacionTres = new Map<string, string>();
                        Map<string, string> mapRelacionCuatro = new Map<string, string>();
                        Map<string, string> mapRelacionCinco = new Map<string, string>();
                        
                        integer cuentaUno = 0;
                        for(Vehiculo__c vehicle:MapVehiculosStockVO.values()){
                            if (vehicle.Activo_stock_VO__c) {  
                                if (vehicle.MarcaString__c == MarcaCaso && 
                                    ModeloCaso != null && 
                                    vehicle.ModeloString__c != null && 
                                    vehicle.ModeloString__c.toUpperCase().contains(ModeloCaso) &&
                                    vehicle.Precio__c != null && vehicle.Precio__c != 0 && 
                                    vehicle.Precio__c >= ImporteDesde &&
                                    vehicle.Precio__c <= ImporteHasta) {
                                    if (vehicle.VIN__c != caso.VIN__c) {    
                                        mapRelacionUno.put(vehicle.id, vehicle.id);
                                        cuentaUno =+ 1;
                                        if (cuentaUno == 3) {break;}    
                                    }
                                } else if (vehicle.Precio__c != null && vehicle.Precio__c != 0 && 
                                           vehicle.Precio__c >= ImporteDesde &&
                                           vehicle.Precio__c <= ImporteHasta) {
                                    boolean encontradoModelo = false;
                                                              
                                    if (!GrupoModelo.isEmpty() && vehicle.ModeloString__c != null) {           
                                        for(string Modelo:GrupoModelo){
                                            if (vehicle.ModeloString__c.toUpperCase().contains(Modelo)) {
                                                encontradoModelo = true;
                                                break;
                                            }    
                                        }
                                    }
                                    
                                    if (encontradoModelo) {
                                        mapRelacionDos.put(vehicle.id, vehicle.id);
                                    } else {
                                        system.debug('solo importe case.id: '+case.id);
                                        mapRelacionTres.put(vehicle.id, vehicle.id);
                                    }     
                                               
                                } else {
                                    boolean encontradoModelo = false;
                                                              
                                    if (!GrupoModelo.isEmpty() && vehicle.ModeloString__c != null) {           
                                        for(string Modelo:GrupoModelo){
                                            if (vehicle.ModeloString__c.toUpperCase().contains(Modelo)) {
                                                encontradoModelo = true;
                                                break;
                                            }    
                                        }
                                    }
                                    
                                    if (encontradoModelo) {
                                        mapRelacionCuatro.put(vehicle.id, vehicle.id);
                                    } else {
                                        system.debug('solo importe case.id: '+case.id);
                                        mapRelacionCinco.put(vehicle.id, vehicle.id);
                                    }     
                                    
                                }
                            }    
                        }
                        
                        integer completo = 0;
                        
                        if (!mapRelacionUno.isEmpty()) {
                            for(string VehicleRel:mapRelacionUno.keySet()) {
                                if (caso.Vehiculo_stock_VO_1__c == null) {
                                    caso.Vehiculo_stock_VO_1__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_2__c == null) {
                                    caso.Vehiculo_stock_VO_2__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_3__c == null) {
                                    caso.Vehiculo_stock_VO_3__c = VehicleRel; 
                                    completo =+ 1;
                                }
                            }
                        }
    
                        if (!mapRelacionDos.isEmpty() && completo < 3) {
                            for(string VehicleRel:mapRelacionDos.keySet()) {
                                if (caso.Vehiculo_stock_VO_1__c == null) {
                                    caso.Vehiculo_stock_VO_1__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_2__c == null) {
                                    caso.Vehiculo_stock_VO_2__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_3__c == null) {
                                    caso.Vehiculo_stock_VO_3__c = VehicleRel; 
                                    completo =+ 1;
                                }
                            }
                        }    
    
                        if (!mapRelacionTres.isEmpty() && completo < 3) {
                            for(string VehicleRel:mapRelacionTres.keySet()) {
                                if (caso.Vehiculo_stock_VO_1__c == null) {
                                    caso.Vehiculo_stock_VO_1__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_2__c == null) {
                                    caso.Vehiculo_stock_VO_2__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_3__c == null) {
                                    caso.Vehiculo_stock_VO_3__c = VehicleRel; 
                                    completo =+ 1;
                                }
                            }
                        }    
    
                        if (!mapRelacionCuatro.isEmpty() && completo < 3) {
                            for(string VehicleRel:mapRelacionCuatro.keySet()) {
                                if (caso.Vehiculo_stock_VO_1__c == null) {
                                    caso.Vehiculo_stock_VO_1__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_2__c == null) {
                                    caso.Vehiculo_stock_VO_2__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_3__c == null) {
                                    caso.Vehiculo_stock_VO_3__c = VehicleRel; 
                                    completo =+ 1;
                                }
                            }
                        }    
    
                        if (!mapRelacionCinco.isEmpty() && completo < 3) {
                            for(string VehicleRel:mapRelacionCinco.keySet()) {
                                if (caso.Vehiculo_stock_VO_1__c == null) {
                                    caso.Vehiculo_stock_VO_1__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_2__c == null) {
                                    caso.Vehiculo_stock_VO_2__c = VehicleRel; 
                                    completo =+ 1;
                                } else if (caso.Vehiculo_stock_VO_3__c == null) {
                                    caso.Vehiculo_stock_VO_3__c = VehicleRel; 
                                    completo =+ 1;
                                }
                            }
                        }    
                    }
                } else if (!caso.Vehiculo_vendido__c && caso.VIN__c != null) {
                    caso.Vehiculo_vendido__c = true;
                    caso.Vehiculo_stock_VO_1__c = null;
                    caso.Vehiculo_stock_VO_2__c = null;
                    caso.Vehiculo_stock_VO_3__c = null;
                    actualizaCaso = true;
                }
            } else {   
                caso.Vehiculo_stock_VO_1__c = null;
                caso.Vehiculo_stock_VO_2__c = null;
                caso.Vehiculo_stock_VO_3__c = null;
            	actualizaCaso = true;
            }   
            
            if (actualizaCaso) {
                listCaseToUpdate.add(caso);
            }    
            
	        TriggerHandler.areDisabled = true;

        	if(!listCaseToUpdate.isEmpty()){
            	update listCaseToUpdate;
        	}
            
        }    
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new UpdateStockVOBatch(), 10);
    }
    
}