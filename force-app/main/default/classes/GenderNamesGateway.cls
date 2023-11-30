public class GenderNamesGateway {
    public static Genero_de_Nombre__c getGenderNamesByNombrePais(String NombrePais) {
        Genero_de_Nombre__c GenderName;
        
        if (!String.isBlank(NombrePais)) {
            Map<String, Genero_de_Nombre__c> mapGenderNames = getGenderNamesByNombrePais(new List<String>{NombrePais});
            
            if (!mapGenderNames.isEmpty()) {
                GenderName = mapGenderNames.get(NombrePais);
            }
        }
        
        return GenderName;
    }

    public static Map<String, Genero_de_Nombre__c> getGenderNamesByNombrePais(List<String> lstNombrePais) {
        Map<String, Genero_de_Nombre__c> mapGenderNames = new Map<String, Genero_de_Nombre__c>();
        
        if (!lstNombrePais.isEmpty()) {
            List<Genero_de_Nombre__c> lstGenderNames = [SELECT Id, Nombre_Pais__c, Genero_Asignado__c 
                                                          FROM Genero_de_Nombre__c 
                                                         WHERE Nombre_Pais__c IN :lstNombrePais
                                                         LIMIT 2000];
            
            for (Genero_de_Nombre__c GenderName : lstGenderNames) {
                mapGenderNames.put(GenderName.Nombre_Pais__c, GenderName);
            }
        }
        
        return mapGenderNames;
    }

}