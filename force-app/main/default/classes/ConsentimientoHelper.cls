public class ConsentimientoHelper {
	public static Map<String, Map<String, Consentimientos__c>> mapConsents = new Map<String, Map<String, Consentimientos__c>>();
    
    public static void createMap() {
        if (Trigger.new != null) {
            List<String> lstContactId = new List<String>();
            
            for (SObject so : Trigger.new) {
                Consentimientos__c consent = (Consentimientos__c) so;
                
                if (!String.isBlank(consent.Contact__c)) {
                    lstContactId.add(consent.Contact__c);
                }                
            }
            
            List<Consentimientos__c> lstConsents = [SELECT Id, ChannelValue__c, Contact__c FROM Consentimientos__c WHERE Contact__c IN :lstContactId];
            Map<String, Consentimientos__c> mapInner;
            
            for (Consentimientos__c consent : lstConsents) {
                mapInner = mapConsents.containsKey(consent.Contact__c) ? mapConsents.get(consent.Contact__c) : new Map<String, Consentimientos__c>();
                mapInner.put(consent.ChannelValue__c, consent);
                mapConsents.put(consent.Contact__c, mapInner);
            }
        }
    }
	/*
    public static void verifyConsentChannelValue(Consentimientos__c consent) {
        if (mapConsents.containsKey(consent.Contact__c)) {
            Map<String, Consentimientos__c> mapAux = mapConsents.get(consent.Contact__c);
            
            if (!mapAux.containsKey(consent.ChannelValue__c)) {
                throw new CustomException('');
            }
        }
    }
 	*/
    public static void validationsBefore(Consentimientos__c consent) {
        Map<Id, Schema.RecordTypeInfo> rtMapConsentimientoById = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosById();
        String rtName = rtMapConsentimientoById.get(consent.RecordTypeId).getDeveloperName();
        system.debug('emailCOnsent:'+ consent.ChannelValue__c);
        
        if (rtName.equalsIgnoreCase('Email')
            && !DataValidations.validateEmail(consent.ChannelValue__c)) {
            consent.addError('No es un email válido');
        }
        else if (rtName.equalsIgnoreCase('Telefono') 
                 && (!DataValidations.validatePhone(consent.ChannelValue__c) || DataValidations.isMobile(consent.ChannelValue__c)) ) {
            consent.addError('No es un teléfono válido');
        }
        else if (rtName.equalsIgnoreCase('Movil')
                 && (!DataValidations.validatePhone(consent.ChannelValue__c) || !DataValidations.isMobile(consent.ChannelValue__c))) {
            consent.addError('No es un móvil válido');
        }
        
        //verificar que no este creado 
    }
    
    public static void transformationsBefore(Consentimientos__c consent) {
        Map<Id, Schema.RecordTypeInfo> rtMapConsentimientoById = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosById();
        String rtName = rtMapConsentimientoById.get(consent.RecordTypeId).getDeveloperName();
        
        if (rtName.equals('Telefono') || rtName.equals('Movil')) {
            consent.ChannelValue__c = DataValidations.transformPhone(consent.ChannelValue__c);
        }
        
    }
    
    public static void transforUnknown(Consentimientos__c consent, Consentimientos__c consentOld){
        if(consent.AfterSales__c != null && !consent.AfterSales__c.equalsIgnoreCase(consentOld.AfterSales__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.AfterSales__c)){
            consent.AfterSales__c = consentOld.AfterSales__c;
        }
        if(consent.AfterSalesSMS__c != null && !consent.AfterSalesSMS__c.equalsIgnoreCase(consentOld.AfterSalesSMS__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.AfterSalesSMS__c)){
            consent.AfterSalesSMS__c = consentOld.AfterSalesSMS__c;
        }
        if(consent.CustomerSatisfaction__c != null && !consent.CustomerSatisfaction__c.equalsIgnoreCase(consentOld.CustomerSatisfaction__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.CustomerSatisfaction__c)){
            consent.CustomerSatisfaction__c = consentOld.CustomerSatisfaction__c;
        }
        if(consent.CustomerSatisfactionAfterSales__c != null && !consent.CustomerSatisfactionAfterSales__c.equalsIgnoreCase(consentOld.CustomerSatisfactionAfterSales__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.CustomerSatisfactionAfterSales__c)){
            consent.CustomerSatisfactionAfterSales__c = consentOld.CustomerSatisfactionAfterSales__c;
        }
        if(consent.CustomerSatisfactionSales__c != null && !consent.CustomerSatisfactionSales__c.equalsIgnoreCase(consentOld.CustomerSatisfactionSales__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.CustomerSatisfactionSales__c)){
            consent.CustomerSatisfactionSales__c = consentOld.CustomerSatisfactionSales__c;
        }
        if(consent.CustomerSatisfactionSMS__c != null && !consent.CustomerSatisfactionSMS__c.equalsIgnoreCase(consentOld.CustomerSatisfactionSMS__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.CustomerSatisfactionSMS__c)){
            consent.CustomerSatisfactionSMS__c = consentOld.CustomerSatisfactionSMS__c;
        }
        if(consent.EventInvitation__c != null && !consent.EventInvitation__c.equalsIgnoreCase(consentOld.EventInvitation__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.EventInvitation__c)){
            consent.EventInvitation__c = consentOld.EventInvitation__c;
        }
        if(consent.EventInvitationSMS__c != null &&!consent.EventInvitationSMS__c.equalsIgnoreCase(consentOld.EventInvitationSMS__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.EventInvitationSMS__c)){
            consent.EventInvitationSMS__c = consentOld.EventInvitationSMS__c;
        }
        if(consent.MarketResearch__c != null && !consent.MarketResearch__c.equalsIgnoreCase(consentOld.MarketResearch__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.MarketResearch__c)){
            consent.MarketResearch__c = consentOld.MarketResearch__c;
        }
        if(consent.MarketResearchSMS__c != null && !consent.MarketResearchSMS__c.equalsIgnoreCase(consentOld.MarketResearchSMS__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.MarketResearchSMS__c)){
            consent.MarketResearchSMS__c = consentOld.MarketResearchSMS__c;
        }
        if(consent.ProductSale__c  != null && !consent.ProductSale__c.equalsIgnoreCase(consentOld.ProductSale__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.ProductSale__c)){
            consent.ProductSale__c = consentOld.ProductSale__c;
        }
        if(consent.ProductSaleSMS__c != null && !consent.ProductSaleSMS__c.equalsIgnoreCase(consentOld.ProductSaleSMS__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.ProductSaleSMS__c)){
            consent.ProductSaleSMS__c = consentOld.ProductSaleSMS__c;
        }
        if(consent.eave__c != null && !consent.eave__c.equalsIgnoreCase(consentOld.eave__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.eave__c)){
            consent.eave__c = consentOld.eave__c;
        }
        if(consent.Insurance__c != null && !consent.Insurance__c.equalsIgnoreCase(consentOld.Insurance__c) && Label.ConsentimientoUnknown.equalsIgnoreCase(consent.Insurance__c)){
            consent.Insurance__c = consentOld.Insurance__c;
        }
        
    }
}