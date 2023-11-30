public class DeleteAccountMarketingGateway {
    
    public static Delete_Account_Marketing__c getDAMByRegId(String identificador) {
        Delete_Account_Marketing__c dam;
        if (!String.isBlank(identificador)) {
            Map<String, Delete_Account_Marketing__c> mapRegIdToDAM = getDAMByRegId(new List<String>{identificador});
            if (!mapRegIdToDAM.isEmpty()) {
                dam = mapRegIdToDAM.get(identificador);
            }
        }
        
        return dam;
    }
   
    public static Map<String, Delete_Account_Marketing__c> getDAMByRegId(List<String> listRegId) {
        Map<String, Delete_Account_Marketing__c> mapRegIdToDAM = new Map<String, Delete_Account_Marketing__c>();
        if (!listRegId.isEmpty()) {
            List<Delete_Account_Marketing__c> listDam = [SELECT Id, Fecha_eliminacion__c, RecordId__c from Delete_Account_Marketing__c 
                                                          WHERE RecordId__c in :listRegId
                                                            AND Fecha_eliminacion__c > TODAY
                                                          LIMIT 2000]; 
            for(Delete_Account_Marketing__c dam : listDam) {
                mapRegIdToDAM.put(dam.RecordId__c, dam);
            }
        }
        
        return mapRegIdToDAM;
    }
    
}