/**
 * @description  :
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 12-06-2023
 * @group        :
 * @see          :
**/
public with sharing class NBK_BatchSendNurturing implements Database.Batchable<SObject>{
	public Database.QueryLocator start(Database.BatchableContext BC){

		return Database.getQueryLocator([SELECT Id, CaseNumber, Fecha_Hora_de_cita__c, Date_Send_nurturing_retry_notification__c
																		 FROM Case
																		 WHERE RecordTypeId = :NBK_GlobalConstants.CASE_GESTION_LEAD_RT_ID
																		 		AND baja_de_precio__c = False
																		 		AND(TypeOfAppointment__c = :NBK_GlobalConstants.CASE_APPOINTMENT_TYPE
																						OR TypeOfAppointment__c = :NBK_GlobalConstants.CASE_PHONE_TYPE)
																				AND Status = :NBK_GlobalConstants.CASE_GESTION_WHATSAPP_CLOSE_STATUS
																				AND Motivo_de_cierre__c = :NBK_GlobalConstants.CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE
																				AND Enviado_plantilla_nurturing__c = False
																				AND Send_Nurturing_Notification__c = False
																				AND Estado_Oportunidad__c = :NBK_GlobalConstants.OPPO_QUALIFICATION_STATUS
																				AND (Fecha_Hora_de_cita__c = N_DAYS_AGO:2
																						 OR Date_Send_nurturing_retry_notification__c = TODAY)]);
	}
	public void execute(Database.BatchableContext BC, List<Case> scope){
	try{

		Datetime now = Datetime.now();
		Integer offset = UserInfo.getTimezone().getOffset(now);
		Datetime actualHour = now.addSeconds(offset/1000);
		List<Case> caseToUpdate = new List<Case>();

		for(Case caseActual : scope){

			DateTime twoDaysLater =  caseActual.Fecha_Hora_de_cita__c.addDays(2);

			// Date_Send_nurturing_retry_notification__c and is same hour than now
		 	if (caseActual.Date_Send_nurturing_retry_notification__c != null && caseActual.Date_Send_nurturing_retry_notification__c.date() == actualHour.date() && caseActual.Date_Send_nurturing_retry_notification__c.hour() <= actualHour.hour()){
				Case auxCase = new Case(Id=caseActual.Id);
				auxCase.Send_Nurturing_Notification__c = true;

				caseToUpdate.add(auxCase);
			// Fecha_Hora_de_cita__c is 2 days ago and same hour than now
			} else if(twoDaysLater != null && twoDaysLater.date() == actualHour.date() && twoDaysLater.hour() <= actualHour.hour()){
				Case auxCase = new Case(Id=caseActual.Id);
				DateTime sendDate = NBK_HolydaysManager.checkHolidays(twoDaysLater);
				auxCase.Date_Send_nurturing_retry_notification__c = sendDate;
				auxCase.Send_Nurturing_Notification__c = (sendDate.date() == actualHour.date() && sendDate.hour() <= actualHour.hour()) ? true : false;

				caseToUpdate.add(auxCase);

			// Date_Send_nurturing_retry_notification__c is not calculated yet
			} else if (caseActual.Date_Send_nurturing_retry_notification__c == null){

				Case auxCase = new Case(Id=caseActual.Id);
				DateTime sendDate = NBK_HolydaysManager.checkHolidays(twoDaysLater);
				auxCase.Date_Send_nurturing_retry_notification__c = sendDate;
				auxCase.Send_Nurturing_Notification__c = false;

				caseToUpdate.add(auxCase);
			}

		}

		System.debug('caseToUpdate: '+JSON.serialize(caseToUpdate));
		if(!caseToUpdate.isEmpty()){
			update caseToUpdate;
		}

	} catch(Exception e){
		System.debug(e.getMessage() + ' at line \n' + e.getStackTraceString());
	}
	}

	public void finish(Database.BatchableContext BC){

	}
}