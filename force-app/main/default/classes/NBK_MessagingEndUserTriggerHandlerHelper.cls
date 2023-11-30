/**
 * @description       : 
 * @author            : alberto.martinez@nubika.com
 * @group             : 
 * @last modified on  : 11-16-2021
 * @last modified by  : alberto.martinez@nubika.com
**/
public with sharing class NBK_MessagingEndUserTriggerHandlerHelper {

    public static void mappingLeadsByPhone(List<MessagingEndUser> newValues, Map<Id, MessagingEndUser> oldMap){

        try{
            Map<String,MessagingEndUser> unmappedMessagingEndUsers = new Map<String,MessagingEndUser>();
            
            Set<String> phoneNumbers = new Set<String>();
            for(MessagingEndUser item : newValues){
                if(item.AccountId == null && item.Lead__c == null && oldMap.get(item.Id)?.Lead__c == null){
                    String phone = '%'+getPhoneKey(item.MessagingPlatformKey)+'%';
                    unmappedMessagingEndUsers.put(phone, item.clone(true,false,false,false));
                }
            }

            Map<String, Lead> leadsByPhone = new Map<String, Lead>();
            for(Lead item : [SELECT Id,Phone_Key__c FROM Lead WHERE Phone_Key__c LIKE :unmappedMessagingEndUsers.keySet()]){
                leadsByPhone.put(getPhoneKey(item.Phone_Key__c), item);
            }

            for(MessagingEndUser item : unmappedMessagingEndUsers.values()){
                String phoneKey = getPhoneKey(item.MessagingPlatformKey);
                if(leadsByPhone.containsKey(phoneKey)){
                    item.Lead__c = leadsByPhone.get(phoneKey).Id;
                }
            }   

            if(!unmappedMessagingEndUsers.isEmpty()){
                TriggerHandler.bypass('NBK_MessagingEndUserTriggerHandler');
                update unmappedMessagingEndUsers.values();
                TriggerHandler.clearBypass('NBK_MessagingEndUserTriggerHandler');
            }
        }catch(Exception e){
            System.debug(e);
        }
    }


    public static String getPhoneKey(String phoneStr){
        String[] str = phoneStr.split('\\+');
        String phone = str[1];
        return phone;
    }
}