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
#import "MBProgressHUD.h"

@class DBRestClient;
@class DBMetadata;
@protocol DropboxBrowserDelegate;
@interface DropboxBrowserViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate> {
    DBRestClient *restClient;
}

@property (nonatomic, weak) id <DropboxBrowserDelegate> rootViewDelegate;

//Current File Path, Name, and List
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, copy, readwrite) NSMutableArray *list;
@property (nonatomic, strong) NSArray *allowedFileTypes;
- (void)setList:(NSMutableArray *)newList;
//- (void)setAllowedFiles:(NSArray *)allowedFiles;
+ (NSString *)fileName;

//Busy indicator while loading new directory info - No longer used in iOS 6+
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)dismissHUD;
- (void)timeout:(id)arg;

//Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;

//Download Operations
- (BOOL)downloadFile:(DBMetadata *)file;
- (void)loadShareLinkForFile:(DBMetadata *)file;
- (void)downloadedFile;
- (void)startDownloadFile;
- (void)downloadedFileFailed;
- (void)updateDownloadProgressTo:(CGFloat)progress;

//List content of the root directory
- (BOOL)listHomeDirectory;

//Move up one directory
- (void)moveToParentDirectory;

//Refresh content
- (void)refreshTableView;
- (void)updateContent;
- (void)updateTableData;

//List content of specific subdirectories
- (BOOL)listDirectoryAtPath:(NSString*)path;

//Check if app is linked to dropbox
- (BOOL)isDropboxLinked;

//Remove DropboxBrowser
- (void)removeDropboxBrowser;

@end

//DropboxBrowser Delegate

@protocol DropboxBrowserDelegate <NSObject>

@optional

//Successful File Download
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)fileName;

//User selected a file - automatically downloads file if not implemented. Implementing this method will require you to download or manage the selection on your own
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser selectedFile:(DBMetadata *)file;

//Successfully loaded share link
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didLoadShareLink:(NSString *)link;

//Error creating or loading share link
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedLoadingShareLinkWithError:(NSError *)error;

//Failed to download file from Dropbox
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedToDownloadFile:(NSString *)fileName;

//Selected file already exists locally
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictError:(NSDictionary *)conflict;

//Dropbox Browser was dismissed by the user - Do NOT use this method to dismiss the DropboxBrowser
- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser;

//Dereciated Methods - No longer called. Do not use.
- (void)removeDropboxBrowser __deprecated;
- (void)refreshLibrarySection __deprecated;
- (void)dropboxBrowserDismissed __deprecated;
- (void)dropboxBrowserDownloadedFile:(NSString *)fileName __deprecated;
- (void)dropboxBrowserFailedToDownloadFile:(NSString *)fileName __deprecated;
- (void)dropboxBrowserFileConflictError:(NSDictionary *)conflict __deprecated;

@end
