public class ModeloGateway {
    /*Todavia no se utiliza
	public static Modelo__c getmodelById(String id) {
        Modelo__c model;
        
        if (!String.isBlank(id)) {
            Map<String, Modelo__c> mapIdToModel = getModelById(new List<String>{id});
            
            if (!mapIdToModel.isEmpty()) {
                model = mapIdToModel.get(id);
            }
        }
        
        return model;
    }
    */
    /*Todavia no se utiliza
    public static Map<String, Modelo__c> getModelById(List<String> lstId) {
        Map<String, Modelo__c> mapIdToModel = new Map<String, Modelo__c>();
        
        if (!lstId.isEmpty()) {
            List<Modelo__c> lstModels = [SELECT Id,
												Name
                                     	 FROM Modelo__c
                                    	 WHERE Id in :lstId
                                    	 LIMIT 2000];
            
            for (Modelo__c model : lstModels) {
                mapIdToModel.put(model.Id, model);
            }
        }
        
        return mapIdToModel;
    }
    */
	/*Todavia no se utiliza
    public static Modelo__c getModelByName(String modelName) {
        Modelo__c model;
        
        if (!String.isBlank(modelName)) {
        	Map<String, Modelo__c> mapNameToModel = ModeloGateway.getModelsByName(new List<String>{modelName});
        	model = mapNameToModel.containsKey(modelName) ? mapNameToModel.get(modelName) : null;
        }
        
        return model;
    }
    */
	/*Todavia no se utiliza
    public static Map<String, Modelo__c> getModelsByName(List<String> lstModels) {
        Map<String, Modelo__c> mapModels = new Map<String, Modelo__c>();
        
        if (!lstModels.isEmpty()) {
            for (Modelo__c model : [SELECT Id, Name FROM Modelo__c WHERE Name in :lstModels LIMIT 2000]) {
                mapModels.put(model.Name, model);
            }
        }
        
        return mapModels;
    }
	*/
}