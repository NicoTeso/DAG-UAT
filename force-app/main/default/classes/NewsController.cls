global class NewsController {
    @AuraEnabled
    global static List<Noticias__c> getNews(id recordID){
        List <Noticias__c> devuelve = [SELECT Id, Imagen__c, Titular__c, Fecha_noticia__c, Texto_Noticia__c FROM Noticias__c WHERE id = :recordId];
    	system.debug(devuelve + '|' + recordId);
        return devuelve;
    
    }}