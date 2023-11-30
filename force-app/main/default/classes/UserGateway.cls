public class UserGateway {
    public static User getUserById(String id) {
        User user;
        
        if (!String.isBlank(id)) {
            Map<String, User> mapIdToUser = getUserById(new List<String>{id});
            
            if (!mapIdToUser.isEmpty()) {
                user = mapIdTouser.get(id);
            }
        }
        
        return user;
    }
    
    
    public static Map<String, User> getUserById(List<String> lstId) {
        Map<String, User> mapIdToUser = new Map<String, User>();
        
        if (!lstId.isEmpty()) {
            List<User> lstUsers = [SELECT Id,
                                          Name,
                                          EmployeeNumber,
                                          Email
                                   FROM User
                                   WHERE Id in :lstId
                                   LIMIT 2000];
            
            for (User user : lstUsers) {
                mapIdToUser.put(user.Id, user);
            }
        }
        
        return mapIdToUser;
    }
/*
    public static User getUserBySalesman(String salesman) {
        User user;
        
        if (!String.isBlank(salesman)) {
            List<User> lstUsers = [SELECT Id,
                                          Name,
                                          EmployeeNumber
                                   FROM User
                                   WHERE EmployeeNumber = :salesman];
            
            if (!lstUsers.isEmpty()) {
                user = lstUsers[0];
            }
        }
        
        return user;
    }
*/
}