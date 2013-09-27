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
@synthesize clearDocsBtn, navBar, imgView;

//------------------------------------------------------------------------------------------------------------//
//Region: View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Setup Background Color
    self.view.backgroundColor = [UIColor underPageBackgroundColor];
    
    //Setup Navigation Bar Image
    [navBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    
    //Setup Background Image
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        [imgView setImage:[UIImage imageNamed:@"Background-568h"]];
    } else {
        [imgView setImage:[UIImage imageNamed:@"Background"]];
    }
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    clearDocsBtn.hidden = NO;
    [super viewWillAppear:YES];
}

- (void)viewDidUnload {
    [self setClearDocsBtn:nil];
    [self setNavBar:nil];
    [self setImgView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------------------------------------------------------------------------------//
//Region: Dropbox --------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDropboxBrowser"])
    {
        // Get reference to the destination view controller
        UINavigationController *navigationController = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        
        DropboxBrowserViewController *dropboxBrowser = (DropboxBrowserViewController *) navigationController.topViewController;
        
        #warning create an array of allowed types. (N.B. to allow all file types simply don't set the property)
        dropboxBrowser.allowedFileTypes = @[@"docx", @"pdf"];
        dropboxBrowser.rootViewDelegate = self;
        
    }}

- (IBAction)browseDropbox:(id)sender {
    [self performSegueWithIdentifier:@"showDropboxBrowser" sender:self];
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)fileName isLocalFileOverwritten:(BOOL)isLocalFileOverwritten{
    NSLog(@"Downloaded %@ overwritten = %d", fileName, isLocalFileOverwritten);
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedToDownloadFile:(NSString *)fileName {
    NSLog(@"Failed to download %@", fileName);
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictError:(NSDictionary *)conflict {
    DBMetadata *file = [conflict objectForKey:@"file"];
    NSString *errorMessage = [conflict objectForKey:@"message"];
    NSLog(@"Conflict error with %@\n%@ last modified on %@\nError: %@", file.filename, file.filename, file.lastModifiedDate, errorMessage);
}

- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser {
    //This method is called after Dropbox Browser is dismissed. Do NOT dismiss DropboxBrowser from this method
    //Perform any UI updates here to display any new data from Dropbox Browser
    // ex. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
    //     NSString *fileName = [DropboxBrowserViewController fileName];
}

//------------------------------------------------------------------------------------------------------------//
//Region: Documents ------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Documents

- (IBAction)clearDocs:(id)sender {
    //Clear all files from the local documents folder. This is helpful for testing purposes
    dispatch_queue_t delete = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(delete, ^{
        //Background Process;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
        
        for (NSString *filename in fileArray)  {
            [fileMgr removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Main UI Process
            clearDocsBtn.titleLabel.text = @"Cleared Docs";
            clearDocsBtn.hidden = YES;
        });
    });
}

@end
