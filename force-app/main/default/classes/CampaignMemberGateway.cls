public class CampaignMemberGateway {
    /*No se utilizan
    public static Map<String,CampaignMember> getMapCOrLToCampaignMemberByCampaignId (String campaigId) {
        Map<String,CampaignMember> mapCOrLToCampaignMember = new Map<String,CampaignMember>();
        
        if (!String.isBlank(campaigId)) {
            Map<String,Map<String, CampaignMember>> mapCOrLToCampaignMemberByCampaignId = getMapCOrLToCampaignMemberByCampaignId(new List<String>{campaigId});
            
            if (!mapCOrLToCampaignMemberByCampaignId.isEmpty()) {
                mapCOrLToCampaignMember = mapCOrLToCampaignMemberByCampaignId.get(campaigId);
            }
        }
        
        return mapCOrLToCampaignMember;
    }

    public static Map<String,Map<String,CampaignMember>> getMapCOrLToCampaignMemberByCampaignId (List<String> lstCampaignId) {
        Map<String,Map<String, CampaignMember>> mapCOrLToCampaignMemberByCampaignId = new Map<String,Map<String,CampaignMember>>();
        
        if (!lstCampaignId.isEmpty()) {
            List<CampaignMember> lstCampaignMember = [SELECT id , ContactId, LeadId, CampaignId, Status FROM CampaignMember WHERE CampaignId in :lstCampaignId LIMIT 2000];
            
            for (CampaignMember cMember : lstCampaignMember) {
                Map<String,CampaignMember> mapCOrLToCampaignMember = mapCOrLToCampaignMemberByCampaignId.containsKey(cMember.campaignId) ? mapCOrLToCampaignMemberByCampaignId.get(cMember.campaignId): new Map<String,CampaignMember>();
                if(cMember.ContactId != null ){
                    mapCOrLToCampaignMember.put(cMember.ContactId, cMember);
                }
                else if(cMember.LeadId != null ){
                    mapCOrLToCampaignMember.put(cMember.LeadId, cMember);
                }
                mapCOrLToCampaignMemberByCampaignId.put(cMember.CampaignId,mapCOrLToCampaignMember );
            }
        }
        
        return mapCOrLToCampaignMemberByCampaignId;
    }
  */
    public static Map<String,CampaignMember> getMapCOrLToCampaignMemberByCampaignId (String campaigId, String contactoId, String leadId) {
        Map<String,CampaignMember> mapCOrLToCampaignMember = new Map<String,CampaignMember>();
        List<String> listLeadId = !String.isBlank(leadId)? new List<String>{leadId}:new List<String>();
        List<String> listContactoId = !String.isBlank(contactoId) ? new List<String>{contactoId}: new List<String>();
            
        if (!String.isBlank(campaigId)) {
            Map<String,Map<String, CampaignMember>> mapCOrLToCampaignMemberByCampaignId = getMapCOrLToCampaignMemberByCampaignId(new List<String>{campaigId},listContactoId, listLeadId);
            
            if (!mapCOrLToCampaignMemberByCampaignId.isEmpty()) {
                mapCOrLToCampaignMember = mapCOrLToCampaignMemberByCampaignId.get(campaigId);
            }
        }
        
        return mapCOrLToCampaignMember;
    }

    public static Map<String,Map<String,CampaignMember>> getMapCOrLToCampaignMemberByCampaignId (List<String> lstCampaignId, List<String> lstContactId, List<String> lstLeadId) {
        Map<String,Map<String, CampaignMember>> mapCOrLToCampaignMemberByCampaignId = new Map<String,Map<String,CampaignMember>>();
        
        if (!lstCampaignId.isEmpty()) {
            List<CampaignMember> lstCampaignMember;
            if(!lstContactId.isEmpty() && !lstLeadId.isEmpty()){
                 lstCampaignMember = [SELECT id , ContactId, LeadId, CampaignId, Status FROM CampaignMember WHERE CampaignId IN :lstCampaignId AND (ContactId IN :lstContactId OR  LeadId IN :lstLeadId ) LIMIT 10000];
            
            }
            else if(!lstContactId.isEmpty()){
                 lstCampaignMember = [SELECT id , ContactId, LeadId, CampaignId, Status FROM CampaignMember WHERE CampaignId in :lstCampaignId AND ContactId IN :lstContactId LIMIT 10000];
            
            }
            else if(!lstLeadId.isEmpty()){
                 lstCampaignMember = [SELECT id , ContactId, LeadId, CampaignId, Status FROM CampaignMember WHERE CampaignId in :lstCampaignId AND LeadId IN :lstLeadId LIMIT 10000];
            
            }
            else {
                 lstCampaignMember = [SELECT id , ContactId, LeadId, CampaignId, Status FROM CampaignMember WHERE CampaignId in :lstCampaignId LIMIT 10000];
            
            }
            
            for (CampaignMember cMember : lstCampaignMember) {
                Map<String,CampaignMember> mapCOrLToCampaignMember = mapCOrLToCampaignMemberByCampaignId.containsKey(cMember.campaignId) ? mapCOrLToCampaignMemberByCampaignId.get(cMember.campaignId): new Map<String,CampaignMember>();
                if(cMember.ContactId != null ){
                    mapCOrLToCampaignMember.put(cMember.ContactId, cMember);
                }
                else if(cMember.LeadId != null ){
                    mapCOrLToCampaignMember.put(cMember.LeadId, cMember);
                }
                mapCOrLToCampaignMemberByCampaignId.put(cMember.CampaignId,mapCOrLToCampaignMember );
            }
        }
        
        return mapCOrLToCampaignMemberByCampaignId;
    }
    
    
}