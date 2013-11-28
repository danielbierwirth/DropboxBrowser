//
//  DropboxBrowserViewController.m
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 11/28/13
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

#import "DropboxBrowserViewController.h"

// View tags to differeniate alert views
static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kFileExistsAlertViewTag = 2;
static NSUInteger const kDBSignOutAlertViewTag = 3;

@interface DropboxBrowserViewController () <DBRestClientDelegate> {
    DBMetadata *selectedFile;
    BOOL isLocalFileOverwritten;
    UIBackgroundTaskIdentifier backgroundProcess;
}

- (DBRestClient *)restClient;

@end

@implementation DropboxBrowserViewController
@synthesize downloadProgressView, currentPath, rootViewDelegate, fileList;
@synthesize allowedFileTypes, tableCellID, deliverDownloadNotifications;
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
    self.title = @"Dropbox";
    self.currentPath = @"/";
    
    // Setup Navigation Bar, use different styles for iOS 7 and higher
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(removeDropboxBrowser)];
    // UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutDropbox)];
    self.navigationItem.rightBarButtonItem = rightButton;
    // self.navigationItem.leftBarButtonItem = leftButton;
    
    // Create Search Bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search my Dropbox";
    self.tableView.tableHeaderView = searchBar;
    
    // Setup Search Controller
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    searchController.delegate = self;
    
    // Add Download Progress View to Navigation Bar
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // The user is on an iPad - Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        newProgressView.frame = CGRectMake(0, 15, self.view.frame.size.width, 20);
        newProgressView.hidden = YES;
        newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        [self.parentViewController.view addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    } else {
        // The user is on an iPhone / iPod Touch - Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        newProgressView.frame = CGRectMake(0, 64, 320, 20);
        newProgressView.hidden = YES;
        newProgressView.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
        newProgressView.trackTintColor = [UIColor lightGrayColor];
        [self.parentViewController.view addSubview:newProgressView];
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
//------- Table View Setup -----------------------------------------------------------------------------------//
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
            cell.textLabel.text = @"Folder is Empty";
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
            DropboxBrowserViewController *newVC = [[DropboxBrowserViewController alloc] init];
            NSString *subpath = [currentPath stringByAppendingPathComponent:selectedFile.filename];
            newVC.currentPath = subpath;
            newVC.title = [subpath lastPathComponent];
            
            [newVC listDirectoryAtPath:subpath];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSLog(@"Path: %@ | New Title: %@ | Subpath: %@", currentPath, newVC.title, subpath);
            [self.navigationController pushViewController:newVC animated:YES];
        } else {
            currentFileName = selectedFile.filename;
            
            // Check if our delegate handles file selection
            if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:selectedFile:)]) {
                [self.rootViewDelegate dropboxBrowser:self selectedFile:selectedFile];
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
    NSLog(@"Search Query: %@", searchBar.text);
    [[self restClient] searchPath:currentPath forKeyword:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Dismiss the Keyboard
    [searchBar resignFirstResponder];
    
    // Reset the data and reload the table
    [self listDirectoryAtPath:currentPath];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchBar.text isEqualToString:@""]) {
        [searchBar resignFirstResponder];
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
                if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowserDismissed:)]) {
                    [[self rootViewDelegate] dropboxBrowserDismissed:self];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
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
                
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowserDismissed:)])
                        [[self rootViewDelegate] dropboxBrowserDismissed:self];
                }];
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
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
}

- (void)refreshTableView {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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
    
    [self.downloadProgressView setHidden:YES];
    [self.downloadProgressView setProgress:0.0];
    self.navigationItem.title = @"Dropbox";
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Downloaded" message:[NSString stringWithFormat:@"%@ was downloaded to the documents folder.", currentFileName] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    
    // Deliver Local Notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Downloaded %@ from Dropbox", currentFileName];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    if (deliverDownloadNotifications == YES) [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:downloadedFile:isLocalFileOverwritten:)])
        [[self rootViewDelegate] dropboxBrowser:self downloadedFile:currentFileName isLocalFileOverwritten:isLocalFileOverwritten];
    
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
}

- (void)startDownloadFile {
    self.navigationItem.title = @"";
    [self.downloadProgressView setHidden:NO];
}

