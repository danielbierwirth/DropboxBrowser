//
//  DropboxBrowserViewController.m
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 4/4/13
//  Many Major contributions made by iRare Media: http://www,github.com/iraremedia
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DropboxBrowserViewController.h"

@interface DropboxBrowserViewController () <DropboxRootViewControllerDelegate>

- (void)removeDropboxBrowser;

@end

@implementation DropboxBrowserViewController
@synthesize uiDelegate;
@synthesize rootViewController;
@synthesize dataController;

//------------------------------------------------------------------------------------------------------------//
//Region: View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//Do any additional setup after loading the view, typically from a nib.
    
    //Setup Navigation Bar color
    self.topViewController.navigationController.navigationBar.tintColor = [UIColor colorWithRed:38.0/255.0f green:151.0/255.0f blue:227.0/255.0f alpha:1.0f];
    
    //Set Bar Button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(removeDropboxBrowser)];
    self.topViewController.navigationItem.rightBarButtonItem = rightButton;
    
    DropboxRootViewController *tController = (DropboxRootViewController *)[[self viewControllers]objectAtIndex:0];
    self.rootViewController = tController;
    self.rootViewController.rootViewDelegate = self;
    
    DropboxDataController *controller = [[DropboxDataController alloc] init];
    self.dataController = controller;
    
    self.rootViewController.dataController = self.dataController;
    self.dataController.dataDelegate = self.rootViewController;
    
}

//------------------------------------------------------------------------------------------------------------//
//Region: Setup ----------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Setup

+ (void)displayDropboxBrowserInPhoneStoryboard:(UIStoryboard *)iPhoneStoryboard displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard onView:(UIViewController *)viewController withPresentationStyle:(UIModalPresentationStyle)presentationStyle withTransitionStyle:(UIModalTransitionStyle)transitionStyle withDelegate:(id<DropboxBrowserDelegate>)delegate
{
    //The session has already been linked
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //The user is on an iPhone - link the correct storyboard below
        DropboxBrowserViewController *targetController = [iPhoneStoryboard instantiateViewControllerWithIdentifier:@"DropboxBrowserID"];
        
        targetController.modalPresentationStyle = presentationStyle;
        targetController.modalTransitionStyle = transitionStyle;
        [viewController presentViewController:targetController animated:YES completion:nil];
        
        targetController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UIInterfaceOrientation interfaceOrientation = viewController.interfaceOrientation;
        
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
            targetController.view.superview.center = viewController.view.center;
        } else {
            targetController.view.superview.center = CGPointMake(viewController.view.center.y, viewController.view.center.x);
        }
        
        targetController.uiDelegate = delegate;
        
        //List the Dropbox Directory
        [targetController listDropboxDirectory];
        
    } else {
        //The user is on an iPad - link the correct storyboard below
        DropboxBrowserViewController *targetController = [iPadStoryboard instantiateViewControllerWithIdentifier:@"DropboxBrowserID"];
        
        targetController.modalPresentationStyle = presentationStyle;
        targetController.modalTransitionStyle = transitionStyle;
        [viewController presentViewController:targetController animated:YES completion:nil];
        
        UIInterfaceOrientation interfaceOrientation = viewController.interfaceOrientation;
        
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
            targetController.view.superview.center = viewController.view.center;
        } else {
            targetController.view.superview.center = CGPointMake(viewController.view.center.y, viewController.view.center.x);
        }
        
        targetController.uiDelegate = delegate;
        
        //List the Dropbox Directory
        [targetController listDropboxDirectory];
    }

}

//------------------------------------------------------------------------------------------------------------//
//Region: Dropbox Functions ----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox Functions

- (void)listDropboxDirectory
{
    if (![self.dataController isDropboxLinked]) {
        //Raise alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"This application is not linked to your Dropbox account."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        [self.rootViewController listHomeDirectory];
    }
    
    
}

- (void)removeDropboxBrowser {
    //User tapped 'Done' button, tell delegate to remove modal view
    if ([[self uiDelegate] respondsToSelector:@selector(removeDropboxBrowser)])
        [[self uiDelegate] removeDropboxBrowser];
}

- (void)loadedFileFromDropbox:(NSString *)fileName
{
    [[self uiDelegate] refreshLibrarySection];
}

@end
