/**
 * @description  :
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 31-05-2023
 * @group        :
 * @see          :
**/
public with sharing class NBK_HolydaysManager {


	/**
     * @description Return the first date from input that isnt holiday or weekend
	 * @param dateTimeInput
     * @return DateTime
     */
	public static DateTime checkHolidays(DateTime dateTimeInput) {
		DateTime dateTimeOutput = null;

		if(dateTimeInput != null){
			Boolean isWeekend = checkWeekend(dateTimeInput.date());
			Boolean isHoliday = (isWeekend) ? true : checkHolidaysMetadata(dateTimeInput.date());

			if(isHoliday || isWeekend){
				// If is Holiday or weekend, check the next day
				dateTimeOutput = checkHolidays(dateTimeInput.addDays(1));
			} else {
				dateTimeOutput = dateTimeInput;
			}
		}

		return dateTimeOutput;
	}

	/**
     * @description Return true if the day is weekend
	 * @param dateInput
     * @return Boolean
     */
	public static Boolean checkWeekend(Date dateInput){
		Boolean result = false;
		// Get day of week
		Integer dayOfWeek = getDayOfWeek(dateInput);

		// Verify if it is Saturday or Sunday
		if (dayOfWeek == 5 || dayOfWeek == 6) {
			result = true;
		} else {
			result = false;
		}

		return result;
	}

	/**
     * @description Return true if the day is in the Holidays metadata
	 * @param dateInput
     * @return Boolean
     */
	public static Boolean checkHolidaysMetadata(Date dateInput){
		Boolean result = false;
		List<Holidays__mdt> lMetadataValues = Holidays__mdt.getAll().values();

		for(Holidays__mdt hDay : lMetadataValues){
			if(hDay.Date_Holiday__c == dateInput){
				result = true;
				break;
			}
		}

		return result;
	}

	/**
     * @description Return integer of day of the week Ex: Monday = 0, Saturday = 5, Sunday = 6
	 * @param dateInput
     * @return Integer
     */
	private static Integer getDayOfWeek(Date dateInput){

		Date monday = Date.newInstance(1900, 1, 1);

		return Math.mod(monday.daysBetween(dateInput), 7);
	}

	/**
     * @description Invocable that return the first date from input that isnt holiday or weekend
	 * @param input
     * @return List<FlowOutput>
     */
	@InvocableMethod(label='Check Holidays' description='Check holidays and return first business day')
	public static List<FlowOutput> checkHolidaysInvocable(List<FlowInput> input) {
		DateTime dateTimeOutput = null;
		List<FlowOutput> lOutput = new List<FlowOutput>();
		FlowOutput output = new FlowOutput();

		output.dateTimeOutput = checkHolidays(input.get(0).dateTimeInput);
		lOutput.add(output);

		return lOutput;
	}

	public class FlowInput {
		@InvocableVariable
		public DateTime dateTimeInput;
	}

	public class FlowOutput {
		@InvocableVariable
		public DateTime dateTimeOutput;
	}
}