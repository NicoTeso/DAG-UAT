public class PaisGateway {
    /*Todavia no se utiliza
    public static Pais__c getPaisById(String identificador) {
        Pais__c pais;
        
        if (!String.isBlank(identificador)) {
            Map<String, Pais__c> mapIdToPais = getPaisById(new List<String>{identificador});
            
            if (!mapIdToPais.isEmpty()) {
                pais = mapIdToPais.get(identificador);
            }
        }
        
        return pais;
    }
	*/
    public static Map<String, Pais__c> getPaisById(List<String> listId) {
        Map<String, Pais__c> mapIdToPais = new Map<String, Pais__c>();
        
        if (!listId.isEmpty()) {
            List<Pais__c> paises = [SELECT Id, ISO_31661_alfa2__c, ISO_31661_alfa3__c, ISO_31661_numerico__c
                                    FROM Pais__c
                                    WHERE Id in :listId
                                    LIMIT 2000];
            
            for (Pais__c pais : paises) {
                mapIdToPais.put(pais.Id, pais);
            }
        }
        
        return mapIdToPais;
    }
	
	/*
	* Countries by two letters code
	*/    
    public static Pais__c getPaisByAlfa2(String identificador) {
        Pais__c pais;
        
        if (!String.isBlank(identificador)) {
            Map<String, Pais__c> mapCodeToPais = getPaisByAlfa2(new List<String>{identificador});
            
            if (!mapCodeToPais.isEmpty()) {
                pais = mapCodeToPais.get(identificador);
            }
        }
        
        return pais;
    }

    public static Map<String, Pais__c> getPaisByAlfa2(List<String> listId) {
        Map<String, Pais__c> mapCodeToPais = new Map<String, Pais__c>();
        
        if (!listId.isEmpty()) {
            List<Pais__c> paises = [SELECT Id, Name, ISO_31661_alfa2__c, ISO_31661_alfa3__c, ISO_31661_numerico__c
                                    FROM Pais__c
                                    WHERE ISO_31661_alfa2__c in :listId
                                    LIMIT 2000];
            
            for (Pais__c pais : paises) {
                mapCodeToPais.put(pais.ISO_31661_alfa2__c, pais);
            }
        }
        
        return mapCodeToPais;
    }
    
    public static Pais__c getPaisByName(String identificador) {
        Pais__c pais;
        
        if (!String.isBlank(identificador)) {
            Map<String, Pais__c> mapCodeToPais = getPaisByAlfa2(new List<String>{identificador});
            
            if (!mapCodeToPais.isEmpty()) {
                pais = mapCodeToPais.get(identificador);
            }
        }
        
        return pais;
    }

    public static Map<String, Pais__c> getPaisByName(List<String> listName) {
        Map<String, Pais__c> mapCodeToPais = new Map<String, Pais__c>();
        
        if (!listName.isEmpty()) {
            List<Pais__c> paises = [SELECT Id, Name, ISO_31661_alfa2__c, ISO_31661_alfa3__c, ISO_31661_numerico__c
                                    FROM Pais__c
                                    WHERE Name in :listName
                                    LIMIT 2000];
            
            for (Pais__c pais : paises) {
                mapCodeToPais.put(pais.Name, pais);
            }
        }
        
        return mapCodeToPais;
    }
}