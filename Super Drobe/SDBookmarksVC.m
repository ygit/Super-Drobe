//
//  SDBookmarksVC.m
//  Super Drobe
//
//  Created by yogesh singh on 04/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "SDBookmarksVC.h"
#import "SDUtils.h"
#import "iCarousel.h"
#import "SDDataHelper.h"

@interface SDBookmarksVC() <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) iCarousel *shirtCarousel;
@property (nonatomic, strong) iCarousel *pantCarousel;

@end

@implementation SDBookmarksVC

@synthesize shirtArr, pantArr;
@synthesize shirtCarousel, pantCarousel;


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [titleLab setTextAlignment:NSTextAlignmentCenter];
    [titleLab setText:@"Bookmarks"];
    [titleLab setFont:FONT_LRG];
    [titleLab setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    [titleLab sizeToFit];
    self.navigationItem.titleView = titleLab;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                              target:self
                                                                              action:@selector(share:)];
    
    self.toolbarItems = [NSArray arrayWithObjects: spaceItem, shareBtn, spaceItem, nil];
    
    self.navigationController.toolbar.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    shirtCarousel = [[iCarousel alloc] init];
    [shirtCarousel setDelegate:self];
    [shirtCarousel setDataSource:self];
    [shirtCarousel setType:iCarouselTypeCylinder];
    [self.view addSubview:shirtCarousel];
    
    pantCarousel = [[iCarousel alloc] init];
    [pantCarousel setDelegate:self];
    [pantCarousel setDataSource:self];
    [pantCarousel setType:iCarouselTypeCylinder];
    [self.view addSubview:pantCarousel];
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


#pragma mark - Action Helpers

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
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please add a pair of shirt & pants to share"
                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}


#pragma mark - UI Helpers

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    
    return (carousel == shirtCarousel) ? shirtArr.count : pantArr.count;
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
        if (index < shirtArr.count) {
            
            Shirt *shirt = shirtArr[index];
            
            img.image = [UIImage imageWithData:shirt.img];
        }
        
    }
    else{
        if (index < pantArr.count) {
            
            Pant *pant = pantArr[index];
            img.image = [UIImage imageWithData:pant.img];
        }
        
    }
    
    return view;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
    
}

@end
