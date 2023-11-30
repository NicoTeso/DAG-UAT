/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_CaseTriggerHandler
     Created Date:      18/03/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/

public with sharing class NBK_CaseTriggerHandler {

    private final static Integer MEDIUM_FITNESS = 10;
    private final static Integer NUM_RETRIES = 3;

    private static List<Lead_Management__c> lLeadManagements = new List<Lead_Management__c>();
    private static Map<String,Group> mQueuesByDeveloperName = new Map<String,Group>();
    private static Map<String,RecordType> mCallTaskRecordTypesByDeveloperName = new Map<String,RecordType>();

    private static Map<Id,Boolean> mCaseAvailableToReschedule = new Map<Id,Boolean>();
    private static Map<String,Phone_Config__c> mBrandPhoneConfig = new Map<String,Phone_Config__c>();
    private static BusinessHours defaultBusinessHours;

    public final static List<Group> lQueues{
        get{
            if(lQueues == null){
                lQueues = new List<Group>();
                for(Group g : [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue']){
                    lQueues.add(g);
                }
            }
            return lQueues;
        }set;
    }

    public static void proccessCasesForLeadManagement(List<Case> lCasesToProcess){

        Set<Id> caseIds = new Set<Id>();
        for(Case caseObj: lCasesToProcess){
            if(filterCasesByRecordType(caseObj)){
                caseIds.add(caseObj.Id);
            }
        }

        if(!caseIds.isEmpty()){
            List<Case> lCases = [
                SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Marca__c,
                Concesionario__c, Centro__c, Intencion_de_compra__c, Origin, Campana__c,
                PurchasePriority__c, Lead__c, ContactId, SuppliedPhone, CreatedDate, Numero_de_llamadas__c 
                FROM Case
                WHERE Id IN :caseIds
            ];
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - lCases: ' + lCases);
    
            for(Group q : lQueues){
                mQueuesByDeveloperName.put(q.DeveloperName,q);
            }
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - mQueuesByDeveloperName: ' + mQueuesByDeveloperName);
    
    
            List<RecordType> lCallTaskRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Call_Task__c'];
            for(RecordType rt : lCallTaskRecordTypes){
                mCallTaskRecordTypesByDeveloperName.put(rt.DeveloperName, rt);
            }
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - mCallTaskRecordTypesByDeveloperName: ' + mCallTaskRecordTypesByDeveloperName);
    
            defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - defaultBusinessHours: ' + defaultBusinessHours);
            
            Set<String> lTypes = new Set<String>();
            Set<String> lBrands = new Set<String>();
            Set<String> lDealearships = new Set<String>();
            Set<String> lEstablishments = new Set<String>();
            Set<String> lPurchaseReasons = new Set<String>(); //Multipicklist
            Set<String> lOrigins = new Set<String>();
            Set<String> lCampaigns = new Set<String>();
    
            for(Case caseObj : lCases){
                if(!lTypes.contains(caseObj.RecordType.DeveloperName)) lTypes.add(caseObj.RecordType.DeveloperName);
                if(!lBrands.contains(caseObj.Marca__c)) lBrands.add(caseObj.Marca__c);
                if(!lDealearships.contains(caseObj.Concesionario__c)) lDealearships.add(caseObj.Concesionario__c);
                if(!lEstablishments.contains(caseObj.Centro__c)) lEstablishments.add(caseObj.Centro__c);
                if(!lOrigins.contains(caseObj.Origin)) lOrigins.add(caseObj.Origin);
                if(!lCampaigns.contains(caseObj.Campana__c)) lCampaigns.add(caseObj.Campana__c);
    
                Set<String> purchaseReasonValues = splitValues(caseObj.Intencion_de_compra__c);
                for(String purchaseReason : purchaseReasonValues){
                    if(!lPurchaseReasons.contains(purchaseReason)) lPurchaseReasons.add(purchaseReason);
                }
            }
    
            String query =  'SELECT Id, Name, Call__c, Call_In__c, Type__c, Brand__c, Dealership__c, ' +
                            'Establishment__c, Purchase_Reason__c, Origin__c, Campaign__c ' +
                            'FROM Lead_Management__c WHERE Id != null ';
    
            if(lTypes != null && lTypes.size() > 0) query += 'OR Type__c IN :lTypes ';
            if(lBrands != null && lBrands.size() > 0) query += 'OR Brand__c IN :lBrands ';
            if(lDealearships != null && lDealearships.size() > 0) query += 'OR Dealership__c IN :lDealearships ';
            if(lEstablishments != null && lEstablishments.size() > 0) query += 'OR Establishment__c IN :lEstablishments ';
            if(lOrigins != null && lOrigins.size() > 0) query += 'OR Origin__c IN :lOrigins ';
            if(lCampaigns != null && lCampaigns.size() > 0) query += 'OR Campaign__c IN :lCampaigns ';
    
            if(lPurchaseReasons != null && lPurchaseReasons.size() > 0){
                for(String purchaseReason : lPurchaseReasons)
                    query += 'OR Purchase_Reason__c INCLUDES (:purchaseReason) ';
            }
    
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - query: ' + query);
            lLeadManagements = Database.query(query);
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - lLeadManagements: ' + lLeadManagements);
    
            Map<Id,Lead_Management__c> mLeadManagementByIds = new Map<Id,Lead_Management__c>();
            for(Lead_Management__c leadManagement : lLeadManagements){
                mLeadManagementByIds.put(leadManagement.Id,leadManagement);
            }
    
            Map<Id,Case> mCasesByIds = new Map<Id,Case>();
    
            List<Call_Task__c> lCallTasks = new List<Call_Task__c>();
            Map<String,List<Call_Task__c>> mCallInCallTaskList = new Map<String,List<Call_Task__c>>();
    
            getBrandPhoneInfoMap();
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - mBrandPhoneConfig: ' + mBrandPhoneConfig);
    
            for(Case caseObj : lCases){
                mCasesByIds.put(caseObj.Id,caseObj);
                Lead_Management__c leadManagement = getLeadManagement(caseObj);
                System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - leadManagement: ' + leadManagement);
                if(leadManagement != null && (leadManagement.Call__c || leadManagement.Call_In__c != null)){
    
                    Group assignedQueue = getQueue(caseObj);
                    System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - assignedQueue: ' + assignedQueue);
    
                    if(assignedQueue != null){
                        Call_Task__c callTask = generateCallTask(caseObj,assignedQueue);
                        System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - callTask: ' + callTask);
    
                        if(leadManagement.Call__c && callTask != null) lCallTasks.add(callTask);
                        else if(leadManagement.Call_In__c != null && callTask != null){
                            String hours = String.valueOf(leadManagement.Call_In__c);
                            List<Call_Task__c> lCurrentCallTasks = mCallInCallTaskList.get(hours);
                            if(lCurrentCallTasks != null){
                                lCurrentCallTasks.add(callTask);
                                mCallInCallTaskList.put(hours,lCurrentCallTasks);
                            }
                            else{
                                List<Call_Task__c> lNewCallTasks = new List<Call_Task__c>{callTask};
                                mCallInCallTaskList.put(hours,lNewCallTasks);
                            }
                        }
                    }
                }
            }
    
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - lCallTasks: ' + lCallTasks);
            System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement() - mCallInCallTaskList: ' + mCallInCallTaskList);
        
            if(lCallTasks != null && lCallTasks.size() > 0) upsert lCallTasks;
            if(mCallInCallTaskList != null && mCallInCallTaskList.size() > 0){
                for(String hour : mCallInCallTaskList.keySet()){
                    List<Call_Task__c> lHourCallTasks = mCallInCallTaskList.get(hour);
                    NBK_ScheduleCall scheduleJob = new NBK_ScheduleCall(lHourCallTasks);
                    Datetime today = System.now();
                    today = today.addHours(Integer.valueOf(hour));
                    String sch = today.second() + ' ' + today.minute() + ' ' + today.hour() + ' ' + today.day() + ' ' + today.month() + ' ?';
                    System.debug('### NBK_CaseTriggerHandler - proccessCasesForLeadManagement - sch: ' + sch);
                    String jobID = System.schedule('CallLog#'+hour, sch, scheduleJob);
                }
            }
        }
    }
    
    private static Set<String> splitValues(String values){

        if(values == null) return new Set<String>();

        Set<String> allValues = new Set<String>();
        String[] lValues = values.split(';');
        for(String s : lValues){
            allValues.add(s);
        }

        return allValues;
    }

    private static void getBrandPhoneInfoMap(){
        List<Phone_Config__c> lPhoneConfigs = [SELECT Name, Phone__c, Brand__c, Business_Hours__c FROM Phone_Config__c];
        for(Phone_Config__c phoneConfig : lPhoneConfigs){
            mBrandPhoneConfig.put(phoneConfig.Brand__c,phoneConfig);
        }
    }

    private static Lead_Management__c getLeadManagement(Case caseObj){
        Integer bestFitness = 0;
        Lead_Management__c bestLeadManagement = null;
        for(Lead_Management__c leadManagement : lLeadManagements) {
            System.debug('### NBK_CaseTriggerHandler - getLeadManagement() - leadManagement: ' + leadManagement);
            Integer currentFitness = getFitness(leadManagement, caseObj);
            System.debug('### NBK_CaseTriggerHandler - getLeadManagement() - currentFitness: ' + currentFitness);
            if (currentFitness > bestFitness) {
                bestFitness = currentFitness;
                bestLeadManagement = leadManagement;
            }
        }
        System.debug('### NBK_CaseTriggerHandler - getLeadManagement() - bestLeadManagement: ' + bestLeadManagement);
        return bestLeadManagement;
    }

    private static Integer getFitness(Lead_Management__c leadManagement, Case caseObj){
        String recordType = (caseObj.RecordTypeId != null) ? caseObj.RecordType.DeveloperName : null;
        String brand = caseObj.Marca__c;
        String dealership = caseObj.Concesionario__c;
        String establishment = caseObj.Centro__c;
        String purchaseReasons = caseObj.Intencion_de_compra__c;
        Set<String> lPurchaseReasons = splitValues(caseObj.Intencion_de_compra__c);
        String origin = caseObj.Origin;
        String campaign = caseObj.Campana__c;

        System.debug('### NBK_CaseTriggerHandler - getFitness() - recordType: ' + recordType);
        System.debug('### NBK_CaseTriggerHandler - getFitness() - brand: ' + brand);
        System.debug('### NBK_CaseTriggerHandler - getFitness() - dealership: ' + dealership);
        System.debug('### NBK_CaseTriggerHandler - getFitness() - establishment: ' + establishment);
        System.debug('### NBK_CaseTriggerHandler - getFitness() - purchaseReasons: ' + purchaseReasons);
        System.debug('### NBK_CaseTriggerHandler - getFitness() - origin: ' + origin);
        System.debug('### NBK_CaseTriggerHandler - getFitness() - campaign: ' + campaign);

        Integer fitness = 0;
        if((leadManagement.Type__c != null && recordType != leadManagement.Type__c)
                || (leadManagement.Brand__c != null && brand != leadManagement.Brand__c)
                || (leadManagement.Dealership__c != null && dealership != leadManagement.Dealership__c)
                || (leadManagement.Establishment__c != null && establishment != leadManagement.Establishment__c)
                || (leadManagement.Origin__c != null && origin != leadManagement.Origin__c)
                || (leadManagement.Campaign__c != null && campaign != leadManagement.Campaign__c)
        ) return 0;

        if(recordType != null && recordType.equals(leadManagement.Type__c)) fitness += MEDIUM_FITNESS;
        if(brand != null && brand.equals(leadManagement.Brand__c)) fitness += MEDIUM_FITNESS;
        if(dealership != null && dealership.equals(leadManagement.Dealership__c)) fitness += MEDIUM_FITNESS;
        if(establishment != null && establishment.equals(leadManagement.Establishment__c)) fitness += MEDIUM_FITNESS;
        if(origin != null && origin.equals(leadManagement.Origin__c)) fitness += MEDIUM_FITNESS;
        if(campaign != null && campaign.equals(leadManagement.Campaign__c)) fitness += MEDIUM_FITNESS;

        if(purchaseReasons != null && purchaseReasons.equals(leadManagement.Purchase_Reason__c)) fitness += MEDIUM_FITNESS;
        else{
            for(String purchaseReason : splitValues(leadManagement.Purchase_Reason__c)){
                if(lPurchaseReasons.contains(purchaseReason)) fitness += MEDIUM_FITNESS;
            }
        }

        return fitness;

    }

    @TestVisible
    public static Group getQueue(Case caseObj){
        String recordType = (caseObj.RecordTypeId != null) ? caseObj.RecordType.DeveloperName : null;
        String brand = caseObj.Marca__c;
        String origin = caseObj.Origin;
        String purchasePriority = caseObj.PurchasePriority__c;
        Boolean isWorkingDay = isWorkingDay(caseObj.CreatedDate);
        String totalCallAttempts = caseObj.Numero_de_llamadas__c; 

        if(mQueuesByDeveloperName.isEmpty()){
            for(Group q : lQueues){
                mQueuesByDeveloperName.put(q.DeveloperName,q);
            }
        }

        System.debug('### NBK_CaseTriggerHandler - getQueue() - recordType: ' + recordType);
        System.debug('### NBK_CaseTriggerHandler - getQueue() - brand: ' + brand);
        System.debug('### NBK_CaseTriggerHandler - getQueue() - purchasePriority: ' + purchasePriority);
        System.debug('### NBK_CaseTriggerHandler - getQueue() - caseObj.CreatedDate: ' + String.valueOf(caseObj.CreatedDate));
        System.debug('### NBK_CaseTriggerHandler - getQueue() - isWorkingDay: ' + isWorkingDay);
        System.debug('### NBK_CaseTriggerHandler - getQueue() - totalCallAttempts: ' + totalCallAttempts);
        System.debug('### NBK_CaseTriggerHandler - getQueue() - mQueuesByDeveloperName: ' + mQueuesByDeveloperName);

        if(!isVO(recordType) && isVWH(brand) && !hasBeenContacted(totalCallAttempts) && isWorkingDay){
            //VWT_y_HONDA_Prioridad_Alta_Laboral
            return mQueuesByDeveloperName.get('VWT_y_HONDA_Prioridad_Alta_Laboral');
        } else if(!isVO(recordType) && isVWH(brand) && hasBeenContacted(totalCallAttempts) && isWorkingDay){
            //VWT_y_HONDA_Prioridad_Baja_Laboral
            return mQueuesByDeveloperName.get('VWT_y_HONDA_Prioridad_Baja_Laboral');
        } else if(!isVO(recordType) && isVWH(brand) && !hasBeenContacted(totalCallAttempts) && !isWorkingDay){
            //VWT_y_HONDA_Prioridad_Alta_NoLaboral
            return mQueuesByDeveloperName.get('VWT_y_HONDA_Prioridad_Alta_NoLaboral');
        } else if(!isVO(recordType) && isVWH(brand) && hasBeenContacted(totalCallAttempts) && !isWorkingDay){
            //VWT_y_HONDA_Prioridad_Baja_NoLaboral
            return mQueuesByDeveloperName.get('VWT_y_HONDA_Prioridad_Baja_NoLaboral');
        } else if(!isVO(recordType) && isHSA(brand) && !hasBeenContacted(totalCallAttempts) && isWorkingDay){
            //Hyu_Audi_y_Sko_Prioridad_Alta_Laboral
            return mQueuesByDeveloperName.get('Hyu_Audi_y_Sko_Prioridad_Alta_Laboral');
        } else if(!isVO(recordType) && isHSA(brand) && hasBeenContacted(totalCallAttempts) && isWorkingDay){
            //Hyu_Audi_y_Sko_Prioridad_Baja_Laboral
            return mQueuesByDeveloperName.get('Hyu_Audi_y_Sko_Prioridad_Baja_Laboral');
        } else if(!isVO(recordType) && isHSA(brand) && !hasBeenContacted(totalCallAttempts) && !isWorkingDay){
            //Hyu_Audi_y_Sko_Prioridad_Alta_NoLaboral
            return mQueuesByDeveloperName.get('Hyu_Audi_y_Sko_Prioridad_Alta_NoLaboral');
        } else if(!isVO(recordType) && isHSA(brand) && hasBeenContacted(totalCallAttempts) && !isWorkingDay){
            //Hyu_Audi_y_Sko_Prioridad_Baja_NoLaboral
            return mQueuesByDeveloperName.get('Hyu_Audi_y_Sko_Prioridad_Baja_NoLaboral');
        } else if(isAVIS(origin)){
            //Feria_AVIS
            return mQueuesByDeveloperName.get('Feria_AVIS');
        } else if(isVO(recordType) && !hasBeenContacted(totalCallAttempts) && isWorkingDay){
            //VO_Prioridad_Alta_Laboral
            return mQueuesByDeveloperName.get('VO_Prioridad_Alta_Laboral');
        } else if(isVO(recordType) && hasBeenContacted(totalCallAttempts)){
            //VO_Prioridad_Alta_NoLaboral
            return mQueuesByDeveloperName.get('VO_Prioridad_Alta_NoLaboral');
        }
        return null;
    }

    private static Boolean isVO(String recordType){
        return recordType.equals('Gestion_de_Lead_VO');
    }
    private static Boolean isVWH(String brand){
        if(String.isBlank(brand)) return false;
        Set<String> setVWH = new Set<String>{'VOLKSWAGEN', 'VW COMERCIALES', 'HONDA', 'HONDA MOTOS', 'SILENCE'};
        return setVWH.contains(brand);
    }
    private static Boolean isHSA(String brand){
        if(String.isBlank(brand)) return false;
        Set<String> setHSA = new Set<String>{'HYUNDAI', 'SKODA', 'AUDI'};
        return setHSA.contains(brand);
    }
    private static Boolean isAVIS(String origin){
        if(String.isBlank(origin)) return false;
        return origin.equals('FeriaAVIS');
    }
    private static Boolean isLowPriority(String priority){
        if(String.isBlank(priority)) return false;
        return priority.equals('2') || priority.equals('3');
    }
    private static Boolean isHighPriority(String priority){
        return String.isBlank(priority) || priority.equals('1');
    }
    private static Boolean hasBeenContacted(String totalCallsAttempts){
        return (totalCallsAttempts != '0');
    }

    /*private static Boolean isInTimeRange(DateTime dt, Integer startHour, Integer endHour){

        if(dt == null) return false;
        String dayOfWeek = dt.format('EEEE');
        if(dayOfWeek == 'Sunday') return false;

        String dateTimeStr = String.valueOf(dt);

        //Get HH:mm:ss
        String[] dateTimeValues = datetimeStr.split(' ');
        String timeValues = dateTimeValues[1];

        //Get only HH
        String[] timeValue = timeValues.split(':');
        String hour = timeValue[0];

        Integer hourInt = Integer.valueOf(hour);

        if(hourInt >= startHour && hourInt <= endHour) return true;
        else return false;
    }*/

    public static Boolean isWorkingDay(Datetime dt){
        if(dt == null) return false;

        BusinessHours callTaskManagement = [SELECT Id FROM BusinessHours WHERE Name = :NBK_GlobalConstants.CALL_TASK_MANAGER_BH];

        if(callTaskManagement != NULL){
            return BusinessHours.isWithin(callTaskManagement.Id, dt);

        } else {
            if (defaultBusinessHours == null) {
                defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
            }

            return BusinessHours.isWithin(defaultBusinessHours.Id,dt);
        }
    }

    private static Call_Task__c generateCallTask(Case caseObj, Group assignedQueue){
        Call_Task__c callTask = new Call_Task__c();
        callTask.RecordTypeId = mCallTaskRecordTypesByDeveloperName.get('Lead_Management').Id;
        callTask.Case__c = caseObj.Id;
        callTask.Assigned_Queue__c = assignedQueue.Id;
        callTask.OwnerId = assignedQueue.Id;
        callTask.Lead__c = caseObj.Lead__c;
        callTask.Client__c = caseObj.ContactId;
        callTask.Status__c = 'No completada';
        callTask.Total_Call_Attempts__c = caseObj.Numero_de_llamadas__c;

        Phone_Config__c phoneConfig = mBrandPhoneConfig.get(caseObj.Marca__c);
        if(phoneConfig != null) callTask.Brand_Phone__c = phoneConfig.Phone__c;
        /*Brand_Phones__c bp = Brand_Phones__c.getValues(caseObj.Marca__c);
        if(bp != null) callTask.Brand_Phone__c = bp.Phone__c;*/
        callTask.Target_Phone__c = caseObj.SuppliedPhone;

        return callTask;
    }

    public static void rescheduleCases(Map<Id,Case> oldCasesMap, Map<Id,Case> newCasesMap){
        Map<Id, Case> filteredCases = new Map<Id, Case>();

        for (Id caseId : newCasesMap.keySet()) {
            Case getCase = newCasesMap.get(caseId);
            if (filterCasesByRecordType(getCase)) {
                filteredCases.put(caseId, getCase);
            }
        }

        if(!filteredCases.isEmpty()){
            getAvailableCasesForRescheduleMap(oldCasesMap,newCasesMap);
            Map<Id, Case> mNewCases = new Map<Id, Case> ([
                    SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Marca__c,
                            Concesionario__c, Centro__c, Intencion_de_compra__c, Origin, Campana__c,
                            PurchasePriority__c, Lead__c, ContactId, SuppliedPhone, CreatedDate, Numero_de_llamadas__c
                    FROM Case
                    WHERE Id IN :filteredCases.keySet()
            ]);
            List<Call_Task__c> lCallTasks = new List<Call_Task__c>();
            for(Case oldCase : oldCasesMap.values()){
                Case newCase = mNewCases.get(oldCase.Id);
                if(newCase != null && mCaseAvailableToReschedule != null && mCaseAvailableToReschedule.containsKey(newCase.Id) && mCaseAvailableToReschedule.get(newCase.Id) == true){
                    System.debug('### NBK_CaseTriggerHandler - rescheduleCases() - newCase: ' + newCase);
                    Group assignedQueue = getQueue(newCase);
                    System.debug('### NBK_CaseTriggerHandler - rescheduleCases() - assignedQueue: ' + assignedQueue);
                    Call_Task__c callTask = generateCallTask(newCase,assignedQueue);
                    System.debug('### NBK_CaseTriggerHandler - rescheduleCases() - callTask: ' + callTask);
                    lCallTasks.add(callTask);
                }
            }
            System.debug('### NBK_CaseTriggerHandler - rescheduleCases() - lCallTasks: ' + lCallTasks);
            if(lCallTasks.size() > 0) upsert lCallTasks;
        }
    }

    private static void getAvailableCasesForRescheduleMap(Map<Id,Case> oldCasesMap, Map<Id,Case> newCasesMap){
        List<Case> checkedCases = new List<Case>();
        Set<Id> checkedCasesIds = new Set<Id>();
        System.debug('### NBK_CaseTriggerHandler - getAvailableCasesForRescheduleMap() - newCasesMap: ' + newCasesMap);
        for(Case oldCase : oldCasesMap.values()){
            Case newCase = newCasesMap.get(oldCase.Id);
            System.debug('### NBK_CaseTriggerHandler - getAvailableCasesForRescheduleMap() - newCase: ' + newCase);
            if(oldCase.Call_Again__c != newCase.Call_Again__c && newCase.Call_Again__c == true){
                checkedCases.add(newCase);
                checkedCasesIds.add(newCase.Id);
            }
        }

        List<Call_Task__c> lCallTasks = [
                SELECT Id, Name, Case__c, Status__c, Call_Attempts__c, Total_Call_Attempts__c
                FROM Call_Task__c
                WHERE Case__c IN :checkedCases
        ];
        System.debug('### NBK_CaseTriggerHandler - getAvailableCasesForRescheduleMap() - lCallTasks: ' + lCallTasks);


        Map<Id,List<Call_Task__c>> mCaseIdCallTasks = new Map<Id,List<Call_Task__c>>();
        for(Call_task__c callTask : lCallTasks){
            List<Call_Task__c> lRelatedCallTasks = mCaseIdCallTasks.get(callTask.Case__c);
            if(lRelatedCallTasks != null){
                lRelatedCallTasks.add(callTask);
                mCaseIdCallTasks.put(callTask.Case__c,lRelatedCallTasks);
            }
            else{
                mCaseIdCallTasks.put(callTask.Case__c,new List<Call_Task__c>{callTask});
            }
        }
        System.debug('### NBK_CaseTriggerHandler - getAvailableCasesForRescheduleMap() - mCaseIdCallTasks: ' + mCaseIdCallTasks);


        for(Id caseId : mCaseIdCallTasks.keySet()){
            List<Call_Task__c> lRelatedCallTasks = mCaseIdCallTasks.get(caseId);

            Boolean hasIncompletedCallTask = false;
            for(Call_Task__c callTask : lRelatedCallTasks){
                System.debug('### NBK_CaseTriggerHandler - getAvailableCasesForRescheduleMap() - callTask: ' + callTask);
                if(!hasIncompletedCallTask && callTask.Status__c == 'No Completada' && callTask.Call_Attempts__c < 6 && Integer.valueof(callTask.Total_Call_Attempts__c) < 6)
                    hasIncompletedCallTask = true;
            }

            mCaseAvailableToReschedule.put(caseId,!hasIncompletedCallTask);
        }

        System.debug('### NBK_CaseTriggerHandler - getAvailableCasesForRescheduleMap() - mCaseAvailableToReschedule: ' + mCaseAvailableToReschedule);

    }


	public static Set<Id> assignCaseIdToMessagingSession(Set<Id> newCasesIds){
        Set<Id> casesAlreadyUpdated = new Set<Id>();
        List<MessagingSession> listToUpdateMessagingSession = New List<MessagingSession>();
        Map<Id, Case> casesMapById = New Map<Id,Case>([SELECT Id, AccountId, Lead__c, Marca__c, Enviado_plantilla_2_Llamada__c, Enviado_plantilla_Preferencia_de_contact__c, Enviado_plantilla_Recordatorio_de_cita__c, Enviado_confirmacion_cita__c, Reenganche_2_llamada__c, Reenganche_preferencia_de_contacto__c, Enviado_plantilla_nurturing__c FROM Case WHERE Id IN: newCasesIds AND Id NOT IN:casesAlreadyUpdated]);
        Set<Id> accountIds = New Set<Id>();
        Set<Id> leadIds = new set<Id>();
        
        try{
            for(Case cs : casesMapById.values()){
                if(!String.isEmpty(cs.accountId)){
                    accountIds.add(cs.accountId);
                }else if(!String.isEmpty(cs.Lead__c)){
                    leadIds.add(cs.Lead__c);
                }
            }
            Map<Id, Map<Id,MessagingEndUser>> messagingUserMapByAccountIdMap = new Map<Id, Map<Id, MessagingEndUser>>();
            Map<Id, Map<Id,MessagingEndUser>> messagingUserMapByLeadIdMap = new Map<Id, Map<Id, MessagingEndUser>>();
            Set<Id> messagingEndUserIds = New Set<Id>();
            for(MessagingEndUser meu : [SELECT Id, AccountId FROM MessagingEndUser WHERE AccountId IN: accountIds]){
                if(!messagingUserMapByAccountIdMap.containsKey(meu.AccountId)){
                    messagingUserMapByAccountIdMap.put(meu.AccountId, new map<Id,MessagingEndUser>{meu.Id=>meu});
                }else{
                    messagingUserMapByAccountIdMap.get(meu.AccountId).put(meu.Id, meu);
                }
                messagingEndUserIds.add(meu.Id);
            }
            for(MessagingEndUser meu : [SELECT Id, Lead__c FROM MessagingEndUser WHERE Lead__c IN: leadIds AND AccountId = NULL]){
                if(!messagingUserMapByLeadIdMap.containsKey(meu.Lead__c)){
                    messagingUserMapByLeadIdMap.put(meu.Lead__c, new map<Id,MessagingEndUser>{meu.Id=>meu});
                }else{
                    messagingUserMapByLeadIdMap.get(meu.Lead__c).put(meu.Id, meu);
                }
                messagingEndUserIds.add(meu.Id);
            }
            System.debug('### NBK_CaseTriggerHandler -  messagingUserMapByLeadIdMap: ' + messagingUserMapByLeadIdMap);
            System.debug('### NBK_CaseTriggerHandler -  messagingUserMapByAccountIdMap: ' + messagingUserMapByAccountIdMap);
            Map<Id, Map<String, MessagingSession>> messagingSessionMapByEndUserId = new Map<Id, Map<String, MessagingSession>>();
            for(MessagingSession ms : [SELECT Id, MessagingEndUserId, CreatedDate, LeadId, CaseId, Marca__c  
                                        FROM MessagingSession 
                                        WHERE  MessagingEndUserId IN: messagingEndUserIds AND Marca__c != NULL
                                        ORDER BY CreatedDate desc]){

                if(messagingSessionMapByEndUserId.containsKey(ms.MessagingEndUserId)){
                    Map<String, MessagingSession> mapSession = messagingSessionMapByEndUserId.get(ms.MessagingEndUserId);                        
                    if(!mapSession.containsKey(ms.Marca__c) || 
                    (mapSession.get(ms.Marca__c)?.CreatedDate < ms.CreatedDate)){
                        mapSession.put(ms.Marca__c, ms);
                    }
                }else{
                    messagingSessionMapByEndUserId.put(ms.MessagingEndUserId, new Map<String, MessagingSession>{ms.Marca__c => ms});
                }
            }
            System.debug('### NBK_CaseTriggerHandler - messagingSessionMapByEndUserId() - messagingSessionMapByEndUserId: ' + messagingSessionMapByEndUserId);
            for(Case caseToUpdate : casesMapById.values()){
                System.debug('### NBK_CaseTriggerHandler - assignCaseIdToMessagingSession() - newCase: ' + caseToUpdate);
                if(caseToUpdate.Enviado_plantilla_2_Llamada__c || caseToUpdate.Enviado_plantilla_Preferencia_de_contact__c || caseToUpdate.Enviado_plantilla_Recordatorio_de_cita__c || caseToUpdate.Enviado_confirmacion_cita__c || caseToUpdate.Reenganche_2_llamada__c || caseToUpdate.Reenganche_preferencia_de_contacto__c || caseToUpdate.Enviado_plantilla_nurturing__c){
                    System.debug('### NBK_CaseTriggerHandler - inside condition: ' + caseToUpdate);    
                    System.debug('### NBK_CaseTriggerHandler - caseToUpdate: ' + caseToUpdate);
                    List<Id> messagingEndUserIdsByParentObject = new List<Id>();
                    messagingEndUserIdsByParentObject.addAll(new List<Id>(messagingUserMapByAccountIdMap.get(caseToUpdate.AccountId)?.keySet()));
                    messagingEndUserIdsByParentObject.addAll(new List<Id>(messagingUserMapByLeadIdMap.get(caseToUpdate.Lead__c)?.keySet()));
                    System.debug('### NBK_CaseTriggerHandler - messagingEndUserIdsByParentObject: ' + messagingEndUserIdsByParentObject);
                    for(Id id : messagingEndUserIdsByParentObject){
                        if(messagingSessionMapByEndUserId.containsKey(id)){
                            Map<String, MessagingSession> msByBrandMap = messagingSessionMapByEndUserId.get(id);
                            System.debug('### NBK_CaseTriggerHandler - msByBrandMap: ' + msByBrandMap);
                            if(msByBrandMap.containsKey(caseToUpdate.Marca__c)){
                                MessagingSession lastMessagingSessionByUser = msByBrandMap.get(caseToUpdate.Marca__c);
                                System.debug('### NBK_CaseTriggerHandler - lastMessagingSessionByUser: ' + lastMessagingSessionByUser);
                                
                                Boolean modified = false;

                                if(lastMessagingSessionByUser.CaseId == null){
                                    lastMessagingSessionByUser.CaseId = caseToUpdate.Id;
                                    modified = true;
                                }

                                if(lastMessagingSessionByUser.LeadId == null){
                                    lastMessagingSessionByUser.LeadId = caseToUpdate.Lead__c;
                                    modified = true;
                                }

                                if(modified){
                                    listToUpdateMessagingSession.add(lastMessagingSessionByUser);
                                }
                                
                                casesAlreadyUpdated.add(caseToUpdate.Id);
                            }
                        }
                    }
                }
            }
            System.debug('### NBK_CaseTriggerHandler - listToUpdateMessagingSession: ' + listToUpdateMessagingSession);
            if(!listToUpdateMessagingSession.isEmpty()){
                update listToUpdateMessagingSession;
            }
        }catch(DmlException e){
            System.debug(' DML Exception caught: ' +e.getMessage());
        }catch(Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
        System.debug('casesAlreadyUpdated ids --> ' + casesAlreadyUpdated);
        return casesAlreadyUpdated;
    }

    public static void scheduleAssignCaseIdToMessagingSession(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        Set<Id> sFilteredCases = new Set<Id>();
        for(Case newCase : newCaseMap.values()){
            Case oldCase = oldCaseMap.get(newCase.id);

            Boolean enviadoPlantilla2 = (oldCase != null && newCase.Enviado_plantilla_2_Llamada__c != null && !oldCase.Enviado_plantilla_2_Llamada__c && newCase.Enviado_plantilla_2_Llamada__c) ? True : False;
            Boolean enviadoPlantillaPreferencia = (oldCase != null && newCase.Enviado_plantilla_Preferencia_de_contact__c != null && !oldCase.Enviado_plantilla_Preferencia_de_contact__c && newCase.Enviado_plantilla_Preferencia_de_contact__c) ? True : False;
            Boolean enviadoPlantillaRecordatorio = (oldCase != null && newCase.Enviado_plantilla_Recordatorio_de_cita__c != null && !oldCase.Enviado_plantilla_Recordatorio_de_cita__c && newCase.Enviado_plantilla_Recordatorio_de_cita__c) ? True : False;
            Boolean enviadoConfirmacion = (oldCase != null && newCase.Enviado_confirmacion_cita__c != null && !oldCase.Enviado_confirmacion_cita__c && newCase.Enviado_confirmacion_cita__c) ? True : False;
            Boolean enviadoReenganche2Llamada = (oldCase != null && newCase.Reenganche_2_llamada__c != null && !oldCase.Reenganche_2_llamada__c && newCase.Reenganche_2_llamada__c) ? True : False;
            Boolean enviadoReenganchePreferencia = (oldCase != null && newCase.Reenganche_preferencia_de_contacto__c != null && !oldCase.Reenganche_preferencia_de_contacto__c && newCase.Reenganche_preferencia_de_contacto__c) ? True : False;
            Boolean enviadoNurturing = (oldCase != null && newCase.Enviado_plantilla_nurturing__c != null && !oldCase.Enviado_plantilla_nurturing__c && newCase.Enviado_plantilla_nurturing__c) ? True : False;
            
            // Check if any of the previous values have changed from false value to true value and its RecordType
            Logger.debug('beforeCheck' + newCase);
            if(newCase.RecordTypeId == NBK_GlobalConstants.CASE_GESTION_LEAD_RT_ID && ( enviadoPlantilla2||enviadoPlantillaPreferencia||enviadoPlantillaRecordatorio||enviadoConfirmacion||enviadoReenganche2Llamada||enviadoReenganchePreferencia||enviadoNurturing ) ){
                newCase.ExecuteMessagingSessionMapping__c = true;
                Logger.debug('newCase.ExecuteMessagingSessionMapping__c -- true -- ' + newCase);
            }
        }
        Logger.saveLog();
    }

    @InvocableMethod(label='MessagingSessionMapping' description='Maps case with the last messaging session' category='Apex')
    public static void messagingSessionMapping(List<Id> recordIds){
        Logger.debug('MessagingSessionMapping -- recordIds -- ' + recordIds);
        Logger.saveLog();
        NBK_CaseTriggerHandler.assignCaseIdToMessagingSession(new Set<Id>(recordIds));
    }

    public static Boolean filterCasesByRecordType(Case record){
        if(record.RecordTypeId == NBK_GlobalConstants.CASE_GESTION_LEAD_RT_ID ||
           record.RecordTypeId == NBK_GlobalConstants.CASE_GESTION_LEAD_VO_RT_ID){
            return true;
        } else {
            return false;
        }
    }
}