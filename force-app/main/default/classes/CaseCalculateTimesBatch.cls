global class CaseCalculateTimesBatch implements Database.Batchable<sObject>, Schedulable {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, CreatedDate, WorkingCreatedDate1__c, 
                                         Fecha_Hora_de_contacto_c__c, FirstCallDate__c, SecondCallDate__c, ThirdCallDate__c,
										 FourthCallDate__c, FifthCallDate__c, SixthCallDate__c, FirstCallTime__c, SecondCallTime__c,
										 ThirdCallTime__c, FourthCallTime__c, FifthCallTime__c, SixthCallTime__c, ContactTime__c,
										 FirstCallWorking__c, SecondCallWorking__c, ThirdCallWorking__c, FourthCallWorking__c,
										 FifthCallWorking__c, SixthCallWorking__c                                         
                                         FROM Case
                                         WHERE FirstCallDate__c != null]);
//                                         WHERE WorkingCreatedDate1__c = null ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> lstcases) {
        Map<String, BusinessHours> mapBusinessHoursByName = new Map<String, BusinessHours>();
        mapBusinessHoursByName = CacheUtil.getBusinessHoursMap();
        BusinessHours bh = mapBusinessHoursByName.get('DAG Canarias');
        
//        system.debug('bh:'+bh);
        
        for (Case caso : lstcases) {
            
//            if(caso.WorkingCreatedDate1__c == null){
//                system.debug('caso.CreatedDate: '+caso.CreatedDate);
//                system.debug('BusinessHours.nextStartDate(bh.Id, caso.CreatedDate):'+BusinessHours.nextStartDate(bh.Id, caso.CreatedDate));
                caso.WorkingCreatedDate1__c= BusinessHours.isWithin(bh.Id, caso.CreatedDate)?caso.CreatedDate:BusinessHours.nextStartDate(bh.Id, caso.CreatedDate);
//                system.debug('despues 1 '+caso.WorkingCreatedDate1__c);
//            }
    
            if (caso.Fecha_Hora_de_contacto_c__c != null){
//                system.debug('caso.CreatedDate: '+caso.CreatedDate);
//                system.debug('caso.Fecha_Hora_de_contacto_c__c:'+caso.Fecha_Hora_de_contacto_c__c);
                caso.ContactTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.CreatedDate, caso.Fecha_Hora_de_contacto_c__c);
//                system.debug('despues 2 '+caso.ContactTime__c);
            }
            
            if (caso.FirstCallDate__c != null){
//                system.debug('caso.CreatedDate: '+caso.CreatedDate);
//                system.debug('caso.FirstCallDate__c:'+caso.FirstCallDate__c);
                caso.FirstCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.CreatedDate, caso.FirstCallDate__c);
//                system.debug('despues 3 '+caso.FirstCallTime__c);
            }
    
            if (caso.FirstCallDate__c != null && caso.SecondCallDate__c != null){
//                system.debug('caso.FirstCallDate__c:'+caso.FirstCallDate__c);
//                system.debug('caso.SecondCallDate__c:'+caso.SecondCallDate__c);
                caso.SecondCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.FirstCallDate__c, caso.SecondCallDate__c);
//                system.debug('despues 4 '+caso.SecondCallTime__c);
            }
    
            if (caso.SecondCallDate__c != null && caso.ThirdCallDate__c != null){
//                system.debug('caso.SecondCallDate__c:'+caso.SecondCallDate__c);
//                system.debug('caso.ThirdCallDate__c:'+caso.ThirdCallDate__c);
                caso.ThirdCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.SecondCallDate__c, caso.ThirdCallDate__c);
//                system.debug('despues 5 '+caso.ThirdCallTime__c);
            }
    
            if (caso.SecondCallDate__c != null && caso.FourthCallDate__c != null){
//                system.debug('caso.ThirdCallDate__c:'+caso.ThirdCallDate__c);
//                system.debug('caso.FourthCallDate__c:'+caso.FourthCallDate__c);
                caso.FourthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.ThirdCallDate__c, caso.FourthCallDate__c);
//                system.debug('despues 6 '+caso.FourthCallTime__c);
            }
    
            if (caso.FourthCallDate__c != null && caso.FifthCallDate__c != null){
//                system.debug('caso.FourthCallDate__c:'+caso.FourthCallDate__c);
//                system.debug('caso.FifthCallDate__c:'+caso.FifthCallDate__c);
                caso.FifthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.FourthCallDate__c, caso.FifthCallDate__c);
//                system.debug('despues 7 '+caso.FifthCallTime__c);
            }
    
            if (caso.FifthCallDate__c != null && caso.SixthCallDate__c != null){
//                system.debug('caso.FifthCallDate__c:'+caso.FifthCallDate__c);
//                system.debug('caso.SixthCallDate__c:'+caso.SixthCallDate__c);
                caso.SixthCallTime__c = BusinessHoursHelper.diferenciaTiempo(bh, caso.FifthCallDate__c, caso.SixthCallDate__c);
//                system.debug('despues 8 '+caso.SixthCallTime__c);
            }
            
            if(caso.FirstCallDate__c != null){
                caso.FirstCallWorking__c = BusinessHours.isWithin(bh.Id, caso.FirstCallDate__c);
            }

            if(caso.SecondCallDate__c != null){
                caso.SecondCallWorking__c = BusinessHours.isWithin(bh.Id, caso.SecondCallDate__c);
            }
            
            if(caso.ThirdCallDate__c != null){
                caso.ThirdCallWorking__c = BusinessHours.isWithin(bh.Id, caso.ThirdCallDate__c);
            }
            
            if(caso.FourthCallDate__c != null){
                caso.FourthCallWorking__c = BusinessHours.isWithin(bh.Id, caso.FourthCallDate__c);
            }
            
            if(caso.FifthCallDate__c != null){
                caso.FifthCallWorking__c = BusinessHours.isWithin(bh.Id, caso.FifthCallDate__c);
            }
            
            if(caso.SixthCallDate__c != null){
                caso.SixthCallWorking__c = BusinessHours.isWithin(bh.Id, caso.SixthCallDate__c);
            }
            
        }
    	update lstcases;

    }
    
    global void finish(Database.BatchableContext bc) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CaseCalculateTimesBatch());
    }
}