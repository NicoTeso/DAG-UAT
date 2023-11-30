public class DuplicateRecordItemGateway {
    
    public static Map<String, DuplicateRecordItem> getFirstDRItemByDRSetId(List<String> lstId) {
        Map<String, DuplicateRecordItem> mapFistDRItembyDRSetId = new Map<String, DuplicateRecordItem>();
        
        if (!lstId.isEmpty()) {
            List<DuplicateRecordItem> lstDRItems = [SELECT Id, DuplicateRecordSetId, RecordId  
                                                    FROM DuplicateRecordItem 
                                    				WHERE DuplicateRecordSetId in :lstId ORDER BY DuplicateRecordSetId ];
            
            for (DuplicateRecordItem dri : lstDRItems) {
                if(Lead.sObjectType != dri.RecordId.getSObjectType()){
                    mapFistDRItembyDRSetId.put(dri.DuplicateRecordSetId, dri);
                }
            }
        }
        
        return mapFistDRItembyDRSetId;
    }
    

}