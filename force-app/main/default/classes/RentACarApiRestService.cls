@RestResource(urlMapping='/ContractRentACarApi/*')
global with sharing class RentACarApiRestService {
	@HttpPost
    global static ResponseApi rentACarApi() {
        ResponseApi response = new ResponseApi();
        System.debug('JSON Input: ' + RestContext.request.requestBody.toString());
        
        RentACarRestModel req = (RentACarRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), RentACarRestModel.class);
        
        if(req != null && String.isNotBlank(req.uuid)){
            response = RentACarApiRestServiceController.upsertRentACar(req); 
        }else {
			response.Status = Label.errorStatus_Error;
			response.Message = Label.responseMessage_Error;
        }        
    	return response;
    }
}