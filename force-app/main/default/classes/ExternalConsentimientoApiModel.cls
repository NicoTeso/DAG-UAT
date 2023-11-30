global class ExternalConsentimientoApiModel {
    global ConsentimientoApi consentimientoApi {get;set;}
    
    global class ConsentimientoApi {
        global DateTime Fecha {get;set;}
        global List<customers> customers{get;set;}
        global List<consentimientos> consentimientos {get;set;}
        global List<consentimientosCustom> consentCustom{get;set;}
    }
    
    global class customers{
        global String customerId {get;set;}
        global String companyId {get;set;}
    }
    global class consentimientos{
        global String ChannelValue {get;set;}
        global String ChannelType {get;set;}
        global String CustomerSatisfaction {get;set;}
        global String MarketResearch {get;set;}
        global String EventInvitation {get;set;}
        global String AfterSales {get;set;}
        global String SalesProduct {get;set;}
        global String ProductSale {get;set;}
        global String CustomerSatisfactionSMS {get;set;}
        global String MarketResearchSMS {get;set;}
        global String EventInvitationSMS {get;set;}
        global String AfterSalesSMS {get;set;}
 		global String SalesProductSMS {get;set;}
        global String ProductSaleSMS {get;set;}

    }
    global class consentimientosCustom{
        global String companyId {get;set;}
        global String CustomerSatisfactionSales {get;set;}
        global String CustomerSatisfactionSalesSMS {get;set;}
        global String CustomerSatisfactionAfterSales {get;set;}
        global String CustomerSatisfactionAfterSalesSMS {get;set;}
        global String Insurance {get;set;}
        global String EAVE {get;set;}
    }
}