@RestResource(urlMapping='/salesProcessApi/*')
global with sharing class SalesProcessApiRestService {
    @HttpPost
    global static ResponseApi upsertSalesProcess() {
        ResponseApi response = new ResponseApi();
        System.debug('JSON Input: ' + RestContext.request.requestBody.toString());
        
        SalesProcessApiRestModel req = (SalesProcessApiRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), SalesProcessApiRestModel.class);
        
        // Tipos de eventos: SalesProcessCreated, SalesProcessDelivered, SalesProcessSucceeded, SalesProcessRejected, SalesProcessVehicleDelivered
        if (!String.isBlank(req.eventType)) {
            if (req.eventType.equalsIgnoreCase(Label.eventSalesProcessCreate)) {
                response = SalesProcessApiRestController.createProcessSales(req);
            }
            else if (req.eventType.equalsIgnoreCase(Label.eventSalesProcessDelivered)) {
                response = SalesProcessApiRestController.upsertProcessSales(req); 
            }
            else if (req.eventType.equalsIgnoreCase(Label.eventSalesProcessSuccess)) {
                response = SalesProcessApiRestController.successProcessSales(req);
			}
            else if (req.eventType.equalsIgnoreCase(Label.eventSalesProcessFailure)) {
                response = SalesProcessApiRestController.failureProcessSales(req);
			}
            else if (req.eventType.equalsIgnoreCase(Label.eventSalesProcessSaleCompleted)) {
                response = SalesProcessApiRestController.completedProcessSales(req);
			}
            else if (req.eventType.equalsIgnoreCase(Label.eventSalesProcessVehicleDelivered)) {
                response = SalesProcessApiRestController.vehicleDeliveredProcessSales(req);
			}
            else if(req.eventType.equalsIgnoreCase(Label.eventSalesProcessSaleCompletedCancelled)){
                response = SalesProcessApiRestController.cancelCompletedProcessSales(req);
            }
            else if(req.eventType.equalsIgnoreCase(Label.eventSalesProcessSaleCancelled)){
                response = SalesProcessApiRestController.cancelProcessSalesCancelled(req);
            }
            else if(req.eventType.equalsIgnoreCase(Label.eventSalesProcessAnonymized)){
                response = SalesProcessApiRestController.SalesProcessAnonymized(req);
            }
            else if(req.eventType.equalsIgnoreCase(Label.eventSalesmanOwnerChanged)){
                response = SalesProcessApiRestController.SalesmanOwnerChanged(req);
            }
        }
        else {
            response.Status = Label.errorStatus_Error;
			response.Message = Label.responseMessage_Error;
        }
        
        return response;
    }
}