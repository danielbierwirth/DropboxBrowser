//
//  ODBTableViewController.h
//  OpenDropboxBrowser
//
//  Created by Sam Spencer on 2/10/17.
//  Copyright © 2017 Spencer Software. All rights reserved.
//

@import UIKit;
@import Foundation;
@import QuartzCore;

#import "ODBoxHandler.h"

@protocol ODBTableViewControllerDelegate;

/// Display system for browsing and downloading Dropbox files.
IB_DESIGNABLE @interface ODBTableViewController : UITableViewController <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

/// Dropbox Delegate Property
@property (nonatomic, weak) IBOutlet id <ODBTableViewControllerDelegate> delegate;

/// The current file path of the ODBTableViewController
@property (nonatomic, strong, readonly) NSString *currentPath;

/// YES if a search bar should be displayed and content should be searchable
@property (nonatomic, assign) IBInspectable BOOL shouldDisplaySearchBar;

/// Allowed file types (like a filter). Create an array of allowed file extensions. Leave this property nil to allow all files.
@property (nonatomic, strong) NSArray *allowedFileTypes;

/// The UITableViewCell ID for dequeueing
@property (nonatomic, strong) IBInspectable NSString *tableCellID;

/// A custom prompt that overrides the default login access alert when the user first opens the Dropbox Browser.
@property (nonatomic, strong) IBInspectable NSString *accessReason;

/** Set to YES if the authentication process should prefer the system web-browser (Safari) over an in-app browser. 
 @discussion Using an external browser allows the user to autocomplete saved passwords (if applicable) or continue from an already open session. Using the in-app browser prevents the authentication process from temporarily navigating away from the app. */
@property (nonatomic, assign) IBInspectable BOOL accessPromptCanExit;

/// The color that will be used to tint any objects. Defaults to a blue color.
@property (nonatomic, strong) IBInspectable UIColor *colorTheme;

@end


@protocol ODBTableViewControllerDelegate <NSObject>

@optional


// MARK: - Delegate: File Selection

/// Sent to the delegate when the user selects a file. Implementing this method will require you to download or manage the selection on your own. Otherwise, automatically downloads file if not implemented.
- (void)dropboxBrowser:(ODBTableViewController *)browser didSelectFile:(NSDictionary *)file;


// MARK: - Delegate: Controller Cycle

/// Sent to the delegate just before the ODBTableViewController is dismissed by the user - Do \b NOT use this method to dismiss the ODBTableViewController.
- (void)dropboxBrowserWillDismiss:(ODBTableViewController *)browser;


// Unimplemented features

/// Sent to the delegate if the share link is successfully loaded
// - (void)dropboxBrowser:(ODBTableViewController *)browser didLoadShareLink:(NSString *)link; // Sharing is not implemented in this version.

/// Sent to the delegate if there was an error creating or loading share link
// - (void)dropboxBrowser:(ODBTableViewController *)browser didFailToLoadShareLinkWithError:(NSError *)error; // Sharing is not implemented in this version.

@end
