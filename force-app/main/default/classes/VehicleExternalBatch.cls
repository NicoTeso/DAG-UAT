global class VehicleExternalBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext bc) {
            return  Database.getQueryLocator([SELECT Id, VIN__c, Name, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Agente_con_taller__c, 
                                                     Concesionario_Taller__c, Concesionario_Taller__r.Id_Concesionario_Sima__c,
                                                     kms__c, Fecha_primera_matriculacion__c, Fecha_inicio_garantia__c, Fecha_fin_garantia__c, 
                                                     Fecha_inicio_extension_garantia__c, Fecha_fin_extension_garantia__c, 
                                                     Fecha_inicio_garantia_VO__c, Fecha_fin_garantia_VO__c,
                                                     MarcaString__c, ModeloString__c, Codigo_de_modelo__c, Version__c, modelDescription__c,
                                                     Ano_Modelo__c, Potencia__c, Cilindrada__c, Combustible__c, Transmision__c, Letra_Motor__c,
                                                     Numero_de_Motor__c, Codigo_Motor__c, Clasificacion__c, Caja_de_cambios__c
                                              FROM Vehiculo__c
                                         WHERE Actualizar_Sima__c = true]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Vehiculo__c> lstVehiculo) {
        
        List<Vehiculo__c> vehicleToUpdate = new List<Vehiculo__c>();
        
        system.debug('lstVehiculo: '+lstVehiculo);
        for(Vehiculo__c veh:lstVehiculo){
            VehicleExternalModel vem =null;
            if(veh.Concesionario__c != null){
                String ConceSima;
                if (veh.Concesionario__r.Agente_con_taller__c) {
                    Detalle_Venta__c dSale = DetalleVentaGateway.getDetalleVentaByVin(veh.VIN__c);
                    if (dSale != null) {
                       ConceSima = dSale.Concesionario__r.Id_Concesionario_Sima__c;
                       system.debug('0 ConceSima: '+ConceSima);
                    }
                } else {
                    ConceSima = veh.Concesionario__r.Id_Concesionario_Sima__c;
                       system.debug('1 ConceSima: '+ConceSima);
                }
                if (ConceSima != null) {
	                vem = VehicleExternalController.getVehicleSIMA(veh.VIN__c, ConceSima);
                    system.debug('vem: '+vem);
                    
                } else if(veh.Concesionario_Taller__c != null){
    	        	vem = VehicleExternalController.getVehicleSIMA(veh.VIN__c, veh.Concesionario_Taller__r.Id_Concesionario_Sima__c);
        	    }
            } else if(veh.Concesionario_Taller__c != null){
            	vem = VehicleExternalController.getVehicleSIMA(veh.VIN__c, veh.Concesionario_Taller__r.Id_Concesionario_Sima__c);
            }
            if(vem != null){
                system.debug('vem: '+vem);
                Vehiculo__c vehToUpdate = new Vehiculo__c();
                vehToUpdate.Id = veh.Id;
                vehToUpdate.Name = veh.Name;
                vehToUpdate.VIN__c = veh.VIN__c;
                vehToUpdate.MarcaString__c = !String.isBlank(vem.brand) ? vem.brand.toUpperCase() : veh.MarcaString__c;
                vehToUpdate.ModeloString__c = !String.isBlank(vem.model)? vem.model.toUpperCase() : veh.ModeloString__c;
                vehToUpdate.Codigo_de_modelo__c = !String.isBlank(vem.modelCode) ? vem.modelCode : veh.Codigo_de_modelo__c;
                vehToUpdate.Version__c = !String.isBlank(vem.version) ? vem.version : veh.Version__c;
                vehToUpdate.modelDescription__c = !String.isBlank(vem.engine) ? vem.engine : veh.modelDescription__c;
                vehToUpdate.Ano_Modelo__c = !String.isBlank(vem.modelYear) ? vem.modelYear : veh.Ano_Modelo__c;
                vehToUpdate.Potencia__c = vem.power != null && vem.power != 0 ? vem.power : veh.Potencia__c;
                vehToUpdate.Cilindrada__c = vem.enginecapacity != null && vem.enginecapacity != 0 ? vem.enginecapacity : veh.Cilindrada__c ;
                vehToUpdate.Combustible__c = !String.isBlank(vem.fuel) ? vem.fuel : veh.Combustible__c;
                vehToUpdate.Transmision__c = !String.isBlank(vem.transmission) ? vem.transmission : veh.Transmision__c;
                vehToUpdate.Letra_Motor__c = !String.isBlank(vem.engineLetter) ? vem.engineLetter : veh.Letra_Motor__c;
                vehToUpdate.Numero_de_Motor__c = !String.isBlank(vem.engineNumber) ? vem.engineNumber : veh.Numero_de_Motor__c;
                vehToUpdate.Codigo_Motor__c = !String.isBlank(vem.engineCode) ? vem.engineCode : veh.Codigo_Motor__c;
                 
                vehToUpdate.kms__c = veh.kms__c < vem.kms? vem.kms : veh.kms__c;
                vehToUpdate.Fecha_primera_matriculacion__c = !String.isBlank(vem.registrationPlateDate) ? Datetime.valueOf(vem.registrationPlateDate.replace('T', ' ')) : veh.Fecha_primera_matriculacion__c;
                vehToUpdate.Fecha_inicio_garantia__c = !String.isBlank(vem.warrantyStartDate) ? Datetime.valueOf(vem.warrantyStartDate.replace('T', ' ')) : veh.Fecha_inicio_garantia__c;
                vehToUpdate.Fecha_fin_garantia__c = !String.isBlank(vem.warrantyEndDate) ? Datetime.valueOf(vem.warrantyEndDate.replace('T', ' ')) : veh.Fecha_fin_garantia__c;
                Datetime inicioExGarantia = !String.isBlank(vem.warrantyExtensionStartDate) ? Datetime.valueOf(vem.warrantyExtensionStartDate.replace('T', ' ')) : veh.Fecha_inicio_extension_garantia__c;
                if (vehToUpdate.Fecha_fin_garantia__c != null && inicioExGarantia != null && inicioExGarantia >= vehToUpdate.Fecha_fin_garantia__c) {
                    vehToUpdate.Fecha_inicio_extension_garantia__c = inicioExGarantia;
                }
                Datetime finExGarantia = !String.isBlank(vem.warrantyExtensionEndDate) ? Datetime.valueOf(vem.warrantyExtensionEndDate.replace('T', ' ')):veh.Fecha_fin_extension_garantia__c;
                if (inicioExGarantia != null && finExGarantia != null && inicioExGarantia <= finExGarantia) {
                    vehToUpdate.Fecha_fin_extension_garantia__c = finExGarantia;
                }
                vehToUpdate.Fecha_inicio_garantia_VO__c = !String.isBlank(vem.usedVehicleWarrantyStartDate) ? Datetime.valueOf(vem.UsedVehicleWarrantyStartDate.replace('T', ' ')) : veh.Fecha_inicio_garantia_VO__c;
            	vehToUpdate.Fecha_fin_garantia_VO__c = !String.isBlank(vem.usedVehicleWarrantyEndDate) ? Datetime.valueOf(vem.UsedVehicleWarrantyEndDate.replace('T', ' ')) : veh.Fecha_fin_garantia_VO__c;

                vehToUpdate.Clasificacion__c = !String.isBlank(vem.technicalVehicleClassification) ? vem.technicalVehicleClassification : veh.Clasificacion__c;
                vehToUpdate.Caja_de_cambios__c = !String.isBlank(vem.gearBox) ? vem.gearBox : veh.Caja_de_cambios__c;

                system.debug('vehToUpdate: '+vehToUpdate); 
                if(!String.isBlank(vem.registrationPlate)){
                    vehToUpdate.Name = vem.registrationPlate;
                    vehToUpdate.Actualizar_Sima__c = false;
                    vehToupdate.RecalcularTargetBatch__c = true;
                } else {
                    vehToUpdate.Actualizar_Sima__c = true;
                }
                vehicleToUpdate.add(vehToUpdate);
            }
        }
        
        if(!vehicleToUpdate.isEmpty()){
            update vehicleToUpdate;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new VehicleExternalBatch());
    }

}