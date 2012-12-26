//
//  DBBViewController.h
//  DropboxBrowser
//
//  Created by The Spencer Family on 12/26/12.
//  Copyright (c) 2012 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KioskDropboxPDFBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/ALAsset.h>

@interface DBBViewController : UIViewController <KioskDropboxPDFBrowserViewControllerUIDelegate, DBRestClientDelegate,UINavigationControllerDelegate>

- (IBAction)browseDropbox:(id)sender;

@end
