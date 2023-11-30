global class ExternalLeadApiModel {
	global LeadApi leadApi {get;set;}
    
    global class LeadApi {
        global String companyId {get;set;}
        global String caseId {get;set;}
        global String salesCenterCode {get;set;}
        global String brandCode {get;set;}
        global String salesmanEmail {get;set;}
        global String customerId {get;set;}
        
        global AgendaTask agendaTask {get;set;}
    }
    
    global class AgendaTask {
        global String scheduledDate {get;set;}
        global String remarks {get;set;}
    }
}