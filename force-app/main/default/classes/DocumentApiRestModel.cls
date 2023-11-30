global class DocumentApiRestModel {
    global DocumentInfo documentInfo {get;set;}
    
    global class DocumentInfo {
        global String parentId {get;set;}
        global String title {get;set;}
        global String body {get;set;} 
        global String contentType {get;Set;}
   	} 
}
/*{
    "documentInfo":{
        "parentId":"",
        "title": "", 
        "body" : "",
        "contentType" : ""
    }
}*/