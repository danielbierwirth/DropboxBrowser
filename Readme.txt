

Here is a short note about how to integrate the DropboxBrowser:

/**
* Open the dropboxbrowser navigationcontroller view as modal presentation
* Note: Make sure you're referencing the correct interface object using the 'instantiateViewControllerWithIdentifier'

* Note: The browser filters the dropbox content - therefore only directories and pdf-files * will be displayed.
*/
- (void)  showDropboxBrowser {
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"MainStoryboard" bundle:[NSBundle mainBundle]];
        KioskDropboxPDFBrowserViewController *targetController = [storyboard
                                                                  instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
        
        
        targetController.modalPresentationStyle = UIModalPresentationFormSheet;
        targetController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:targetController animated:YES];
        
        targetController.view.superview.frame = CGRectMake(0, 0, 748, 720);
        
        UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
        
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
            targetController.view.superview.center = self.view.center;
        }
        else {
            targetController.view.superview.center = CGPointMake(self.view.center.y, self.view.center.x);
        }
        
        targetController.uiDelegate = self;
        
        // list the dropbox directory
        [targetController listDropboxDirectory];
    }
}

# pragma mark - KioskDropboxPDFBrowserViewControllerUIDelegate functions
- (void) removeDropboxBrowser {
    [self dismissModalViewControllerAnimated:NO];
}

