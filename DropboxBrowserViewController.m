//
//  DropboxBrowserViewController.m
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

#import "DropboxBrowserViewController.h"

// view tags to differeniate alert views
static NSUInteger const kDBSignInAlertViewTag = 1;
static NSUInteger const kFileExistsAlertViewTag = 2;

@interface DropboxBrowserViewController () <DBRestClientDelegate> {
    //Back Button
    UIBarButtonItem *leftButton;
    DBMetadata *selectedFile;
    BOOL isLocalFileOverwritten;
}

- (DBRestClient *)restClient;

@end

@implementation DropboxBrowserViewController
@synthesize downloadProgressView;
@synthesize hud, currentPath;
@synthesize rootViewDelegate, list;
@synthesize allowedFileTypes;
static NSString *currentFileName = nil;

//------------------------------------------------------------------------------------------------------------//
//Region: Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Files and Directories

+ (NSString *)fileName {
    return currentFileName;
}

- (NSArray *) allowedFileTypes
{
    if (allowedFileTypes == nil) {
        allowedFileTypes = [NSArray array];
    }
    return allowedFileTypes;
}

- (void)moveToParentDirectory {
    //Go up one directory level
    NSString *filePath = [self.currentPath stringByDeletingLastPathComponent];
    self.currentPath = filePath;
    
    if ([self.currentPath isEqualToString:@"/"]) {
        leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(moveToParentDirectory)];
        self.navigationItem.leftBarButtonItem = nil;
        self.title = @"Dropbox";
    } else {
        leftButton.image = [UIImage imageNamed:@"BackButton"];
        leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(moveToParentDirectory)];
        self.navigationItem.leftBarButtonItem = leftButton;
        self.title = [currentPath lastPathComponent];
    }
    
    [self listDirectoryAtPath:self.currentPath];
}

//------------------------------------------------------------------------------------------------------------//
//Region: View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark  - View Lifecycle

- (id)init {
	self = [super init];
	if (self)  {
        //Custom initialization
        isLocalFileOverwritten = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //Custom Init
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Dropbox";
    self.currentPath = @"/";
    
    //Setup Navigation Bar color
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:223.0/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    
    //Set Bar Button
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"DoneButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(removeDropboxBrowser)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //Setup Search Bar - Coming Soon
    /*
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    searchController.delegate = self;
    */
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //The user is on an iPad
        //Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        newProgressView.frame = CGRectMake(180, 15, 200, 30);
        newProgressView.hidden = YES;
        [self.parentViewController.view addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    } else {
        //The user is on an iPhone / iPod Touch
        //Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        newProgressView.frame = CGRectMake(80, 37, 150, 30);
        newProgressView.hidden = YES;
        [self.parentViewController.view addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    }
    
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:223.0/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    //Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    if (![self isDropboxLinked]) {
        //Raise alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not Signed In to Dropbox"
                                                            message:[NSString stringWithFormat:@"%@ is not linked to your Dropbox account. Would you like to sign-in now?", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Sign In to Dropbox", nil];
        alertView.tag = kDBSignInAlertViewTag;
        
        [alertView show];
    } else {
        //Start progress indicator
        if ([UIRefreshControl class]) {
            [self.refreshControl beginRefreshing];
            [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.labelText = @"Loading Data...";
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        }
        
        [self listHomeDirectory];
        [self refreshTableView];
    }
}

//In case of missing response - remove busy indicator after certain time interval
- (void)timeout:(id)arg {
    self.hud.labelText = @"Timeout!";
    self.hud.detailsLabelText = @"Please try again later.";
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:3.0];
    if ([UIRefreshControl class]) {
        [self.refreshControl endRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

//------------------------------------------------------------------------------------------------------------//
//Region: Table View Setup -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([list count] == 0) {
        return 1; //Return One cell to show the folder is empty
    } else {
        return [self.list count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([list count] == 0) {
        //There are no files in the directory - let the user know
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = @"Folder is Empty";
        cell.textLabel.textColor = [UIColor darkGrayColor];
        return cell;
    } else {
        //Setup the Cell and its ID
        #warning Use the correct UITableViewCell ID in your Storyboard: DropboxBrowserCell
        static NSString *CellIdentifier = @"DropboxBrowserCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
        //Configure the Dropbox Data for the cell
        DBMetadata *file = (DBMetadata *)[self.list objectAtIndex:indexPath.row];
    
        //Setup the Cell File Name
        cell.textLabel.text = file.filename;
        [cell.textLabel setNeedsDisplay];
    
        //Setup Icon
        cell.imageView.image = [UIImage imageNamed:file.icon];
        
        //Setup Last Modified Date
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        //Get File Details and Display
        if ([file isDirectory]) {
            //Folder
            cell.detailTextLabel.text = @"";
            [cell.detailTextLabel setNeedsDisplay];
        } else {
            //File
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, modified %@", file.humanReadableSize, [formatter stringFromDate:file.lastModifiedDate]];
            [cell.detailTextLabel setNeedsDisplay];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == nil)
        return;
    
    if ([list count] == 0) {
        //Do nothing, there are no items in the list. We don't want to download a file that doesn't exist (that'd cause a crash)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
            selectedFile = (DBMetadata*)[self.list objectAtIndex:indexPath.row];
        
        if ([selectedFile isDirectory]) {
            //Show Back Button for a new directory
            leftButton.image = [UIImage imageNamed:@"BackButton"];
            leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(moveToParentDirectory)];
            self.navigationItem.leftBarButtonItem = leftButton;
            
            //Push new tableviewcontroller
            NSString *subpath = [self.currentPath stringByAppendingPathComponent:selectedFile.filename];
            self.currentPath = subpath;
            self.title = [currentPath lastPathComponent];
            
            //Start progress indicator
            if ([UIRefreshControl class]) {
                [self.refreshControl beginRefreshing];
                [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
            } else {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.hud.labelText = @"Loading Data...";
                [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
            }
            
            [self listDirectoryAtPath:subpath];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSLog(@"Path: %@", currentPath);
            
        } else {
            
            currentFileName = selectedFile.filename;
            
            //Check if our delegate handles file selection
            if ([self.rootViewDelegate respondsToSelector:@selector(dropboxBrowser:selectedFile:)]) {
                [self.rootViewDelegate dropboxBrowser:self selectedFile:selectedFile];
            } else {
                //Download file
                [self downloadFile:selectedFile replaceLocalVersion:NO];
            }
        }

    }
}

- (void)refreshTableView {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    
    if ([UIRefreshControl class])
        [self.refreshControl endRefreshing];
}

- (void)updateContent {
    [self listDirectoryAtPath:currentPath];
}

//------------------------------------------------------------------------------------------------------------//
//Region: SearchBar Delegate ---------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - SearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Query: %@", searchBar.text);
    [[self restClient] searchPath:currentPath forKeyword:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchBar.text isEqualToString:@""]) {
        [searchBar resignFirstResponder];
    } else if (![searchBar.text isEqualToString:@" "] || ![searchBar.text isEqualToString:@""]) {
        [[self restClient] searchPath:currentPath forKeyword:searchBar.text];
    }
}

//------------------------------------------------------------------------------------------------------------//
//Region: AlertView Delegate ---------------------------------------------------------------------------------//
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
                // user selected overwrite
                [self downloadFile:selectedFile replaceLocalVersion:YES];
                break;
            default:
                break;
        }
    }
    
}

//------------------------------------------------------------------------------------------------------------//
//Region: DataController Delegate ----------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DataController Delegate

- (void)removeDropboxBrowser {
    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowserDismissed:)])
        [[self rootViewDelegate] dropboxBrowserDismissed:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissHUD {
    if ([UIRefreshControl class]) {
        [self.refreshControl endRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)updateTableData {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //Code here to populate data source
    
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
    
}

- (void)downloadedFile {
    
    self.tableView.userInteractionEnabled = YES;
    
    [self.downloadProgressView setHidden:YES];
    [self.downloadProgressView setProgress:0.0];
    self.navigationItem.title = @"Dropbox";
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Downloaded"
                                                        message:[NSString stringWithFormat:@"%@ was downloaded to the documents folder.", currentFileName]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];

    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:downloadedFile:isLocalFileOverwritten:)])
        [[self rootViewDelegate] dropboxBrowser:self downloadedFile:currentFileName isLocalFileOverwritten:isLocalFileOverwritten];
    
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
    
    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:failedToDownloadFile:)])
        [[self rootViewDelegate] dropboxBrowser:self failedToDownloadFile:currentFileName];
}

