public class CacheUtil {

    private static User currentUser;
    private static Map<String, User> mapUserById;
    private static Map<String,Gestion_Lead__c> gestionLeadMap;
    private static User integrador;
    private static User MKTUser;
    private static Map<String,BusinessHours> mapBusinessHoursByName;
    
    
    private static User getCurrentUserInfo() {
        User currentUser;
        System.debug('CacheUtil: getUserInfo: mapUserById: '+mapUserById);
        String userId = UserInfo.getUserId();
        if (mapUserById != null) {
            currentUser = (User) mapUserById.get(userId);
        }else{
            mapUserById = new Map<String, User>();
        }
        if (currentUser == null) {
            List<User> listaUser = [Select id, Name,ProfileId, Profile.Name,EmployeeNumber, Unidad_de_negocio__c
            						from User where Id = :userId limit 1];
            System.debug('CacheUtil: getUserInfo: QUERY EJECUTADA');
            if(!listaUser.isEmpty()){
                currentUser = listaUser.get(0);
                if(currentUser != null){
                    mapUserById.put(currentUser.Id, currentUser);    
                }
            }
        } 
        else {
            System.debug('CacheUtil: getUserInfo: QUERY AHORRADA');
        }
        return currentUser;
    }
   
    private static void fillGestionLead(){
        if(gestionLeadMap == null){
            gestionLeadMap = new Map<String,Gestion_Lead__c>();
            for(Gestion_Lead__c gLead :[Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c, Origen__c, RecordTypeId, RecordType.DeveloperName, EmailAsesor__c from Gestion_Lead__c]){
                gestionLeadMap.put(gLead.Id, gLead);
            }
        }
        else {
            System.debug('Ahorro:Query');
        }
    }
    
    private static void fillBusinessHours(){
        if(mapBusinessHoursByName == null){
            mapBusinessHoursByName = new Map<String,BusinessHours>();
            for(BusinessHours bh :[select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime,
                                   WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime, TimeZoneSidKey 
                                   from BusinessHours ]){
                mapBusinessHoursByName.put(bh.Name, bh);
            }
        }
        else {
            System.debug('Ahorro:Query');
        }
    }
    
    public static String getCurrentUserProfile(){
        String profile = '';
         if(currentUser == null){
            currentUser = getCurrentUserInfo();
        }else{
            System.debug('UtilCache: getCurrentUserBU: QUERY AHORRADA');
        }
        if(currentUser != null){
            profile =  currentUser.Profile.Name;
        }
        return profile;
        
    }
    public static User getCurrentUser(){
        if(currentUser == null){
            currentUser = getCurrentUserInfo();
        }else{
            System.debug('CacheUtil: getCurrentUser: QUERY AHORRADA');
        }
        return currentUser;
    }
    public static User getIntegrador(){
        if(integrador ==null){
           List<User> ul = [Select id from User where Alias = :'Int'];
               if(ul.size()> 0 ){
                   integrador = ul[0];
               }
        }
        else {
            system.debug('QUERY: AHORRADA');
        }
        return integrador;
    }

    public static User getUsuarioMKT(){
        if(MKTUser ==null){
           List<User> ul = [Select id from User where Alias = :'MKTUser'];
               if(ul.size()> 0 ){
                   MKTUser = ul[0];
               }
        }
        else {
            system.debug('QUERY: AHORRADA');
        }
        return MKTUser;
    }
    
   
    public static Map<String,Gestion_Lead__c> getGestionLeadMap(){
        fillGestionLead();
        return gestionLeadMap;
        
    }
    
    public static Map<String,BusinessHours> getBusinessHoursMap(){
        fillBusinessHours();
        return mapBusinessHoursByName;
        
    }
}