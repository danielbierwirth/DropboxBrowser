//
//  DBBViewController.h
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/ALAsset.h>

@interface DBBViewController : UIViewController <DropboxBrowserDelegate, DBRestClientDelegate, UINavigationControllerDelegate>

- (IBAction)browseDropbox:(id)sender;
- (IBAction)clearDocs:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *clearDocsBtn;

@end
