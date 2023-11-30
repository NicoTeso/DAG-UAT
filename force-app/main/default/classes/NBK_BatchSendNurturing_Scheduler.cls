/**
 * @description  :
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 30-05-2023
 * @group        :
 * @see          :
**/
global class NBK_BatchSendNurturing_Scheduler implements Schedulable{

	global void execute(SchedulableContext sc) {
			System.debug('### NBK_BatchSendNurturing_Scheduler - execute() - start');
			NBK_BatchSendNurturing sendNurturingBatch = new NBK_BatchSendNurturing();
			Id batchId = Database.executeBatch(sendNurturingBatch);
			System.debug('### NBK_BatchSendNurturing_Scheduler - execute() - batchId: ' + batchId);
	}
}