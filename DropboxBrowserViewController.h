//
//  DropboxBrowserViewController.h
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 08/05/15
//  Copyright (c) 2013 iRare Media. All rights reserved.
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Daniel Bierwirth and iRare Media
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
typedef NS_ENUM(NSInteger, kDBFileConflictError) {
    /// The Dropbox file was modified more recently than the local file, and is therefore newer.
    kDBDropboxFileNewerError = 1,
    /// The Dropbox file was modified after the local file, and is therefore older.
    kDBDropboxFileOlderError = 2,
    /// Both the Dropbox file and the local file were modified at the same time.
    kDBDropboxFileSameAsLocalFileError = 3
};

@class DBRestClient;
@class DBMetadata;
@protocol DropboxBrowserDelegate;

@interface DropboxBrowserViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate>


- (instancetype)init;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;


/// Dropbox Delegate Property
@property (nonatomic, weak) id <DropboxBrowserDelegate> rootViewDelegate;


/// The current or most recently selected file name
@property (nonatomic, strong, readonly) NSString *currentFileName;

/// The current file path of the DropboxBrowserViewController
@property (nonatomic, strong, readonly) NSString *currentPath;


/// The list of files currently being displayed in the DropboxBrowserViewController
@property (nonatomic, copy, readwrite) NSMutableArray *fileList;

/// Allowed file types (like a filter). Create an array of allowed file extensions. Leave this property nil to allow all files.
@property (nonatomic, strong) NSArray *allowedFileTypes;


/// The tableview cell ID for dequeueing
@property (nonatomic, strong) NSString *tableCellID;

/// Download indicator in UINavigationBar to indicate progress of file download
@property (nonatomic, strong, readonly) UIProgressView *downloadProgressView;


/// Deliver notifications to the user about file downloads
@property (nonatomic, assign) BOOL deliverDownloadNotifications;

/// Display a search bar in the DropboxBrowser
@property (nonatomic, assign) BOOL shouldDisplaySearchBar;


/** Check if the current app is linked to Dropbox.
 @return YES if the current app is linked to Dropbox with a valid API Key, Secret, and User Account. NO if one or more of the API Key, Secret, or User Account is not valid. */
- (BOOL)isDropboxLinked;

/** Force a content update of the current directory. 
 @discussion This is usually not necessary because the DropboxSDK will asynchronously update content. Additionally, the DropboxBrowser supplies a Refresh Control to allow the user to force an update. However, there may be points when it is useful to force a content update of the current directory. */
- (void)updateContent;

/** Download a file from Dropbox and specify whether or not it should be overwritten.
 @param file File metadata from dropbox. A DBMetadata object is supplied from the \p dropboxBrowser:didSelectFile: and file conflict delegate methods.
 @param replaceLocalVersion When set to YES, DropboxBrowser will overwrite any local version of the file without checking for conflicts. When set to NO, conflict handling will be preserved.
 @return YES if the download is successful. NO if the download fails. */
- (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion:(BOOL)replaceLocalVersion;

/** Create a share link for a specifc file. 
 @param file File metadata from dropbox. A DBMetadata object is supplied from the \p dropboxBrowser:didSelectFile: and file conflict delegate methods. */
- (void)loadShareLinkForFile:(DBMetadata *)file;

/** Logout of Dropbox and dismiss the DropboxBrowser.
 @discussion The current user will be signed out of Dropbox. This implicitly calls \p removeDropboxBrowser if the DropboxBrowser is presented. */
- (void)logoutOfDropbox;

/** Remove DropboxBrowser from the view hierarchy.
 @discussion Dismisses DropboxBrowserViewController from the view hierarchy. Do not attempt to call \p dismissViewControllerAnimated:completion: on the DropboxBrowserViewController before or after calling this method. When dismissed the appropriate method is sent to the delegate. */
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

@end
