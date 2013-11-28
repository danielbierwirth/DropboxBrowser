//
//  DBBAppDelegate.m
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DBBAppDelegate.h"

@implementation DBBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Setup Dropbox Here with YOUR OWN APP info
    #error Dropbox App Key and Secret are required for basic functionality. Add them below AND in the Info.plist file in the URL-Schemes section. Replace the "APP_KEY" text with your app key (make sure to leave the "db-" there)
    DBSession *dbSession = [[DBSession alloc] initWithAppKey:@"APP_KEY" appSecret:@"APP_SECRET" root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Override point for customization after application launch.
    return YES;

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
