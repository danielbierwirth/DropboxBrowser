//
//  DropboxBrowserViewController.h
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 4/4/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//
// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2013 Daniel Bierwirth
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

@class DBRestClient;
@class DBMetadata;
@protocol DropboxBrowserDelegate;
@interface DropboxBrowserViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate> {
    DBRestClient *restClient;
}

/// Dropbox Delegate Property
@property (nonatomic, weak) id <DropboxBrowserDelegate> rootViewDelegate;

// Current File Path, Name, and List
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, copy, readwrite) NSMutableArray *fileList;

/// Set allowed file types (like a filter). Just create an array of allowed file extensions. Do not set to allow all files
@property (nonatomic, strong) NSArray *allowedFileTypes;

/// Set the tableview cell ID for dequeueing
@property (nonatomic, strong) NSString *tableCellID;

/// Set the tableview cell ID for dequeueing
@property BOOL deliverDownloadNotifications;

- (void)setList:(NSMutableArray *)newList;
+ (NSString *)fileName;

// Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;

// Download Operations
- (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion:(BOOL)replaceLocalVersion;
- (void)loadShareLinkForFile:(DBMetadata *)file;
- (void)downloadedFile;
- (void)startDownloadFile;
- (void)downloadedFileFailed;
- (void)updateDownloadProgressTo:(CGFloat)progress;

// Refresh content
- (void)refreshTableView;
- (void)updateContent;
- (void)updateTableData;

// List content of specific subdirectories
- (BOOL)listDirectoryAtPath:(NSString *)path;

/// Check if app is linked to dropbox
- (BOOL)isDropboxLinked;

// Remove DropboxBrowser
- (void)removeDropboxBrowser;

@end

/// The DropboxBrowser Delegate can be used to recieve download notifications, failures, successes, errors, file conflicts, and even handle the download yourself.
@protocol DropboxBrowserDelegate <NSObject>

@optional

/// Sent to the delegate when there is a successful file download
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)fileName isLocalFileOverwritten:(BOOL)isLocalFileOverwritten;

/// Sent to the delegate when the user selects a file. Implementing this method will require you to download or manage the selection on your own. Otherwise, automatically downloads file if not implemented.
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser selectedFile:(DBMetadata *)file;

/// Sent to the delegate if the share link is successfully loaded
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didLoadShareLink:(NSString *)link;

/// Sent to the delegate if there was an error creating or loading share link
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedLoadingShareLinkWithError:(NSError *)error;

/// Sent to the delegate if DropboxBrowser failed to download file from Dropbox
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedToDownloadFile:(NSString *)fileName;

/// Sent to the delegate if the selected file already exists locally
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictError:(NSDictionary *)conflict;

/// Dropbox Browser was dismissed by the user - Do NOT use this method to dismiss the DropboxBrowser
- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser;

// Dereciated Methods - No longer called. Do not use.
- (void)removeDropboxBrowser __deprecated;
- (void)refreshLibrarySection __deprecated;
- (void)dropboxBrowserDismissed __deprecated;
- (void)dropboxBrowserDownloadedFile:(NSString *)fileName __deprecated;
- (void)dropboxBrowserFailedToDownloadFile:(NSString *)fileName __deprecated;
- (void)dropboxBrowserFileConflictError:(NSDictionary *)conflict __deprecated;

@end
