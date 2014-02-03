//
//  DropboxBrowserViewController.m
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

#import "DropboxBrowserViewController.h"

// View tags to differeniate alert views
static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kFileExistsAlertViewTag = 2;
static NSUInteger const kDBSignOutAlertViewTag = 3;

@interface DropboxBrowserViewController () <DBRestClientDelegate> {
    DBMetadata *selectedFile;
    BOOL isLocalFileOverwritten;
    BOOL isSearching;
    UIBackgroundTaskIdentifier backgroundProcess;
    DropboxBrowserViewController *newSubdirectoryController;
}

- (DBRestClient *)restClient;

- (void)updateContent;
- (void)updateTableData;

- (void)downloadedFile;
- (void)startDownloadFile;
- (void)downloadedFileFailed;
- (void)updateDownloadProgressTo:(CGFloat)progress;

- (BOOL)listDirectoryAtPath:(NSString *)path;

@end

@implementation DropboxBrowserViewController
@synthesize downloadProgressView, currentPath, rootViewDelegate, fileList;
@synthesize allowedFileTypes, tableCellID, deliverDownloadNotifications, shouldDisplaySearchBar;
static NSString *currentFileName = nil;

//------------------------------------------------------------------------------------------------------------//
//------- View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark  - View Lifecycle

- (id)init {
	self = [super init];
	if (self)  {
        // Custom initialization
        isLocalFileOverwritten = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom Init
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Title and Path
    if (self.title == nil || [self.title isEqualToString:@""]) self.title = @"Dropbox";
    if (self.currentPath == nil || [self.currentPath isEqualToString:@""]) self.currentPath = @"/";
    
    // Setup Navigation Bar, use different styles for iOS 7 and higher
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(removeDropboxBrowser)];
    // UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutDropbox)];
    self.navigationItem.rightBarButtonItem = rightButton;
    // self.navigationItem.leftBarButtonItem = leftButton;
    
    if (shouldDisplaySearchBar == YES) {
        // Create Search Bar
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
        searchBar.delegate = self;
        searchBar.placeholder = [NSString stringWithFormat:@"Search %@", self.title];
        self.tableView.tableHeaderView = searchBar;
        
        // Setup Search Controller
        UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
        searchController.delegate = self;
        self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    }
    
    // Add Download Progress View to Navigation Bar
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // The user is on an iPad - Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
        CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
        CGFloat heigthBoundary = newProgressView.bounds.size.height;
        newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
        
        newProgressView.alpha = 0.0;
        newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        
        [self.navigationController.navigationBar addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    } else {
        // The user is on an iPhone / iPod Touch - Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
        CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
        CGFloat heigthBoundary = newProgressView.bounds.size.height;
        newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
        
        newProgressView.alpha = 0.0;
        newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        
        [self.navigationController.navigationBar addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    }
    
    // Add a refresh control, pull down to refresh
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    // Initialize Directory Content
    if ([self.currentPath isEqualToString:@"/"]) {
        [self listDirectoryAtPath:@"/"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self isDropboxLinked]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login to Dropbox" message:[NSString stringWithFormat:@"%@ is not linked to your Dropbox. Would you like to login now and allow access?", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alertView.tag = kDBSignInAlertViewTag;
        [alertView show];
    }
}

- (void)logoutDropbox {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logout of Dropbox?" message:[NSString stringWithFormat:@"Are you sure you want to logout of Dropbox and revoke Dropbox access for %@?", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    alertView.tag = kDBSignOutAlertViewTag;
    [alertView show];
}

//------------------------------------------------------------------------------------------------------------//
//------- Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Files and Directories

+ (NSString *)fileName {
    return currentFileName;
}

- (NSArray *)allowedFileTypes {
    if (allowedFileTypes == nil) {
        allowedFileTypes = [NSArray array];
    }
    return allowedFileTypes;
}

//------------------------------------------------------------------------------------------------------------//
//------- Table View -----------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([fileList count] == 0) {
        return 2; // Return cell to show the folder is empty
    } else {
        return [fileList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([fileList count] == 0) {
        // There are no files in the directory - let the user know
        if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            if (isSearching == YES) {
                cell.textLabel.text = @"No Search Results";
            } else {
                cell.textLabel.text = @"Folder is Empty";
            }
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    } else {
        // Check if the table cell ID has been set, otherwise create one
        if (!tableCellID || [tableCellID isEqualToString:@""]) {
            tableCellID = @"DropboxBrowserCell";
        }
        
        // Create the table view cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DropboxBrowserCell"];
        }
        
        // Configure the Dropbox Data for the cell
        DBMetadata *file = (DBMetadata *)[fileList objectAtIndex:indexPath.row];
        
        // Setup the cell file name
        cell.textLabel.text = file.filename;
        [cell.textLabel setNeedsDisplay];
        
        // Display icon
        cell.imageView.image = [UIImage imageNamed:file.icon];
        
        // Setup Last Modified Date
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        // Get File Details and Display
        if ([file isDirectory]) {
            // Folder
            cell.detailTextLabel.text = @"";
            [cell.detailTextLabel setNeedsDisplay];
        } else {
            // File
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, modified %@", file.humanReadableSize, [formatter stringFromDate:file.lastModifiedDate]];
            [cell.detailTextLabel setNeedsDisplay];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil)
        return;
    if ([fileList count] == 0) {
        // Do nothing, there are no items in the list. We don't want to download a file that doesn't exist (that'd cause a crash)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        selectedFile = (DBMetadata *)[fileList objectAtIndex:indexPath.row];
        if ([selectedFile isDirectory]) {
            // Create new UITableViewController
            newSubdirectoryController = [[DropboxBrowserViewController alloc] init];
            newSubdirectoryController.rootViewDelegate = self.rootViewDelegate;
            NSString *subpath = [currentPath stringByAppendingPathComponent:selectedFile.filename];
            newSubdirectoryController.currentPath = subpath;
            newSubdirectoryController.title = [subpath lastPathComponent];
            newSubdirectoryController.shouldDisplaySearchBar = self.shouldDisplaySearchBar;
            newSubdirectoryController.deliverDownloadNotifications = self.deliverDownloadNotifications;
            newSubdirectoryController.allowedFileTypes = self.allowedFileTypes;
            newSubdirectoryController.tableCellID = self.tableCellID;
            
            [newSubdirectoryController listDirectoryAtPath:subpath];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self.navigationController pushViewController:newSubdirectoryController animated:YES];
        } else {
            currentFileName = selectedFile.filename;
            
            // Check if our delegate handles file selection
            if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didSelectFile:)]) {
                [self.rootViewDelegate dropboxBrowser:self didSelectFile:selectedFile];
            } else if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:selectedFile:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [self.rootViewDelegate dropboxBrowser:self selectedFile:selectedFile];
