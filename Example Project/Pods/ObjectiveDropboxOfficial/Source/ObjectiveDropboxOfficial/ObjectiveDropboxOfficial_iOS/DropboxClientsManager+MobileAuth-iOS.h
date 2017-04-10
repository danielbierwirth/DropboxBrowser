///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

#import <Foundation/Foundation.h>

#import "DBOAuthMobile-iOS.h"
#import "DBOAuthResult.h"
#import "DropboxClientsManager.h"
@class DBTransportClient;
@class UIApplication;
@class UIViewController;

///
/// Code with platform-specific (here, iOS) dependencies.
///
/// Extends functionality of the `DropboxClientsManager` class.
///
@interface DropboxClientsManager (MobileAuth)

///
/// Commences OAuth mobile flow from supplied view controller.
///
/// @param sharedApplication The `UIApplication` with which to render the
/// OAuth flow.
/// @param controller The `UIViewController` with which to render the OAuth
/// flow.
/// @param openURL A wrapper around app-extension unsafe `openURL` call.
/// @param browserAuth Whether to use an external web-browser to perform
/// authorization. If set to false, then an in-app webview will be used
/// to facilitate the auth flow. The advantage of browser auth is it is
/// safer for the end user and it can leverage existing session information,
/// which might mean the end user can avoid re-entering their Dropbox login
/// credentials. The disadvantage of browser auth is it requires navigating
/// outside of the current app.
///
+ (void)authorizeFromController:(UIApplication * _Nonnull)sharedApplication
                     controller:(UIViewController * _Nonnull)controller
                        openURL:(void (^_Nonnull)(NSURL * _Nonnull))openURL
                    browserAuth:(BOOL)browserAuth;

///
/// Initializes a `DropboxClient` shared instance with the supplied app key.
///
/// This method should be used in the single Dropbox user case. If any stored OAuth
/// tokens exist, one will arbitrarily be retrieved and used to authenticate
/// API calls. Use `setupWithAppKey:transportClient`, if additional customization
/// of network calls is necessary. This method should be called from the app delegate.
///
/// @param appKey The app key of the third-party Dropbox API user app that will be
/// associated with all API calls. To create an app or to locate your app's
/// app key, please visit the App Console here:
/// https://www.dropbox.com/developers/apps.
///
+ (void)setupWithAppKey:(NSString * _Nonnull)appKey;

///
/// Initializes a `DropboxClient` shared instance with the supplied app key and
/// transport client.
///
/// This method should be used in the single Dropbox user case. If any stored OAuth
/// tokens exist, one will arbitrarily be retrieved and used to authenticate API calls.
/// You can customize configuration of network calls using the different `DBTransportClient`
/// constructors. This method should be called from the app delegate.
///
/// @param appKey The app key of the third-party Dropbox API user app that will be
/// associated with all API calls. To create an app or to locate your app's
/// app key, please visit the App Console here:
/// https://www.dropbox.com/developers/apps.
/// @param transportClient The transport client used to make all API networking
/// calls. The transport client settings can be manually configured using one
/// of the numerous `DBTransportClient` constructors.
///
+ (void)setupWithAppKey:(NSString * _Nonnull)appKey transportClient:(DBTransportClient * _Nullable)transportClient;

///
/// Initializes a `DropboxClient` shared instance with the supplied app key, transport
/// client, and stored access token uid.
///
/// This method should be used in the multi Dropbox user case (i.e. when it is necessary
/// to track multiple Dropbox accounts / access tokens). In this case, a nullable token
/// uid is supplied by the client of the SDK. If an access token is stored with that uid as a
/// key, it is retrieved and used to instantiate a `DropboxClient` instance. This method
/// should be called from the app delegate.
///
/// @param appKey The app key of the third-party Dropbox API user app that will be
/// associated with all API calls. To create an app or to locate your app's
/// app key, please visit the App Console here:
/// https://www.dropbox.com/developers/apps.
/// @param transportClient The transport client used to make all API networking
/// calls. The transport client settings can be manually configured using one
/// of the numerous `DBTransportClient` constructors.
/// @param tokenUid The uid of the stored access token to use. This uid is returned
/// after a successful progression through the OAuth flow (via `handleRedirectURL` or
/// `handleRedirectURLTeam`) in the `DBAccessToken` field of the `DBOAuthResult` object.
///
+ (void)setupWithAppKeyMultiUser:(NSString * _Nonnull)appKey
                 transportClient:(DBTransportClient * _Nullable)transportClient
                        tokenUid:(NSString * _Nullable)tokenUid;

///
/// Initializes a `DropboxTeamClient` shared instance with the supplied app key.
///
/// This method should be used in the single Dropbox user case. If any stored OAuth
/// token exists, one will arbitrarily be retrieved and used to authenticate
/// API calls. Use `setupWithTeamAppKey:transportClient`, if additional customization
/// of network calls is necessary. This method should be called from the app delegate.
///
/// @param appKey The app key of the third-party Dropbox API team app that will be
/// associated with all API calls. To create an app or to locate your app's
/// app key, please visit the App Console here:
/// https://www.dropbox.com/developers/apps.
///
+ (void)setupWithTeamAppKey:(NSString * _Nonnull)appKey;

///
/// Initializes a `DropboxTeamClient` shared instance with the supplied app key and
/// transport client.
///
/// This method should be used in the single Dropbox user case. If any stored OAuth
/// tokens exist, one will arbitrarily be retrieved and used to authenticate API calls.
/// You can customize configuration of network calls using the different `DBTransportClient`
/// constructors. This method should be called from the app delegate.
///
/// @param appKey The app key of the third-party Dropbox API team app that will be
/// associated with all API calls. To create an app or to locate your app's
/// app key, please visit the App Console here:
/// https://www.dropbox.com/developers/apps.
/// @param transportClient The transport client used to make all API networking
/// calls. The transport client settings can be manually configured using one
/// of the numerous `DBTransportClient` constructors.
///
+ (void)setupWithTeamAppKey:(NSString * _Nonnull)appKey transportClient:(DBTransportClient * _Nullable)transportClient;

///
/// Initializes a `DropboxTeamClient` shared instance with the supplied app key, transport
/// client, and stored access token uid.
///
/// This method should be used in the multi Dropbox user case (i.e. when it is necessary
/// to track multiple Dropbox accounts / access tokens). In this case, a nullable token
/// uid is supplied by the client of the SDK. If an access token is stored with that uid as a
/// key, it is retrieved and used to instantiate a `DropboxTeamClient` instance. This method
/// should be called from the app delegate.
///
/// @param appKey The app key of the third-party Dropbox API user app that will be
/// associated with all API calls. To create an app or to locate your app's
/// app key, please visit the App Console here:
/// https://www.dropbox.com/developers/apps.
/// @param transportClient The transport client used to make all API networking
/// calls. The transport client settings can be manually configured using one
/// of the numerous `DBTransportClient` constructors.
/// @param tokenUid The uid of the stored access token to use. This uid is returned
/// after a successful progression through the OAuth flow (via `handleRedirectURL` or
/// `handleRedirectURLTeam`) in the `DBAccessToken` field of the `DBOAuthResult` object.
///
+ (void)setupWithTeamAppKeyMultiUser:(NSString * _Nonnull)appKey
                     transportClient:(DBTransportClient * _Nullable)transportClient
                            tokenUid:(NSString * _Nullable)tokenUid;

@end
