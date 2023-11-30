public class DocumentApiRestController {
    public static ResponseApi createDocument(DocumentApiRestModel req) {
        ResponseApi response = new ResponseApi();
        
        try {
            ContentVersion cv = new ContentVersion();
            cv.Title = req.documentInfo.title;
            cv.PathOnClient = req.documentInfo.title + '.'+req.documentInfo.contentType;
            cv.ContentLocation ='S';
            cv.VersionData = EncodingUtil.base64Decode(req.documentInfo.body);
            insert cv;
            
            ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
            
            ContentDocumentLink cdlink = new ContentDocumentLink();
            cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
            cdLink.LinkedEntityId = req.documentInfo.parentId;
            cdLink.Visibility = 'AllUsers';
            insert cdLink;
                
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Message = e.getMessage();
            response.Status = Label.errorStatus_Error;
            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.documentInfo.ParentId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'DocumentApiRestController.createDocument';
            
            insert exc;
            
        }
        
        return response;
    }
   
}