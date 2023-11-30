/**
 * @description       : 
 * @author            : alberto.martinez@nubika.com
 * @group             : 
 * @last modified on  : 11-12-2021
 * @last modified by  : alberto.martinez@nubika.com
**/
trigger MessagingEndUserTrigger on MessagingEndUser (after insert, after update) {
    new NBK_MessagingEndUserTriggerHandler().run();
}