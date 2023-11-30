public class MarcaGateway {
    /*Todavia no se utiliza
	public static Marca__c getmodelById(String id) {
        Marca__c brand;
        
        if (!String.isBlank(id)) {
            Map<String, Marca__c> mapIdToBrand = getBrandById(new List<String>{id});
            
            if (!mapIdToBrand.isEmpty()) {
                brand = mapIdToBrand.get(id);
            }
        }
        
        return brand;
    }
    */
    /*Todavi no se utiliza
    public static Map<String, Marca__c> getBrandById(List<String> lstId) {
        Map<String, Marca__c> mapIdToBrand = new Map<String, Marca__c>();
        
        if (!lstId.isEmpty()) {
            List<Marca__c> lstBrands = [SELECT Id,
											   Name
                                     	FROM Marca__c
                                    	WHERE Id in :lstId
                                    	LIMIT 2000];
            
            for (Marca__c brand : lstBrands) {
                mapIdToBrand.put(brand.Id, brand);
            }
        }
        
        return mapIdToBrand;
    }
    */
    /*Todavia no se utiliza
    public static Marca__c getBrandByName(String brandName) {
        Marca__c brand;
        
        if (!String.isBlank(brandName)) {
        	Map<String, Marca__c> mapNameToBrand = MarcaGateway.getBrandsByName(new List<String>{brandName});
        	brand = mapNameToBrand.containsKey(brandName) ? mapNameToBrand.get(brandName) : null;
        }
        
        return brand;
    }
    */
    /*Todavia no se utiliza
    public static Map<String, Marca__c> getBrandsByName(List<String> lstBrands) {
        Map<String, Marca__c> mapBrands = new Map<String, Marca__c>();
        
        if (!lstBrands.isEmpty()) {
            for (Marca__c brand : [SELECT Id, Name FROM Marca__c WHERE Name in :lstBrands LIMIT 2000]) {
                mapBrands.put(brand.Name, brand);
            }
        }
        
        return mapBrands;
    }
	*/
}