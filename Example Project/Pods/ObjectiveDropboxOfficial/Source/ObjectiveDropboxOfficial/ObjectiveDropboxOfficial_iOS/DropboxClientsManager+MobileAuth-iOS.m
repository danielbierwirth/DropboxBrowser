///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///

#import <UIKit/UIKit.h>

#import "DBOAuth.h"
#import "DBOAuthMobile-iOS.h"
#import "DBTransportClient.h"
#import "DropboxClientsManager.h"

@interface DropboxClientsManager ()

+ (void)setupWithOAuthManager:(DBOAuthManager * _Nonnull)oAuthManager
              transportClient:(DBTransportClient * _Nonnull)transportClient;

+ (void)setupWithOAuthManagerMultiUser:(DBOAuthManager * _Nonnull)oAuthManager
                       transportClient:(DBTransportClient * _Nonnull)transportClient
                              tokenUid:(NSString * _Nullable)tokenUid;

+ (void)setupWithOAuthManagerTeam:(DBOAuthManager * _Nonnull)oAuthManager
                  transportClient:(DBTransportClient * _Nonnull)transportClient;

+ (void)setupWithOAuthManagerMultiUserTeam:(DBOAuthManager * _Nonnull)oAuthManager
                           transportClient:(DBTransportClient * _Nonnull)transportClient
                                  tokenUid:(NSString * _Nullable)tokenUid;

@end

@implementation DropboxClientsManager (MobileAuth)

+ (void)authorizeFromController:(UIApplication *)sharedApplication
                     controller:(UIViewController *)controller
                        openURL:(void (^_Nonnull)(NSURL *))openURL
                    browserAuth:(BOOL)browserAuth {
  NSAssert([DBOAuthManager sharedOAuthManager] != nil,
           @"Call `Dropbox.setupWithAppKey` or `Dropbox.setupWithTeamAppKey` before calling this method");
  DBMobileSharedApplication *sharedMobileApplication =
      [[DBMobileSharedApplication alloc] init:sharedApplication controller:controller openURL:openURL];
  [[DBOAuthManager sharedOAuthManager] authorizeFromSharedApplication:sharedMobileApplication browserAuth:browserAuth];
}

+ (void)setupWithAppKey:(NSString *)appKey {
  [[self class] setupWithAppKey:appKey transportClient:nil];
}

+ (void)setupWithAppKey:(NSString *)appKey transportClient:(DBTransportClient *)transportClient {
  [[self class] setupWithOAuthManager:[[DBMobileOAuthManager alloc] initWithAppKey:appKey]
                      transportClient:transportClient];
}

+ (void)setupWithAppKeyMultiUser:(NSString *)appKey
                 transportClient:(DBTransportClient *)transportClient
                        tokenUid:(NSString *)tokenUid {
  [[self class] setupWithOAuthManagerMultiUser:[[DBMobileOAuthManager alloc] initWithAppKey:appKey]
                               transportClient:transportClient
                                      tokenUid:tokenUid];
}

+ (void)setupWithTeamAppKey:(NSString *)appKey {
  [[self class] setupWithTeamAppKey:appKey transportClient:nil];
}

+ (void)setupWithTeamAppKey:(NSString *)appKey transportClient:(DBTransportClient *)transportClient {
  [[self class] setupWithOAuthManagerTeam:[[DBMobileOAuthManager alloc] initWithAppKey:appKey]
                          transportClient:transportClient];
}

+ (void)setupWithTeamAppKeyMultiUser:(NSString *)appKey
                     transportClient:(DBTransportClient *)transportClient
                            tokenUid:(NSString *)tokenUid {
  [[self class] setupWithOAuthManagerMultiUserTeam:[[DBMobileOAuthManager alloc] initWithAppKey:appKey]
                                   transportClient:transportClient
                                          tokenUid:tokenUid];
}

@end
