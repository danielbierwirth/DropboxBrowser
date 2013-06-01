//
//  DropboxCustomeBrowserController.m
//  DropboxBrowser
//
//  Created by iRare Media on 4/7/13.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DropboxCustomBrowserController.h"

@interface DropboxCustomBrowserController () <DBRestClientDelegate> {
    UIRefreshControl *refreshControl;
}

- (DBRestClient *)restClient;

@end

@implementation DropboxCustomBrowserController
@synthesize backButton, downloadProgressView, tableView, navigationBar;
@synthesize hud, currentPath;
@synthesize customViewDelegate, list;
static NSString* currentFileName = nil;

//------------------------------------------------------------------------------------------------------------//
//Region: Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Files and Directories

+ (NSString *)fileName
{
    return currentFileName;
}

- (IBAction)moveToParentDirectory
{
    if ([self.currentPath isEqualToString:@"/"]) {
        NSLog(@"Current Path: %@", self.currentPath);
        if ([self navigationController]) {
            [[self navigationController] popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        backButton.hidden = NO;
    }
    
    //Go up one directory level
    NSString *filePath = [self.currentPath stringByDeletingLastPathComponent];
    self.currentPath = filePath;
    
    [self listDirectoryAtPath:self.currentPath];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *imageShade = [defaults objectForKey:@"buttonColor"];
    if (imageShade != nil)
        backButton.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ArrowBack-%@", imageShade]];
}
//------------------------------------------------------------------------------------------------------------//
//Region: View Lifecycle -------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark  - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup TableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Customize UIRefreshControl, UIProgressView, and UINavigationBar here
    navigationBar.text = @"Dropbox";
    self.currentPath = @"/";
    
    //Hide the Progress Bar
    downloadProgressView.hidden = TRUE;
    [self setDownloadProgressView:downloadProgressView];
    
    //Create Reload Control
    if ([UIRefreshControl class]) {
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:65.0/255.0f green:68.0/255.0f blue:70.0/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![self isDropboxLinked]) {
        //Raise alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Cypher Bot is not linked to your Dropbox account."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        //Start progress indicator
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Loading Data...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        
        [self listHomeDirectory];
        [self refreshTableView];
    }
    
    //Setup Theme
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *colorData = [defaults objectForKey:@"backgroundColor"];
    NSString *imageShade = [defaults objectForKey:@"buttonColor"];
    if (colorData != nil) {
        UIColor *backColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
        
        tableView.backgroundColor = backColor;
        self.view.backgroundColor = backColor;
        navigationBar.backgroundColor = backColor;
        
        backButton.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ArrowBack-%@", imageShade]];
        
        if ([imageShade isEqualToString:@"White"]) {
            navigationBar.textColor = [UIColor whiteColor];
            tableView.separatorColor = [UIColor whiteColor];
            refreshControl.tintColor = [UIColor lightGrayColor];
            downloadProgressView.trackTintColor = [UIColor lightGrayColor];
            downloadProgressView.progressTintColor = [UIColor colorWithRed:240.0/255.0f green:239.0/255.0f blue:235.0/255.0f alpha:1.0f];
        } else {
            navigationBar.textColor = [UIColor blackColor];
            tableView.separatorColor = [UIColor darkGrayColor];
            refreshControl.tintColor = [UIColor darkGrayColor];
            downloadProgressView.progressTintColor = [UIColor colorWithRed:240.0/255.0f green:239.0/255.0f blue:235.0/255.0f alpha:1.0f];
            downloadProgressView.trackTintColor = [UIColor colorWithRed:94.0/255.0f green:94.0/255.0f blue:94.0/255.0f alpha:1.0f];
        }
    } else {
        
    }
    
    //Add Shadows and Rounded Corners
    CGSize size = CGSizeMake(-1, 1);
    [Animation roundView:navigationBar withCornerRadius:3 shouldMaskToBounds:NO shouldRasterize:NO];
    [Animation shadeView:navigationBar withShadowOffset:&size withShadowRadius:3 withShadowOpacity:0.3 shouldRasterize:YES];
    
}

- (void)timeout:(id)arg
{
    //In case of missing response - remove busy indicator after certain time interval
    self.hud.labelText = @"Timeout!";
    self.hud.detailsLabelText = @"Please try again later.";
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:3.0];
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
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //#warning Use the correct UITableViewCell ID in your Storyboard: DropboxBrowserCell
    static NSString *CellIdentifier = @"DropboxBrowserCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Configure the cell
    DBMetadata *file = (DBMetadata *)[self.list objectAtIndex:indexPath.row];
    
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
    
    //Setup Theme
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *imageShade = [defaults objectForKey:@"buttonColor"];
    if (imageShade != nil) {
        if ([imageShade isEqualToString:@"White"]) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor lightTextColor];
        } else {
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
    } else {
        
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
        
        if (imageShade != nil) {
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Files-%@", imageShade]];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"Files-Dark"];
        }

        cell.detailTextLabel.text = [NSString stringWithFormat:@"Folder Modified: %@", [formatter stringFromDate:file.lastModifiedDate]];
        
    } else { //if (![file.filename hasSuffix:@".exe"]){
        //File
        NSString *cellData = file.filename;
        
        if (imageShade != nil) {
            //Setup Cell Icon
            if ([cellData hasSuffix:@"txt"] || [cellData hasSuffix:@"rtf"] || [cellData hasSuffix:@"md"] || [cellData hasSuffix:@"markdown"] || [cellData hasSuffix:@"pdf"] || [cellData hasSuffix:@"doc"] || [cellData hasSuffix:@"docx"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"File-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"ics"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileCal-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"vcf"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileAddress-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"dat"] || [cellData hasSuffix:@"xml"] || [cellData hasSuffix:@"log"] || [cellData hasSuffix:@"tex"] || [cellData hasSuffix:@"cypher"] || [cellData hasSuffix:@"db"] || [cellData hasSuffix:@"xls"] || [cellData hasSuffix:@"xlsx"] || [cellData hasSuffix:@"csv"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileData-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"pptx"] || [cellData hasSuffix:@"ppt"] || [cellData hasSuffix:@"pps"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FilePresentation-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"jpeg"] || [cellData hasSuffix:@"jpg"] || [cellData hasSuffix:@"gif"] || [cellData hasSuffix:@"png"] || [cellData hasSuffix:@"bmp"] || [cellData hasSuffix:@"psd"] || [cellData hasSuffix:@"tif"] || [cellData hasSuffix:@"tiff"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileImage-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"aif"] || [cellData hasSuffix:@"aac"] || [cellData hasSuffix:@"iff"] || [cellData hasSuffix:@"m3u"] || [cellData hasSuffix:@"m4a"] || [cellData hasSuffix:@"mid"] || [cellData hasSuffix:@"mp3"] || [cellData hasSuffix:@"mp4"] || [cellData hasSuffix:@"mpa"] || [cellData hasSuffix:@"ra"] || [cellData hasSuffix:@"wav"] || [cellData hasSuffix:@"wma"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileMusic-%@", imageShade]];
            }
            if ([cellData hasSuffix:@"avi"] || [cellData hasSuffix:@"flv"] || [cellData hasSuffix:@"mov"] || [cellData hasSuffix:@"mp4"] || [cellData hasSuffix:@"mpg"] || [cellData hasSuffix:@"rm"] || [cellData hasSuffix:@"wmv"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileVideo-%@", imageShade]];
            }
            if ([cellData isEqualToString:@"Passwords.txt"] || [cellData isEqualToString:@"Login Credentials.txt"] || [cellData isEqualToString:@"Login.txt"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FilePassword-%@", imageShade]];
            }
            if ([cellData isEqualToString:@"Finances.txt"] || [cellData isEqualToString:@"Money Management.txt"] || [cellData isEqualToString:@"Money.txt"]) {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"FileMoney-%@", imageShade]];
            }
        } else {
            //Setup Cell Icon
            if ([cellData hasSuffix:@"txt"] || [cellData hasSuffix:@"rtf"] || [cellData hasSuffix:@"md"] || [cellData hasSuffix:@"markdown"] || [cellData hasSuffix:@"pdf"] || [cellData hasSuffix:@"doc"] || [cellData hasSuffix:@"docx"]) {
                cell.imageView.image = [UIImage imageNamed:@"File-Dark"];
            }
            if ([cellData hasSuffix:@"ics"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileCal-Dark"];
            }
            if ([cellData hasSuffix:@"vcf"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileAddress-Dark"];
            }
            if ([cellData hasSuffix:@"dat"] || [cellData hasSuffix:@"xml"] || [cellData hasSuffix:@"log"] || [cellData hasSuffix:@"tex"] || [cellData hasSuffix:@"cypher"] || [cellData hasSuffix:@"db"] || [cellData hasSuffix:@"xls"] || [cellData hasSuffix:@"xlsx"] || [cellData hasSuffix:@"csv"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileData-Dark"];
            }
            if ([cellData hasSuffix:@"pptx"] || [cellData hasSuffix:@"ppt"] || [cellData hasSuffix:@"pps"]) {
                cell.imageView.image = [UIImage imageNamed:@"FilePresentation-Dark"];
            }
            if ([cellData hasSuffix:@"jpeg"] || [cellData hasSuffix:@"jpg"] || [cellData hasSuffix:@"gif"] || [cellData hasSuffix:@"png"] || [cellData hasSuffix:@"bmp"] || [cellData hasSuffix:@"psd"] || [cellData hasSuffix:@"tif"] || [cellData hasSuffix:@"tiff"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileImage-Dark"];
            }
            if ([cellData hasSuffix:@"aif"] || [cellData hasSuffix:@"aac"] || [cellData hasSuffix:@"iff"] || [cellData hasSuffix:@"m3u"] || [cellData hasSuffix:@"m4a"] || [cellData hasSuffix:@"mid"] || [cellData hasSuffix:@"mp3"] || [cellData hasSuffix:@"mp4"] || [cellData hasSuffix:@"mpa"] || [cellData hasSuffix:@"ra"] || [cellData hasSuffix:@"wav"] || [cellData hasSuffix:@"wma"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileMusic-Dark"];
            }
            if ([cellData hasSuffix:@"avi"] || [cellData hasSuffix:@"flv"] || [cellData hasSuffix:@"mov"] || [cellData hasSuffix:@"mp4"] || [cellData hasSuffix:@"mpg"] || [cellData hasSuffix:@"rm"] || [cellData hasSuffix:@"wmv"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileVideo-Dark"];
            }
            if ([cellData isEqualToString:@"Passwords.txt"] || [cellData isEqualToString:@"Login Credentials.txt"] || [cellData isEqualToString:@"Login.txt"]) {
                cell.imageView.image = [UIImage imageNamed:@"FilePassword-Dark"];
            }
            if ([cellData isEqualToString:@"Finances.txt"] || [cellData isEqualToString:@"Money Management.txt"] || [cellData isEqualToString:@"Money.txt"]) {
                cell.imageView.image = [UIImage imageNamed:@"FileMoney-Dark"];
            }
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"File Size: %@", file.humanReadableSize];
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
    
    DBMetadata *file = (DBMetadata*)[self.list objectAtIndex:indexPath.row];
    
    if ([file isDirectory]) {
        //Show Back Button for a new directory
        backButton.hidden = NO;
        
        //Push new tableviewcontroller
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        self.currentPath = subpath;
        
        //Start progress indicator
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Loading Data...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        
        [self listDirectoryAtPath:subpath];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [self downloadFile:file];
        currentFileName = file.filename;
    }
}

- (void)refreshTableView
{
    [self.tableView reloadData];
    
    if ([UIRefreshControl class])
        [refreshControl endRefreshing];
}

- (void)dismissHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - DataController Delegate

- (void)updateTableData
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //Code here to populate your data source
    //Call refreshTableViewOnMainThread like below:
    [self refreshTableView];
    [self.tableView reloadData];
}

- (void)downloadedFile
{
    [self.downloadProgressView setHidden:TRUE];
    self.navigationBar.text = @"Dropbox";
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Downloaded"
                                                        message:[NSString stringWithFormat:@"%@ was downloaded to the documents folder.", currentFileName]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    
    [[self customViewDelegate] loadedFileFromDropbox:currentFileName];
}

- (void)startDownloadFile {
    self.navigationBar.text = @"";
    [self.downloadProgressView setHidden:FALSE];
}

- (void)downloadedFileFailed {
    [self.downloadProgressView setHidden:TRUE];
    self.navigationBar.text = @"Dropbox";
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)updateDownloadProgressTo:(CGFloat) progress {
    [self.downloadProgressView setProgress:progress];
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        list = [newList mutableCopy];
    }
}

//------------------------------------------------------------------------------------------------------------//
//Region: Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox File and Directory Functions

- (BOOL)listDirectoryAtPath:(NSString *)path
{
    if ([self isDropboxLinked]) {
        [[self restClient] loadMetadata:path];
        return TRUE;
    } else {
        return FALSE;
    }
}
- (BOOL)listHomeDirectory
{
    return [self listDirectoryAtPath:@"/"];
}

- (BOOL)isDropboxLinked
{
    return [[DBSession sharedSession] isLinked];
}

- (BOOL)downloadFile:(DBMetadata *)file {
    
    BOOL res = FALSE;
    
    if (!file.isDirectory) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *localPath = [documentsPath stringByAppendingPathComponent:file.filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            [self startDownloadFile];
            res = TRUE;
            [[self restClient] loadFile:file.path intoPath:localPath];
        } else {
            NSURL *fileUrl = [NSURL URLWithString:localPath];
            NSDate *fileDate;
            NSError *error;
            [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
            if (!error) {
                //#warning Handle any file conflicts here
                NSComparisonResult result; //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
                result = [file.lastModifiedDate compare:fileDate]; //Compare the Dates
                if (result == NSOrderedAscending || result == NSOrderedSame) {
                    //Dropbox File is older than local file
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Already Downloaded"
                                                                        message:[NSString stringWithFormat:@"%@ is already in your Documents folder.", file.filename]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                    [alertView show];
                } else if (result == NSOrderedDescending) {
                    //Dropbox File is newer than local file
                    NSLog(@"Dropbox File is newer than local file");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict"
                                                                        message:[NSString stringWithFormat:@"%@ exists in both your Dropbox and in your Documents folder. The one in Dropbox is newer.", file.filename]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
                [self updateTableData];
            }
        }
    }
    
    return res;
}

//------------------------------------------------------------------------------------------------------------//
//Region: Dropbox Delegate -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DBRestClientDelegate methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            //Check if directory or document
            if ([file isDirectory] || ![file.filename hasSuffix:@".exe"]) {
                //Push new tableviewcontroller
                [dirList addObject:file];
            }
        }
    }
    
    self.list = dirList;
    NSLog(@"List: %@", list);
    
    [self updateTableData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [self updateTableData];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    [self downloadedFile];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    [self downloadedFileFailed];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
    [self updateDownloadProgressTo:progress];
}

@end
