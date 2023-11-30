public class CampaignGateway {
public static Campaign getCampaignById(String id) {
        Campaign campania;
        
        if (!String.isBlank(id)) {
            Map<String, Campaign> mapIdToCampaign = getCampaignById(new List<String>{id});
            
            if (!mapIdToCampaign.isEmpty()) {
                campania = mapIdToCampaign.get(id);
            }
        }
        
        return campania;
    }

    public static Map<String, Campaign> getCampaignById(List<String> lstId) {
        Map<String, Campaign> mapIdToCampaign = new Map<String, Campaign>();
        
        if (!lstId.isEmpty()) {
            for (Campaign campania :  [SELECT Id,Name, Marca__c, Status, Type FROM Campaign WHERE Id in :lstId LIMIT 2000]) {
                mapIdToCampaign.put(campania.Id, campania);
            }
        }
        
        return mapIdToCampaign;
    }
    
}