//
//  DBBViewController.m
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2014 iRare Media. All rights reserved.
//

#import "DBBViewController.h"

@interface DBBViewController ()
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) NSString *cacheDirectory;
@end

@implementation DBBViewController

// MARK: - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Set the OpenDropboxHandler delegate so we can get information about file activity
    [[ODBoxHandler sharedHandler] setDelegate:self];
    
    // Let's make our local files table look nice
    self.localFiles.layer.cornerRadius = 6.0f;
    self.localFiles.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.localFiles.layer.borderWidth = 0.5f;
    
    // Check the app status real quick
    [self checkAppStatus:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // Reset the badge count
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // Check the account status
    BOOL loggedIn = [[ODBoxHandler sharedHandler] clientIsAuthenticated];
    if (loggedIn) [self.accountStatusButton setTitle:@"Logout" forState:UIControlStateNormal];
    else [self.accountStatusButton setTitle:@"No Account" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Dropbox

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDropboxBrowser"]) {
        // Get reference to the destination view controller
        UINavigationController *navigationController = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        ODBTableViewController *dropboxBrowser = (ODBTableViewController *)navigationController.topViewController;
        
        // dropboxBrowser.allowedFileTypes = @[@"doc", @"pdf"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
        // dropboxBrowser.tableCellID = @"DropboxBrowserCell"; // Uncomment to use a custom UITableViewCell ID. This property is not required
        
        // Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.
        dropboxBrowser.shouldDisplaySearchBar = YES;
        
        // Set the delegate property to recieve delegate method calls
        dropboxBrowser.delegate = self;
    }
}

- (void)dropboxHandler:(ODBoxHandler *)handler didFinishDownloadingFile:(NSString *)fileName atURL:(NSURL *)localFileDownload data:(NSData *)fileData {
    if (localFileDownload) {
        NSLog(@"Downloaded %@ to location: %@.", fileName, localFileDownload);
    } else if (fileData) {
        NSLog(@"Downloaded %@'s file data.", fileName);
    }
    
    // In OpenDropboxBrowser v6.0, it is now the delegate's responsibility to deliver and handle notifications.
    long badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

- (void)dropboxHandler:(ODBoxHandler *)handler didFailToDownloadFile:(NSString *)fileName error:(NSError *)error {
    NSLog(@"Failed to download %@.", fileName);
}

- (void)dropboxBrowserWillDismiss:(ODBTableViewController *)browser {
    // This method is called just before the ODBTableViewController is dismissed. Thus, you are provided an opportunity to maintain a reference to the controller. Do NOT dismiss an ODBTableViewController from this method.
    // Perform any UI updates here to display any new data after an ODBTableViewController session.
    // i.e. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
    //      NSString *fileName = [ODBTableViewController currentFileName];
}

// - (void)dropboxBrowser:(ODBTableViewController *)browser didSelectFile:(NSDictionary *)file {
        // Implementing this method will override the standard download procedure. A dictionary with file information is provided using the keys on ODBoxHandler.
// }


// MARK: - Actions

- (IBAction)resetFiles:(id)sender {
    // Clear all files from the local documents folder. This is helpful for testing purposes
    dispatch_queue_t delete = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(delete, ^{
        // Background Process
        NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
        
        for (NSString *filename in fileArray)  {
            [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.45 animations:^{
                [self.resetFilesButton setTitle:@"Reset Complete" forState:UIControlStateNormal];
                [self.localFiles reloadData];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.45 animations:^{
                    [self.resetFilesButton setTitle:@"Reset Files" forState:UIControlStateNormal];
                }];
            }];
        });
    });
}

- (IBAction)toggleAccountAccess:(id)sender {
    BOOL loggedIn = [[ODBoxHandler sharedHandler] clientIsAuthenticated];
    if (loggedIn) {
        [[ODBoxHandler sharedHandler] clientRequestedLogout];
        [self.accountStatusButton setTitle:@"No Account" forState:UIControlStateNormal];
    } else {
        [self.accountStatusButton setTitle:@"Waiting..." forState:UIControlStateNormal];
        [self performSegueWithIdentifier:@"showDropboxBrowser" sender:self];
    }
}

- (IBAction)checkAppStatus:(id)sender {
    BOOL configured = [[ODBoxHandler sharedHandler] applicationIsConfiguredForAuthorization];
    if (configured) {
        [self.appStatusButton setTitle:@"Configured" forState:UIControlStateNormal];
    } else {
        [self.appStatusButton setTitle:@"ERROR" forState:UIControlStateNormal];
    }
}

// MARK: - Local files

- (void)getLocalFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    self.cacheDirectory = [paths objectAtIndex:0];
    
    NSError *error;
    self.files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDirectory error:&error];
    if (error) NSLog(@"Error: %@", error);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self getLocalFiles];
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.files objectAtIndex:indexPath.row];
    
    NSDictionary *fileAttribute = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", self.cacheDirectory, [self.files objectAtIndex:indexPath.row]] error:nil];
    NSDate *modified = fileAttribute[NSFileModificationDate];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    cell.detailTextLabel.text = [formatter stringFromDate:modified];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
