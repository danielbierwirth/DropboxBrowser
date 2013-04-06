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
@synthesize clearDocsBtn;

//------------------------------------------------------------------------------------------------------------//
//Region: View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor underPageBackgroundColor];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    clearDocsBtn.hidden = NO;
    [super viewWillAppear:YES];
}

- (void)viewDidUnload {
    [self setClearDocsBtn:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------------------------//
//Region: Dropbox --------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox

- (IBAction)browseDropbox:(id)sender
{
    [self didPressLink];
}

- (void)didPressLink
{
    //Check if Dropbox is Setup
    if (![[DBSession sharedSession] isLinked]) {
        //Dropbox is not setup
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Logging into Dropbox...");
    } else {
        //Dropbox has already been setup
        
        //Setup DropboxBrowserViewController
        DropboxBrowserViewController *browser = [[DropboxBrowserViewController alloc] init];
        [browser setDelegate:self];
        
        //Setup Storyboard. If you aren't using iPad, set the iPad Storyboard the same as the iPhone Storyboard. If you have an iPad-only project, set the iPhone Storyboard as NIL.
        UIStoryboard *iPhoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:[NSBundle mainBundle]];
        
        //Present Dropbox Browser
        [DropboxBrowserViewController displayDropboxBrowserInPhoneStoryboard:iPhoneStoryboard
                                                displayDropboxBrowserInPadStoryboard:iPadStoryboard
                                                                              onView:self
                                                               withPresentationStyle:UIModalPresentationFormSheet
                                                                 withTransitionStyle:UIModalTransitionStyleFlipHorizontal
                                                                        withDelegate:self];
    }
}

- (DBRestClient *)restClient
{
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)removeDropboxBrowser
{
    //This is where you can handle the cancellation of selection, ect.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshLibrarySection
{
    NSLog(@"Final Filename: %@", [DropboxRootViewController fileName]);
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
