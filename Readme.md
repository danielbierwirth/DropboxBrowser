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
2. Add the DropboxSDK Framework to your project. The latest version of the SDK can be downloaded here: https://www.dropbox.com/developers | The sample project currently uses version 1.3.3 of the Dropbox SDK  
3. Register as a developer on Dropbox and setup your App. If you've already done this, skip this step. If you haven't done this, please follow this link to get setup: https://www.dropbox.com/developers/start/setup#ios  
4. Setup and add the required methods used by Dropbox for authenticating. This includes customizing your Info.plist file and your App Delegate. Instructions from Dropbox are available here: https://www.dropbox.com/developers/start/authentication#ios  
5. Create an IBAction that will call the `didPressLink` method, then connect that IBAction to a button that will allow users to browse their Dropbox folder.  
6. Add all of the DropboxBrowser files to Xcode
	- `KioskDropboxPDFBrowserViewController`
	- `KioskDropboxPDFDataController`
	- `KioskDropboxPDFRootViewController`
	- Make sure to also include the `Icons` folder and the `Utilities` folder along with the others
7. In your ViewController's header file, add the following `#import` statement: `#import "KioskDropboxPDFBrowserViewController.h"`. Also add the following delegate: `KioskDropboxPDFBrowserViewControllerUIDelegate`.
8. In your Implementation File (.m) find the `didPressLink` method and substitute all current code inside with the following code:

        - (void)didPressLink {
            //Check if Dropbox is Setup
            if (![[DBSession sharedSession] isLinked]) {
                    //Dropbox is not setup
                    [[DBSession sharedSession] linkFromController:self];
                    NSLog(@"Logging into Dropbox...");
            } else {
                    //Dropbox has already been setup
                    //Setup KioskDropboxPDFBrowserViewController
                    KioskDropboxPDFBrowserViewController *browser = [[KioskDropboxPDFBrowserViewController alloc] init];
                    [browser setDelegate:self];
        
                   //Setup Storyboard. If you aren't using iPad, set the iPad Storyboard the same as the iPhone Storyboard. If you have an iPad-only project, set the iPhone Storyboard as NIL.
                   UIStoryboard *iPhoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
                   UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:[NSBundle mainBundle]];
        
                  //Present Dropbox Browser. The following method requires you to set a storyboard to use, a view controller to present the DropboxBrowser on, modal presentation and transition styles, and a delegate which you set above.
                 [KioskDropboxPDFBrowserViewController displayDropboxBrowserInPhoneStoryboard:iPhoneStoryboard displayDropboxBrowserInPadStoryboard:iPadStoryboard onView:self  withPresentationStyle:UIModalPresentationFormSheet withTransitionStyle:UIModalTransitionStyleFlipHorizontal withDelegate:self];    } }

9. Next, Implement the following delegate functions to handle the dismissal of the Dropbox Browser:

         - (void)removeDropboxBrowser {
             //This is where you can handle the cancellation of selection, ect.
             [self dismissViewControllerAnimated:YES completion:nil];
         }  
Please refer to the **Delegates & Results** section of this document to learn more about different delegate methods and what they do.  
10. The next step is to edit the required interface files. In your storyboard, add the following UI Objects from the Objects Library:
    - Navigation Controller  
11.  Click on the root of the navigation controller you just added. Change its class to `KioskDropboxPDFBrowserViewController` using the Identity Inspector. Change the Storyboard ID to `KioskDropboxPDFBrowserViewControllerID` and then check the "Use Storyboard ID" checkbox
12. Select the Table View Controller just added along with the Navigation Controller and change the class to `KioskDropboxPDFRootViewController` using the Identity Inspector.
13. Click on the first cell of the Table View and change its identifier to `KioskDropboxBrowserCell`

If you have completed everything properly, when the user clicks on the button connected to the `didPressLink` method, the navigation controller will present itself modally over the current view controller. Please refer to the sample project included.

## Delegates & Results
There are two delegate methods available with DropboxBrowser, both of which provide a way to know when the user performs one out of two possible actions. The first action that the user can perform is the cancellation of any file selection. This can be done simply by pressing the 'Cancel' button in the top right corner of the DropboxBrowser. The following *required* method is called when the user presses 'Cancel':

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

## Change Log
This project is now ready for primetime use in any iOS application. Just follow the steps above to integrate Dropbox Browser. Here are a few key changes in the project:

**Version 2.3**: Condenses presentation of DropboxBrowser to four lines (compared to a previous 40+ lines of code) using one simple method  
**Version 2.2**: Dropbox Browser now fits all screen sizes using Autosizing instead of defined sizes - in other words, iPhone 5 compatibility  
**Version 2.1**: Updated Documentation, New Methods, Improved Selection  
**Version 2.0**: Added Sample Project, iOS 6 Support, ARC Support, New Documentation, Improved ReadMe, Improved UI, and more
**Version 1.2**: Added Download Indicator
**Version 1.1**: Added Sync Functionality
**Version 1.0**: Initial Commit
