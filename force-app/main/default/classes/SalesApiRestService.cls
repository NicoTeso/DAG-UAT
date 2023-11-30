@RestResource(urlMapping='/SalesApi/*')
global with sharing class SalesApiRestService {
    /*@HttpPost
    global static ResponseApi upsertSalesApi() {
        ResponseApi response = new ResponseApi();
        System.debug('JSON Input: ' + RestContext.request.requestBody.toString());
        
        SalesApiRestModel req = (SalesApiRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), SalesApiRestModel.class);
        
        // Tipo de eventos: OfferVehicleDeliveredToCustomer, InvoiceOrderVehicleDeliveredToCustomer
        if (req.salesApi != null && req.salesApi.eventType != null) {
            if (req.salesApi.eventType.equalsIgnoreCase(Label.eventOfferVehicleDeliveredToCustomer) || req.salesApi.eventType.equalsIgnoreCase(Label.eventInvoiceOrderVehicleDeliveredToCustomer)) {
                response = SalesApiRestServiceController.insertSale(req);
            }
        }
        else {
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