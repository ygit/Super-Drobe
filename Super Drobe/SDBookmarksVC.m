//
//  SDBookmarksVC.h
//  Super Drobe
//
//  Created by yogesh singh on 04/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "SDUtils.h"
#import "iCarousel.h"
#import "SDDataHelper.h"
#import "SDBookmarksVC.h"

@interface SDBookmarksVC () <iCarouselDelegate, iCarouselDataSource>

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
    
    self.toolbarItems = [NSArray arrayWithObjects:spaceItem, shareBtn, spaceItem, nil];
    
    self.navigationController.toolbar.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    shirtCarousel = [[iCarousel alloc] init];
    [shirtCarousel setDelegate:self];
    [shirtCarousel setDataSource:self];
    [shirtCarousel setType:iCarouselTypeRotary];
    [self.view addSubview:shirtCarousel];
    
    pantCarousel = [[iCarousel alloc] init];
    [pantCarousel setDelegate:self];
    [pantCarousel setDataSource:self];
    [pantCarousel setType:iCarouselTypeRotary];
    [self.view addSubview:pantCarousel];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchShirts:)
                                                 name:SHOULD_UPDATE_SHIRTS_VIEW object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPants:)
                                                 name:SHOULD_UPDATE_PANTS_VIEW object:nil];
    
    self.navigationController.toolbarHidden = NO;
    
    [self.navigationController.toolbar setBackgroundImage:[UIImage new]
                                       forToolbarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [self fetchShirts:nil];
    [self fetchPants:nil];
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
    UIBezierPath *navShadow = [UIBezierPath bezierPathWithRect:self.navigationController.toolbar.bounds];
    self.navigationController.toolbar.layer.masksToBounds = NO;
    self.navigationController.toolbar.layer.shadowColor   = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.navigationController.toolbar.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    self.navigationController.toolbar.layer.shadowOpacity = 0.5f;
    self.navigationController.toolbar.layer.shadowPath    = navShadow.CGPath;
    
    shirtCarousel.frame  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2.75);
    shirtCarousel.center = CGPointMake(self.view.center.x, self.view.center.y - shirtCarousel.frame.size.height/2);
    
    pantCarousel.frame   = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2.75);
    pantCarousel.center  = CGPointMake(self.view.center.x, self.view.center.y + pantCarousel.frame.size.height/2 + 15);
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

- (void)fetchShirts:(NSNotification *)notification{
    
    shirtArr = [SDDataHelper getAllShirtsByBookmark:YES];
    [shirtCarousel reloadData];
    if (shirtArr.count> 0) [shirtCarousel scrollToItemAtIndex:(shirtArr.count-1)
                                                     animated:(notification) ? YES : NO];
    
    shirtCarousel.scrollEnabled = !(shirtArr.count == 1);
}

- (void)fetchPants:(NSNotification *)notification{
    pantArr = [SDDataHelper getAllPantsByBookmark:YES];
    [pantCarousel reloadData];
    if (pantArr.count> 0) [pantCarousel scrollToItemAtIndex:(pantArr.count-1)
                                                   animated:(notification) ? YES : NO];
    
    pantCarousel.scrollEnabled  = !(pantArr.count == 1);
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
}


#pragma mark - Carousel Helpers

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    
    return (carousel == shirtCarousel) ? shirtArr.count : pantArr.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view{
    
    UIImageView *img;
    if (view) {
        for (UIView *subview in view.subviews) {
            if (subview.tag == 10) {
                img = (UIImageView *)subview;
            }
        }
    }
    else{
        view = [[UIView alloc] init];
        img = [[UIImageView alloc] init];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.tag = 10;
        [view addSubview:img];
    }
    
    view.frame = CGRectMake(0, 0, 260, 220);
    img.frame = CGRectMake(0, 0, 220, 220);
    img.center = view.center;
    
    img.layer.cornerRadius = 10;
    img.layer.borderWidth  = 2.0f;
    img.layer.borderColor  = [[UIColor whiteColor] CGColor];
    
    UIBezierPath *loginViewShadow = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = loginViewShadow.CGPath;
    
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


@end
