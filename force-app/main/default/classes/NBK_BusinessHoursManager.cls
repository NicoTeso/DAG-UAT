/*----------------------------------------------------------------------------------------------------------------------------------------
    Apex Class Name: NBK_BusinessHoursManager
    Version:         1.0
    Created Date:    07/04/2021
    Function:        Manage REST API calls to get Business hours
    Company:         Nubika Consulting
----------------------------------------------------------------------------------------------------------------------------------------*/
@RestResource(UrlMapping='/businesshours/*')
global with sharing class NBK_BusinessHoursManager {
    private static final String DEBUG_PREFIX = '@@ NBK_BusinessHoursManager - ';

    @HttpGet
    global static ApexRestResultWrapper doGet() {
        ApexRestResultWrapper responseWrapper = new ApexRestResultWrapper();

        String phoneNumber = RestContext.request.params.get('phone');
        System.debug(DEBUG_PREFIX + phoneNumber);

        try {
            List<Phone_Config__c> lPhoneConfig = [SELECT Phone__c, Business_Hours__c, Service_Time_Text__c, HolidaysLocution__c FROM Phone_Config__c WHERE Phone__c = :phoneNumber LIMIT 1];
            System.debug(DEBUG_PREFIX + lPhoneConfig);

            responseWrapper.success = true;
            responseWrapper.errors = '';
            if (lPhoneConfig.isEmpty() || lPhoneConfig.size() != 1) {
                lPhoneConfig.add([SELECT Business_Hours__c, Service_Time_Text__c FROM Phone_Config__c WHERE Business_Hours__r.IsDefault = TRUE LIMIT 1]);
            }

            responseWrapper.result = BusinessHours.isWithin(lPhoneConfig.get(0).Business_Hours__c, Datetime.now());

            if (responseWrapper.result == false) {
                List <Holiday> freeDay = [SELECT Id FROM Holiday WHERE ActivityDate = TODAY];

                if (freeDay.isEmpty()){
                    responseWrapper.horario = lPhoneConfig.get(0).Service_Time_Text__c;
                }else {
                    responseWrapper.horario = lPhoneConfig.get(0).HolidaysLocution__c;
                }
                
            }else {
                responseWrapper.horario = lPhoneConfig.get(0).HolidaysLocution__c;
            }

        } catch (Exception e) {
            responseWrapper.success = false;
            responseWrapper.errors = e.getMessage();
        }

        return responseWrapper;
    }

    global class ApexRestResultWrapper {
        public Boolean success { get; set; }
        public Boolean result { get; set; }
        public String errors { get; set; }
        public String horario { get; set; }
    }
}