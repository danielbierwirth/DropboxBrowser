//
//  DropboxRootViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 4/4/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

#import "DropboxDataController.h"
#import "MBProgressHUD.h"

typedef enum {
    DisclosureFileType
    , DisclosureDirType
} DisclosureType;

@protocol DropboxRootViewControllerDelegate;
@interface DropboxRootViewController : UITableViewController <DropboxDataControllerDelegate>

@property (nonatomic, weak) id <DropboxRootViewControllerDelegate> rootViewDelegate;
@property (nonatomic, strong) DropboxDataController *dataController;

//Current File Path and File Name
@property (nonatomic, strong) NSString *currentPath;
+ (NSString*)fileName;

//Busy indicator while loading new directory info
@property (strong, nonatomic) MBProgressHUD *hud;

//Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;

// List content of home directory inside rootview controller
- (BOOL)listHomeDirectory;

@end

@protocol DropboxRootViewControllerDelegate <NSObject>

- (void)loadedFileFromDropbox:(NSString *)fileName;

@end
