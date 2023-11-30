global class AddInfoContractVehicleBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    private static List<String> tiposRegistros = new List<String>{Label.TRGarantiaCVehiculo, Label.TRContratoVehiculo};
    private Map<String,List<String>> mapMarcasByGrupo = new Map<String,List<String>>();
    private Set<String> vinProcesoModificado = new Set<String>();
    private Boolean inicioEjecucion;
    private String grupoMarca;
    
    public AddInfoContractVehicleBatch(String grupo){
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
        return Database.getQueryLocator([SELECT Id, Name, CreatedDate, VIN__c, Contrato_modalidad__c, Contrato_Servicio_1__c, Contrato_Servicio_2__c, Contrato_Servicio_3__c, Contrato_Servicio_4__c,
                                         Contrato_Servicio_5__c, Contrato_Servicio_6__c, Contrato_Servicio_7__c, Contrato_Servicio_8__c, Contrato_Servicio_9__c, Contrato_Servicio_10__c,
                                         Fecha_contrato_inicio_e_garantia__c, PR_Number__c, Kms_contrato_prestacion__c, Fecha_contrato_fin_e_garantia__c, Procesado__c, Estado_ejecucion__c, Tipo_registro__c, Tipo__c
                                         FROM AuxiliarAdicionalVehiculo__c WHERE Procesado__c = false AND Tipo_registro__c in :tiposRegistros AND Grupo_Marca__c = :codigo  order by Tipo_registro__c desc]);
    }
    
    global void execute(Database.BatchableContext bc, List<AuxiliarAdicionalVehiculo__c> lstAuxAd) {
        
        Set<String> vins = new Set<String>();
        List<Vehiculo__c> vehiculosToUpdate = new List<Vehiculo__c>();
        Map<String,List<AuxiliarAdicionalVehiculo__c>> mapAuxAdVehicleByVIN = new Map<String,List<AuxiliarAdicionalVehiculo__c>>();
        
        //List<CargaAuxiliares__c> cAux = [select id, Name, Inicio_Ejecucion__c, IdsAuxiliares__c, Principal__c from CargaAuxiliares__c where Name = :Label.TitleAddInfoVehicle and Principal__c = true];
        //CargaAuxiliares__c cargaAuxiliar = cAux[0];
        
        if(!lstAuxAd.isEmpty()){ 
            inicioEjecucion = true;
            //if(!cargaAuxiliar.Inicio_Ejecucion__c){
            //	system.debug('entra inicioEjecucion');
            //	cargaAuxiliar.Inicio_Ejecucion__c = true;
            //	update cargaAuxiliar;
        	//}
            
            //CargaAuxiliares__c cargaAuxiliarCod = new CargaAuxiliares__c();
            //cargaAuxiliarCod.Name = cargaAuxiliar.Name;
            //cargaAuxiliarCod.IdsAuxiliares__c='';
        
            for(Integer i=0; i<lstAuxAd.size();i++){
                if(!String.isEmpty(lstAuxAd[i].VIN__c)){
                    List<AuxiliarAdicionalVehiculo__c> listAuxAdAux = mapAuxAdVehicleByVIN.containsKey(lstAuxAd[i].VIN__c) ? mapAuxAdVehicleByVIN.get(lstAuxAd[i].VIN__c):new List<AuxiliarAdicionalVehiculo__c>();
                    listAuxAdAux.add(lstAuxAd[i]);
                    mapAuxAdVehicleByVIN.put(lstAuxAd[i].VIN__c, listAuxAdAux);
                    if(lstAuxAd[i].Tipo_registro__c.equalsIgnoreCase(Label.TRContratoVehiculo)){
                        //if(i+1<lstAuxAd.size()){
                       //     cargaAuxiliarCod.IdsAuxiliares__c +=lstAuxAd[i].VIN__c+',';
                       // }
                       // else{ cargaAuxiliarCod.IdsAuxiliares__c +=lstAuxAd[i].VIN__c;}
                        vinProcesoModificado.add(lstAuxAd[i].VIN__c);
                    }
                    vins.add(lstAuxAd[i].VIN__c);
                    
                }
                //inicialmente todos con problemas
                lstAuxAd[i].Estado_ejecucion__c='KO, problemas con el VIN';
                lstAuxAd[i].Procesado__c=true;
                
            }
            if(!vins.isEmpty()){
                List<Vehiculo__c> listVehs =[SELECT Id, VIN__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, Kms_contrato_prestacion__c, PR_Number__c, Contrato_modalidad__c,Contrato_Servicio_1__c, Contrato_Servicio_2__c,
                                             Contrato_Servicio_3__c, Contrato_Servicio_4__c, Contrato_Servicio_5__c, Contrato_Servicio_6__c, Contrato_Servicio_7__c, Contrato_Servicio_8__c, Contrato_Servicio_9__c, Contrato_Servicio_10__c
                                             FROM  Vehiculo__c where VIN__c in :vins];
                for(Vehiculo__c veh : listVehs){
                    List<AuxiliarAdicionalVehiculo__c> listAuxAdVehs = mapAuxAdVehicleByVIN.containsKey(veh.VIN__c)?mapAuxAdVehicleByVIN.get(veh.VIN__c):null;
                    if(listAuxAdVehs != null){
                        for(AuxiliarAdicionalVehiculo__c auxAdVeh :listAuxAdVehs){
                            if(auxAdVeh.Tipo_registro__c.equalsIgnoreCase(Label.TRContratoVehiculo)){
                                veh.Contrato_modalidad__c = auxAdVeh.Contrato_modalidad__c;
                                veh.Contrato_Servicio_1__c = auxAdVeh.Contrato_Servicio_1__c;
                                veh.Contrato_Servicio_2__c = auxAdVeh.Contrato_Servicio_2__c;
                                veh.Contrato_Servicio_3__c = auxAdVeh.Contrato_Servicio_3__c;
                                veh.Contrato_Servicio_4__c = auxAdVeh.Contrato_Servicio_4__c;
                                veh.Contrato_Servicio_5__c = auxAdVeh.Contrato_Servicio_5__c;
                                veh.Contrato_Servicio_6__c = auxAdVeh.Contrato_Servicio_6__c;
                                veh.Contrato_Servicio_7__c = auxAdVeh.Contrato_Servicio_7__c;
                                veh.Contrato_Servicio_8__c = auxAdVeh.Contrato_Servicio_8__c;
                                veh.Contrato_Servicio_9__c = auxAdVeh.Contrato_Servicio_9__c;
                                veh.Contrato_Servicio_10__c = auxAdVeh.Contrato_Servicio_10__c;
                            }
                            else {
                                veh.Fecha_contrato_inicio_e_garantia__c = auxAdVeh.Fecha_contrato_inicio_e_garantia__c;
                                veh.Fecha_contrato_fin_e_garantia__c = auxAdVeh.Fecha_contrato_fin_e_garantia__c;
                                veh.Kms_contrato_prestacion__c = auxAdVeh.Kms_contrato_prestacion__c;
                                veh.PR_Number__c = auxAdVeh.PR_Number__c;
                            }
                            //operación realizada correctamente
                            auxAdVeh.Estado_ejecucion__c = 'OK';
                            
                        }
                    }
                    vehiculosToUpdate.add(veh);
                }
            }
            
            if(!lstAuxAd.isEmpty()){
                upsert lstAuxAd;
            }
            if(!vehiculosToUpdate.isEmpty()){
                upsert vehiculosToUpdate;
            }
            
            //insert cargaAuxiliarCod;
    	}
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('inicia finish');
        
        //CargaAuxiliares__c cAuxPrincipal;
        //List<String> codigos = new List<String>();
        //List<CargaAuxiliares__c> listCargaAuxiliarToDelete = new List<CargaAuxiliares__c>();
        //List<CargaAuxiliares__c> listCargaAux = [select id, Name, Inicio_Ejecucion__c, IdsAuxiliares__c, Principal__c from CargaAuxiliares__c where Name = :Label.TitleAddInfoVehicle ];
        //for(CargaAuxiliares__c cAux :listCargaAux){
         //   if(cAux.Principal__c){
         //       cAuxPrincipal = cAux;
         //   }
         //   else{
         //       List<String> codAux = cAux.IdsAuxiliares__c != null ? cAux.IdsAuxiliares__c.split(','): new List<String>();
        //        if(!codAux.isEmpty()){
        //            codigos.addAll(codAux);
        //        } 
        //        listCargaAuxiliarToDelete.add(cAux);
        //    }
       // }
        
        //if(cAuxPrincipal.Inicio_Ejecucion__c){
        if(inicioEjecucion){
            system.debug('dentro inicioEjecucion ');
            List<String> marcas = mapMarcasByGrupo.get(grupoMarca);
    	    //List<Vehiculo__c> vehiculosToUpdate = [Select Id, VIN__c, Contrato_modalidad__c  From Vehiculo__c where Contrato_modalidad__c != null AND VIN__c NOT IN :codigos];
            List<Vehiculo__c> vehiculosToUpdate = [Select Id, VIN__c, Contrato_modalidad__c  From Vehiculo__c where Contrato_modalidad__c != null AND MarcaString__c  IN :marcas AND VIN__c NOT IN :vinProcesoModificado];
            for(Vehiculo__c veh :vehiculosToUpdate){
                veh.Contrato_modalidad__c =null;
                veh.Contrato_Servicio_1__c = null;
                veh.Contrato_Servicio_2__c = null;
                veh.Contrato_Servicio_3__c = null;
                veh.Contrato_Servicio_4__c = null;
                veh.Contrato_Servicio_5__c = null;
                veh.Contrato_Servicio_6__c = null;
                veh.Contrato_Servicio_7__c = null;
                veh.Contrato_Servicio_8__c = null;
                veh.Contrato_Servicio_9__c = null;
                veh.Contrato_Servicio_10__c = null;
                
            }
            if(!vehiculosToUpdate.isEmpty()){
                upsert vehiculosToUpdate;
            }
            
            //cAuxPrincipal.Inicio_Ejecucion__c =false;
            //update cAuxPrincipal;
            //delete listCargaAuxiliarToDelete;
        }
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AddInfoContractVehicleBatch(this.grupoMarca));
        
    }


}