//
//  DBBViewController.h
//  DropboxBrowser
//
//  Created by iRare Media on 12/26/12.
//  Copyright (c) 2014 iRare Media. All rights reserved.
//

@import UIKit;

#import "ODBTableViewController.h"

@interface DBBViewController : UIViewController <ODBTableViewControllerDelegate, ODBoxDelegate, UINavigationControllerDelegate, UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate>

- (IBAction)resetFiles:(id)sender;
- (IBAction)toggleAccountAccess:(id)sender;
- (IBAction)checkAppStatus:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *resetFilesButton;
@property (weak, nonatomic) IBOutlet UITableView *localFiles;
@property (weak, nonatomic) IBOutlet UIButton *accountStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *appStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *bylineLabe;

@end
