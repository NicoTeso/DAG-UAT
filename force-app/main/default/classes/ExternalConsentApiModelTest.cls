@isTest
public class ExternalConsentApiModelTest {
    
    @isTest static void upsertConsentimientoApiDefaultTest(){
    
        Test.startTest();
        ExternalConsentimientoApiModel modelo = new ExternalConsentimientoApiModel();
        ExternalConsentimientoApiModel.ConsentimientoApi consentimientoApi =new ExternalConsentimientoApiModel.ConsentimientoApi(); 
        ExternalConsentimientoApiModel.Customers customers = new ExternalConsentimientoApiModel.Customers();
        ExternalConsentimientoApiModel.Consentimientos consentimientos = new ExternalConsentimientoApiModel.Consentimientos();
        
        customers.companyId ='694';
        customers.customerId ='b4040d21-269a-4f5d-855a-879bf8b2734a';
        
        consentimientos.AfterSales ='Allow';
        consentimientos.AfterSalesSMS='Allow';
        consentimientos.ChannelType='Email';
        consentimientos.ChannelValue='mail@mail.com';
        consentimientos.CustomerSatisfaction='Allow';
        consentimientos.CustomerSatisfactionSMS='Allow';
        consentimientos.EventInvitation='Allow';
        consentimientos.EventInvitationSMS='Allow';
        consentimientos.MarketResearch='Allow';
        consentimientos.MarketResearchSMS='Deny';
        consentimientos.ProductSale='Deny';
        consentimientos.ProductSaleSMS='Deny';
        
        consentimientoApi.consentimientos = new List<ExternalConsentimientoApiModel.Consentimientos>{consentimientos};
        consentimientoApi.customers = new List<ExternalConsentimientoApiModel.Customers>{customers};
        consentimientoApi.fecha = system.today();
            
            
            
            
            
        
        Test.stopTest();
    }

}