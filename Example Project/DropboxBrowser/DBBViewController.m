//
//  DBBViewController.m
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2012 iRare Media. All rights reserved.
//

#import "DBBViewController.h"

@interface DBBViewController ()
{
    DBRestClient *restClient;
}

@end

@implementation DBBViewController
@synthesize clearDocsBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor underPageBackgroundColor];
    clearDocsBtn.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)browseDropbox:(id)sender
{
    [self didPressLink];
}

- (IBAction)clearDocs:(id)sender
{
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

- (void)didPressLink
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        NSLog(@"Login");
    } else {
        //The session has already been linked
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //The user is on an iPhone - link the correct storyboard below
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
            KioskDropboxPDFBrowserViewController *targetController = [storyboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
        
            targetController.modalPresentationStyle = UIModalPresentationFormSheet;
            targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:targetController animated:YES completion:nil];
        
            targetController.view.superview.frame = CGRectMake(0, 0, 320, 480);
            UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
        
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
                targetController.view.superview.center = self.view.center;
            } else {
                targetController.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
            }
        
            targetController.uiDelegate = self;
            // List the Dropbox Directory
            [targetController listDropboxDirectory];
        } else {
            //The user is on an iPhone - link the correct storyboard below
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:[NSBundle mainBundle]];
            KioskDropboxPDFBrowserViewController *targetController = [storyboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
            
            targetController.modalPresentationStyle = UIModalPresentationFormSheet;
            targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:targetController animated:YES completion:nil];
            
            //targetController.view.superview.frame = CGRectMake(0, 0, 748, 720);
            UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
            
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
                targetController.view.superview.center = self.view.center;
            } else {
                targetController.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
            }
            
            targetController.uiDelegate = self;
            // List the Dropbox Directory
            [targetController listDropboxDirectory];
        }
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
    NSLog(@"Final Filename: %@", [KioskDropboxPDFRootViewController fileName]);
}

- (void)viewDidUnload {
    [self setClearDocsBtn:nil];
    [super viewDidUnload];
}
@end
