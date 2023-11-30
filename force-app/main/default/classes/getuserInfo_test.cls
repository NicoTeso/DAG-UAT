@isTest//(SeeAllData=true)
public class getuserInfo_test{

  @testSetup
  static void setupTestData(){
    test.startTest();
    User user_Obj = new User(
        					 Username = 'TestUser534320190307162213@codecoverage.com', 
                             LastName = 'LastName801', Email = 'Email22@test.com', 
                             EmailPreferencesAutoBcc = false, EmailPreferencesAutoBccStayInTouch = false, 
                             EmailPreferencesStayInTouchReminder = false, Alias = 'Alias682', 
                             CommunityNickname = 'cNickName25189', IsActive = true, 
                             TimeZoneSidKey = 'Pacific/Kiritimati', 
                             LocaleSidKey = 'sq_AL', ReceivesInfoEmails = false, 
                             ReceivesAdminInfoEmails = false, EmailEncodingKey = 'UTF-8', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Lead Management'].Id,
                             LanguageLocaleKey = 'en_US');
                             
    Insert user_Obj; 
    test.stopTest();
  }
  static testMethod void test_getCurrentUserId_UseCase1(){
    List<User> user_Obj  =  [SELECT Username,LastName,Email,EmailPreferencesAutoBcc,
                             EmailPreferencesAutoBccStayInTouch,EmailPreferencesStayInTouchReminder,
                             Alias,CommunityNickname,IsActive,TimeZoneSidKey,LocaleSidKey,ReceivesInfoEmails,
                             ReceivesAdminInfoEmails,EmailEncodingKey,ProfileId,
                             LanguageLocaleKey,UserPermissionsMarketingUser,UserPermissionsOfflineUser,
                             UserPermissionsCallCenterAutoLogin,ForecastEnabled,
                             UserPreferencesActivityRemindersPopup,UserPreferencesEventRemindersCheckboxDefault,
                             UserPreferencesTaskRemindersCheckboxDefault,UserPreferencesReminderSoundOff,
                             UserPreferencesDisableAllFeedsEmail,UserPreferencesDisableFollowersEmail,
                             UserPreferencesDisableProfilePostEmail,UserPreferencesDisableChangeCommentEmail,
                             UserPreferencesDisableLaterCommentEmail,UserPreferencesDisProfPostCommentEmail,
                             UserPreferencesApexPagesDeveloperMode,UserPreferencesHideCSNGetChatterMobileTask,
                             UserPreferencesDisableMentionsPostEmail,UserPreferencesDisMentionsCommentEmail,
                             UserPreferencesHideCSNDesktopTask,UserPreferencesHideChatterOnboardingSplash,
                             UserPreferencesHideSecondChatterOnboardingSplash,UserPreferencesDisCommentAfterLikeEmail,UserPreferencesDisableLikeEmail,UserPreferencesSortFeedByComment,UserPreferencesDisableMessageEmail,UserPreferencesJigsawListUser,
                             UserPreferencesDisableBookmarkEmail,UserPreferencesDisableSharePostEmail,UserPreferencesEnableAutoSubForFeeds,UserPreferencesDisableFileShareNotificationsForApi,UserPreferencesShowTitleToExternalUsers,UserPreferencesShowManagerToExternalUsers,UserPreferencesShowEmailToExternalUsers,
                             UserPreferencesShowWorkPhoneToExternalUsers,UserPreferencesShowMobilePhoneToExternalUsers,
                             UserPreferencesShowFaxToExternalUsers,UserPreferencesShowStreetAddressToExternalUsers,
                             UserPreferencesShowCityToExternalUsers,UserPreferencesShowStateToExternalUsers,
                             UserPreferencesShowPostalCodeToExternalUsers,UserPreferencesShowCountryToExternalUsers,
                             UserPreferencesShowProfilePicToGuestUsers,UserPreferencesShowTitleToGuestUsers,UserPreferencesHideS1BrowserUI,
                             UserPreferencesDisableEndorsementEmail,UserPreferencesPathAssistantCollapsed,UserPreferencesCacheDiagnostics,
                             UserPreferencesShowEmailToGuestUsers,UserPreferencesShowManagerToGuestUsers,UserPreferencesShowWorkPhoneToGuestUsers,
                             UserPreferencesShowMobilePhoneToGuestUsers,UserPreferencesShowFaxToGuestUsers,UserPreferencesShowStreetAddressToGuestUsers,
                             UserPreferencesLightningExperiencePreferred,UserPreferencesPreviewLightning,UserPreferencesHideEndUserOnboardingAssistantModal,UserPreferencesHideLightningMigrationModal,UserPreferencesHideSfxWelcomeMat,UserPreferencesHideBiggerPhotoCallout,UserPreferencesGlobalNavBarWTShown,UserPreferencesGlobalNavGridMenuWTShown,UserPreferencesCreateLEXAppsWTShown,UserPreferencesFavoritesWTShown,
                             DigestFrequency From User];
    System.assertEquals(true,user_Obj.size()>0);
    GetUserInfo obj01 = new GetUserInfo();
    GetUserInfo.getCurrentUserId();
  }
}