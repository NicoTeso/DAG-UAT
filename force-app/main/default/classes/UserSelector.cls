/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public with sharing class UserSelector {
    public static userSelector_WithoutSharing getWithoutSharingContext(){
        return new UserSelector_WithoutSharing();
    }

    public without sharing class userSelector_WithoutSharing {
        public List<User> getUsersByContactId(Set<Id> contactIds) {
            return [SELECT id, contactId FROM User WHERE contactId IN:contactIds AND isActive = true];
        }
    }
}