- (void)downloadedFileFailed {
    self.tableView.userInteractionEnabled = YES;
    
    [self.downloadProgressView setHidden:YES];
    self.navigationItem.title = [currentPath lastPathComponent];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // Deliver Local Notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Failed to download %@ from Dropbox.", currentFileName];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    if (deliverDownloadNotifications == YES) [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:failedToDownloadFile:)])
        [[self rootViewDelegate] dropboxBrowser:self failedToDownloadFile:currentFileName];
    
    // End the background task
    [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
}

- (void)updateDownloadProgressTo:(CGFloat) progress {
    [self.downloadProgressView setProgress:progress];
}

- (void)setList:(NSMutableArray *)newList {
    if (fileList != newList) {
        fileList = [newList mutableCopy];
    }
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
    // Background Process
    backgroundProcess = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // End the Background Process
        [[UIApplication sharedApplication] endBackgroundTask:backgroundProcess];
        backgroundProcess = UIBackgroundTaskInvalid;
    }];
    
    BOOL res = NO;
    
    if (!file.isDirectory) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *localPath = [documentsPath stringByAppendingPathComponent:file.filename];
        
        if (replaceLocalVersion) {
            isLocalFileOverwritten = YES;
            [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
        } else {
            isLocalFileOverwritten = NO;
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            self.tableView.userInteractionEnabled = NO;
            
            [self startDownloadFile];
            res = YES;
            [[self restClient] loadFile:file.path intoPath:localPath];
        } else {
            // Use [NSURL fileURLWithPath:] with local files, otherwise NSURLContentModificationDateKey returns null
            NSURL *fileUrl = [NSURL fileURLWithPath:localPath];
            NSDate *fileDate;
            NSError *error;
            [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
            if (!error) {
                NSComparisonResult result; // Has three possible values: NSOrderedSame, NSOrderedDescending, NSOrderedAscending
                result = [file.lastModifiedDate compare:fileDate]; // Compare the Dates
                if (result == NSOrderedAscending || result == NSOrderedSame) {
                    // Dropbox File is older than local file
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Already Downloaded"
                                                                        message:[NSString stringWithFormat:@"%@ has already been downloaded to the Documents folder. You can overwrite the local version with this one though.", file.filename]
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"Overwrite", nil];
                    alertView.tag = kFileExistsAlertViewTag;
                    [alertView show];
                    
                    NSDictionary *conflict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:file, @"File already exists in the Documents folder", nil] forKeys:[NSArray arrayWithObjects:@"file", @"message", nil]];
                    
                    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)])
                        [[self rootViewDelegate] dropboxBrowser:self fileConflictError:conflict];
                    
                } else if (result == NSOrderedDescending) {
                    // Dropbox File is newer than local file
                    NSLog(@"Dropbox File is newer than local file");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict"
                                                                        message:[NSString stringWithFormat:@"%@ exists in both Dropbox and the Documents folder. The one in Dropbox is newer.", file.filename]
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"Overwrite", nil];
                    alertView.tag = kFileExistsAlertViewTag;
                    [alertView show];
                    
                    NSDictionary *conflict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:file, @"File exists in Dropbox and the Documents folder. The Dropbox file is newer.", nil] forKeys:[NSArray arrayWithObjects:@"file", @"message", nil]];
                    
                    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)])
                        [[self rootViewDelegate] dropboxBrowser:self fileConflictError:conflict];
                }
                
                [self updateTableData];
            }
        }
    }
    
    return res;
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
    NSLog(@"List: %@", fileList);
    
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)restClient searchFailedWithError:(NSError *)error {
    NSLog(@"Search Failed");
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [self updateTableData];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    [self downloadedFile];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    [self downloadedFileFailed];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
    [self updateDownloadProgressTo:progress];
}

- (void) restClient:(DBRestClient *)client loadedSharableLink:(NSString *)link forFile:(NSString *)path {
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:didLoadShareLink:)]) {
        [self.rootViewDelegate dropboxBrowser:self didLoadShareLink:link];
    }
}

- (void) restClient:(DBRestClient *)client loadSharableLinkFailedWithError:(NSError *)error {
    if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:failedLoadingShareLinkWithError:)]) {
        [self.rootViewDelegate dropboxBrowser:self failedLoadingShareLinkWithError:error];
    }
}

@end
