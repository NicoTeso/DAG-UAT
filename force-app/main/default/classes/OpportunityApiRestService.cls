//@RestResource(urlMapping='/OpportunityApi/*')
global with sharing class OpportunityApiRestService {
	/*@HttpPost
    global static ResponseApi upsertOpportunityApi() {
        ResponseApi response = new ResponseApi();
        System.debug('JSON Input: ' + RestContext.request.requestBody.toString());
        
        OpportunityApiRestModel req = (OpportunityApiRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), OpportunityApiRestModel.class);
        
        // Tipo de eventos: SalesProcessDeliveredToCustomer, SalesProcessSuccess, SalesProcessFailure
        if (req.oppApi != null && req.oppApi.eventType != null) {
            if (req.oppApi.eventType.equalsIgnoreCase(Label.eventSalesProcessDeliveredToCustomer)) {
                //response = AccountApiRestServiceController.upsertCliente(req); 
           		//response.Status = 'Success';
           		//response.Message = 'Operation completed successfully!';
            }
            else if (req.oppApi.eventType.equalsIgnoreCase(Label.eventSalesProcessSuccess)) {
                //response = AccountApiRestServiceController.updateExternalInfoCliente(req);
				//response.Status = 'Success';
				//response.Message = 'Other Operation completed successfully!'; 
            }
            else if (req.oppApi.eventType.equalsIgnoreCase(Label.eventSalesProcessFailure)) {
                //response = AccountApiRestServiceController.updateExternalInfoCliente(req);
				//response.Status = 'Success';
				//response.Message = 'Other Operation completed successfully!'; 
            }
        }
        else {
            //response = 'Error: wrong event';
			response.Status = Label.errorStatus_Error;
			response.Message = Label.responseMessage_Error;
        }
        
        return response;
    }
    
    global class ResponseApi {
        public String Status {get; set;}
    	public String Message {get;set;}
    	public String ErrorCode {get; set;}
    }*/
}