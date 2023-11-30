public class CaseHelper {
    public static Consentimientos__c AssigmentConsentimientos(Consentimientos__c consentimiento, Case caso, String tipo){
        if(consentimiento.Fecha_de_captura__c< caso.CreatedDate){
            if(tipo.equalsIgnoreCase(Label.channelEmail)){
    			consentimiento.AfterSales__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.CustomerSatisfaction__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.EventInvitation__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.MarketResearch__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            	consentimiento.ProductSale__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
        	}
        	else if(tipo.equalsIgnoreCase(Label.channelPhone)){
    			consentimiento.AfterSales__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.CustomerSatisfaction__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.EventInvitation__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.MarketResearch__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            	consentimiento.ProductSale__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
        	}
        	else if(tipo.equalsIgnoreCase(Label.channelMobile)){
    			consentimiento.AfterSales__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.CustomerSatisfaction__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.EventInvitation__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.MarketResearch__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            	consentimiento.ProductSale__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            	consentimiento.AfterSalesSMS__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.CustomerSatisfactionSMS__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.EventInvitationSMS__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            	consentimiento.MarketResearchSMS__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
           	 	consentimiento.ProductSaleSMS__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
        	}
        }
        else {
            consentimiento = null;
        }
        return consentimiento;
    }
    
    public static Consentimientos__c CreateConsentimiento(String valor, Case caso, String tipo){
        Consentimientos__c consentimiento = new Consentimientos__c();
        
        if(tipo.equalsIgnoreCase(Label.channelEmail)){
            consentimiento.ChannelValue__c = valor;
            consentimiento.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName(tipo);
            consentimiento.Medio_de_contacto__c = Label.channelOther;
    		consentimiento.AfterSales__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.CustomerSatisfaction__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.EventInvitation__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.MarketResearch__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            consentimiento.ProductSale__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
        }
        else if(tipo.equalsIgnoreCase(Label.channelPhone)){
            consentimiento.ChannelValue__c = valor;
            consentimiento.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName('Telefono');
            consentimiento.Medio_de_contacto__c = Label.channelOther;
    		consentimiento.AfterSales__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.CustomerSatisfaction__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.EventInvitation__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.MarketResearch__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            consentimiento.ProductSale__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
        }
        else if(tipo.equalsIgnoreCase(Label.channelMobile)){
            consentimiento.ChannelValue__c = valor;
            consentimiento.Medio_de_contacto__c = Label.channelOther;
            consentimiento.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName('Movil');
    		consentimiento.AfterSales__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.CustomerSatisfaction__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.EventInvitation__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.MarketResearch__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            consentimiento.ProductSale__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            consentimiento.AfterSalesSMS__c = caso.AfterSales__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.CustomerSatisfactionSMS__c = caso.CustomerSatisfaction__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.EventInvitationSMS__c = caso.EventInvitation__c ? Label.ConsentimientoAllow : Label.ConsentimientosDeny;
            consentimiento.MarketResearchSMS__c = caso.MarketReresearch__c ? Label.ConsentimientoAllow: Label.ConsentimientosDeny;
            consentimiento.ProductSaleSMS__c = caso.SalesProduct__c ?  Label.ConsentimientoAllow: Label.ConsentimientosDeny;
        }
        
        return consentimiento;
    }
    
    public static Consentimientos__c CreateConsentimientoBase(String valor, Case caso, String tipo){
        Consentimientos__c consentimiento = new Consentimientos__c();
        
        if(tipo.equalsIgnoreCase(Label.channelEmail)){
            consentimiento.ChannelValue__c = valor;
            consentimiento.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName(tipo);
            consentimiento.Medio_de_contacto__c = Label.channelOther;
    		consentimiento.AfterSales__c = Label.ConsentimientoUnknown;
            consentimiento.CustomerSatisfaction__c = Label.ConsentimientoUnknown;
            consentimiento.EventInvitation__c = Label.ConsentimientoUnknown;
            consentimiento.MarketResearch__c = Label.ConsentimientoUnknown;
            consentimiento.ProductSale__c = Label.ConsentimientoUnknown;
        }
        else if(tipo.equalsIgnoreCase(Label.channelPhone)){
            consentimiento.ChannelValue__c = valor;
            consentimiento.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName('Telefono');
            consentimiento.Medio_de_contacto__c = Label.channelOther;
    		consentimiento.AfterSales__c = Label.ConsentimientoUnknown;
            consentimiento.CustomerSatisfaction__c = Label.ConsentimientoUnknown;
            consentimiento.EventInvitation__c = Label.ConsentimientoUnknown;
            consentimiento.MarketResearch__c = Label.ConsentimientoUnknown;
            consentimiento.ProductSale__c = Label.ConsentimientoUnknown;
        }
        else if(tipo.equalsIgnoreCase(Label.channelMobile)){
            consentimiento.ChannelValue__c = valor;
            consentimiento.Medio_de_contacto__c = Label.channelOther;
            consentimiento.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName('Movil');
    		consentimiento.AfterSales__c = Label.ConsentimientoUnknown;
            consentimiento.CustomerSatisfaction__c = Label.ConsentimientoUnknown;
            consentimiento.EventInvitation__c = Label.ConsentimientoUnknown;
            consentimiento.MarketResearch__c = Label.ConsentimientoUnknown;
            consentimiento.ProductSale__c = Label.ConsentimientoUnknown;
            consentimiento.AfterSalesSMS__c = Label.ConsentimientoUnknown;
            consentimiento.CustomerSatisfactionSMS__c = Label.ConsentimientoUnknown;
            consentimiento.EventInvitationSMS__c = Label.ConsentimientoUnknown;
            consentimiento.MarketResearchSMS__c = Label.ConsentimientoUnknown;
            consentimiento.ProductSaleSMS__c = Label.ConsentimientoUnknown;
        }
        
        return consentimiento;
    }
}