#pragma clang diagnostic pop
            } else {
                // Download file
                [self downloadFile:selectedFile replaceLocalVersion:NO];
            }
        }
        
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- SearchBar Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [[self restClient] searchPath:currentPath forKeyword:searchBar.text];
    [searchBar resignFirstResponder];
    
    // We are no longer searching the directory
    isSearching = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // We are no longer searching the directory
    isSearching = NO;
    
    // Dismiss the Keyboard
    [searchBar resignFirstResponder];
    
    // Reset the data and reload the table
    [self listDirectoryAtPath:currentPath];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // We are searching the directory
    isSearching = YES;
    
    if ([searchBar.text isEqualToString:@""] || searchBar.text == nil) {
        // [searchBar resignFirstResponder];
        [self listDirectoryAtPath:currentPath];
    } else if (![searchBar.text isEqualToString:@" "] || ![searchBar.text isEqualToString:@""]) {
        [[self restClient] searchPath:currentPath forKeyword:searchBar.text];
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- AlertView Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kDBSignInAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                [self removeDropboxBrowser];
                break;
            case 1:
                [[DBSession sharedSession] linkFromController:self];
                break;
            default:
                break;
        }
    } else if (alertView.tag == kFileExistsAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                // User selected overwrite
                [self downloadFile:selectedFile replaceLocalVersion:YES];
                break;
            default:
                break;
        }
    } else if (alertView.tag == kDBSignOutAlertViewTag) {
        switch (buttonIndex) {
            case 0: break;
            case 1: {
                [[DBSession sharedSession] unlinkAll];
                [self removeDropboxBrowser];
            } break;
            default:
                break;
        }
    }
}

//------------------------------------------------------------------------------------------------------------//
//------- Content Refresh ------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Content Refresh

- (void)updateTableData {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)updateContent {
    [self listDirectoryAtPath:currentPath];
}

//------------------------------------------------------------------------------------------------------------//
//------- DataController Delegate ----------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DataController Delegate

