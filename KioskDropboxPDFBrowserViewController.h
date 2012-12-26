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

@interface KioskDropboxPDFBrowserViewController : UINavigationController {
   
}
// contains dropbox data inside a tableview and manages file navigation as well
// as item download
@property (nonatomic, strong) KioskDropboxPDFRootViewController *rootViewController;
// manages the dropbox access and data fetch
@property (nonatomic, strong) KioskDropboxPDFDataController *dataController;

/**
 * manage ui events
 */
@property (nonatomic) id <KioskDropboxPDFBrowserViewControllerUIDelegate> uiDelegate;


/**
 * list content of home directory in a tableview
 * alert if application is not linked to dropbox
 */
- (void) listDropboxDirectory;

@end

/**
 * notify dropbox browser delegate about close and pdf download events
 */
@protocol KioskDropboxPDFBrowserViewControllerUIDelegate <NSObject>

@optional
/**
 * parent controller can remove dropbox browser
 * delegate is notified on close button press in dropbox browser
 */
- (void) removeDropboxBrowser;
/**
 * ok, document was downloaded - tell delegate about it
 */
- (void) refreshLibrarySection;

@end

