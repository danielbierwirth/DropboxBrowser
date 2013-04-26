//
//  KioskDropboxPDFBrowserViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 2/24/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license. 

// Copyright (c) 2013 Daniel Bierwirth
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <UIKit/UIKit.h>
#import "KioskDropboxPDFRootViewController.h"
#import "KioskDropboxPDFDataController.h"

@protocol KioskDropboxPDFBrowserViewControllerUIDelegate;
@class KioskDropboxPDFRootViewController;
@class KioskDropboxPDFDataController;

@interface KioskDropboxPDFBrowserViewController : UINavigationController {}

//Contains dropbox data inside a tableview and manages file navigation as well as item download
@property (nonatomic, strong) KioskDropboxPDFRootViewController *rootViewController;
// manages the dropbox access and data fetch
@property (nonatomic, strong) KioskDropboxPDFDataController *dataController;

// Manage UI events
@property (nonatomic) id <KioskDropboxPDFBrowserViewControllerUIDelegate> uiDelegate;

// List content of home directory in a tableview. Alert if application is not linked to dropbox
- (void) listDropboxDirectory;

//Display the Viewer
+ (void)displayDropboxBrowserInPhoneStoryboard:(UIStoryboard *)iPhoneStoryboard displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard onView:(UIViewController *)viewController withPresentationStyle:(UIModalPresentationStyle)presentationStyle withTransitionStyle:(UIModalTransitionStyle)transitionStyle withDelegate:(id<KioskDropboxPDFBrowserViewControllerUIDelegate>)delegate;

@end

// Notify dropbox browser delegate about close and download events
@protocol KioskDropboxPDFBrowserViewControllerUIDelegate <NSObject>

// Parent controller can remove dropbox browser. Delegate is notified on close button press in dropbox browser
@required - (void) removeDropboxBrowser;

// Document was downloaded - tell delegate about it. The fileName property in the KioskRootViewController also gives access to the name of the file just downloaded
 - (void)refreshLibrarySection;

@end

