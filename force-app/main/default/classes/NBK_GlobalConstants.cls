/**
 * @description  :
 * @author       : development@nubika.com
**/
public class NBK_GlobalConstants {

    public static final MyDagConfig__mdt DAG_CONFIG = !Test.isRunningTest() ? MyDagConfig__mdt.getInstance('MyDagConfig') : new MyDagConfig__mdt();

    public static final String CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_NAME  = 'Ficha_unica';
    public static final String CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID  = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName().get(CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_NAME).getRecordTypeId();

    // CASE
    public static final String CASE_GESTION_LEAD_RT_NAME = 'Gestion_de_Lead';
    public static final String CASE_GESTION_LEAD_VO_RT_NAME = 'Gestion_de_Lead_VO';
    public static final String CASE_GESTION_WHATSAPP_RT_NAME = 'Gestion_de_WhatsApp';
    public static final String CASE_GESTION_WHATSAPP_CLOSE_STATUS = 'Closed';
    public static final String CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE = 'Se abre oportunidad';

    public static final Map<String,Schema.RecordTypeInfo> CASE_RT_BY_DEV_NAMEs = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

    public static final Id CASE_GESTION_LEAD_RT_ID = CASE_RT_BY_DEV_NAMEs.get(CASE_GESTION_LEAD_RT_NAME).getRecordTypeId();
    public static final Id CASE_GESTION_LEAD_VO_RT_ID = CASE_RT_BY_DEV_NAMEs.get(CASE_GESTION_LEAD_VO_RT_NAME).getRecordTypeId();
    public static final Id CASE_GESTION_WHATSAPP_RT_ID = CASE_RT_BY_DEV_NAMEs.get(CASE_GESTION_WHATSAPP_RT_NAME).getRecordTypeId();

    // CASE APPOINTMENT TYPE
    public static final String CASE_APPOINTMENT_TYPE = 'Presencial';
    public static final String CASE_PHONE_TYPE = 'Telefónica';
    public static final String CASE_VIDEOCALL_TYPE = 'Videollamada';

    // TASK
    public static final String TASK_REMINDER_TYPE = 'Recordatorio_Cita';
    public static final String TASK_COMPLETED_STATUS = 'Completada';

    public static final String TASK_OUTBOUND_CALL_RT_NAME = 'Outbound_Call';

    public static final Map<String,Schema.RecordTypeInfo> TASK_RT_BY_DEV_NAME = Schema.SObjectType.Call_Task__c.getRecordTypeInfosByDeveloperName();

    public static final Id TASK_OUTBOUND_CALL_RT_ID = TASK_RT_BY_DEV_NAME.get(TASK_OUTBOUND_CALL_RT_NAME).getRecordTypeId();

    // DEFAULT CALL TASK MAGER BH
    public static final String CALL_TASK_MANAGER_BH = 'Lead Management Tarea llamada';

    //VOICE CALL
    public static final String VC_IN_PROGRESS_STATUS = 'En curso';

		// OPPORTUNITY
		public static final String OPPO_QUALIFICATION_STATUS =  'Qualification';
}