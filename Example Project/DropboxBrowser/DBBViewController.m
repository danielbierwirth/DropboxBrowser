//
//  DBBViewController.m
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DBBViewController.h"

@interface DBBViewController () {
    DBRestClient *restClient;
}

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

- (IBAction)browseDropbox:(id)sender {
    //Check if Dropbox is Setup
    if (![[DBSession sharedSession] isLinked]) {
        //Dropbox is not setup
        [[DBSession sharedSession] linkFromController:self];
    } else {
        //Dropbox has already been setup
        [self performSegueWithIdentifier:@"showDropboxBrowser" sender:self];
    }
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)downloadedFileFromDropbox:(NSString *)fileName {
    NSLog(@"Loaded File: %@", fileName);
}

//------------------------------------------------------------------------------------------------------------//
//Region: Documents ------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Documents

- (IBAction)clearDocs:(id)sender
{
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
