//
//  SDHomeVC.m
//  Super Drobe
//
//  Created by yogesh singh on 04/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import FBSDKCoreKit;
@import FBSDKLoginKit;

#import "SDHomeVC.h"
#import "SDUtils.h"
#import "iCarousel.h"

@interface SDHomeVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *shirtArr;
@property (nonatomic, strong) NSMutableArray *pantArr;

@end

@implementation SDHomeVC
@synthesize shirtArr, pantArr;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    UILabel *titleLab = [[UILabel alloc] init];
    [titleLab setTextAlignment:NSTextAlignmentCenter];
    [titleLab setText:@"Wardrobe"];
    [titleLab setFont:FONT_LRG];
    [titleLab setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    [titleLab sizeToFit];
    self.navigationItem.titleView = titleLab;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];

    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(performLogout:)];
    
    self.navigationItem.leftBarButtonItem = logoutBtn;
    
    UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                            target:self
                                                                            action:@selector(showCameraOptions:)];

    UIBarButtonItem *showBookmarkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"showBookmarks"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(showBookmarks:)];
    
    self.navigationItem.rightBarButtonItems = @[camBtn, showBookmarkBtn];
    
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *bookmarkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(addToBookmarks:)];
    
    UIBarButtonItem *dislikeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dislike"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(addToDislike:)];
    
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                              target:self
                                                                              action:@selector(share:)];
    
    self.toolbarItems = [NSArray arrayWithObjects:spaceItem, bookmarkBtn, spaceItem, dislikeBtn, spaceItem, shareBtn, spaceItem, nil];
    
    self.navigationController.toolbar.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
   
    [self.navigationController.toolbar setBackgroundImage:[UIImage new]
                                       forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];

}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    //background image
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [BG_IMAGE drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    UIBezierPath *loginViewShadow = [UIBezierPath bezierPathWithRect:self.navigationController.toolbar.bounds];
    self.navigationController.toolbar.layer.masksToBounds = NO;
    self.navigationController.toolbar.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.navigationController.toolbar.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.navigationController.toolbar.layer.shadowOpacity = 0.5f;
    self.navigationController.toolbar.layer.shadowPath = loginViewShadow.CGPath;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Action Helpers

- (void)performLogout:(id)sender{

    [[FBSDKLoginManager new] logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showCameraOptions:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add Image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
            [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showBookmarks:(id)sender{
    NSLog(@"showBookmarks: %@",sender);
}

- (void)addToBookmarks:(id)sender{
    NSLog(@"addToBookmarks");
}

- (void)addToDislike:(id)sender{
    NSLog(@"addToDislike");
}

- (void)share:(id)sender{
   
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[@"string"]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ...
                                     }];
}

@end