- (void)removeDropboxBrowser {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowserDismissed:)])
            [[self rootViewDelegate] dropboxBrowserDismissed:self];
    }];
}

- (void)downloadedFile {
    self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.tableView.alpha = 1.0;
        downloadProgressView.alpha = 0.0;
    }];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Downloaded" message:[NSString stringWithFormat:@"%@ was downloaded from Dropbox.", currentFileName] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    
    // Deliver File Download Notification
    if (deliverDownloadNotifications == YES) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"Downloaded %@ from Dropbox", currentFileName];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:deliveredFileDownloadNotification:)])
            [[self rootViewDelegate] dropboxBrowser:self deliveredFileDownloadNotification:localNotification];
    }
    
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didDownloadFile:didOverwriteFile:)]) {
        [self.rootViewDelegate dropboxBrowser:self didDownloadFile:currentFileName didOverwriteFile:isLocalFileOverwritten];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:downloadedFile:isLocalFileOverwritten:)]) {
        [[self rootViewDelegate] dropboxBrowser:self downloadedFile:currentFileName isLocalFileOverwritten:isLocalFileOverwritten];
    } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:downloadedFile:)]) {
        [[self rootViewDelegate] dropboxBrowser:self downloadedFile:currentFileName];
    }
#pragma clang diagnostic pop
    
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
}

- (void)startDownloadFile {
    [self.downloadProgressView setProgress:0.0];
    [UIView animateWithDuration:0.75 animations:^{
        downloadProgressView.alpha = 1.0;
    }];
}

- (void)downloadedFileFailed {
    self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.75 animations:^{
        self.tableView.alpha = 1.0;
        downloadProgressView.alpha = 0.0;
    }];
    
    self.navigationItem.title = [currentPath lastPathComponent];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Deliver File Download Notification
    if (deliverDownloadNotifications == YES) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"Failed to download %@ from Dropbox.", currentFileName];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:deliveredFileDownloadNotification:)])
            [[self rootViewDelegate] dropboxBrowser:self deliveredFileDownloadNotification:localNotification];
    }
    
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didFailToDownloadFile:)]) {
        [self.rootViewDelegate dropboxBrowser:self didFailToDownloadFile:currentFileName];
    } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:failedToDownloadFile:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[self rootViewDelegate] dropboxBrowser:self failedToDownloadFile:currentFileName];
#pragma clang diagnostic pop
    }
    
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
}

- (void)updateDownloadProgressTo:(CGFloat)progress {
    [self.downloadProgressView setProgress:progress];
}

//------------------------------------------------------------------------------------------------------------//
//------- Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox File and Directory Functions

- (BOOL)listDirectoryAtPath:(NSString *)path {
    if ([self isDropboxLinked]) {
        [[self restClient] loadMetadata:path];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}

- (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion:(BOOL)replaceLocalVersion {
    // Begin Background Process
    backgroundProcess = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
        backgroundProcess = UIBackgroundTaskInvalid;
    }];
    
    // Check if the file is a directory
    if (file.isDirectory) return NO;
    
    // Set download success
    BOOL downloadSuccess = NO;
    
    // Setup the File Manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Create the local file path
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *localPath = [documentsPath stringByAppendingPathComponent:file.filename];
    
    // Check if the local version should be overwritten
    if (replaceLocalVersion) {
        isLocalFileOverwritten = YES;
        [fileManager removeItemAtPath:localPath error:nil];
    } else {
        isLocalFileOverwritten = NO;
    }
    
    // Check if a file with the same name already exists locally
    if ([fileManager fileExistsAtPath:localPath] == NO) {
        // Prevent the user from downloading any more files while this donwload is in progress
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.75 animations:^{
            self.tableView.alpha = 0.8;
        }];
        
        // Start the file download
        [self startDownloadFile];
        [[self restClient] loadFile:file.path intoPath:localPath];
        
        // The download was a success
        downloadSuccess = YES;
        
    } else {
        // Create the local URL and get the modification date
        NSURL *fileUrl = [NSURL fileURLWithPath:localPath];
        NSDate *fileDate;
        NSError *error;
        [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
        
        if (!error) {
            NSComparisonResult result;
            result = [file.lastModifiedDate compare:fileDate]; // Compare the Dates
            
            if (result == NSOrderedAscending) {
                // Dropbox file is older than local file
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict" message:[NSString stringWithFormat:@"%@ has already been downloaded from Dropbox. You can overwrite the local version with the Dropbox one. The file in local files is newer than the Dropbox file.", file.filename] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in Dropbox and locally. The local file is newer."};
                NSError *error = [NSError errorWithDomain:@"[DropboxBrowser] File Conflict Error: File already exists in Dropbox and locally. The local file is newer." code:kDBDropboxFileOlderError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError:)]) {
                    [self.rootViewDelegate dropboxBrowser:self fileConflictWithLocalFile:fileUrl withDropboxFile:file withError:error];
                } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[self rootViewDelegate] dropboxBrowser:self fileConflictError:infoDictionary];
