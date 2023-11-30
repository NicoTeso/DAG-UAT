/**
 * @description  : 
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 31-05-2023
 * @group        : 
 * @see          : 
**/
trigger NBK_VoiceCallTrigger on VoiceCall (before insert, before update, after insert, after update) {    
    //new NBK_VoiceCallTriggerController().run(); //NO VOICECALL SET IN UAT
}