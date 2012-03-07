//
//  KioskDropboxPDFBrowserViewController.h
//  epaper
//
//  Created by daniel bierwirth on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KioskDropboxPDFBrowserViewControllerUIDelegate;


@class KioskDropboxPDFRootViewController;
@class KioskDropboxPDFDataController;

/**
 * main dropbox browser object. you can use it as follows from within any view controller. here is how to display
 * the browser as modal view:
 
 --> this goes into some controller
 
 - (void)  showDropboxBrowser {
 
 if (![[DBSession sharedSession] isLinked]) {
 [[DBSession sharedSession] link];
 }
 else {
 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
 @"MainStoryboard" bundle:[NSBundle mainBundle]];
 KioskDropboxPDFBrowserViewController *targetController = [storyboard
 instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
 
 
 targetController.modalPresentationStyle = UIModalPresentationFormSheet;
 targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
 [self presentModalViewController:targetController animated:YES];
 
 targetController.view.superview.frame = CGRectMake(0, 0, 748, 720);
 
 UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
 
 if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
 targetController.view.superview.center = self.view.center;
 }
 else {
 targetController.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
 }
 
 targetController.uiDelegate = self;
 
 // list the dropbox directory
 [targetController listDropboxDirectory];
 }
 }
 
 # pragma mark - KioskDropboxPDFBrowserViewControllerUIDelegate functions
 - (void) removeDropboxBrowser {
 [self dismissModalViewControllerAnimated:NO];
 }
 
 <---- end sample 
 */

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
@property (nonatomic, weak) id <KioskDropboxPDFBrowserViewControllerUIDelegate> uiDelegate;


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

