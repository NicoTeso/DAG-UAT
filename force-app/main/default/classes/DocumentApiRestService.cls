@RestResource(urlMapping='/documentApi/*')
global class DocumentApiRestService {
	 @HttpPost
    global static ResponseApi document() {
        ResponseApi response = new ResponseApi();
        System.debug('JSON Input: ' + RestContext.request.requestBody.toString());
        
        DocumentApiRestModel req = (DocumentApiRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), DocumentApiRestModel.class);
        
        response = DocumentApiRestController.createDocument(req);
        
        return response;
    }
}