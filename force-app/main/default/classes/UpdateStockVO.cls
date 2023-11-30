global class UpdateStockVO implements Schedulable {

    @future(callout=true)
    public static void UpdateStockVO() {
        
        List<Exception__c> listExceptionToInsert = new List<Exception__c>();
        try {
            vehiclesAvailableVOModel response;
            List<Vehiculo__c> vehicleList = new List<Vehiculo__c>();
            List<Vehiculo__c> vehicleToUpsert = new List<Vehiculo__c>();
            Id jobId;
            Map<String,Concesionario__c> mapConcesionarioBySimaId = new Map<String,Concesionario__c>();
            
            List<Object> listObject = new List<Object>();
            response = vehiclesAvailableVOController.getvehiclesAvailableVOList();
            System.debug('UpdateStockVO.start response ' + response);
            if(response != null) {
                if(response != null && response.vehiclesAvailableVO  != null && !response.vehiclesAvailableVO.isEmpty()){
                    listObject = (List<Object>) response.vehiclesAvailableVO;
                }
                system.debug('listObject.size: '+listObject.size());
                system.debug('listObject: '+listObject);
                Map<String,vehiclesAvailableVOModel.vehiclesAvailableVO> mapVehiclesAvailableVO = new Map<String,vehiclesAvailableVOModel.vehiclesAvailableVO>();
                Map<String,vehiclesAvailableVOModel.vehiclesAvailableVO> mapVehiclesAvailableVOActualizado = new Map<String,vehiclesAvailableVOModel.vehiclesAvailableVO>();
                Set<String> listVinVO = new Set<String>();
                
                if (listObject != null && !listObject.isEmpty()){
                    vehiclesAvailableVOModel.vehiclesAvailableVO vehicleAvailableVO;
                    List<String> listSimaCompanyCode = new List<String>();
        
                    for (Object vc : listObject){
                        
                        vehicleAvailableVO = (vehiclesAvailableVOModel.vehiclesAvailableVO) vc;
    
                        if (String.isNotBlank(vehicleAvailableVO.vin)){
                            mapVehiclesAvailableVO.put(vehicleAvailableVO.vin,vehicleAvailableVO);
                        }
                        if (String.isNotBlank(vehicleAvailableVO.sima_company_code)){
                            listSimaCompanyCode.add(vehicleAvailableVO.sima_company_code);
                        }
                    }
        
                    if(!listSimaCompanyCode.isEmpty()){
                        mapConcesionarioBySimaId = ConcesionarioGateway.getConcessionaireByCompanyId(listSimaCompanyCode);
                    }            
    
                    System.debug('UpdateStockVO.execute mapVehiclesAvailableVO ' + mapVehiclesAvailableVO);
                    if(mapVehiclesAvailableVO != null && !mapVehiclesAvailableVO.isEmpty()){
                        listVinVO = mapVehiclesAvailableVO.keySet();
                    }
                     
                }
                
                system.debug('mapConcesionarioBySimaId: '+mapConcesionarioBySimaId);
                system.debug('listVinVO: '+listVinVO);
                
                vehicleList = [ SELECT Id, Name, VIN__c, MarcaString__c, ModeloString__c, modelDescription__c, kms__c, Motor__c, colorDescription__c,
                                       Combustible__c, Fecha_primera_matriculacion__c, Potencia__c, Caja_de_cambios__c, url_Foto__c, url_dwacanarias__c,
                                       url_carpluscanarias__c, url_lookar__c, Activo_stock_VO__c, Fecha_entrada_stock_VO__c, Destacado__c, Novedad__c,
                                       Puertas__c, Plazas__c, Tipo_de_vehiculo__c, Isla__c, Precio__c, Coste_real__c, Cuota_Aconsejada__c, Precio_final__c,
                                       Precio_VN__c, Precio_final_financiado__c, Concesionario_Propietario__c, Fecha_salida_stock_VO__c, equipments__c,
                                       RecalcularTargetBatch__c 
                                  FROM Vehiculo__c 
                                 WHERE VIN__c IN :listVinVO OR Activo_stock_VO__c = true
                               ];
        
                System.debug('UpdateStockVO.execute vehicleList ' + vehicleList);
        
                vehicleToUpsert.clear();
                
                if (vehicleList != null && !vehicleList.isEmpty()){
                    for(Vehiculo__c vehicle: vehicleList){
                        if (mapVehiclesAvailableVO.containsKey(vehicle.VIN__c)) {
                            vehiclesAvailableVOModel.vehiclesAvailableVO vehicleAvailableVO = mapVehiclesAvailableVO.get(vehicle.VIN__c);
        
                            vehicle.MarcaString__c = vehicle.MarcaString__c == null && vehicleAvailableVO.marca != null? vehicleAvailableVO.marca.toUpperCase(): vehicle.MarcaString__c;
                            vehicle.ModeloString__c = vehicle.ModeloString__c == null && vehicleAvailableVO.modelo != null? vehicleAvailableVO.modelo.toUpperCase(): vehicle.ModeloString__c;
                            vehicle.modelDescription__c = vehicle.modelDescription__c == null && vehicleAvailableVO.version != null? vehicleAvailableVO.version: vehicle.modelDescription__c;
                    
                            if (vehicleAvailableVO.kilometros != null) {
                                integer kms = integer.valueOf(vehicleAvailableVO.kilometros);
                                vehicle.kms__c = kms > vehicle.kms__c? kms : vehicle.kms__c;
                            }
                    
                            vehicle.Motor__c = 	vehicle.Motor__c == null && vehicleAvailableVO.motor != null? vehicleAvailableVO.motor: vehicle.Motor__c;
                            vehicle.colorDescription__c = vehicle.colorDescription__c == null && vehicleAvailableVO.color != null? vehicleAvailableVO.color: vehicle.colorDescription__c;
                
                            if(vehicle.Combustible__c == null){
                                switch on vehicleAvailableVO.combustible {
                                  when 'Gasolina' {vehicle.Combustible__c = '1';} 
                                  when 'Diesel' {vehicle.Combustible__c = '2';}
                                  when 'Híbrido' {vehicle.Combustible__c = '9';}
                                  when 'Eléctrico' {vehicle.Combustible__c = '8';}
                                  when 'Diésel' {vehicle.Combustible__c = '2';}
                                  when 'Gas Natural' {vehicle.Combustible__c = '4';}
                                  when 'Híbrido Enchufable' {vehicle.Combustible__c = '7';}
                                  when else {vehicle.Combustible__c = vehicleAvailableVO.combustible;}
                                }
                            }
                            
                            vehicle.Fecha_primera_matriculacion__c = vehicle.Fecha_primera_matriculacion__c == null && vehicleAvailableVO.fecha_matriculacion != null? datetime.newInstance(date.valueOf(vehicleAvailableVO.fecha_matriculacion), time.newInstance(0, 0, 0, 0)) : vehicle.Fecha_primera_matriculacion__c;
                            
                            if (vehicle.Name == string.valueOf(vehicle.Id).substring(0, 15) && vehicleAvailableVO.matricula != null) {
                                if ((vehicleAvailableVO.matricula.length() == 7) && (vehicleAvailableVO.matricula.toUpperCase().left(1) != 'E')) {
                                    vehicle.Name = 'E'+vehicleAvailableVO.matricula;
                                } else {
                                    vehicle.Name = vehicleAvailableVO.matricula;
                                }
                            }      
                            
                            if (vehicle.Potencia__c == null && vehicleAvailableVO.potencia != null) {
                                integer potencia = integer.valueOf(vehicle.Potencia__c);
                                vehicle.Potencia__c = potencia;
                            }
                            
                            if ((vehicle.Caja_de_cambios__c == null || vehicle.Caja_de_cambios__c == 'Sin definir') && vehicleAvailableVO.cambio != null) {
                                vehicle.Caja_de_cambios__c = vehicleAvailableVO.cambio;
                            } 
                
                            vehicle.url_Foto__c = vehicleAvailableVO.foto;
                            vehicle.url_dwacanarias__c = vehicleAvailableVO.enlace_sf.dwacanarias_com;
                            vehicle.url_carpluscanarias__c = vehicleAvailableVO.enlace_sf.carpluscanarias_net;
                            vehicle.url_lookar__c = vehicleAvailableVO.enlace_sf.lookar_es;
                            vehicle.Activo_stock_VO__c = true;
                            vehicle.Fecha_entrada_stock_VO__c = vehicle.Fecha_entrada_stock_VO__c == null? date.today(): vehicle.Fecha_entrada_stock_VO__c;
                            vehicle.Fecha_salida_stock_VO__c = null;
                            vehicle.Destacado__c = vehicleAvailableVO.destacado == '1'? true: false;
                            vehicle.Novedad__c = vehicleAvailableVO.novedad == '1'? true: false;
                            vehicle.Puertas__c = vehicle.Puertas__c == null && vehicleAvailableVO.puertas != null? vehicleAvailableVO.puertas: vehicle.Puertas__c;
                            vehicle.Plazas__c = vehicle.Plazas__c == null && vehicleAvailableVO.plazas != null? vehicleAvailableVO.plazas: vehicle.Plazas__c; 
                            vehicle.Tipo_de_vehiculo__c = vehicle.Tipo_de_vehiculo__c == null && vehicleAvailableVO.tipo_de_coche != null? vehicleAvailableVO.tipo_de_coche: vehicle.Tipo_de_vehiculo__c;
                            
                            switch on vehicleAvailableVO.isla {
                              when 'Gran Canaria' {vehicle.Isla__c = 'GCA';} 
                              when 'Lanzarote' {vehicle.Isla__c = 'LAN';}
                              when 'Tenerife' {vehicle.Isla__c = 'TEN';}
                              when 'Fuerteventura' {vehicle.Isla__c = 'FUE';}
                              when 'La Palma' {vehicle.Isla__c = 'PAL';}
                              when 'El Hierro' {vehicle.Isla__c = 'HIE';}
                              when 'La Gomera' {vehicle.Isla__c = 'GOM';}
                              when else {vehicle.Isla__c = null;}
                            }
                
                            vehicle.Precio__c = vehicleAvailableVO.precio != null && vehicleAvailableVO.precio != '' ? decimal.valueOf(vehicleAvailableVO.precio): 0;
                            vehicle.Coste_real__c = vehicleAvailableVO.coste_real_del_vehiculo != null && vehicleAvailableVO.coste_real_del_vehiculo != '' ? decimal.valueOf(vehicleAvailableVO.coste_real_del_vehiculo): 0;
                            vehicle.Cuota_Aconsejada__c =  vehicleAvailableVO.cuota_aconsejada != null ? vehicleAvailableVO.cuota_aconsejada: 0;
                            vehicle.Precio_final__c = vehicleAvailableVO.precio_final != null && vehicleAvailableVO.precio_final != '' ? decimal.valueOf(vehicleAvailableVO.precio_final): 0;
                            vehicle.Precio_VN__c = vehicleAvailableVO.precio_vn != null && vehicleAvailableVO.precio_vn != '' ? decimal.valueOf(vehicleAvailableVO.precio_vn): 0;
                            vehicle.Precio_final_financiado__c = vehicleAvailableVO.precio_final_financiado != null && vehicleAvailableVO.precio_final_financiado != '' ? decimal.valueOf(vehicleAvailableVO.precio_final_financiado): 0;
                            
                            if (vehicleAvailableVO.sima_company_code != null && mapConcesionarioBySimaId.containsKey(vehicleAvailableVO.sima_company_code)) {
                                vehicle.Concesionario_Propietario__c = mapConcesionarioBySimaId.get(vehicleAvailableVO.sima_company_code).id;
                            } else {
                                vehicle.Concesionario_Propietario__c = null;
                            }
        
                            string EquipanientoAnt = '';
                            
                            if (vehicle.equipments__c != null) {
                                EquipanientoAnt = vehicle.equipments__c;
                            } else {
                                vehicle.equipments__c = '';
                            }
                            
                            if (vehicleAvailableVO.equipamiento != null) {
                                for (Integer i = 0; i < vehicleAvailableVO.equipamiento.size(); i++) {
                                    if (!EquipanientoAnt.contains(vehicleAvailableVO.equipamiento[i].CodeEquipamiento)) {
                                        if (vehicle.equipments__c.length() > 0) {vehicle.equipments__c += '\n';}
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].CodeEquipamiento; 
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Texto != null && string.isBlank(vehicleAvailableVO.equipamiento[i].CodeEquipamiento) ? '':' - ';
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Texto != null ? vehicleAvailableVO.equipamiento[i].Texto: ''; 
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Categoria != null ? ' ('+ vehicleAvailableVO.equipamiento[i].Categoria +')':'';
                                    }
                                }
                            }
                            
                            if (!String.isBlank(vehicle.MarcaString__c) && Label.BrandTarget.contains(vehicle.MarcaString__c)) {
                                vehicle.RecalcularTargetBatch__c = true;
                            }
                           
                            vehicleToUpsert.add(vehicle);
                            mapVehiclesAvailableVOActualizado.put(vehicleAvailableVO.vin,vehicleAvailableVO);
                        } else {
                            vehicle.url_Foto__c = null;
                            vehicle.url_dwacanarias__c = null;
                            vehicle.url_carpluscanarias__c = null;
                            vehicle.url_lookar__c = null;
                            vehicle.Activo_stock_VO__c = false;
                            vehicle.Fecha_entrada_stock_VO__c = null;
                            vehicle.Fecha_salida_stock_VO__c = date.today();
                            vehicle.Destacado__c = false;
                            vehicle.Novedad__c = false;
                            vehicle.Tipo_de_vehiculo__c = null;
                            vehicle.Isla__c = null;
                            vehicle.Precio__c = null;
                            vehicle.Coste_real__c = null;
                            vehicle.Cuota_Aconsejada__c = null;
                            vehicle.Precio_final__c = null;
                            vehicle.Precio_VN__c = null;
                            vehicle.Precio_final_financiado__c = null;
                            vehicle.Concesionario_Propietario__c = null;
                            if (!String.isBlank(vehicle.MarcaString__c) && Label.BrandTarget.contains(vehicle.MarcaString__c)) {
                                vehicle.RecalcularTargetBatch__c = true;
                            }
                            vehicleToUpsert.add(vehicle);
                        }
                    }
                }
                
                if (!mapVehiclesAvailableVO.isEmpty()) {
                    for(vehiclesAvailableVOModel.vehiclesAvailableVO vehicleAvailableVO: mapVehiclesAvailableVO.values()){
                        if (!mapVehiclesAvailableVOActualizado.containsKey(vehicleAvailableVO.vin)){
                            Vehiculo__c vehicle = new Vehiculo__c();
                            vehicle.MarcaString__c = vehicleAvailableVO.marca != null? vehicleAvailableVO.marca.toUpperCase(): vehicle.MarcaString__c;
                            vehicle.ModeloString__c = vehicleAvailableVO.modelo != null? vehicleAvailableVO.modelo.toUpperCase(): vehicle.ModeloString__c;
                            vehicle.modelDescription__c = vehicleAvailableVO.version;
                    
                            if (vehicleAvailableVO.kilometros != null) {
                                vehicle.kms__c = integer.valueOf(vehicleAvailableVO.kilometros);
                            }
                    
                            vehicle.Motor__c = vehicleAvailableVO.motor;
                            vehicle.colorDescription__c = vehicleAvailableVO.color;
                            switch on vehicleAvailableVO.combustible {
                                 when 'Gasolina' {vehicle.Combustible__c = '1';} 
                                 when 'Diesel' {vehicle.Combustible__c = '2';}
                                 when 'Híbrido' {vehicle.Combustible__c = '9';}
                                 when 'Eléctrico' {vehicle.Combustible__c = '8';}
                                 when 'Diésel' {vehicle.Combustible__c = '2';}
                                 when 'Gas Natural' {vehicle.Combustible__c = '4';}
                                 when 'Híbrido Enchufable' {vehicle.Combustible__c = '7';}
                                 when else {vehicle.Combustible__c = vehicleAvailableVO.combustible;}
                            }
                            
                            vehicle.Fecha_primera_matriculacion__c = vehicleAvailableVO.fecha_matriculacion != null? datetime.newInstance(date.valueOf(vehicleAvailableVO.fecha_matriculacion), time.newInstance(0, 0, 0, 0)) : null;
                            
                            if (vehicleAvailableVO.matricula != null) {
                                if ((vehicleAvailableVO.matricula.length() == 7) && (vehicleAvailableVO.matricula.toUpperCase().left(1) != 'E')) {
                                    vehicle.Name = 'E'+vehicleAvailableVO.matricula;
                                } else {
                                    vehicle.Name = vehicleAvailableVO.matricula;
                                }
                            }   
                            vehicle.VIN__c = vehicleAvailableVO.vin;
                            
                            if (vehicleAvailableVO.potencia != null) {
                                vehicle.Potencia__c = integer.valueOf(vehicle.Potencia__c);
                            }
                            
                            if (vehicleAvailableVO.cambio != null) {
                                vehicle.Caja_de_cambios__c = vehicleAvailableVO.cambio;
                            } 
                
                            vehicle.url_Foto__c = vehicleAvailableVO.foto;
                            vehicle.url_dwacanarias__c = vehicleAvailableVO.enlace_sf.dwacanarias_com;
                            vehicle.url_carpluscanarias__c = vehicleAvailableVO.enlace_sf.carpluscanarias_net;
                            vehicle.url_lookar__c = vehicleAvailableVO.enlace_sf.lookar_es;
                            vehicle.Activo_stock_VO__c = true;
                            vehicle.Fecha_entrada_stock_VO__c = date.today();
                            vehicle.Destacado__c = vehicleAvailableVO.destacado == '1'? true: false;
                            vehicle.Novedad__c = vehicleAvailableVO.novedad == '1'? true: false;
                            vehicle.Puertas__c = vehicleAvailableVO.puertas;
                            vehicle.Plazas__c = vehicleAvailableVO.plazas; 
                            vehicle.Tipo_de_vehiculo__c = vehicleAvailableVO.tipo_de_coche;
                            
                            switch on vehicleAvailableVO.isla {
                              when 'Gran Canaria' {vehicle.Isla__c = 'GCA';} 
                              when 'Lanzarote' {vehicle.Isla__c = 'LAN';}
                              when 'Tenerife' {vehicle.Isla__c = 'TEN';}
                              when 'Fuerteventura' {vehicle.Isla__c = 'FUE';}
                              when 'La Palma' {vehicle.Isla__c = 'PAL';}
                              when 'El Hierro' {vehicle.Isla__c = 'HIE';}
                              when 'La Gomera' {vehicle.Isla__c = 'GOM';}
                              when else {vehicle.Isla__c = null;}
                            }
                
                            vehicle.Precio__c = vehicleAvailableVO.precio != null && vehicleAvailableVO.precio != ''  ? decimal.valueOf(vehicleAvailableVO.precio): 0;
                            vehicle.Coste_real__c = vehicleAvailableVO.coste_real_del_vehiculo != null && vehicleAvailableVO.coste_real_del_vehiculo != ''? decimal.valueOf(vehicleAvailableVO.coste_real_del_vehiculo): 0;
                            vehicle.Cuota_Aconsejada__c =  vehicleAvailableVO.cuota_aconsejada != null ? vehicleAvailableVO.cuota_aconsejada: 0;
                            vehicle.Precio_final__c = vehicleAvailableVO.precio_final != null && vehicleAvailableVO.precio_final != ''  ? decimal.valueOf(vehicleAvailableVO.precio_final): 0;
                            vehicle.Precio_VN__c = vehicleAvailableVO.precio_vn != null && vehicleAvailableVO.precio_vn != '' ? decimal.valueOf(vehicleAvailableVO.precio_vn): 0;
                            vehicle.Precio_final_financiado__c = vehicleAvailableVO.precio_final_financiado != null && vehicleAvailableVO.precio_final_financiado != ''  ? decimal.valueOf(vehicleAvailableVO.precio_final_financiado): 0;
                            
                            if (vehicleAvailableVO.sima_company_code != null && mapConcesionarioBySimaId.containsKey(vehicleAvailableVO.sima_company_code)) {
                                vehicle.Concesionario_Propietario__c = mapConcesionarioBySimaId.get(vehicleAvailableVO.sima_company_code).id;
                            } else {
                                vehicle.Concesionario_Propietario__c = null;
                            }
        
                            vehicle.equipments__c = '';
                            if (vehicleAvailableVO.equipamiento != null) {
                                for (Integer i = 0; i < vehicleAvailableVO.equipamiento.size(); i++) {
                                    if (i + 1 == vehicleAvailableVO.equipamiento.size()) {
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].CodeEquipamiento; 
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Texto != null && string.isBlank(vehicleAvailableVO.equipamiento[i].CodeEquipamiento) ? '':' - ';
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Texto != null ? vehicleAvailableVO.equipamiento[i].Texto: ''; 
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Categoria != null ? ' ('+ vehicleAvailableVO.equipamiento[i].Categoria +')':'';
                                    }
                                    else {
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].CodeEquipamiento; 
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Texto != null && string.isBlank(vehicleAvailableVO.equipamiento[i].CodeEquipamiento) ? '':' - ';
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Texto != null ? vehicleAvailableVO.equipamiento[i].Texto: ''; 
                                        vehicle.equipments__c += vehicleAvailableVO.equipamiento[i].Categoria != null ? ' ('+ vehicleAvailableVO.equipamiento[i].Categoria +')'+ '\n':'\n';
                                    }
                                }
                            }
    
                            if (!String.isBlank(vehicle.MarcaString__c) && Label.BrandTarget.contains(vehicle.MarcaString__c)) {
                                vehicle.RecalcularTargetBatch__c = true;
                            }
                            
                            vehicleToUpsert.add(vehicle);
                            
                        }
                    }    
                }
                
                if(!vehicleToUpsert.isEmpty()){
                    upsert vehicleToUpsert;
                }
            
            } else {
                Exception__c exc = new Exception__c ();
                
                exc.Exception__c = 'La llamada a recuperar el stock falla';
                exc.Linea__c = 15;
                exc.Clase_Metodo__c = 'UpdateStockVO';
                listExceptionToInsert.add(exc);
            }
        } catch (Exception e) {
            System.debug('UpdateStockVO.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            
            exc.Exception__c = e.getStackTraceString()+'// Message'+e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'UpdateStockVO.execute';
            listExceptionToInsert.add(exc);
            
        }

        if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()) {
            insert listExceptionToInsert;
        }
    }

    // Scheduler
    public void execute(SchedulableContext sc) {
       UpdateStockVO();
    }    

}