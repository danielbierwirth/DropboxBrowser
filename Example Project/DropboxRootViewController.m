//
//  DropboxRootViewController.m
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 4/4/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DropboxRootViewController.h"

@interface DropboxRootViewController () <DBRestClientDelegate> {
    //Refresh Control
    UIRefreshControl *refreshControl;
    //Back Button
    UIBarButtonItem *leftButton;
}

- (void)timeout:(id)arg;
- (void)refreshTableView;
- (void)moveToParentDirectory;
- (UIButton *)makeDetailDisclosureButton:(DisclosureType)disclosureType;

@end

@implementation DropboxRootViewController
@synthesize dataController, currentPath, rootViewDelegate, hud, downloadProgressView;
static NSString* currentFileName = nil;

//------------------------------------------------------------------------------------------------------------//
//Region: Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Files and Directories

+ (NSString *)fileName
{
    return currentFileName;
}

- (void) moveToParentDirectory
{
    //Go up one directory level
    NSString *filePath = [self.currentPath stringByDeletingLastPathComponent];
    self.currentPath = filePath;
    
    [[self dataController] listDirectoryAtPath:self.currentPath];
    
    if ([self.currentPath isEqualToString:@"/"]) {
        leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonSystemItemDone target:self action:@selector(moveToParentDirectory)];
        self.navigationItem.leftBarButtonItem = nil;
    } else {
        leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone target:self action:@selector(moveToParentDirectory)];
        self.navigationItem.leftBarButtonItem = leftButton;
    }
}

- (BOOL)listHomeDirectory
{
    //Start progress indicator
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Loading Data...";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
    
    [self.dataController listHomeDirectory];
    
    return TRUE;
}

