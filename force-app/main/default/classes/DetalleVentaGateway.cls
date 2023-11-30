public class DetalleVentaGateway {
    public static Detalle_venta__c getDetalleVentaById(String id) {
        Detalle_venta__c saleDetail;
        
        if (!String.isBlank(id)) {
            Map<String, Detalle_venta__c> mapIdToSaleDetail = getDetalleVentaById(new List<String>{id});
            saleDetail = mapIdToSaleDetail.containsKey(id) ? mapIdToSaleDetail.get(id) : null;
        }
        
        return saleDetail;
    }
    
    public static Map<String, Detalle_venta__c> getDetalleVentaById(List<String> lstIds) {
        Map<String, Detalle_venta__c> mapIdToSaleDetail = new Map<String, Detalle_venta__c>();
        
        if (!lstIds.isEmpty()) {
            for (Detalle_venta__c saleDetail : [SELECT Id, Name, Vehiculo__c, External_Id__c, Opportunity__c, Intermediario__c,
                                                Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Centro__c, Propietario__c, Fecha_de_entrega__c, Comprador__c, 
                                                Vendedor__c, Vendedor__r.Name, Vendedor__r.Email__c, Vendedor__r.Phone__c,
                                                Vehiculo__r.MarcaString__c, Vehiculo__r.Name, Vehiculo__r.modelDescription__c, Vehiculo__r.VIN__c, Vehiculo__r.ModeloString__c,
                                                Propietario__r.Name, 
                                                Propietario__r.PersonEmail, Propietario__r.OtherEmail__pc, Propietario__r.PersonMobilePhone, 
                                                Propietario__r.OtherMobilePhone__pc, Propietario__r.Phone, Propietario__r.PersonOtherPhone,
                                                CompradorTXT__c, PropietarioTXT__c
                                                FROM Detalle_venta__c
                                                WHERE Id in :lstIds LIMIT 2000]) {
                
                mapIdToSaleDetail.put(saleDetail.Id, saleDetail);
            }
        }
        
        return mapIdToSaleDetail;
    }
    
    public static Detalle_venta__c getDetalleVentaByExternalId(String externalId) {
         Detalle_venta__c detalleVenta;
        
        if (!String.isBlank(externalId)) {
            Map<String,Detalle_venta__c> mapDetalleVentaByExternalId = DetalleVentaGateway.getDetalleVentaByExternalId(new List<String>{externalId});
            
            if (!mapDetalleVentaByExternalId.isEmpty()) {
                detalleVenta = mapDetalleVentaByExternalId.get(externalId); 
            }
        }
        
        return detalleVenta;
    }
    
    public static Map<String, Detalle_venta__c> getDetalleVentaByExternalId(List<String> listExternalId) {
        Map<String, Detalle_venta__c> mapDVentaByExternalId = new Map<String, Detalle_venta__c>();
        
        if (!listExternalId.isEmpty()) {
            for (Detalle_venta__c dVenta : [SELECT Id, Name, Vehiculo__c, External_Id__c, Opportunity__c, Intermediario__c,
                                                Concesionario__c, Centro__c, Propietario__c, Fecha_de_entrega__c, Comprador__c, 
                                                Vendedor__c, Vendedor__r.Name,
                                                CompradorTXT__c, PropietarioTXT__c
                                            FROM Detalle_venta__c WHERE  External_Id__c in :listExternalId]) {
                mapDVentaByExternalId.put(dVenta.External_Id__c, dVenta);
            }
        }
        return mapDVentaByExternalId;
    }

    public static Detalle_venta__c getDetalleVentaByOpportunityId(String opportunityId) {
         Detalle_venta__c detalleVenta;
        
        if (!String.isBlank(opportunityId)) {
            Map<String,Detalle_venta__c> mapDetalleVentaByOpportunityId = DetalleVentaGateway.getDetalleVentaByOpportunityId(new List<String>{opportunityId});
            
            if (!mapDetalleVentaByOpportunityId.isEmpty()) {
                detalleVenta = mapDetalleVentaByOpportunityId.get(opportunityId); 
            }
        }
        
        return detalleVenta;
    }
    
    public static Map<String, Detalle_venta__c> getDetalleVentaByOpportunityId(List<String> listOpportunityId) {
        Map<String, Detalle_venta__c> mapDVentaByOpportunityId = new Map<String, Detalle_venta__c>();
        
        if (!listOpportunityId.isEmpty()) {
            for (Detalle_venta__c dVenta : [SELECT Id, Name, Vehiculo__c, External_Id__c, Opportunity__c, Intermediario__c,
                                                Concesionario__c, Centro__c, Propietario__c, Fecha_de_entrega__c, Comprador__c, 
                                                Vendedor__c, Vendedor__r.Name, Vendedor__r.Email__c, Propietario__r.Name, 
                                                Propietario__r.PersonEmail, Propietario__r.OtherEmail__pc, Propietario__r.PersonMobilePhone, 
                                                Propietario__r.OtherMobilePhone__pc, Propietario__r.Phone, Propietario__r.PersonOtherPhone,   
                                                Centro__r.Activo__c, Centro__r.Gestiona_LEAD__c, Centro__r.Id_Centro_Sima__c,
                                                CompradorTXT__c, PropietarioTXT__c
                                            
                                            FROM Detalle_venta__c WHERE  Opportunity__c in :listOpportunityId
                                            ORDER by CreatedDate desc]) {
                mapDVentaByOpportunityId.put(dVenta.Opportunity__c, dVenta);
            }
        }
        return mapDVentaByOpportunityId;
    }

    public static Detalle_venta__c getDetalleVentaByVin(String vin) {
         Detalle_venta__c detalleVenta;
        
        if (!String.isBlank(vin)) {
            Map<String,Detalle_venta__c> mapDetalleVentaByVin = DetalleVentaGateway.getDetalleVentaByVin(new List<String>{vin});
            
            if (!mapDetalleVentaByVin.isEmpty()) {
                detalleVenta = mapDetalleVentaByVin.get(vin); 
            }
        }
        
        return detalleVenta;
    }
    
    public static Map<String, Detalle_venta__c> getDetalleVentaByVin(List<String> listVin) {
        Map<String, Detalle_venta__c> mapDVentaByVin = new Map<String, Detalle_venta__c>();
        
        if (!listVin.isEmpty()) {
            for (Detalle_venta__c dVenta : [SELECT Id, Name, Vehiculo__c,Vehiculo__r.VIN__c,
                                                Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c
                                            FROM Detalle_venta__c WHERE Vehiculo__r.VIN__c  in :listVin
                                            ORDER by CreatedDate desc]) {
                mapDVentaByVin.put(dVenta.Vehiculo__r.VIN__c, dVenta);
            }
        }
        return mapDVentaByVin;
    }
    
}