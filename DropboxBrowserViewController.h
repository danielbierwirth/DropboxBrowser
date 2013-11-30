//
//  DropboxBrowserViewController.h
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 11/30/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Daniel Bierwirth and iRare Media
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

/** @typedef kDBFileConflictError
 @abstract Error codes for file conflicts with Dropbox and Local files.
 @param kDBDropboxFileNewerError The Dropbox file was modified more recently than the local file, and is therefore newer.
 @param kDBDropboxFileOlderError The Dropbox file was modified after the local file, and is therefore older.
 @param kDBDropboxFileSameAsLocalFileError Both the Dropbox file and the local file were modified at the same time.
 @discussion These error codes are used with the \p dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError: delegate method's error parameter. That delegate method is caled when there is a file conflict between a local file and a Dropbox file. */
typedef enum kDBFileConflictError : NSInteger {
    kDBDropboxFileNewerError = 1,
    kDBDropboxFileOlderError = 2,
    kDBDropboxFileSameAsLocalFileError = 3
} kDBFileConflictError;

@class DBRestClient;
@class DBMetadata;
@protocol DropboxBrowserDelegate;
@interface DropboxBrowserViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate> {
    DBRestClient *restClient;
}

/// Dropbox Delegate Property
@property (nonatomic, weak) id <DropboxBrowserDelegate> rootViewDelegate;

/// The file path that the current DropboxBrowserViewController is at
@property (nonatomic, strong) NSString *currentPath;

/// The list of files currently being displayed in the DropboxBrowserViewController
@property (nonatomic, copy, readwrite) NSMutableArray *fileList;

/// Set allowed file types (like a filter). Just create an array of allowed file extensions. Do not set to allow all files
@property (nonatomic, strong) NSArray *allowedFileTypes;

/// Set the tableview cell ID for dequeueing
@property (nonatomic, strong) NSString *tableCellID;

/// Download indicator in UINavigationBar to indicate progress of file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;

/// Set whether or not DBBrowser should deliver notifications to the user about file downloads
@property BOOL deliverDownloadNotifications;

/// Set whether DropboxBrowserViewController should display a search bar
@property BOOL shouldDisplaySearchBar;

/// Get the currently (or most recently selected) file name
+ (NSString *)fileName;

/// Check if app is linked to dropbox
- (BOOL)isDropboxLinked;

/// Download a file from DropboxBrowser and specify whether or not it should be overwritten
- (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion:(BOOL)replaceLocalVersion;

/// Create a share link for a specifc file
- (void)loadShareLinkForFile:(DBMetadata *)file;

/// Remove DropboxBrowser from the view hierarchy - dismiss DropboxBrowserViewController
- (void)removeDropboxBrowser;

@end

/// The DropboxBrowser Delegate can be used to recieve download notifications, failures, successes, errors, file conflicts, and even handle the download yourself.
@protocol DropboxBrowserDelegate <NSObject>

@optional

//----------------------------------------------------------------------------------------//
// Available Methods - Use these delegate methods for a variety of operations and events  //
//----------------------------------------------------------------------------------------//

/// Sent to the delegate when there is a successful file download
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten;

/// Sent to the delegate if DropboxBrowser failed to download file from Dropbox
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName;

/// Sent to the delegate if the selected file already exists locally
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error;

/// Sent to the delegate when the user selects a file. Implementing this method will require you to download or manage the selection on your own. Otherwise, automatically downloads file if not implemented.
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didSelectFile:(DBMetadata *)file;

/// Sent to the delegate if the share link is successfully loaded
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didLoadShareLink:(NSString *)link;

/// Sent to the delegate if there was an error creating or loading share link
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToLoadShareLinkWithError:(NSError *)error;

/// Sent to the delegate when a file download notification is delivered to the user. You can use this method to record the notification ID so you can clear the notification if ncessary.
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification;

/// Sent to the delegate after the DropboxBrowserViewController is dismissed by the user - Do \b NOT use this method to dismiss the DropboxBrowser
- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser;

//---------------------------------------------------------------------------------//
// Deprecated Methods - These methods will become unavailable in a future version  //
//---------------------------------------------------------------------------------//

/** DEPRECATED. Called when a file finishes downloading. @deprecated This method is deprecated. Use \p dropboxBrowser:didDownloadFile:didOverwriteFile:  instead */
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)fileName __deprecated;

/** DEPRECATED. Called when a file finishes downloading. @deprecated This method is deprecated. Use \p dropboxBrowser:didDownloadFile:didOverwriteFile: instead */
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)file isLocalFileOverwritten:(BOOL)isLocalFileOverwritten __deprecated;

/** DEPRECATED. Called when a file is selected for download. @deprecated This method is deprecated. Use \p dropboxBrowser:didSelectFile: instead */
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser selectedFile:(DBMetadata *)file __deprecated;

/** DEPRECATED. Called when a file download fails. @deprecated This method is deprecated. Use \p dropboxBrowser:didFailToDownloadFile: instead */
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedToDownloadFile:(NSString *)fileName __deprecated;

/** DEPRECATED. Called when there is a conflict between a Dropbox file and a local file. @deprecated This method is deprecated. Use \p dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError: instead */
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictError:(NSDictionary *)error __deprecated;

/** DEPRECATED. Called when a there is an error creating a share link. @deprecated This method is deprecated. Use \p dropboxBrowser:didFailToLoadShareLinkWithError: instead */
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedLoadingShareLinkWithError:(NSError *)error __deprecated;

//--------------------------------------------------------------------------------------//
// Unavailable Methods - These methods are never called and are not in use. Do not use  //
//--------------------------------------------------------------------------------------//
- (void)removeDropboxBrowser __unavailable;
- (void)refreshLibrarySection __unavailable;
- (void)dropboxBrowserDismissed __unavailable;
- (void)dropboxBrowserDownloadedFile:(NSString *)fileName __unavailable;
- (void)dropboxBrowserFailedToDownloadFile:(NSString *)fileName __unavailable;
- (void)dropboxBrowserFileConflictError:(NSDictionary *)conflict __unavailable;

@end
