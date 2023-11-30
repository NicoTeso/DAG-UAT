global class CampaignVehicleRegisterBatch implements Database.Batchable<sObject>, Schedulable{
    
   private static List<String> tiposRegistros = new List<String>{Label.TRGarantiaCVehiculo, Label.TRContratoVehiculo};
   private  Map<String,List<String>> mapMarcasByGrupo = new Map<String,List<String>>();
   private Set<String> codigosProcesoModificado = new Set<String>();
   private Boolean inicioEjecucion;
   private String grupoMarca;
    
    public CampaignVehicleRegisterBatch(String grupo){
        grupoMarca = grupo;
        inicioEjecucion = false;
        mapMarcasByGrupo.put('Hyundai', new List<String>{'HYUNDAI'});
        mapMarcasByGrupo.put('Citroen', new List<String>{'CITROËN'});
        mapMarcasByGrupo.put('Honda', new List<String>{'HONDA'});
        mapMarcasByGrupo.put('GrupoVW', new List<String>{'VOLKSWAGEN','VW COMERCIALES', 'SKODA', 'DUCATI', 'AUDI'});
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String codigo;
        switch on grupoMarca {                                                       
    		when 'GrupoVW' {		// when block 1
        		codigo = '1';
    		}	
    		when 'Hyundai' {		// when block 2
        		codigo = '2';
    		}
    		when 'Citroen' {		// when block 3
        		codigo = '3';
    		}
    		when 'Honda' {		  
        		codigo = '4';
    		}
            when else {
                codigo = 'N/P';
            }
		}
        
        return Database.getQueryLocator([SELECT Id, Name, Codigo__c,CreatedDate, VIN__c, Contrato_modalidad__c, Contrato_Servicio_1__c, Contrato_Servicio_2__c, Contrato_Servicio_3__c, Contrato_Servicio_4__c,
                                         Contrato_Servicio_5__c, Contrato_Servicio_6__c, Contrato_Servicio_7__c, Contrato_Servicio_8__c, Contrato_Servicio_9__c, Contrato_Servicio_10__c,
                                         Fecha_contrato_inicio_e_garantia__c, PR_Number__c, Kms_contrato_prestacion__c, Fecha_contrato_fin_e_garantia__c, Procesado__c, Estado_ejecucion__c, Tipo_registro__c, Descripcion__c, Tipo__c
                                         FROM AuxiliarAdicionalVehiculo__c WHERE Procesado__c = false AND Tipo_registro__c  = :Label.TRCampanaVehiculo AND Grupo_Marca__c = :codigo ]);
    }
    
    global void execute(Database.BatchableContext bc, List<AuxiliarAdicionalVehiculo__c> lstAuxAd) {
        
        Set<String> vins = new Set<String>();
        List<Vehiculo__c> vehiculosToUpdate = new List<Vehiculo__c>();
        Map<String,AuxiliarAdicionalVehiculo__c> mapAuxAdVehicleByCodExt = new Map<String,AuxiliarAdicionalVehiculo__c>();
        Map<String,Campania_Vehiculo__c> mapCampaignVehiculoByCodExt = new Map<String,Campania_Vehiculo__c>();
        Map<String,Vehiculo__c> mapVehiculoByVin = new Map<String,Vehiculo__c>();
        
        //List<CargaAuxiliares__c> cAux = [select id, Name, Inicio_Ejecucion__c, IdsAuxiliares__c, Principal__c from CargaAuxiliares__c where Name = :Label.TitleCampaignVehicle and Principal__c = true];
        //CargaAuxiliares__c cargaAuxiliar = cAux[0];
        
        if(!lstAuxAd.isEmpty()){ 
            //if(!cargaAuxiliar.Inicio_Ejecucion__c){
            	system.debug('entra inicioEjecucion');
            	//cargaAuxiliar.Inicio_Ejecucion__c = true;
            	//update cargaAuxiliar;
        	//}
            inicioEjecucion = true;
            //CargaAuxiliares__c cargaAuxiliarCod = new CargaAuxiliares__c();
            //cargaAuxiliarCod.Name = cargaAuxiliar.Name;
            //cargaAuxiliarCod.IdsAuxiliares__c='';
            
            for(Integer i=0; i<lstAuxAd.size();i++){
                if(!String.isEmpty(lstAuxAd[i].VIN__c) && !String.isEmpty(lstAuxAd[i].Codigo__c)){
                    String codExt= lstAuxAd[i].VIN__c + '/' + lstAuxAd[i].Codigo__c;
                    mapAuxAdVehicleByCodExt.put(codExt, lstAuxAd[i]);
                    vins.add(lstAuxAd[i].VIN__c);
                    //if(i+1<lstAuxAd.size()){
                    //    cargaAuxiliarCod.IdsAuxiliares__c += codExt + ',';
                    //}
                    //else {
                    //    cargaAuxiliarCod.IdsAuxiliares__c += codExt;
                    //}
                    codigosProcesoModificado.add(codExt);
                 }
            }
            
            if(!mapAuxAdVehicleByCodExt.isEmpty()){
                List<Campania_Vehiculo__c> listCamVeh =[select Id, ClaveExterna__c, Descripcion__c
                                                        from Campania_Vehiculo__c where ClaveExterna__c in :mapAuxAdVehicleByCodExt.keySet()];
                for(Campania_Vehiculo__c camVeh : listCamVeh){
                    mapCampaignVehiculoByCodExt.put(camVeh.ClaveExterna__c, camVeh);
                }
                List<Vehiculo__c> listVehs =[SELECT Id, VIN__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, Kms_contrato_prestacion__c, PR_Number__c, Contrato_modalidad__c,Contrato_Servicio_1__c, Contrato_Servicio_2__c,
                                             Contrato_Servicio_3__c, Contrato_Servicio_4__c, Contrato_Servicio_5__c, Contrato_Servicio_6__c, Contrato_Servicio_7__c, Contrato_Servicio_8__c, Contrato_Servicio_9__c, Contrato_Servicio_10__c,
                                             Centro__c, Concesionario__c, Propietario__c, Depositario__c, Centro_Taller__c, Tipo_de_venta__c, Concesionario_Taller__c
                                             FROM  Vehiculo__c where VIN__c in :vins];
                for(Vehiculo__c veh : listVehs){
                    mapVehiculoByVin.put(veh.VIN__c, Veh);
                }
                for(String codExt :mapAuxAdVehicleByCodExt.KeySet()){
                    AuxiliarAdicionalVehiculo__c auxAd = mapAuxAdVehicleByCodExt.get(codExt);
                    Campania_Vehiculo__c camVeh;
                    if(mapCampaignVehiculoByCodExt.containsKey(codExt)){
                        camVeh = mapCampaignVehiculoByCodExt.get(codExt);
                        camVeh.Descripcion__c = auxAd.Descripcion__c;
                        auxAd.Estado_ejecucion__c='OK';
                            auxAd.Procesado__c = true;
                    }
                    else {
                        if(mapVehiculoByVin.containsKey(auxAd.VIN__c)){
                            Vehiculo__c vehiculo = mapVehiculoByVin.get(auxAd.VIN__c);
                            camVeh = new Campania_Vehiculo__c();
                            camVeh.Vehiculo__c = vehiculo.Id;
                            camVeh.Centro__c = vehiculo.Centro_Taller__c != null ? vehiculo.Centro_Taller__c:vehiculo.Centro__c;
                            camVeh.Concesionario__c = vehiculo.Concesionario_Taller__c != null ? vehiculo.Concesionario_Taller__c: vehiculo.Concesionario__c;
                            camVeh.Propietario__c = vehiculo.Propietario__c;
                            camVeh.Depositario__c = vehiculo.Depositario__c;
                            camVeh.Tipo_de_venta__c = vehiculo.Tipo_de_venta__c;
                            camVeh.Codigo__c = auxAd.Codigo__c;
                            camVeh.Descripcion__c = auxAd.Descripcion__c;
                            camVeh.Tipo__c = auxAd.Tipo__c;
                            camVeh.Name = auxAd.Descripcion__c.length() > 80 ? auxAd.Descripcion__c.substring(0,80) : auxAd.Descripcion__c;
                            mapCampaignVehiculoByCodExt.put(codExt, camVeh);
                            auxAd.Estado_ejecucion__c='OK';
                            auxAd.Procesado__c = true;
                        }
                        else {
                            auxAd.Estado_ejecucion__c='KO, problemas con la búsqueda de la campaña y vin del vehículo';
                            auxAd.Procesado__c = true;
                        }
                        
                    }
                }
                upsert mapAuxAdVehicleByCodExt.values();
            }
                
            if(!mapCampaignVehiculoByCodExt.isEmpty()){
                upsert mapCampaignVehiculoByCodExt.values();
            }
            
            //insert cargaAuxiliarCod;
          }  
        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('inicia finish');
        system.debug('');
        //CargaAuxiliares__c cAuxPrincipal;
        List<String> codigos = new List<String>();
        //List<CargaAuxiliares__c> listCargaAuxiliarToDelete = new List<CargaAuxiliares__c>();
        //List<CargaAuxiliares__c> listCargaAux = [select id, Name, Inicio_Ejecucion__c, IdsAuxiliares__c, Principal__c from CargaAuxiliares__c where Name = :Label.TitleCampaignVehicle ];
        //for(CargaAuxiliares__c cAux :listCargaAux){
        //    if(cAux.Principal__c){
        //        cAuxPrincipal = cAux;
        //    }
        //    else{
        //        List<String> codAux = cAux.IdsAuxiliares__c.split(',');
        //        codigos.addAll(codAux);
        //        listCargaAuxiliarToDelete.add(cAux);
        //    }
        //}
        //if(cAuxPrincipal.Inicio_Ejecucion__c){
        if(inicioEjecucion){
            system.debug('dentro inicioEjecucion ');
       		List<String> marcas = mapMarcasByGrupo.get(grupoMarca);
            //List<Campania_Vehiculo__c> listCamVeh =[select Id, Estado__c, Motivo_de_cierre__c, Submotivo_de_cierre__c 
            //                                        from Campania_Vehiculo__c where Estado__c !='Cerrado' AND Estado__c != 'No aplica' AND ClaveExterna__c not in  :codigos];
            List<Campania_Vehiculo__c> listCamVeh =[select Id, Estado__c, Motivo_de_cierre__c, Submotivo_de_cierre__c, Vehiculo__r.MarcaString__c 
                                                    from Campania_Vehiculo__c where Estado__c !='Cerrado' AND Estado__c != 'No aplica' AND Vehiculo__r.MarcaString__c in :codigosProcesoModificado AND ClaveExterna__c not in  :codigosProcesoModificado];
            
        	system.debug('listCamVeh:'+ listCamVeh);
            for(Campania_Vehiculo__c camVeh :listCamVeh){
                camVeh.Estado__c ='Cerrado';
                camVeh.Motivo_de_cierre__c =Label.motivoCierreYaRealizada;
            }
            if(!listCamVeh.isEmpty()){
                upsert listCamVeh;
            }
        	
            //cAuxPrincipal.Inicio_Ejecucion__c =false;
            //update cAuxPrincipal;
            //delete listCargaAuxiliarToDelete;
        }
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CampaignVehicleRegisterBatch(this.grupoMarca));
        
    }

}