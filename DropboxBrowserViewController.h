//
//  DropboxBrowserViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 4/4/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxRootViewController.h"
#import "DropboxDataController.h"

@protocol DropboxBrowserDelegate;
@class DropboxRootViewController;
@class DropboxDataController;

@interface DropboxBrowserViewController : UINavigationController

//Contains dropbox data inside a tableview and manages file navigation as well as item download
@property (nonatomic, strong) DropboxRootViewController *rootViewController;
//Manages the dropbox access and data fetch
@property (nonatomic, strong) DropboxDataController *dataController;

//Manage UI events
@property (nonatomic) id <DropboxBrowserDelegate> uiDelegate;

//List content of home directory in a tableview. Alert if application is not linked to dropbox
- (void) listDropboxDirectory;

//Display the Viewer
+ (void)displayDropboxBrowserInPhoneStoryboard:(UIStoryboard *)iPhoneStoryboard
          displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard
                                        onView:(UIViewController *)viewController
                         withPresentationStyle:(UIModalPresentationStyle)presentationStyle
                           withTransitionStyle:(UIModalTransitionStyle)transitionStyle
                                  withDelegate:(id<DropboxBrowserDelegate>)delegate;

@end

//Notify dropbox browser delegate about close and download events
@protocol DropboxBrowserDelegate <NSObject>
@required

//Parent controller can remove dropbox browser. Delegate is notified on close button press in dropbox browser
- (void)removeDropboxBrowser;

// Document was downloaded - tell delegate about it. The fileName property in the RootViewController also gives access to the name of the file just downloaded
 - (void)refreshLibrarySection;

@end