//------------------------------------------------------------------------------------------------------------//
//Region: View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
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
    
    #warning Customize UIRefreshControl, UIProgressView, and UINavigationBar here
    self.title = @"Dropbox";
    self.currentPath = @"/";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //The user is on an iPad
        //Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        newProgressView.frame = CGRectMake(180, 15, 200, 30);
        newProgressView.hidden = TRUE;
        [self.parentViewController.view addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    } else {
        //The user is on an iPhone / iPod Touch
        //Add progressview
        UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        newProgressView.frame = CGRectMake(80, 37, 150, 30);
        newProgressView.hidden = TRUE;
        [self.parentViewController.view addSubview:newProgressView];
        [self setDownloadProgressView:newProgressView];
    }
    
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:38.0/255.0f green:151.0/255.0f blue:227.0/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    //Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    //Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//In case of missing response - remove busy indicator after certain time interval
- (void)timeout:(id)arg {
    self.hud.labelText = @"Timeout!";
    self.hud.detailsLabelText = @"Please try again later.";
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

//------------------------------------------------------------------------------------------------------------//
//Region: Table View Setup -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataController.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    #warning Use the correct UITableViewCell ID in your Storyboard: DropboxBrowserCell
    static NSString *CellIdentifier = @"DropboxBrowserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Configure the cell
    DBMetadata *file = (DBMetadata *)[self.dataController.list objectAtIndex:indexPath.row];
    
    cell.textLabel.text = file.filename; 
    [cell.textLabel setNeedsDisplay];

    //Check for old custom button
    for (int i = 0; i < [cell.subviews count]; i++) {
        UIView* tView = [cell.subviews objectAtIndex:i];
        if (tView.tag == 123456) {
            [tView removeFromSuperview];
            tView = nil;
            break;
        }
    }
    
    //Add custom button
    UIButton *customDownloadbutton = nil;
    if ([file isDirectory]) {
        //Folder
        
        //Setup Last Modified Date
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        
        //NSLog(@"Icon: %@", file.icon);
        
        cell.imageView.image = [UIImage imageNamed:@"dropboxDirIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Folder Modified: %@", [formatter stringFromDate:file.lastModifiedDate]];
        customDownloadbutton = [self makeDetailDisclosureButton:DisclosureDirType];
        
    } else { //if (![file.filename hasSuffix:@".exe"]){
        //File
        //NSLog(@"Icon: %@", file.icon);
        cell.imageView.image = [UIImage imageNamed:@"pdfFileIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"File Size: %@", file.humanReadableSize];
        customDownloadbutton = [self makeDetailDisclosureButton:DisclosureFileType];
    }
    
    [cell.detailTextLabel setNeedsDisplay];
    
    CGRect tFrame = customDownloadbutton.frame;
    tFrame.origin.x = cell.frame.size.width - (customDownloadbutton.frame.size.width + customDownloadbutton.frame.size.width/2)-10;
    tFrame.origin.y = cell.frame.size.height/2 - customDownloadbutton.frame.size.height/2;
    customDownloadbutton.frame = tFrame;
    customDownloadbutton.tag = 123456;
    [cell addSubview:customDownloadbutton];
    
    return cell;
}

- (UIButton *)makeDetailDisclosureButton:(DisclosureType)disclosureType
{
    //Returned button icon depends on file type (ex. directory or file)
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 37, 37);
    
    switch (disclosureType) {
        case DisclosureDirType:
            //Uncomment to show images as the detail disclosure buttons
            //[button setBackgroundImage:[UIImage imageNamed:@"browseDirectoryIcon.png"] forState:UIControlStateNormal];
            break;
        case DisclosureFileType:
            //Uncomment to show images as the detail disclosure buttons
            //[button setBackgroundImage:[UIImage imageNamed:@"downloadIcon.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    [button addTarget: self action: @selector(accessoryButtonTapped:withEvent:) forControlEvents: UIControlEventTouchUpInside];
    
    return (button);
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    //Get the IndexPath
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    if (indexPath == nil)
        return;
    
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    
    if ([file isDirectory]) {
        //Push New TableViewController
        //Show Back Button for a new directory
        leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone target:self action:@selector(moveToParentDirectory)];
        self.navigationItem.leftBarButtonItem = leftButton;
        
        //Get New Path
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        self.currentPath = subpath;
        
        //Start progress indicator
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Loading Data...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        
        [[self dataController] listDirectoryAtPath:subpath];
    } else { //if (![file.filename hasSuffix:@".exe"]) {
        UITableViewCell *tcell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < [tcell.subviews count]; i++) {
            UIButton* tView = (UIButton*)[tcell.subviews objectAtIndex:i];
            if (tView.tag == 123456) {
                [tView setEnabled:FALSE];
                break;
            }
        }
        
        //Download file
        [[self dataController] downloadFile:file];
        currentFileName = file.filename;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (indexPath == nil)
        return;
    
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    
    if ([file isDirectory]) {
        //Show Back Button for a new directory
        leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone target:self action:@selector(moveToParentDirectory)];
        self.navigationItem.leftBarButtonItem = leftButton;
        
        //Push new tableviewcontroller
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        self.currentPath = subpath;
        
        //Start progress indicator
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Loading Data...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        
        [[self dataController] listDirectoryAtPath:subpath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else { //if (![file.filename hasSuffix:@".exe"]) {
        UITableViewCell *tcell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < [tcell.subviews count]; i++) {
            UIButton* tView = (UIButton*)[tcell.subviews objectAtIndex:i];
            if (tView.tag == 123456) {
                [tView setEnabled:FALSE];
                break;
            }
        }
        
        //Download file
        [[self dataController] downloadFile:file];
        currentFileName = file.filename;
    }
}

- (void) refreshTableView
{
    [self.tableView reloadData];
    
    if ([UIRefreshControl class])
        [self.refreshControl endRefreshing];
}

#pragma mark - DataController Delegate

- (void)updateTableData;
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    // code here to populate your data source
    // call refreshTableViewOnMainThread like below:
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
    
}

- (void)downloadedFile
{
    [self.downloadProgressView setHidden:TRUE];
    self.navigationItem.title = @"Dropbox";
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Downloaded"
                                                        message:[NSString stringWithFormat:@"%@ was downloaded to the documents folder.", currentFileName]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];

    [[self rootViewDelegate] loadedFileFromDropbox:currentFileName];
    
}

- (void)startDownloadFile {
    self.navigationItem.title = @"";
    [self.downloadProgressView setHidden:FALSE];
}

- (void)downloadedFileFailed {
    [self.downloadProgressView setHidden:TRUE];
    self.navigationItem.title = @"Dropbox";
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)updateDownloadProgressTo:(CGFloat) progress {
    [self.downloadProgressView setProgress:progress];
}

@end
