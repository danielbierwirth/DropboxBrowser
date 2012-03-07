//
//  KioskDropboxPDFRootViewController.m
//  epaper
//
//  Created by daniel bierwirth on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KioskDropboxPDFRootViewController.h"

#import "KioskDropboxPDFDataController.h"

#import <DropboxSDK/DropboxSDK.h>

@interface KioskDropboxPDFRootViewController ()
@end

@interface KioskDropboxPDFRootViewController (hudhelper)
/**
 * in case of missing response - remove busiy indicator after certain time intervall
 */
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
/**
 * go back to home directory level
 */
- (void) moveToParentDirectory;
/**
 * returned button icon depends on file type
 * i.e. directory or pdf file
 */
- (UIButton *) makeDetailDisclosureButton:(DisclosureType)disclosureType;
@end

@implementation KioskDropboxPDFRootViewController (customdetaildisclosurebuttonhandling)
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
    else if ([file.filename hasSuffix:@".pdf"]) {
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
        

    }
}

@end

@interface KioskDropboxPDFRootViewController (tabledatahandling)
- (void) refreshTableView;
@end

@implementation KioskDropboxPDFRootViewController (tabledatahandling)
- (void) refreshTableView {
    [self.tableView reloadData];
}
@end

@implementation KioskDropboxPDFRootViewController

#pragma mark - public function
- (BOOL) listHomeDirectory {
    
    // start progress indicator
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Retrieving Data..";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
    
    [self.dataController listHomeDirectory];
    
    return TRUE;
}

# pragma mark  - view lifecycle
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
    
    self.title = @"Dropbox PDF Browser";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonSystemItemDone target:self action:@selector(moveToParentDirectory)];

    self.navigationItem.leftBarButtonItem = leftButton;
    self.currentPath = @"/";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

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
    else if ([file.filename hasSuffix:@".pdf"]){
        cell.imageView.image = [UIImage imageNamed:@"pdfFileIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"PDF, Size: %@", file.humanReadableSize];   
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - datacontroller delegate
- (void) updateTableData;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // code here to populate your data source
    // call refreshTableViewOnMainThread like below:
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
    
}

- (void) downloadedFile {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Done"
                                                        message:@"Your PDF Document was added to your library section."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
    if ([[self rootViewDelegate] respondsToSelector:@selector(loadedFileFromDropbox)])
        [[self rootViewDelegate] loadedFileFromDropbox];
    
}

#pragma mark - synthesize items
@synthesize dataController;
@synthesize currentPath;
@synthesize rootViewDelegate;
@synthesize hud;

@end
