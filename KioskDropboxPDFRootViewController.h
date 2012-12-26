//
//  KioskDropboxPDFRootViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 12/26/12
//  Copyright (c) 2012 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KioskDropboxPDFDataController.h"
#import "MBProgressHUD.h"
#import "KioskDropboxPDFDataController.h"
#import <DropboxSDK/DropboxSDK.h>

typedef enum {
    DisclosureFileType
    , DisclosureDirType
} DisclosureType;

@protocol KioskDropboxPDFRootViewControllerDelegate;

@interface KioskDropboxPDFRootViewController : UITableViewController <KioskDropboxPDFDataControllerDelegate>


@property (nonatomic, weak) id <KioskDropboxPDFRootViewControllerDelegate>  rootViewDelegate;
@property (nonatomic, strong) KioskDropboxPDFDataController *dataController;

//  reflect current path
@property (nonatomic, strong) NSString *currentPath;

// display buisy indicator while loading new directory infos
@property (strong, nonatomic) MBProgressHUD *hud;
// download indicator in toolbar to indicate progress of pdf file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;
/**
 * list content of home directory inside rootview controller
 */
- (BOOL) listHomeDirectory;

@end

@protocol KioskDropboxPDFRootViewControllerDelegate <NSObject>

- (void) loadedFileFromDropbox;

@end
