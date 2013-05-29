//
//  DropboxCustomeBrowserController.h
//  DropboxBrowser
//
//  Created by iRare Media on 4/7/13.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
//#import <iRareMedia/iRareMedia.h>

#import "MBProgressHUD.h"

@class DBRestClient;
@class DBMetadata;
@protocol DropboxCustomControllerDelegate;

@interface DropboxCustomBrowserController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    DBRestClient *restClient;
}

@property (nonatomic, copy, readwrite) NSMutableArray *list;
@property (nonatomic, weak) id <DropboxCustomControllerDelegate> customViewDelegate;

//Current File Path and File Name
@property (nonatomic, strong) NSString *currentPath;
+ (NSString*)fileName;

//Busy indicator while loading new directory info
@property (strong, nonatomic) MBProgressHUD *hud;

//Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressView;

//Navigation Bar
@property (weak, nonatomic) IBOutlet UILabel *navigationBar;

//Download indicator in toolbar to indicate progress of file download
@property (strong, nonatomic) IBOutlet UIButton *backButton;

//Timeout HUD
- (void)timeout:(id)arg;

//Refresh content
- (void)refreshTableView;

//Move up one directory
- (IBAction)moveToParentDirectory;

//List content of specific subdirectories
- (BOOL)listDirectoryAtPath:(NSString*)path;

//Check if app is linked to dropbox
- (BOOL)isDropboxLinked;

//Called on download button press - see root controller
- (BOOL)downloadFile:(DBMetadata *)file;
@end

@protocol DropboxCustomControllerDelegate <NSObject>

- (void)loadedFileFromDropbox:(NSString *)fileName;

@end