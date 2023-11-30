@isTest
public class ExternalLeadApiModelTest {
    
    @isTest static void upsertLeadApiDefaultTest(){
     
        Test.startTest();
        ExternalLeadApiModel modelo = new ExternalLeadApiModel();
        ExternalLeadApiModel.LeadApi leadApi = new ExternalLeadApiModel.LeadApi();
        ExternalLeadApiModel.AgendaTask agendaTask = new ExternalLeadApiModel.AgendaTask(); 
        
        leadApi.companyId ='694';
        leadApi.brandCode ='HYUNDAI';
        leadApi.salesmanEmail ='test@test.com';
        leadApi.salesCenterCode ='01';
        leadApi.customerId='b4040d21-269a-4f5d-855a-879bf8b2734a';
        leadApi.caseId = null; 
        //leadApi.agendaTask = new ExternalLeadApiModel.AgendaTask;
        
        
        agendaTask.remarks='Intención de compra Oferta Modelo';
        agendaTask.scheduledDate ='2020-03-24T12:55:04Z';
        
        Test.stopTest();
        
	}
}