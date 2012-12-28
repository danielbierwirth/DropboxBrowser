//
//  KioskDropboxPDFBrowserViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 12/26/12
//  Copyright (c) 2012 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KioskDropboxPDFRootViewController.h"
#import "KioskDropboxPDFDataController.h"

@protocol KioskDropboxPDFBrowserViewControllerUIDelegate;
@class KioskDropboxPDFRootViewController;
@class KioskDropboxPDFDataController;

@interface KioskDropboxPDFBrowserViewController : UINavigationController {}

// contains dropbox data inside a tableview and manages file navigation as well
// as item download
@property (nonatomic, strong) KioskDropboxPDFRootViewController *rootViewController;
// manages the dropbox access and data fetch
@property (nonatomic, strong) KioskDropboxPDFDataController *dataController;

// Manage UI events
@property (nonatomic) id <KioskDropboxPDFBrowserViewControllerUIDelegate> uiDelegate;

// List content of home directory in a tableview. Alert if application is not linked to dropbox
- (void) listDropboxDirectory;

//Get name of last downloaded file


@end

// Notify dropbox browser delegate about close and download events
@protocol KioskDropboxPDFBrowserViewControllerUIDelegate <NSObject>

// Parent controller can remove dropbox browser. Delegate is notified on close button press in dropbox browser
@required - (void) removeDropboxBrowser;

// Document was downloaded - tell delegate about it. The fileName property in the KioskRootViewController also gives access to the name of the file just downloaded
 - (void)refreshLibrarySection;

@end

