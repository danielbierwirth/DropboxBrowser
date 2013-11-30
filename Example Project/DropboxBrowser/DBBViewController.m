//
//  DBBViewController.m
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DBBViewController.h"

@interface DBBViewController ()

@end

@implementation DBBViewController
@synthesize clearDocsBtn, navBar;

//------------------------------------------------------------------------------------------------------------//
//------- View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [UIView animateWithDuration:0.45 animations:^{
        clearDocsBtn.alpha = 1.0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (IBAction)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------------------------------------------------------------------------------//
//------- Dropbox --------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDropboxBrowser"]) {
        // Get reference to the destination view controller
        UINavigationController *navigationController = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        DropboxBrowserViewController *dropboxBrowser = (DropboxBrowserViewController *)navigationController.topViewController;
        
        // dropboxBrowser.allowedFileTypes = @[@"doc", @"pdf"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
        // dropboxBrowser.tableCellID = @"DropboxBrowserCell"; // Uncomment to use a custom UITableViewCell ID. This property is not required
        
        // When a file is downloaded (either successfully or unsuccessfully) you can have DBBrowser notify the user with Notification Center. Default property is NO.
        dropboxBrowser.deliverDownloadNotifications = YES;
        
        // Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.
        dropboxBrowser.shouldDisplaySearchBar = YES;
        
        // Set the delegate property to recieve delegate method calls
        dropboxBrowser.rootViewDelegate = self;
    }
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten {
    if (isLocalFileOverwritten == YES) {
        NSLog(@"Downloaded %@ by overwriting local file", fileName);
    } else {
        NSLog(@"Downloaded %@ without overwriting", fileName);
    }
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName {
    NSLog(@"Failed to download %@", fileName);
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error {
    NSLog(@"File conflict between %@ and %@\n%@ last modified on %@\nError: %@", localFileURL.lastPathComponent, dropboxFile.filename, dropboxFile.filename, dropboxFile.lastModifiedDate, error);
}

- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser {
    // This method is called after Dropbox Browser is dismissed. Do NOT dismiss DropboxBrowser from this method
    // Perform any UI updates here to display any new data from Dropbox Browser
    // ex. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
    //     NSString *fileName = [DropboxBrowserViewController fileName];
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification {
    long badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber]+1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

//------------------------------------------------------------------------------------------------------------//
//------- Documents ------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Documents

- (IBAction)clearDocs:(id)sender {
    // Clear all files from the local documents folder. This is helpful for testing purposes
    dispatch_queue_t delete = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(delete, ^{
        // Background Process;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
        
        for (NSString *filename in fileArray)  {
            [fileMgr removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.45 animations:^{
                clearDocsBtn.titleLabel.text = @"Cleared Local Documents";
                clearDocsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.45 animations:^{
                    clearDocsBtn.titleLabel.text = @"Clear Local Documents";
                }];
            }];
        });
    });
}

@end
