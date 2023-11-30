@isTest
public class CacheUtil_Test {
	@isTest
    static void getCurrentUserTest() {
        String userProfile = CacheUtil.getCurrentUserProfile();
        User us = CacheUtil.getCurrentUser();
    }

	@isTest
    static void getCurrentUserTest2() {
        User us = CacheUtil.getCurrentUser();
    }
    
    @isTest
    static void getGestionLeadMapTest() {
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('001');
        Concesionario.Es_SIMA__c = true;
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.Id);
        Gestion_Lead__c gLead = CreaObjetos.creaGestionLead(centro.Id);
        insert gLead;
        Map<String, Gestion_Lead__c> mapGestionLead = CacheUtil.getGestionLeadMap();
    }
    
    @isTest
    static void getBusinessHoursTest() {
        Map<String, BusinessHours> mapGestionBusinessHours = CacheUtil.getBusinessHoursMap();
        mapGestionBusinessHours= CacheUtil.getBusinessHoursMap();
    }
    
    @isTest
    static void getIntegradorTest() {
        User integrador = new User();
        integrador = CacheUtil.getIntegrador();
    }
}