- (void)updateDownloadProgressTo:(CGFloat) progress {
    [self.downloadProgressView setProgress:progress];
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        list = [newList mutableCopy];
    }
}

//------------------------------------------------------------------------------------------------------------//
//Region: Files and Directories ------------------------------------------------------------------------------//
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

- (BOOL)listHomeDirectory {
    return [self listDirectoryAtPath:@"/"];
}

- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}

- (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion: (BOOL) replaceLocalVersion {
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
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            
            self.tableView.userInteractionEnabled = NO;
            
            [self startDownloadFile];
            res = YES;
            [[self restClient] loadFile:file.path intoPath:localPath];
        } else {
            // use [NSURL fileURLWithPath:] with local files, otherwise NSURLContentModificationDateKey returns null
            NSURL *fileUrl = [NSURL fileURLWithPath:localPath];
            NSDate *fileDate;
            NSError *error;
            [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
            if (!error) {
                NSComparisonResult result; //has three possible values: NSOrderedSame, NSOrderedDescending, NSOrderedAscending
                result = [file.lastModifiedDate compare:fileDate]; //Compare the Dates
                if (result == NSOrderedAscending || result == NSOrderedSame) {
                    //Dropbox File is older than local file
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Already Downloaded"
                                                                        message:[NSString stringWithFormat:@"%@ is already in the Documents folder.", file.filename]
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"Overwrite", nil];
                    alertView.tag = kFileExistsAlertViewTag;
                    [alertView show];
                    
                    NSDictionary *conflict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:file, @"File already exists in the Documents folder", nil] forKeys:[NSArray arrayWithObjects:@"file", @"message", nil]];
                    
                    if ([[self rootViewDelegate] respondsToSelector:@selector(dropboxBrowser:fileConflictError:)])
                        [[self rootViewDelegate] dropboxBrowser:self fileConflictError:conflict];
                    
                } else if (result == NSOrderedDescending) {
                    //Dropbox File is newer than local file
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
//Region: Dropbox Delegate -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DBRestClientDelegate methods

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if (![file.filename hasSuffix:@".exe"]) {
                // add to list if not '.exe' and either the file is a directory, there are no allowed files set or the file ext is contained in the allowed types
                if ([file isDirectory] || allowedFileTypes.count == 0 || [allowedFileTypes containsObject:[file.filename pathExtension]] ) {
                    [dirList addObject:file];
                }
            }
        }
    }
    
    self.list = dirList;
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword {
    self.list = [NSMutableArray arrayWithArray:results];
    NSLog(@"List: %@", list);
    
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
