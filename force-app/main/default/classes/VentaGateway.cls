public class VentaGateway {
   /*Para eliminar
    public static Venta__c getVentaById(String id) {
        Venta__c sale;
        
        if (!String.isBlank(id)) {
            Map<String, Venta__c> mapIdToSale = VentaGateway.getVentaById(new List<String>{id});
            sale = mapIdToSale.containsKey(id) ? mapIdToSale.get(id) : null;
        }
        
        return sale;
    }
    
    public static Map<String, Venta__c> getVentaById(List<String> lstIds) {
        Map<String, Venta__c> mapIdToSale = new Map<String, Venta__c>();
        
        if (!lstIds.isEmpty()) {
            for (Venta__c sale : [SELECT Id, Name, ID_Venta_DMS__c,  Comprador__c, Concesionario__c, Centro__c
                                  FROM Venta__c WHERE Id in :lstIds LIMIT 2000]) {
                
                mapIdToSale.put(sale.Id, sale);
            }
        }
        
        return mapIdToSale;
    }
    
	public static Venta__c getVentaBySalesProcessId(String salesProcessId) {
        Venta__c sale;
        
        if (!String.isBlank(salesProcessId)) {
            Map<String, Venta__c> mapSalesProcessIdToSale = VentaGateway.getVentaBySalesProcessId(new List<String>{salesProcessId});
            sale = mapSalesProcessIdToSale.containsKey(salesProcessId) ? mapSalesProcessIdToSale.get(salesProcessId) : null;
        }
        
        return sale;
    }
    
    public static Map<String, Venta__c> getVentaBySalesProcessId(List<String> lstSalesProcessId) {
        Map<String, Venta__c> mapSalesProcessIdToSale = new Map<String, Venta__c>();
        
        if (!lstSalesProcessId.isEmpty()) {
            for (Venta__c sale : [SELECT Id, Name, ID_Venta_DMS__c,  Comprador__c, Concesionario__c
                                  FROM Venta__c WHERE ID_Venta_DMS__c in :lstSalesProcessId LIMIT 2000]) {
                
                mapSalesProcessIdToSale.put(sale.ID_Venta_DMS__c, sale);
            }
        }
        
        return mapSalesProcessIdToSale;
    }
		*/
}