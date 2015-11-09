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
#import "SDDataHelper.h"
#import "SDBookmarksVC.h"

@interface SDHomeVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, iCarouselDataSource, iCarouselDelegate>{
    iCarousel *lastSelectedCarousel;
}

@property (nonatomic, strong) NSArray *shirtArr;
@property (nonatomic, strong) NSArray *pantArr;

@property (nonatomic, strong) iCarousel *shirtCarousel;
@property (nonatomic, strong) iCarousel *pantCarousel;

@end

@implementation SDHomeVC

@synthesize shirtArr, pantArr;
@synthesize shirtCarousel, pantCarousel;


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
    

    UIBarButtonItem *showBookmarkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"showBookmarks"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(showBookmarks:)];
    
    UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                            target:self
                                                                            action:@selector(showAddOptions:)];
    self.navigationItem.rightBarButtonItems = @[camBtn, showBookmarkBtn];
    
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *bookmarkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(toggleBookmarks:)];
    
    UIBarButtonItem *dislikeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dislike"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(addToDislike:)];
    
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                              target:self
                                                                              action:@selector(share:)];
    
    self.toolbarItems = [NSArray arrayWithObjects:spaceItem, bookmarkBtn, spaceItem, dislikeBtn, spaceItem, shareBtn, spaceItem, nil];
    
    self.navigationController.toolbar.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    shirtCarousel = [[iCarousel alloc] init];
    [shirtCarousel setDelegate:self];
    [shirtCarousel setDataSource:self];
    [shirtCarousel setType:iCarouselTypeTimeMachine];
    [self.view addSubview:shirtCarousel];
    
    pantCarousel = [[iCarousel alloc] init];
    [pantCarousel setDelegate:self];
    [pantCarousel setDataSource:self];
    [pantCarousel setType:iCarouselTypeInvertedTimeMachine];
    [self.view addSubview:pantCarousel];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchShirts)
                                                 name:ADDED_NEW_SHIRT_UPDATE_VIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPants)
                                                 name:ADDED_NEW_PANT_UPDATE_VIEW object:nil];
    
    self.navigationController.toolbarHidden = NO;
   
    [self.navigationController.toolbar setBackgroundImage:[UIImage new]
                                       forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];

    
    [self fetchShirts];
    [self fetchPants];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    //background image
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [BG_IMAGE drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    //toolbar shadow
    UIBezierPath *loginViewShadow = [UIBezierPath bezierPathWithRect:self.navigationController.toolbar.bounds];
    self.navigationController.toolbar.layer.masksToBounds = NO;
    self.navigationController.toolbar.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.navigationController.toolbar.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.navigationController.toolbar.layer.shadowOpacity = 0.5f;
    self.navigationController.toolbar.layer.shadowPath = loginViewShadow.CGPath;
    
    shirtCarousel.frame = CGRectMake(0, NAVBAR_HEIGHT + 30, self.view.frame.size.width, 160);
    pantCarousel.frame = CGRectMake(0, shirtCarousel.frame.origin.y + shirtCarousel.frame.size.height + 45, self.view.frame.size.width, 160);
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Data Helpers

- (void)fetchShirts{
    shirtArr = [SDDataHelper getAllShirtsByBookmark:NO];
    [shirtCarousel reloadData];
    if (shirtArr.count> 0) [shirtCarousel scrollToItemAtIndex:(shirtArr.count-1) animated:YES];
}

- (void)fetchPants{
    pantArr = [SDDataHelper getAllPantsByBookmark:NO];
    [pantCarousel reloadData];
    if (pantArr.count> 0) [pantCarousel scrollToItemAtIndex:(pantArr.count-1) animated:YES];
}


#pragma mark - Action Helpers

- (void)performLogout:(id)sender{

    [[FBSDKLoginManager new] logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showAddOptions:(id)sender{
 
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add Robes"
                                                                         message:@""
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add Shirts / T-Shirts" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        lastSelectedCarousel = shirtCarousel;
        [self showCameraOptionsWithTitle:@"Add Shirts / T-Shirts"];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add Pants" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        lastSelectedCarousel = pantCarousel;
        [self showCameraOptionsWithTitle:@"Add Pants"];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showCameraOptionsWithTitle:(NSString *)title{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title
                                                                         message:@""
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
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
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (lastSelectedCarousel == shirtCarousel) {
        [SDDataHelper addToShirts:image];
        lastSelectedCarousel = nil;
    }
    else{
        [SDDataHelper addToPants:image];
        lastSelectedCarousel = nil;
    }
}

- (void)showBookmarks:(id)sender{
    
    NSArray *bookmarkShirtArr = [SDDataHelper getAllShirtsByBookmark:YES];
    NSArray *bookmarkPantArr  = [SDDataHelper getAllPantsByBookmark:YES];
    
    if ((bookmarkShirtArr.count > 0) && (bookmarkPantArr.count > 0)) {
        SDBookmarksVC *bookmarkVC = [[SDBookmarksVC alloc] init];
        bookmarkVC.shirtArr = bookmarkShirtArr;
        bookmarkVC.pantArr = bookmarkPantArr;
        [self.navigationController pushViewController:bookmarkVC animated:YES];
    }
}

- (void)toggleBookmarks:(id)sender{
    
    if (shirtArr.count > 0 && pantArr.count > 0) {
        BOOL shirt = [SDDataHelper toggleShirtBookmark:[shirtArr objectAtIndex:shirtCarousel.currentItemIndex]];
        BOOL pant = [SDDataHelper togglePantBookmark:[pantArr objectAtIndex:pantCarousel.currentItemIndex]];
        
        if (shirt && pant) {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Pair added to bookmarks"
                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        else if (!shirt && !pant){
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Pair removed from bookmarks"
                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please add a pair of shirts & pants to Bookmark"
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)addToDislike:(id)sender{

    NSInteger shirtIndex = arc4random() % shirtArr.count;
    [shirtCarousel scrollToItemAtIndex:shirtIndex animated:YES];
    
    NSInteger pantIndex = arc4random() % pantArr.count;
    [pantCarousel scrollToItemAtIndex:pantIndex animated:YES];
}

- (void)share:(id)sender{
   
    UIImage *shirt, *pant;
    if (shirtCarousel.currentItemIndex < shirtArr.count) {
        
        Shirt *shirtObj = shirtArr[shirtCarousel.currentItemIndex];
        
        shirt = [UIImage imageWithData:shirtObj.img];
    }
    
    if (pantCarousel.currentItemIndex < pantArr.count) {
        
        Pant *pantObj = pantArr[pantCarousel.currentItemIndex];
        
        pant = [UIImage imageWithData:pantObj.img];
    }
    
    if (shirt && pant) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                            initWithActivityItems:[NSArray arrayWithObjects:shirt, pant, nil]
                                                            applicationActivities:nil];
        
        [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please add a pair of shirts & pants to Share"
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}


#pragma mark - UI Helpers

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    
    if (carousel == shirtCarousel) {
        return (shirtArr.count == 0) ? 1 : shirtArr.count;
    }
    else{
        return (pantArr.count == 0) ? 1 : pantArr.count;
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view{

    UIImageView *img;
    if (view) {
        for (UIView *subview in view.subviews) {
            if (subview.tag == carousel.tag) {
                img = (UIImageView *)subview;
            }
        }
    }
    else{
        view = [[UIView alloc] init];
        img = [[UIImageView alloc] init];
        img.contentMode = UIViewContentModeScaleAspectFit;
        
        [view addSubview:img];
    }
    
    view.frame = CGRectMake(0, 0, 240, 160);
    img.frame = CGRectMake(0, 0, 220, 160);
    img.center = view.center;
    
    if (carousel == shirtCarousel) {
       
        if (shirtArr.count == 0) {   //zero shirts
            img.image = [UIImage imageNamed:@"camera"];
        }
        else{
            if (index < shirtArr.count) {
                
                Shirt *shirt = shirtArr[index];
                
                img.image = [UIImage imageWithData:shirt.img];
            }
        }
    }
    else{
        if (pantArr.count == 0) {    //zero pants
            img.image = [UIImage imageNamed:@"camera"];
        }
        else{
            if (index < pantArr.count) {
                
                Pant *pant = pantArr[index];
                img.image = [UIImage imageWithData:pant.img];
            }
        }
    }
    
    return view;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
    if (carousel == shirtCarousel) {
        if (shirtArr.count == 0) {
            lastSelectedCarousel = shirtCarousel;
            [self showCameraOptionsWithTitle:@"Add Shirts / T-Shirts"];
        }
    }
    else{
        if (pantArr.count == 0) {
            lastSelectedCarousel = pantCarousel;
            [self showCameraOptionsWithTitle:@"Add Pants"];
        }
    }
}

@end
