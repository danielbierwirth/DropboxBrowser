# Dropbox Browser
A simple and effective way to browse, view, and download files using the iOS Dropbox SDK.

##Integration
Here is a short note about how to integrate the DropboxBrowser  
1. Open the dropboxbrowser navigationcontroller view as modal presentation  
2. Make sure you're referencing the correct interface object using the 'instantiateViewControllerWithIdentifier'

    - (void)  showDropboxBrowser {
        if (![[DBSession sharedSession] isLinked]) {
        //The Session has not yet been linked
            [[DBSession sharedSession] link];
        } else {
        //The session has already been linked
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        KioskDropboxPDFBrowserViewController *targetController = [storyboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
        
        targetController.modalPresentationStyle = UIModalPresentationFormSheet;
        targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:targetController animated:YES];
        
        targetController.view.superview.frame = CGRectMake(0, 0, 748, 720);
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

## KioskDropbox Delegate Functions

    - (void) removeDropboxBrowser {
        [self dismissModalViewControllerAnimated:NO];
    }

## Further Information

This project is a work in project, check back for updates, etc.

## Screenshots (Updated UI Coming Soon)

<img width=600 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/sampleImage.png?raw=true"/>
