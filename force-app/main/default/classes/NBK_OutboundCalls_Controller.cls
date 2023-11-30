/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_OutboundCalls_Controller
     Created Date:      27/04/2021
     Company:           Nubika Consulting
     Author:            Alberto Sanchez
------------------------------------------------------------------------------------------*/
global with sharing class NBK_OutboundCalls_Controller {

    private static final String DEBUG_PREFIX = '### NBK_OutboundCalls_Controller - ';

    /*-----------------------------------------------------------------------------------------
     Apex Method Name:  initComponent
     Version:           1.0
     Created Date :     27/04/2021
     Function:          Initialize NBK_OutboundCalls component. Retrieve the phone numbers related
                        with recordId and returns the source and customers availables phones
    ------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String initComponent(Id recordId) {
        ApexRestResultWrapper resultWrapper = new ApexRestResultWrapper();
        String objectName = recordId.getSobjectType().getDescribe().getName();
        Map<String, Schema.SObjectField> objectFieldMap = recordId.getSobjectType().getDescribe().fields.getMap();
        List<String> queryFields = new List<String>();

        System.debug(DEBUG_PREFIX + 'initComponent - objectName: ' + objectName);
        System.debug(DEBUG_PREFIX + 'initComponent - objectFields: ' + objectFieldMap.keySet());

        for(String fieldName : objectFieldMap.keySet()){
            if(fieldName.contains('phone') || fieldName.contains('mobile')){
                queryFields.add(fieldName);
            }
        }

        System.debug(DEBUG_PREFIX + 'initComponent - queryFields: ' + queryFields);

        List<sObject> resultQueryList = Database.query('SELECT ' + String.join(queryFields, ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId' );
        System.debug(DEBUG_PREFIX + 'initComponent - sobjectList: ' + resultQueryList.size());

        if(!resultQueryList.isEmpty() && resultQueryList.size() == 1){
            Sobject resultQuery = resultQueryList.get(0);
            resultWrapper.success = true;

            if(objectName.equals('Call_Task__c') && resultQuery.get('Brand_Phone__c') != NULL){
                resultWrapper.customerPhone = resultQuery.get('Target_Phone__c').toString();
                resultWrapper.brandPhone = resultQuery.get('Brand_Phone__c').toString();

            } else {
                resultWrapper.customerPhonesMap = new Map<String, String>();

                for(String fieldName : queryFields){
                    if(resultQuery.get(fieldName) != NULL 
                        && String.isNotBlank(resultQuery.get(fieldName).toString()) 
                        && !fieldName.contains('wrong')
                        && !fieldName.contains('copy'))
                    {
                        String customerPhone = resultQuery.get(fieldName).toString();
                        if(!resultWrapper.customerPhonesMap.values().contains(customerPhone)){
                            resultWrapper.customerPhonesMap.put(objectFieldMap.get(fieldName).getDescribe().getLabel(), customerPhone);
                        }
                    }
                }

                resultWrapper.brandPhonesMap = getBrandPhones();
            }

        } else {
            resultWrapper.success = false;
            resultWrapper.errorMessage = System.Label.OutboundCalls_Result_Query_List_Empty_Error;
        }
        System.debug(DEBUG_PREFIX + 'initComponent - resultWrapper: ' + resultWrapper);
        return JSON.serialize(resultWrapper);
    }

    /*-----------------------------------------------------------------------------------------
     Apex Method Name:  initComponentVA
     Version:           1.0
     Created Date :     27/04/2021
     Function:          Initialize NBK_OutboundCalls component for Venta Activa component. Returns
                        the 'Depositario' and 'Propietario' phones of a vehicle and the 'Venta activa'
                        source phone.
    ------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String initComponentVA(Id recordId){
        ApexRestResultWrapper resultWrapper = new ApexRestResultWrapper();
        LC_showPersonVehicleController.Response infoPropietarioResponse;
        LC_showPersonVehicleController.Response infoDepositarioResponse;


        String infoPropietario = LC_showPersonVehicleController.getInfoClient(recordId, 'Propietario');
        String infoDepositario = LC_showPersonVehicleController.getInfoClient(recordId, 'Depositario');
        System.debug(DEBUG_PREFIX + 'initComponentVA - resultWrapper: ' + infoPropietario);
        System.debug(DEBUG_PREFIX + 'initComponentVA - resultWrapper: ' + infoDepositario);

        if(String.isNotBlank(infoPropietario) && infoPropietario != 'KO'){
        	infoPropietarioResponse = (LC_showPersonVehicleController.Response) JSON.deserialize(infoPropietario, LC_showPersonVehicleController.Response.class);
        }

        if(String.isNotBlank(infoDepositario) && infoDepositario != 'KO'){
            infoDepositarioResponse = (LC_showPersonVehicleController.Response) JSON.deserialize(infoDepositario, LC_showPersonVehicleController.Response.class);
        }

        resultWrapper.success = true;
        resultWrapper.customerPhonesMap = new Map<String, String>();
        if(infoPropietarioResponse != NULL){
            if(infoPropietarioResponse.phone != null){
            	resultWrapper.customerPhonesMap.put('Propietario phone', infoPropietarioResponse.phone);
            }
            if(infoPropietarioResponse.mobilePhone != null && !resultWrapper.customerPhonesMap.values().contains(infoPropietarioResponse.mobilePhone)){
                resultWrapper.customerPhonesMap.put('Propietario mobilePhone', infoPropietarioResponse.mobilePhone);
            }
        }

        if(infoDepositarioResponse != NULL){
            if(infoDepositarioResponse.phone != null && !resultWrapper.customerPhonesMap.values().contains(infoDepositarioResponse.phone)){
                resultWrapper.customerPhonesMap.put('Depositario phone', infoDepositarioResponse.phone);
            }
            if(infoDepositarioResponse.mobilePhone != null && !resultWrapper.customerPhonesMap.values().contains(infoDepositarioResponse.mobilePhone)){
                resultWrapper.customerPhonesMap.put('Depositario mobilePhone', infoDepositarioResponse.mobilePhone);
            }
        }
        
        resultWrapper.brandPhone = getBrandPhones().get('Venta Activa');

        System.debug(DEBUG_PREFIX + 'initComponentVA - resultWrapper: ' + resultWrapper);

        return JSON.serialize(resultWrapper);
    }

    /*-----------------------------------------------------------------------------------------
     Apex Method Name:  updateOutboundCallTask
     Version:           1.0
     Created Date :     27/04/2021
     Function:          Get the current call task and update the outbound phone with brand phone
                        selected. If recordId isn't a call task, create one with RT 'Outbound_Call'.
    ------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String updateOutboundCallTask(Id recordId, String customerPhone, String brandPhoneSelected) {
        String objectName = recordId.getSobjectType().getDescribe().getName();
        ApexRestResultWrapper resultWrapper = new ApexRestResultWrapper();

        if(objectName.equals('Call_Task__c')){
            Call_Task__c callTask = [SELECT Id, Status__c, Brand_Phone__c, Case__c, Call_Attempts__c, Total_Call_Attempts__c, OwnerId
                                     FROM Call_Task__c
                                     WHERE Id = :recordId LIMIT 1];
                                    

            if(callTask != Null && callTask.Status__c != 'Completada' && callTask.Status__c != 'Descartada'){

                if(callTask.OwnerId != UserInfo.getUserId()){
                    resultWrapper.success = false;
                    resultWrapper.errorMessage = System.Label.OutboundCalls_Call_Task_Owner_Error;
                    return JSON.serialize(resultWrapper);
                }

                callTask.Status__c = 'En curso';

                if(callTask.Brand_Phone__c != brandPhoneSelected){
                    callTask.Brand_Phone__c = brandPhoneSelected;
                }

                
                if(callTask.Case__c != NULL){
                    resultWrapper.caseId = callTask.Case__c; 
                }
                

                update callTask;
                resultWrapper.success = true;

            }else{
                resultWrapper.success = false;
                resultWrapper.errorMessage = System.Label.OutboundCalls_Call_Task_Status_Error;
            }

        } else {
            Call_Task__c calltask = generateCallTask(brandPhoneSelected, customerPhone);

            if(objectName.equals('Case')){
                calltask.Case__c = recordId;

            } else if(objectName.equals('Lead')){
                calltask.Lead__c = recordId;

            } else if(objectName.equals('Contact')){
                calltask.Client__c = recordId;

            } else if (objectName.equals('Account')) {
                Account customerAccount = [SELECT Id, IsPersonAccount, PersonContactId From Account WHERE Id = :recordId];
                if(customerAccount.IsPersonAccount) calltask.Client__c = customerAccount.PersonContactId;
            }

            upsert calltask;
            System.debug(DEBUG_PREFIX + 'updateOutboundCallTask - insert Call_Task: ' + calltask);
            resultWrapper.success = true;
        }

        return JSON.serialize(resultWrapper);
    }

    private static Map<String, String> getBrandPhones() {
        Map<String, String> phonesByBrandMap = new Map<String, String>();
        List<String> lBusinessUnits = new List<String>();  
        
        User user = [SELECT Id, Business_Units__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		
        if(user.Business_Units__c != NULL){
        	lBusinessUnits = (user.Business_Units__c).split(';');
        }        
        
        List<Phone_Config__c> phoneConfigs = [SELECT Name, Brand__c, Phone__c, Business_Unit__c FROM Phone_Config__c WHERE Business_Unit__c IN :lBusinessUnits OR Business_Unit__c = 'Global'];

        for (Phone_Config__c pc : phoneConfigs) {
            phonesByBrandMap.put(pc.Brand__c != null ? pc.Brand__c : pc.Name, pc.Phone__c);
        }

        return phonesByBrandMap;
    }

    private static Call_Task__c generateCallTask(String brandPhone, String customerPhone){
        RecordType leadManagementRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Call_Task__c' AND DeveloperName = 'Outbound_Call'];

        Call_Task__c callTask = new Call_Task__c();
        callTask.RecordTypeId = leadManagementRT.Id;
        callTask.OwnerId = UserInfo.getUserId();
        callTask.Brand_Phone__c = brandPhone;
        callTask.Target_Phone__c = customerPhone;
        callTask.Status__c = 'En curso';
        callTask.Call_Attempts__c = 0;
        callTask.Total_Call_Attempts__c = '0'; 
        return callTask;
    }

    private static Boolean updateRelatedCase(Id realtedCaseId){
        Case relatedCase = [SELECT Id, Total_Attempts__c, Numero_de_llamadas__c
                            FROM Case
                            WHERE Id = :realtedCaseId LIMIT 1];

        if(relatedCase != NULL){
            relatedCase.Total_Attempts__c = (relatedCase.Total_Attempts__c != NULL) ? ++relatedCase.Total_Attempts__c : 1;
            relatedCase.Numero_de_llamadas__c = String.valueOf(relatedCase.Total_Attempts__c);
            update relatedCase;
            return true;
        }

        return false;
    }

    /*----------------------------------------------------------------------------------------------------------------------------------------
     Apex Class:        ApexRestResultWrapper
     Created Date:      27/04/2021
     Company:           Nubika Consulting
     Author:            Alberto Sanchez
    ----------------------------------------------------------------------------------------------------------------------------------------*/
    global class ApexRestResultWrapper {
        public Boolean success {get;set;}
        public String errorMessage {get;set;}
        public Map<String, String> brandPhonesMap {get;set;}
        public String brandPhone {get;set;}
        public Map<String, String> customerPhonesMap {get;set;}
        public String customerPhone {get;set;}
        public Id caseId {get;set;}
    }
}