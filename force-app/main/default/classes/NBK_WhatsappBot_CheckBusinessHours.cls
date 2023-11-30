public class NBK_WhatsappBot_CheckBusinessHours {
    public class OutputWrapper{
        @InvocableVariable
        public Boolean isInHours;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Check Business Hours')
    public static List<outputWrapper> checkBusinessHours() {
        String whatsAppBusinessHoursName = Default_WhatsApp_Business_Hours__c.getOrgDefaults().Business_Hours_Name__c;
        BusinessHours whatsAppBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = :whatsAppBusinessHoursName];

        outputWrapper wrapper = new outputWrapper();
        wrapper.isInHours = BusinessHours.isWithin(whatsAppBusinessHours.Id, Datetime.now());
        wrapper.message = '';

        return new List<OutputWrapper>{wrapper};
    }
}