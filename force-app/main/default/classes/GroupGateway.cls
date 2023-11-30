public class GroupGateway {

    public static Group getGroupByDeveloperName(String developerName) {
        Group grupo;
        
        if (!String.isBlank(developerName)) {
            Map<String, Group> mapIdToGroup = getGroupByDeveloperName(new List<String>{developerName});
            
            if (!mapIdToGroup.isEmpty()) {
                grupo = mapIdToGroup.get(developerName);
            }
        }
        
        return grupo;
    }

    public static Map<String, Group> getGroupByDeveloperName(List<String> lstDeveloperName) {
        Map<String, Group> mapIdToGroup = new Map<String, Group>();
        
        if (!lstDeveloperName.isEmpty()) {
            for (Group grupo : [SELECT Id,Name, DeveloperName,Type FROM Group WHERE DeveloperName in :lstDeveloperName LIMIT 2000]) {
                mapIdToGroup.put(grupo.DeveloperName, grupo);
            }
        }
        
        return mapIdToGroup;
    }
    
}