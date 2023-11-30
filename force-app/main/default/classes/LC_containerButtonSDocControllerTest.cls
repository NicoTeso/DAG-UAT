@isTest(SeeAllData = true)
public class LC_containerButtonSDocControllerTest {

    @isTest
    static void sendBudgetTest() {
        Test.startTest();
        List<SDOC__SDRelationship__c> listSDoc = [select id, SDOC__Case__c, SDOC__SDoc__c, SDOC__SDoc__r.SDOC__Attachment_ID__c from SDOC__SDRelationship__c where
                                                  SDOC__Case__r.SuppliedEmail != null limit 1];
        if(!listSDoc.isEmpty()){
        	LC_containerButtonSDocController.sendBudget(listSDoc[0].Id);
        }
        
        Test.stopTest();
        
    }
        
    @isTest
    static void getUrlAttachmentTest() {
        Test.startTest();
        List<SDOC__SDRelationship__c> listSDoc = [select id, SDOC__Case__c, SDOC__SDoc__c, SDOC__SDoc__r.SDOC__Attachment_ID__c from SDOC__SDRelationship__c where
                                                  SDOC__Case__r.SuppliedEmail != null limit 1];
        if(!listSDoc.isEmpty()){
        	LC_containerButtonSDocController.getUrlAttachment(listSDoc[0].Id);
        }
        
        Test.stopTest();
        
    }
    
}