/*
* @author Lavinia Ciobanu
* @date Apr 6, 2021
* @name primaryContact
* @description trigger for primary contact 
*/

trigger primaryContact on Contact (before insert, before update, after insert, after update) {
	primaryContactTriggerHandler handler = new primaryContactTriggerHandler();
	
	if (Trigger.isBefore) {
		handler.onBefore(Trigger.new);
	} else if (Trigger.isAfter && Trigger.isInsert) {
		handler.onAfterInsert(Trigger.new);
	} else if (Trigger.isAfter && Trigger.isUpdate) {
		handler.onAfterUpdate(Trigger.old, Trigger.new);
	}
}