# Dropbox Browser
A simple and effective way to browse, view, and download files using the iOS Dropbox SDK.

##Integration
To properly integrate DropboxBrowser into your project, please follow the instructions below. Please use the included Sample Project (inside of the "Example" folder) as a guide. 
 
1. Add the following Frameworks already available in Xcode to your project:  
    - Security  
    - QuartzCore  
    - AssetsLibrary  
    - UIKit  
    - Foundation  
    - CoreGraphics  
2. Add the DropboxSDK Framework to your project. The latest version of the SDK can be downloaded here: https://www.dropbox.com/developers Please note that the sample project surrently uses version 1.3.2 of the Dropbox SDK  
3. Register as a developer on Dropbox and setup your App. If you've already done this, skip this step. If you haven't done this, please follow this link to get setup: https://www.dropbox.com/developers/start/setup#ios  
4. Setup and add the required methods used by Dropbox for authenticating. This includes customizing your Info.plist file and your App Delegate. Instructions from Dropbox are available here: https://www.dropbox.com/developers/start/authentication#ios  
5. Create an IBAction that will call the `didPressLink` method, then connect that IBAction to a button that will allow users to browse their Dropbox folder.  
6. In your ViewController's header file, add the following `#import` statement: `#import "KioskDropboxPDFBrowserViewController.h"`. Also add the following delegate: `KioskDropboxPDFBrowserViewControllerUIDelegate`.
7. In your Implementation File (.m) find the `didPressLink` method and substitute all current code inside with the following code (we're working on a one line method to do this for you):

        -(void)didPressLink {
         if (![[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
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
        }}}

8. Next, Implement the following delegate functions to handle the dismissal of the Dropbox Browser:

         - (void)removeDropboxBrowser {
             //This is where you can handle the cancellation of selection, ect.
             [self dismissViewControllerAnimated:YES completion:nil];
         }
9. The next step is to edit the required interface files. In your storyboard, add the following UI Objects from the Objects Library:
    - Navigation Controller  
10.  Click on the root of the navigation controller you just added. Change its class to `KioskDropboxPDFBrowserViewController` using the Identity Inspector. Change the Storyboard ID to `KioskDropboxPDFBrowserViewControllerID` and then check the "Use Storyboard ID" checkbox
11. Select the Table View Controller just added along with the Navigation Controller and change the class to `KioskDropboxPDFRootViewController` using the Indentity Inspector.
12. Click on the first cell of the Table View and change its identifier to `KioskDropboxBrowserCell`

If you have completed everything properly, when the user clicks on the button connected to the `didPressLink` method, the navigation controller will present itself modally over the current view controller. Please refer to the sample project included.

## Further Information

This project is a work in progress, check back soon for updates, etc.

## Screenshots (Updated UI Coming Soon)

<img width=600 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/sampleImage.png?raw=true"/>
