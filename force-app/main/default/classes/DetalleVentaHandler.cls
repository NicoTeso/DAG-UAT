public with sharing class DetalleVentaHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String,Vehiculo__c> mapVehiculoById = new Map<String,Vehiculo__c>();
    public Map<String,Opportunity> mapOpportunityByExternalId = new Map<String,Opportunity>();
   
    public Map<String,Vehiculo__c> mapVehiculoToUpdate = new Map<String,Vehiculo__c>();
    public Map<String, List<Detalle_Oferta__c>> mapDetalleOfertaByOpp = new Map<String,List<Detalle_Oferta__c>>();
    public Map<String,Centro__c> mapCentroById = new Map<String,Centro__c>();
    public Triggers__c triggerSettings;
    public Map<Id, Case> mapCase;
    
 
    public DetalleVentaHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
        triggerSettings = Triggers__c.getInstance(UserInfo.getUserId());
        system.debug('DetalleVentaHandler triggerSettings: '+ triggerSettings);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {

        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de migración
        if(triggerSettings != null && triggerSettings.Active_Migration__c){
            mapVehiculoById.clear();
            // mapOpportunityById.clear();
            mapDetalleOfertaByOpp.clear();
            List<String> vehiculosId = new List<String>();
            List<String> centrosId = new List<String>();
            List<String> externalSalesProcessId = new List<String>();
        
            if (Trigger.new != null) {
                for (SObject objeto : Trigger.New) {
                    Detalle_venta__c dVenta = (Detalle_venta__c) objeto;
                    if (dVenta.Vehiculo__c != null) {
                        vehiculosId.add(dVenta.Vehiculo__c);
                    }
                    if(dVenta.Centro__c != null){
                        centrosId.add(dVenta.Centro__c);
                    }
                    if(dVenta.Opportunity__c== null && !String.isBlank(dVenta.External_Id__c)){
                        List<String> splitExternalId = dVenta.External_Id__c.split('/');
                        if(splitExternalId != null && !splitExternalId.isEmpty()){
                            externalSalesProcessId.add(splitExternalId[0]);
                        }
                    }
                }
                if(!vehiculosId.isEmpty()){
                    mapVehiculoById = VehiculoGateway.getVehicleById(vehiculosId);
                }
                if(!centrosId.isEmpty()){
                    mapCentroById = CentroGateway.getCenterById(centrosId);
                }
                if(!externalSalesProcessId.isEmpty()){
                    mapOpportunityByExternalId = OpportunityGateway.getOppByIdVentaDMS(externalSalesProcessId);
                }
            }
        }
        //24-11-21 Fin DBI Encapsulado para que solo se ejecute en caso de migración
   }

    public void bulkAfter() {
        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de migración
        if(triggerSettings != null && triggerSettings.Active_Migration__c){
            mapVehiculoToUpdate.clear();
            List<String> vehiculosId = new List<String>();
            List<String> opportunityId = new List<String>();
        
            if (Trigger.new != null) {
                for (SObject objeto : Trigger.New) {
                    Detalle_venta__c dVenta = (Detalle_venta__c) objeto;
                    if (dVenta.Vehiculo__c != null) {
                        vehiculosId.add(dVenta.Vehiculo__c);
                    }
                    if(dVenta.Opportunity__c != null){
                        opportunityId.add(dVenta.Opportunity__c);
                    }
                }
                
                if(!vehiculosId.isEmpty() && mapVehiculoById.isEmpty() ){
                    mapVehiculoById = VehiculoGateway.getVehicleById(vehiculosId);
                }
                if(!opportunityId.isEmpty()){
            //      mapOpportunityById = OpportunityGateway.getOppById(opportunityId);
                    mapDetalleOfertaByOpp = DetalleOfertaGateway.getDOfertaByOppId(opportunityId);
                }
            }
        }
        //24-11-21 Fin DBI Encapsulado para que solo se ejecute en caso de migración 
        
        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de NO migración
        if(triggerSettings != null && !triggerSettings.Active_Migration__c){
            if (Trigger.new != null) {
                Map<String,Detalle_venta__c> mapVIN = new Map<String,Detalle_venta__c>();
                Map<Id,Detalle_venta__c> mapPropietarios = new Map<Id,Detalle_venta__c>();
                mapCase = new Map<Id,Case>();
                for (SObject objeto : Trigger.New) {
                    Detalle_venta__c dVenta = (Detalle_venta__c) objeto;
                    System.debug('DetalleVentaHandler.bulkAfter dVenta.External_Id__c ' + dVenta.External_Id__c + ' dVenta.Propietario__c ' + dVenta.Propietario__c + ' dVenta..Fecha_de_entrega__c ' + dVenta.Fecha_de_entrega__c);
                    if (String.isNotBlank(dVenta.External_Id__c) && String.isNotBlank(dVenta.External_Id__c.subStringAfter('/')) && dVenta.Fecha_de_entrega__c != null) {
                        mapVIN.put(dVenta.External_Id__c.subStringAfter('/'),dVenta);
                    }
                    if (dVenta.Propietario__c != null && dVenta.Fecha_de_entrega__c != null) {
                        mapPropietarios.put(dVenta.Propietario__c, dVenta);
                    }
                }
                System.debug('DetalleVentaHandler.bulkAfter mapVIN ' + mapVIN);
                System.debug('DetalleVentaHandler.bulkAfter mapPropietarios ' + mapPropietarios);

                if( (mapVIN != null && !mapVIN.isEmpty()) || (mapPropietarios != null && !mapPropietarios.isEmpty()) && Case.getSObjectType().getDescribe().isAccessible() ){
                    for(Case c : [
                        SELECT Id, VIN__c, AccountId, Cliente_con_venta_posterior__c, Vehiculo_vendido__c, CreatedDate, Vehiculo_stock_VO_1__c,	Vehiculo_stock_VO_2__c,	Vehiculo_stock_VO_3__c
                        FROM Case
                        WHERE RecordType.DeveloperName = 'Gestion_de_Lead_VO' AND (VIN__c IN :mapVIN.keySet() OR AccountId IN :mapPropietarios.keySet())
                    ]){
                        System.debug('DetalleVentaHandler.bulkAfter c ' + c);
                        if(!c.Vehiculo_vendido__c && String.isNotBlank(c.VIN__c) && mapVIN.containsKey(c.VIN__c) && c.CreatedDate <= mapVIN.get(c.VIN__c).Fecha_de_entrega__c ){
                            c.Vehiculo_vendido__c = true;
                            mapCase.put(c.Id,c);
                        }
                        //if de cliente venta posterior
                        if(!c.Cliente_con_venta_posterior__c && c.AccountId != null && mapPropietarios != null && mapPropietarios.containsKey(c.AccountId) && c.CreatedDate <= mapPropietarios.get(c.AccountId).Fecha_de_entrega__c && mapCase.containsKey(c.Id)){
                            c.Vehiculo_vendido__c = true;
                            c.Cliente_con_venta_posterior__c = true;
                            c.Vehiculo_stock_VO_1__c = null;	
                            c.Vehiculo_stock_VO_2__c = null;	
                            c.Vehiculo_stock_VO_3__c = null;
                            mapCase.put(c.Id,c);
                        }else if(!c.Cliente_con_venta_posterior__c && c.AccountId != null && mapPropietarios != null && mapPropietarios.containsKey(c.AccountId) && c.CreatedDate <= mapPropietarios.get(c.AccountId).Fecha_de_entrega__c && !mapCase.containsKey(c.Id)){
                            c.Cliente_con_venta_posterior__c = true;
                            c.Vehiculo_stock_VO_1__c = null;	
                            c.Vehiculo_stock_VO_2__c = null;	
                            c.Vehiculo_stock_VO_3__c = null;
                            mapCase.put(c.Id,c);
                        }
                    }
                    System.debug('DetalleVentaHandler.bulkAfter mapCase ' + mapCase);
                }
            }
        }
        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de NO migración
    }

    public void beforeInsert(sObject so) {
        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de migración
        if(triggerSettings != null && triggerSettings.Active_Migration__c){
            Detalle_venta__c dVenta =(Detalle_venta__c) so;
            List<String> splitExternalId = !String.isBlank(dVenta.External_Id__c)? dVenta.External_Id__c.split('/'):new List<String>();
            if(dVenta.Vehiculo__c != null && mapVehiculoById.containsKey(dVenta.Vehiculo__c)){
                Vehiculo__c veh = mapVehiculoById.get(dVenta.Vehiculo__c);
                dVenta.Propietario__c = dVenta.Propietario__c == null?veh.Propietario__c: dVenta.Propietario__c;
                dVenta.Comprador__c = dVenta.Comprador__c == null? veh.Comprador__c:dVenta.Comprador__c;
                if(dVenta.Centro__c != null && mapCentroById.containsKey(dVenta.Centro__c)){
                    Centro__c centro = mapCentroById.get(dVenta.Centro__c);
                    dVenta.Name = centro.Concesionario__r.Nombre_Comercial__c +'/'+centro.Id_Centro_Sima__c +'/'+veh.MarcaString__c +'/'+veh.VIN__c;
                }
                else {
                    dVenta.Name = veh.MarcaString__c+'/'+veh.VIN__c;
                }
            }
            if(dVenta.Opportunity__c == null && !splitExternalId.isEmpty() && mapOpportunityByExternalId.containsKey(splitExternalId[0])){
                Opportunity opp = mapOpportunityByExternalId.get(splitExternalId[0]);
                dVenta.Opportunity__c = opp.Id;
                dVenta.Vendedor__c = opp.Vendedor__c;
            }
        }
        //24-11-21 Fin DBI Encapsulado para que solo se ejecute en caso de migración
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de migración
        if(triggerSettings != null && triggerSettings.Active_Migration__c){
            Detalle_venta__c dVenta =(Detalle_venta__c) so;
            List<String> splitExternalId = !String.isBlank(dVenta.External_Id__c)? dVenta.External_Id__c.split('/'):new List<String>();
            if(dVenta.Vehiculo__c != null && mapVehiculoById.containsKey(dVenta.Vehiculo__c)){
                Vehiculo__c veh = mapVehiculoById.get(dVenta.Vehiculo__c);
                dVenta.Propietario__c = dVenta.Propietario__c== null ? veh.Propietario__c: dVenta.Propietario__c;
                dVenta.Comprador__c = dVenta.Comprador__c == null ? veh.Comprador__c: dVenta.Comprador__c;
                if(dVenta.Centro__c != null && mapCentroById.containsKey(dVenta.Centro__c)){
                    Centro__c centro = mapCentroById.get(dVenta.Centro__c);
                    dVenta.Name = centro.Concesionario__r.Nombre_Comercial__c +'/'+centro.Id_Centro_Sima__c +'/'+veh.MarcaString__c +'/'+veh.VIN__c;
                }
                else {
                    dVenta.Name = veh.MarcaString__c+'/'+veh.VIN__c;
                }
            }
            if(dVenta.Opportunity__c == null && !splitExternalId.isEmpty() && mapOpportunityByExternalId.containsKey(splitExternalId[0])){
                Opportunity opp = mapOpportunityByExternalId.get(splitExternalId[0]);
                dVenta.Opportunity__c = opp.Id;
                dVenta.Vendedor__c = opp.Vendedor__c;
            }
        }
        //24-11-21 Fin DBI Encapsulado para que solo se ejecute en caso de migración
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        //24-11-21 Inicio DBI Ya estaba comentado cuando se ha hecho el encapsulamiento para la migración
    /*    Detalle_venta__c dVenta = (Detalle_venta__c) so;
        if(dVenta.Vehiculo__c != null && mapVehiculoById.containsKey(dVenta.Vehiculo__c) 
           && dVenta.Opportunity__c != null && mapDetalleOfertaByOpp.containsKey(dVenta.Opportunity__c)  ){
            Vehiculo__c veh = mapVehiculoById.get(dVenta.Vehiculo__c);
            Vehiculo__c vehiculoToUpdate;
            List<Detalle_Oferta__c> listDOferta = mapDetalleOfertaByOpp.get(dVenta.Opportunity__c);
            for(Detalle_Oferta__c dOferta : listDOferta){
            	if(!String.isBlank(dOferta.vin__c) && dOferta.vin__c.equalsIgnoreCase(veh.VIN__c)){
                	vehiculoToUpdate = new Vehiculo__c();
                    vehiculoToUpdate.Id = veh.Id;
                    vehiculoToUpdate.Accesories__c = dOferta.Accessories__c;
                    vehiculoToUpdate.Services__c = dOferta.Services__c;
                    vehiculoToUpdate.equipments__c = dOferta.Equipment__c;
                    break;
                 }
            }
            if(vehiculoToUpdate != null){
            	mapVehiculoToUpdate.put(vehiculoToUpdate.Id, vehiculoToUpdate);
            }
       	} */
        //24-11-21 Fin DBI Ya estaba comentado cuando se ha hecho el encapsulamiento para la migración

        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de migración
        if(triggerSettings != null && !triggerSettings.Active_Migration__c){

        }
    }
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        
        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de migración
        //if(!mapVehiculoToUpdate.isEmpty()){
        if(triggerSettings != null && triggerSettings.Active_Migration__c && !mapVehiculoToUpdate.isEmpty()){
            update mapVehiculoToUpdate.values();
        }
        //24-11-21 Fin DBI Encapsulado para que solo se ejecute en caso de migración

        //24-11-21 Inicio DBI Encapsulado para que solo se ejecute en caso de NO migración
        //if(!mapVehiculoToUpdate.isEmpty()){
            if(triggerSettings != null && !triggerSettings.Active_Migration__c && mapCase != null && !mapCase.isEmpty()){
                update mapCase.values();
            }
            //24-11-21 Fin DBI Encapsulado para que solo se ejecute en caso de NO migración
    }
}