//
//  ODBTableViewController.m
//  OpenDropboxBrowser
//
//  Created by Sam Spencer on 2/10/17.
//  Copyright © 2017 Spencer Software. All rights reserved.
//

#import "ODBTableViewController.h"

#define kDropboxRootFolder @""

@interface ODBTableViewController ()

/// The current list of files for the ODBTableViewController
@property (nonatomic, strong, readwrite) NSMutableArray *currentFiles;

/// The current file path of the ODBTableViewController
@property (nonatomic, strong, readwrite) NSString *currentPath;

/// The currently selected file path in the ODBTableViewController
@property (nonatomic, strong) NSDictionary *currentFile;

/// The controller's main download progress view.
@property (nonatomic, strong) UIProgressView *downloadProgressView;

/// The user is currently using the search bar.
@property (nonatomic, assign) BOOL searchActive;

/// The controller pushed onto the navigation stack when the users opens a folder.
@property (nonatomic, strong) ODBTableViewController *subdirectoryController;

/// Search controller used to display results and handle queries
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ODBTableViewController

// MARK: - 
// MARK: View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Title and Path
    if (self.title == nil || [self.title isEqualToString:@""]) self.title = @"Dropbox";
    if (self.currentPath == nil || [self.currentPath isEqualToString:@""]) self.currentPath = kDropboxRootFolder;
    if (self.colorTheme == nil) self.colorTheme = [UIColor colorWithRed:0.0/255.0f green:122.0/255.0f blue:255.0/255.0f alpha:1.0f];
    
    // Setup Navigation Bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"DropboxBrowser: Done button to dismiss the DropboxBrowserViewController") style:UIBarButtonItemStyleDone target:self action:@selector(dismissBrowser)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Add the search controller
    if (self.shouldDisplaySearchBar == YES) {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Search %@", @"DropboxBrowser: Search Field Placeholder Text. Search 'CURRENT FOLDER NAME'"), self.title];
        [self.searchController.searchBar sizeToFit];
        
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.definesPresentationContext = YES;
    }
    
    // Add Download Progress View to Navigation Bar
    UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    CGFloat yOrigin = self.navigationController.navigationBar.bounds.size.height-newProgressView.bounds.size.height;
    CGFloat widthBoundary = self.navigationController.navigationBar.bounds.size.width;
    CGFloat heigthBoundary = newProgressView.bounds.size.height;
    newProgressView.frame = CGRectMake(0, yOrigin, widthBoundary, heigthBoundary);
    
    newProgressView.alpha = 0.0;
    newProgressView.tintColor = self.colorTheme;
    newProgressView.trackTintColor = [UIColor lightGrayColor];
    
    [self.navigationController.navigationBar addSubview:newProgressView];
    [self setDownloadProgressView:newProgressView];
    
    // Add a refresh control, pull down to refresh
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = self.colorTheme;
        [refreshControl addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    // Initialize Directory Content
    if ([self.currentPath isEqualToString:kDropboxRootFolder]) {
        [self listDirectoryAtPath:kDropboxRootFolder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self browserAuthenticationProcess];
}

- (void)browserAuthenticationProcess {
    if (![[ODBoxHandler sharedHandler] applicationIsConfiguredForAuthorization]) {
        // The application has not been properly configured to work with Dropbox.
        // If this is a release build, we must gracefully present information to the user and cancel the appearance.
        // If this is a debug build, an exception will be thrown and the developer will be referred to the log.
#if DEBUG
        NSException *exception = [NSException exceptionWithName:@"OpenDropboxBrowser Improper Configuration" reason:@"The application has not been appropriately configured to use Dropbox. Please see the log messages above to determine the exact reason for improper configuration. In a release build, the user will be presented with a warning and Dropbox functionality will not be available." userInfo:nil];
        [exception raise];
#else
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        // Create the alert
        UIAlertController *compatibilityAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Dropbox Incompatible", @"DropboxBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ version %@ is not properly configured to work with Dropbox. Consider contacting the developer.", @"OpenDropboxBrowser Alert Message"), appName, appVersion] preferredStyle:UIAlertControllerStyleAlert];
        
        // Cancel login and dismiss the Browser.
        [compatibilityAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button.") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [compatibilityAlert dismissViewControllerAnimated:YES completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }]];
        
        [self presentViewController:compatibilityAlert animated:YES completion:nil];
#endif
    } else {
        if (![[ODBoxHandler sharedHandler] clientIsAuthenticated]) {
            // The user has not been authenticated or the app needs to be granted permissions.
            
            // Populate the appropriate alert message.
            NSString *loginAlertText;
            if (self.accessReason == nil || [self.accessReason isEqualToString:@""])
                loginAlertText = [NSString stringWithFormat:NSLocalizedString(@"%@ is not linked to your Dropbox. Would you like to login now and allow access?", @"DropboxBrowser: Alert Message. 'APP NAME' is not linked to Dropbox..."), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]];
            else 
                loginAlertText = self.accessReason;
            
            // Create the alert
            UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Login to Dropbox", @"DropboxBrowser: Alert Title") message:loginAlertText preferredStyle:UIAlertControllerStyleAlert];
            
            // Setup the "Login" action
            [loginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Login", @"DropboxBrowser: Alert Button.") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
              [DBClientsManager authorizeFromController:[UIApplication sharedApplication] controller:self openURL:^(NSURL *url) {
                [[UIApplication sharedApplication] openURL:url];
              }];
            }]];
            
            // Cancel login and dismiss the Browser.
            [loginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button.") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:loginAlert animated:YES completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissBrowser {
    if ([self.delegate respondsToSelector:@selector(dropboxBrowserWillDismiss:)]) {
        [self.delegate dropboxBrowserWillDismiss:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - 
// MARK: Content fetching

- (void)updateContent {
    [self listDirectoryAtPath:self.currentPath];
}

- (BOOL)listDirectoryAtPath:(NSString *)path {
    NSLog(@"[ODBTableViewController] Listing directory at path: %@", path);
    
    if ([[ODBoxHandler sharedHandler] clientIsAuthenticated]) {
        [[ODBoxHandler sharedHandler] fetchFileListsInDirectory:self.currentPath completion:^(NSArray * _Nonnull files, NSError * _Nonnull error) {
            if (files) {
                self.currentFiles = nil;
                self.currentFiles = [NSMutableArray arrayWithCapacity:files.count];
                for (NSString *file in files) {
                    if (self.allowedFileTypes.count == 0 || [self.allowedFileTypes containsObject:[file pathExtension]]) {
                        [self.currentFiles addObject:file];
                    }
                }
                
                [self refreshTable];
            } else {
                // Populate the appropriate alert message.
                NSString *failureText = NSLocalizedString(@"Failed to refresh the list of files.", @"DropboxBrowser: Alert Message.");
                
                // Create the alert
                UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Could Not Update", @"DropboxBrowser: Alert Title") message:failureText preferredStyle:UIAlertControllerStyleAlert];
                
                // Cancel login and dismiss the Browser.
                [loginAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button.") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self refreshTable];
                }]];
                
                [self presentViewController:loginAlert animated:YES completion:nil];
            }
        }];
        return YES;
    } else { 
        [self browserAuthenticationProcess];
        return NO;
    }
}


// MARK: - 
// MARK: Content handling

- (void)updateDownloadProgress:(CGFloat)progress {
    [self.downloadProgressView setProgress:progress];
}


// MARK: - 
// MARK: Table view

- (void)refreshTable {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentFiles.count == 0) {
        return 2; // Return cell to show the folder is empty
    } else return self.currentFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.currentFiles count] == 0) {
        // There are no files in the directory - let the user know
        if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            
            if (self.searchActive == YES) {
                cell.textLabel.text = NSLocalizedString(@"No Search Results", @"DropboxBrowser: Empty Search Results Text");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Folder is Empty", @"DropboxBroswer: Empty Folder Text");
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
        if (!self.tableCellID || [self.tableCellID isEqualToString:@""]) self.tableCellID = @"DropboxBrowserCell";
        
        // Create the table view cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.tableCellID];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DropboxBrowserCell"];
        
        // Configure the Dropbox Data for the cell
        NSDictionary *file = self.currentFiles[indexPath.row];
        NSString *fileName = file[ODBFileKeys.kDropboxFileName];
        NSString *fileType = file[ODBFileKeys.kDropboxFileType];
        
        // Set the file name
        cell.textLabel.text = fileName;
        
        // Setup Last Modified Date
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        // Add a cell icon
        UIImage *icon = [UIImage imageNamed:file[ODBFileKeys.kDropboxFileIcon]];
        cell.imageView.image = icon;
        
        // Get File Details and Display
        if ([fileType isEqualToString:ODBFileKeys.kDropboxFileTypeFolder]) {
            cell.detailTextLabel.text = @"";
            
            return cell;
        } else {
            // Format the file size
            NSNumber *size = file[ODBFileKeys.kDropboxFileSize];
            NSString *fileSize = [NSByteCountFormatter stringFromByteCount:size.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@, modified %@", @"DropboxBrowser: File detail label with the file size and modified date."), fileSize, [formatter stringFromDate:file[ODBFileKeys.kDropboxFileModifiedDate]]];
            
            return cell;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil)
        return;
    if ([self.currentFiles count] == 0) {
        // Do nothing, there are no items in the list.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        self.currentFile = self.currentFiles[indexPath.row];
        if ([self.currentFile[ODBFileKeys.kDropboxFileType] isEqualToString:ODBFileKeys.kDropboxFileTypeFolder]) {
            // Create new UITableViewController
            self.subdirectoryController = [[ODBTableViewController alloc] init];
            self.subdirectoryController.delegate = self.delegate;
            // NSString *subpath = [self.currentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/", self.currentFile[ODBFileKeys.kDropboxFileName]]];
            NSString *escapedSubpath = [ODBoxHandler encodeFolderPath:self.currentFile[ODBFileKeys.kDropboxFileName] currentPath:self.currentPath];
            self.subdirectoryController.currentPath = escapedSubpath;
            self.subdirectoryController.title = self.currentFile[ODBFileKeys.kDropboxFileName]; // [subpath lastPathComponent];
            self.subdirectoryController.shouldDisplaySearchBar = self.shouldDisplaySearchBar;
            self.subdirectoryController.allowedFileTypes = self.allowedFileTypes;
            self.subdirectoryController.tableCellID = self.tableCellID;
            self.subdirectoryController.colorTheme = self.colorTheme;
            
            [self.subdirectoryController listDirectoryAtPath:escapedSubpath];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self.navigationController pushViewController:self.subdirectoryController animated:YES];
        } else {
            self.currentFile = self.currentFiles[indexPath.row];
            
            // Check if our delegate handles file selection
            if ([self.delegate respondsToSelector:@selector(dropboxBrowser:didSelectFile:)]) {
                [self.delegate dropboxBrowser:self didSelectFile:self.currentFile];
            } else {
                // Download file
                [[ODBoxHandler sharedHandler] downloadDropboxFile:[NSString stringWithFormat:@"%@/%@", self.currentPath, self.currentFile[ODBFileKeys.kDropboxFileName]] completion:^(NSURL * _Nonnull filePath, NSError * _Nonnull error) {
                    // Check if the table cell ID has been set, otherwise create one
                    if (!self.tableCellID || [self.tableCellID isEqualToString:@""]) {
                        self.tableCellID = @"DropboxBrowserCell";
                    }
                    
                    // Create the table view cell
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.accessoryView.tintColor = self.colorTheme;
                    
                    // Reload the cell
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                } updateProgress:^(NSNumber * _Nonnull progress) {
                    [self updateDownloadProgress:progress.floatValue];
                }];
            }
        }
        
    }
}

// MARK: - 
// MARK: Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    
    [self.refreshControl beginRefreshing];
    
    [[ODBoxHandler sharedHandler] searchFileListsInDirectory:self.currentPath query:searchString completion:^(NSArray * _Nonnull files, NSError * _Nonnull error) {
        if (files) {
            self.currentFiles = files.mutableCopy;
            [self refreshTable];
        } else {
            [self.refreshControl endRefreshing];
            NSLog(@"[OpenDropboxBrowser] An error occured while searching...");
        }
    }];
    
    // [searchBar resignFirstResponder];
    
    // We are no longer searching the directory
    self.searchActive = NO;
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // We are searching the directory
    self.searchActive = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // We are no longer searching the directory
    self.searchActive = NO;
    
    // Reset the data and reload the table
    [self listDirectoryAtPath:self.currentPath];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // We are no longer searching the directory
    self.searchActive = NO;
    
    // Dismiss the Keyboard
    [searchBar resignFirstResponder];
    
    // Reset the data and reload the table
    [self listDirectoryAtPath:self.currentPath];
}

/*  - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.refreshControl beginRefreshing];
    
    [[ODBoxHandler sharedHandler] searchFileListsInDirectory:self.currentPath query:searchBar.text completion:^(NSArray * _Nonnull files, NSError * _Nonnull error) {
        if (files) {
            self.currentFiles = files.mutableCopy;
            [self refreshTable];
        } else {
            [self.refreshControl endRefreshing];
            NSLog(@"[OpenDropboxBrowser] An error occured while searching...");
        }
    }];
    
    [searchBar resignFirstResponder];
    
    // We are no longer searching the directory
    self.searchActive = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // We are searching the directory
    self.searchActive = YES;
    
    if ([searchBar.text isEqualToString:@""] || searchBar.text == nil) {
        // [searchBar resignFirstResponder];
        [self listDirectoryAtPath:self.currentPath];
    } else if (![searchBar.text isEqualToString:@" "] || ![searchBar.text isEqualToString:@""]) {
        [[ODBoxHandler sharedHandler] searchFileListsInDirectory:self.currentPath query:searchBar.text completion:^(NSArray * _Nonnull files, NSError * _Nonnull error) {
            if (files) {
                self.currentFiles = files.mutableCopy;
                [self refreshTable];
            } else {
                [self.refreshControl endRefreshing];
                NSLog(@"[OpenDropboxBrowser] An error occured while searching...");
            }
        }];
    }
} */

@end
