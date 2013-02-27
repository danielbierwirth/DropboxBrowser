//
//  KioskDropboxPDFRootViewController.m
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 2/24/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "KioskDropboxPDFRootViewController.h"

@interface KioskDropboxPDFRootViewController ()

@end

@interface KioskDropboxPDFRootViewController (hudhelper)
// In case of missing response - remove busiy indicator after certain time interval
- (void)timeout:(id)arg;
@end

@implementation KioskDropboxPDFRootViewController (hudhelper)
- (void)timeout:(id)arg {
    self.hud.labelText = @"Timeout!";
    self.hud.detailsLabelText = @"Please try again later.";
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}
@end


@interface KioskDropboxPDFRootViewController (customdetaildisclosurebuttonhandling)
//Go back to home directory level
- (void) moveToParentDirectory;
// Returned button icon depends on file type
// EX. directory or file
- (UIButton *) makeDetailDisclosureButton:(DisclosureType)disclosureType;
@end

//@implementation KioskDropboxPDFRootViewController (customdetaildisclosurebuttonhandling)
//@end

@interface KioskDropboxPDFRootViewController (tabledatahandling)
- (void) refreshTableView;
@end

@implementation KioskDropboxPDFRootViewController (tabledatahandling)
- (void) refreshTableView {
    [self.tableView reloadData];
}
@end

#pragma mark - Main Implementation

@implementation KioskDropboxPDFRootViewController
static NSString* currentFileName = nil;

#pragma mark - Public Functions

+ (NSString*)fileName {
    return currentFileName;
}

- (BOOL) listHomeDirectory {
    
    // start progress indicator
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Retrieving Data...";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
    
    [self.dataController listHomeDirectory];
    
    return TRUE;
}

#pragma mark  - View Lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Dropbox Browser";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonSystemItemDone target:self action:@selector(moveToParentDirectory)];

    self.navigationItem.leftBarButtonItem = leftButton;
    self.currentPath = @"/";
    
    // add progressview
    UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    newProgressView.frame = CGRectMake(80, 17, 150, 30);
    newProgressView.hidden = TRUE;
    [self.parentViewController.view addSubview:newProgressView];
    
    [self setDownloadProgressView:newProgressView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.dataController.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #warning make sure you're using the correct UITableViewCell identifier including gui items
    static NSString *CellIdentifier = @"KioskDropboxBrowserCell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    
    cell.textLabel.text = file.filename; 
    [cell.textLabel setNeedsDisplay];

    // check for old custom button
    for (int i = 0; i < [cell.subviews count]; i++) {
        UIView* tView = [cell.subviews objectAtIndex:i];
        if (tView.tag == 123456) {
            [tView removeFromSuperview];
            tView = nil;
            break;
        }
    }
    
    // add custom button
    UIButton *customDownloadbutton = nil;
    // if folder
    if ([file isDirectory]) {
        cell.imageView.image = [UIImage imageNamed:@"dropboxDirIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Dir"];
        customDownloadbutton = [self makeDetailDisclosureButton:DisclosureDirType];
    }
    // if pdf doc
    else if (![file.filename hasSuffix:@".exe"]){
        cell.imageView.image = [UIImage imageNamed:@"pdfFileIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"File Size: %@", file.humanReadableSize];   
        customDownloadbutton = [self makeDetailDisclosureButton:DisclosureFileType];
    }
    
    [cell.detailTextLabel setNeedsDisplay];
    
    CGRect tFrame = customDownloadbutton.frame;
    tFrame.origin.x = cell.frame.size.width - (customDownloadbutton.frame.size.width 
                                               + customDownloadbutton.frame.size.width/2)-10;
    tFrame.origin.y = cell.frame.size.height/2 - customDownloadbutton.frame.size.height/2;
    customDownloadbutton.frame = tFrame;
    customDownloadbutton.tag = 123456;
    [cell addSubview:customDownloadbutton];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Table View Accessory Button

- (void) moveToParentDirectory {
    self.currentPath = [NSString stringWithFormat:@"/"];
    [[self dataController] listDirectoryAtPath:self.currentPath];
}

- (UIButton *) makeDetailDisclosureButton:(DisclosureType)disclosureType {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 37, 37);
    
    switch (disclosureType) {
        case DisclosureDirType:
            [button setBackgroundImage:[UIImage imageNamed:@"browseDirectoryIcon.png"] forState:UIControlStateNormal];
            break;
        case DisclosureFileType:
            [button setBackgroundImage:[UIImage imageNamed:@"downloadIcon.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return ( button );
}

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event {
    
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    
    if ([file isDirectory]) {
        // push new tableviewcontroller
        
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        
        self.currentPath = subpath;
        
        // start progress indicator
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Retrieving Data..";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        
        [[self dataController] listDirectoryAtPath:subpath];
    }
    else if (![file.filename hasSuffix:@".exe"]) {
        UITableViewCell *tcell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < [tcell.subviews count]; i++) {
            UIButton* tView = (UIButton*)[tcell.subviews objectAtIndex:i];
            if (tView.tag == 123456) {
                [tView setEnabled:FALSE];
                break;
            }
        }
        
        
        // download file
        [[self dataController] downloadFile:file];
        currentFileName = file.filename;
        
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if ( indexPath == nil )
        return;
    
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    
    if ([file isDirectory]) {
        // push new tableviewcontroller
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        self.currentPath = subpath;
        
        // start progress indicator
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Retrieving Data...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        
        [[self dataController] listDirectoryAtPath:subpath];
    } else if (![file.filename hasSuffix:@".exe"]) {
        UITableViewCell *tcell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < [tcell.subviews count]; i++) {
            UIButton* tView = (UIButton*)[tcell.subviews objectAtIndex:i];
            if (tView.tag == 123456) {
                [tView setEnabled:FALSE];
                break;
            }
        }
        
        // download file
        [[self dataController] downloadFile:file];
        currentFileName = file.filename;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DataController Delegate

- (void) updateTableData;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // code here to populate your data source
    // call refreshTableViewOnMainThread like below:
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
    
}

- (void)downloadedFile {
    [self.downloadProgressView setHidden:TRUE];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Downloaded"
                                                        message:@"The Selected file has been downloaded and added to the documents folder."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];

    [[self rootViewDelegate] loadedFileFromDropbox:currentFileName];
    
}

- (void) startDownloadFile {
    [self.downloadProgressView setHidden:FALSE];
}

- (void) downloadedFileFailed {
    [self.downloadProgressView setHidden:TRUE];
}

- (void) updateDownloadProgressTo:(CGFloat) progress {
    [self.downloadProgressView setProgress:progress];
}

#pragma mark - Synthesize Items
@synthesize dataController;
@synthesize currentPath;
@synthesize rootViewDelegate;
@synthesize hud;
@synthesize downloadProgressView;

@end