#pragma clang diagnostic pop
                }
                
            } else if (result == NSOrderedDescending) {
                // Dropbox file is newer than local file
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict" message:[NSString stringWithFormat:@"%@ has already been downloaded from Dropbox. You can overwrite the local version with the Dropbox file. The file in Dropbox is newer than the local file.", file.filename] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in Dropbox and locally. The Dropbox file is newer."};
                NSError *error = [NSError errorWithDomain:@"[DropboxBrowser] File Conflict Error: File already exists in Dropbox and locally. The Dropbox file is newer." code:kDBDropboxFileNewerError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError:)]) {
                    [self.rootViewDelegate dropboxBrowser:self fileConflictWithLocalFile:fileUrl withDropboxFile:file withError:error];
                } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[self rootViewDelegate] dropboxBrowser:self fileConflictError:infoDictionary];
#pragma clang diagnostic pop
                }
            } else if (result == NSOrderedSame) {
                // Dropbox File and local file were both modified at the same time
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict" message:[NSString stringWithFormat:@"%@ has already been downloaded from Dropbox. You can overwrite the local version with the Dropbox file. Both the local file and the Dropbox file were modified at the same time.", file.filename] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
                alertView.tag = kFileExistsAlertViewTag;
                [alertView show];
                
                NSDictionary *infoDictionary = @{@"file": file, @"message": @"File already exists in Dropbox and locally. Both files were modified at the same time."};
                NSError *error = [NSError errorWithDomain:@"[DropboxBrowser] File Conflict Error: File already exists in Dropbox and locally. Both files were modified at the same time." code:kDBDropboxFileSameAsLocalFileError userInfo:infoDictionary];
                
                if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:fileConflictWithLocalFile:withDropboxFile:withError:)]) {
                    [self.rootViewDelegate dropboxBrowser:self fileConflictWithLocalFile:fileUrl withDropboxFile:file withError:error];
                } else if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[self rootViewDelegate] dropboxBrowser:self fileConflictError:infoDictionary];
#pragma clang diagnostic pop
                }
            }
            
            [self updateTableData];
        } else {
            downloadSuccess = NO;
        }
    }
    
    return downloadSuccess;
}

- (void)loadShareLinkForFile:(DBMetadata*)file {
    [self.restClient loadSharableLinkForFile:file.path shortUrl:YES];
}

//------------------------------------------------------------------------------------------------------------//
//------- Dropbox Delegate -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DBRestClientDelegate methods

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if (![file.filename hasSuffix:@".exe"]) {
                // Add to list if not '.exe' and either the file is a directory, there are no allowed files set or the file ext is contained in the allowed types
                if ([file isDirectory] || allowedFileTypes.count == 0 || [allowedFileTypes containsObject:[file.filename pathExtension]] ) {
                    [dirList addObject:file];
                }
            }
        }
    }
    
    fileList = dirList;
    
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword {
    fileList = [NSMutableArray arrayWithArray:results];
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error {
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath {
    [self downloadedFile];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    [self downloadedFileFailed];
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
    [self updateDownloadProgressTo:progress];
}

- (void)restClient:(DBRestClient *)client loadedSharableLink:(NSString *)link forFile:(NSString *)path {
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didLoadShareLink:)]) {
        [self.rootViewDelegate dropboxBrowser:self didLoadShareLink:link];
    }
}

- (void)restClient:(DBRestClient *)client loadSharableLinkFailedWithError:(NSError *)error {
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didFailToLoadShareLinkWithError:)]) {
        [self.rootViewDelegate dropboxBrowser:self didFailToLoadShareLinkWithError:error];
    } else if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:failedLoadingShareLinkWithError:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.rootViewDelegate dropboxBrowser:self failedLoadingShareLinkWithError:error];
#pragma clang diagnostic pop
    }
}

@end
