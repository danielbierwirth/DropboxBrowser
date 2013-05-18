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
@interface DropboxBrowserViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    DBRestClient *restClient;
}

@property (nonatomic, weak) id <DropboxBrowserDelegate> rootViewDelegate;

//Current File Path and File Name
@property (nonatomic, strong) NSString *currentPath;
+ (NSString*)fileName;

//List of Files
@property (nonatomic, copy, readwrite) NSMutableArray *list;

//Busy indicator while loading new directory info - No longer used in iOS 6+
@property (strong, nonatomic) MBProgressHUD *hud;

//Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;
- (void)timeout:(id)arg;

//List content of home directory inside rootview controller
- (BOOL)listHomeDirectory;

//Refresh content
- (void)refreshTableView;

//Move up one directory
- (void)moveToParentDirectory;

//List content of specific subdirectories
- (BOOL)listDirectoryAtPath:(NSString*)path;

//Check if app is linked to dropbox
- (BOOL)isDropboxLinked;

//Called on download button press - see root controller
- (BOOL)downloadFile:(DBMetadata *)file;

@end

//DropboxBrowser Delegate

@protocol DropboxBrowserDelegate <NSObject>

@optional

//Successful File Download
- (void)downloadedFileFromDropbox:(NSString *)fileName;

//Failed to download file from Dropbox
- (void)failedToDownloadDropboxFile:(NSString *)fileName;

//Selected file already exists locally
- (void)fileDownloadConflictError:(NSDictionary *)conflict;

//Dropbox Browser was dismissed by the user - Do NOT use this method to dismiss the DropboxBrowser
- (void)dismissedDropboxBrowser;

//Dereciated Methods

- (void)removeDropboxBrowser __deprecated;

- (void)refreshLibrarySection __deprecated;

@end
