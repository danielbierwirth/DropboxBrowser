# Dropbox Browser
Dropbox Browser provides a simple and effective way to browse, view, and download files using the iOS Dropbox SDK. Add the required files to your Xcode iOS project, setup Dropbox, add one simple method and a navigation controller and now you've got a simple TableView that lets users browse their files and folder, and even download them.

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
6. Add all of the DropboxBrowser files to Xcode
	- `KioskDropboxPDFBrowserViewController`
	- `KioskDropboxPDFDataController`
	- `KioskDropboxPDFRootViewController`
	- Make sure to also include the `Icons` folder and the `Utilities` folder along with the others
7. In your ViewController's header file, add the following `#import` statement: `#import "KioskDropboxPDFBrowserViewController.h"`. Also add the following delegate: `KioskDropboxPDFBrowserViewControllerUIDelegate`.
8. In your Implementation File (.m) find the `didPressLink` method and substitute all current code inside with the following code (we're working on a one line method to do this for you):

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

9. Next, Implement the following delegate functions to handle the dismissal of the Dropbox Browser:

         - (void)removeDropboxBrowser {
             //This is where you can handle the cancellation of selection, ect.
             [self dismissViewControllerAnimated:YES completion:nil];
         }  
Please refer to the **Delegates & Results** section of this document to learn more about different delegate methods and what they do.  
10. The next step is to edit the required interface files. In your storyboard, add the following UI Objects from the Objects Library:
    - Navigation Controller  
11.  Click on the root of the navigation controller you just added. Change its class to `KioskDropboxPDFBrowserViewController` using the Identity Inspector. Change the Storyboard ID to `KioskDropboxPDFBrowserViewControllerID` and then check the "Use Storyboard ID" checkbox
12. Select the Table View Controller just added along with the Navigation Controller and change the class to `KioskDropboxPDFRootViewController` using the Indentity Inspector.
13. Click on the first cell of the Table View and change its identifier to `KioskDropboxBrowserCell`

If you have completed everything properly, when the user clicks on the button connected to the `didPressLink` method, the navigation controller will present itself modally over the current view controller. Please refer to the sample project included.

## Delegates & Results
There are two delegate methods available with DropboxBrowser, both of which provide a way to know when the user performs one out of two possible actions. The first action that the user can perfrom is the cancellation of any file selection. This can be done simply by pressing the 'Cancel' button in the top right corner of the DropboxBrowser. The following *required* method is called when the user presses 'Cancel':

    - (void)removeDropboxBrowser {
         //This is where you can handle the cancellation of selection, ect.
     }  
  
This method is *required* and should be used to dismiss the DropboxBrowser by using the `dismissViewControllerAnimated` method. The next delegate method is the response to the second action the user can take- downloading a file. Files from DropboxBrowser are **always** downloaded to your **application's Documents Directory**. This method is *optional* and is triggered after a file is downloaded:

    - (void)refreshLibrarySection {
        //This is where you can update your UI or dismiss the DropboxBrowser when the user downloads a file.
    }

The next function allows you to retrieve the file name of the last file selected. Simply call this function:

        NSString *fileName = [KioskDropboxPDFRootViewController fileName];
  
This function returns an NSString and can best be utilized in the `refreshLibrarySection` method.
    
## Screenshots
DropboxBrowser now comes with a redesigned UI that can easily be customized simply by swapping PNG files of the same size with the same naming conventions. The default and only skin / theme is the Glyph Icon theme which has been Retina-display optimized. A quick preview of what the UI looks like can be seen below. You can use TableView prototype cells to customize the TableView appearance.

<img width=750 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/Screenshot.png?raw=true"/>

## Further Information
This project is a work in progress, check back soon for updates and more information. We plan on submitting a pull request to the original project soon.
