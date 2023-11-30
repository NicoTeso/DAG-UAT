@RestResource(urlMapping='/AccountApi/*')
global with sharing class AccountApiRestService {
	@HttpPost
    global static ResponseApi upsertAccountApi() {
        ResponseApi response = new ResponseApi();
        System.debug('JSON Input: ' + RestContext.request.requestBody.toString());
        
        AccountApiRestModel req = (AccountApiRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), AccountApiRestModel.class);
        
        // Tipo de eventos: CustomerUpdated, CustomerCreated, ExtendedInfoUpdated, eventConsentsRegistered
        if (req.accountApi != null && req.accountApi.eventType != null) {
            if (req.accountApi.eventType.equalsIgnoreCase(Label.eventCustomerCreated)
                || req.accountApi.eventType.equalsIgnoreCase(Label.eventCustomerUpdated)) {
				response = AccountApiRestServiceController.upsertCliente(req);
        	}
            else if (req.accountApi.eventType.equalsIgnoreCase(Label.eventExtendedInfoUpdated)) {
                response = AccountApiRestServiceController.updateExternalInfoCliente(req);
            }
            else if (req.accountApi.eventType.equalsIgnoreCase(Label.eventConsentsRegistered)) {
                response = AccountApiRestServiceController.upsertConsent(req);
            }
            else if (req.accountApi.eventType.equalsIgnoreCase(Label.eventCustomerRemoved)) {
                response = AccountApiRestServiceController.CustomerRemoved(req);
            }
        }
        else {
			response.Status = Label.errorStatus_Error;
			response.Message = Label.responseMessage_Error;
        }
        
    	return response;
    }
    
    /*global class ResponseApi {
        public String Status {get; set;}
    	public String Message {get;set;}
    	public String ErrorCode {get; set;}
    }*/
}