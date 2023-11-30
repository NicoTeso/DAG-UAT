@isTest
public class NewsTest {
    @isTest static void newsTests(){
        Noticias__c News = new Noticias__c(Name = 'Na');
        insert News;
        
        NewsController.getNews(News.id);
    }
}