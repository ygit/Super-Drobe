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
#import "UIView+Toast.h"
#import "ELCImagePickerController.h"

@interface SDHomeVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ELCImagePickerControllerDelegate, iCarouselDataSource, iCarouselDelegate>{
    iCarousel *lastSelectedCarousel;
    UIBarButtonItem *camBtn, *showBookmarkBtn;
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
    

    showBookmarkBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"showBookmarks"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self action:@selector(showBookmarks:)];
    
    camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (shirtArr.count == 0) {
        
        [self.view makeToast:@"Please add a few shirts"
                    duration:5.0
                    position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                            self.view.center.y + (self.view.frame.size.height - self.view.center.y)/2)]
                       title:@"Uh oh! Seems like you don't have any shirts!"
                       image:[UIImage imageNamed:@"shirtImg"]
                       style:nil
                  completion:^(BOOL didTap) {
                      
                      lastSelectedCarousel = shirtCarousel;
                      [self showCameraOptionsWithTitle:ADD_SHIRTS];
                  }];
    }
    
    [self checkForAutomaticScrolling];
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
   
    shirtArr = [SDDataHelper getAllShirtsByBookmark:NO];
    [shirtCarousel reloadData];
    if (shirtArr.count> 0) [shirtCarousel scrollToItemAtIndex:(shirtArr.count-1)
                                                     animated:(notification) ? YES : NO];
    
    if (shirtArr.count < 3 && shirtCounter < 2) {
        shirtCounter++;
        if (shirtArr.count > shirtCarousel.currentItemIndex) {
            
            Shirt *shirt = shirtArr[shirtCarousel.currentItemIndex];
        
            [self.view makeToast:@"Please add more shirts"
                        duration:5.0
                        position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                       self.view.center.y + (self.view.frame.size.height - self.view.center.y)/2)]
                           title:@"Hmmm! It's better if you add a few more shirts"
                           image:[UIImage imageWithData:shirt.img]
                           style:nil
                      completion:^(BOOL didTap) {
                          
                          lastSelectedCarousel = shirtCarousel;
                          [self showCameraOptionsWithTitle:ADD_SHIRTS];
                      }];
        }
    }
    else{
        [self fetchPants:nil];
        [self performPantChecks];
    }
    
    shirtCarousel.scrollEnabled = !(shirtArr.count == 1);
    
    [self checkForAutomaticScrolling];
}

- (void)fetchPants:(NSNotification *)notification{
    pantArr = [SDDataHelper getAllPantsByBookmark:NO];
    [pantCarousel reloadData];
    if (pantArr.count> 0) [pantCarousel scrollToItemAtIndex:(pantArr.count-1)
                                                   animated:(notification) ? YES : NO];
    
    pantCarousel.scrollEnabled  = !(pantArr.count == 1);

    [self checkForAutomaticScrolling];
}

- (void)performPantChecks{
    
    if (pantArr.count == 0) {
        
        [self.view makeToast:@"Please add a few pants"
                    duration:5.0
                    position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                   self.view.center.y + (self.view.frame.size.height - self.view.center.y)/2)]
                       title:@"Uh oh! Seems like you don't have any pants!"
                       image:[UIImage imageNamed:@"pantImg"]
                       style:nil
                  completion:^(BOOL didTap) {
                      
                      lastSelectedCarousel = pantCarousel;
                      [self showCameraOptionsWithTitle:ADD_PANTS];
                  }];
    }
    else if (pantArr.count < 3 && pantCounter < 2){
        pantCounter++;
        if (pantArr.count > pantCarousel.currentItemIndex) {
            
            Pant *pant = pantArr[pantCarousel.currentItemIndex];
            
            [self.view makeToast:@"Please add more pants"
                        duration:5.0
                        position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                       self.view.center.y + (self.view.frame.size.height - self.view.center.y)/2)]
                           title:@"Hmmm! It's better if you add a few more pants"
                           image:[UIImage imageWithData:pant.img]
                           style:nil
                      completion:^(BOOL didTap) {
                          
                          lastSelectedCarousel = pantCarousel;
                          [self showCameraOptionsWithTitle:ADD_PANTS];
                      }];
        }
    }
}


#pragma mark - Action Helpers

- (void)performLogout:(id)sender{

    [[FBSDKLoginManager new] logOut];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

static bool bookmarkInfo = NO;

- (void)toggleBookmarks:(id)sender{
    
    if (shirtArr.count > 0 && pantArr.count > 0) {
        
        BOOL shirt = [SDDataHelper toggleShirtBookmark:[shirtArr objectAtIndex:shirtCarousel.currentItemIndex]];
        BOOL pant = [SDDataHelper togglePantBookmark:[pantArr objectAtIndex:pantCarousel.currentItemIndex]];
        
        if (shirt && pant) {
            
            shirtCarousel.alpha = 0.5;
            pantCarousel.alpha  = 0.5;
            
            [self.view makeToast:@"Pair added to Bookmarks"
                        duration:2.0
                        position:[NSValue valueWithCGPoint:shirtCarousel.center]
                           title:nil image:nil style:nil completion:^(BOOL didTap) {
                               
                               if (!bookmarkInfo) {
                                   
                                   [self.view makeToast:@"View your Bookmarks from the list button above"
                                               duration:2.0
                                               position:[NSValue valueWithCGPoint:shirtCarousel.center]
                                                  title:nil
                                                  image:nil
                                                  style:nil completion:^(BOOL didTap) {
                                                      
                                                      [UIView animateWithDuration:0.5 animations:^{
                                                          
                                                          showBookmarkBtn.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
                                                          
                                                      } completion:^(BOOL finished) {
                                                          
                                                          showBookmarkBtn.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1];
                                                          bookmarkInfo = YES;
                                                          
                                                          [UIView animateWithDuration:0.5 animations:^{
                                                              shirtCarousel.alpha = 1;
                                                              pantCarousel.alpha  = 1;
                                                          }];
                                                      }];
                                                  }];
                               }
                               else{
                                   
                                   [UIView animateWithDuration:0.5 animations:^{
                                       shirtCarousel.alpha = 1;
                                       pantCarousel.alpha  = 1;
                                   }];
                               }
                           }];
        }
        
        //block for handling adding/removing bookmarks (toggling)

        /*
        else if (!shirt && !pant){
            
            shirtCarousel.alpha = 0.5;
            pantCarousel.alpha  = 0.5;
            
            [self.view makeToast:@"Pair removed from Bookmarks"
                        duration:2.0
                        position:[NSValue valueWithCGPoint:shirtCarousel.center]
                           title:nil image:nil style:nil completion:^(BOOL didTap) {
                               
                               shirtCarousel.alpha = 1;
                               pantCarousel.alpha  = 1;
                           }];
        }
        else if (!shirt){
            
            shirtCarousel.alpha = 0.5;
            pantCarousel.alpha  = 0.5;
            
            [self.view makeToast:@"/---/" //a custom message to notify user
                        duration:2.0
                        position:[NSValue valueWithCGPoint:shirtCarousel.center]
                           title:nil image:nil style:nil completion:^(BOOL didTap) {
                               
                               shirtCarousel.alpha = 1;
                               pantCarousel.alpha  = 1;
                           }];
        }
        else if (!pant){
            
            shirtCarousel.alpha = 0.5;
            pantCarousel.alpha  = 0.5;
            
            [self.view makeToast:@"/---/" //a custom message to notify user
                        duration:2.0
                        position:[NSValue valueWithCGPoint:shirtCarousel.center]
                           title:nil image:nil style:nil completion:^(BOOL didTap) {
                               
                               shirtCarousel.alpha = 1;
                               pantCarousel.alpha  = 1;
                           }];
        }
     */
    }
    else{
        [self.view makeToast:@"Please add a pair of shirt & pant to Bookmark"
                    duration:3.0 position:CSToastPositionCenter];
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
    else{
        [self.view makeToast:@"Please add a pair of shirt & pant to Bookmarks first!"
                    duration:3.0 position:CSToastPositionCenter];
    }
}

//reused for performScroll
//left open ended for a functionality to add to/view dislikes (if required)
- (void)addToDislike:(id)sender{
    
    if (shirtArr.count > 1 && pantArr.count > 1) {
        NSInteger shirtIndex = arc4random() % shirtArr.count;
        [shirtCarousel scrollToItemAtIndex:shirtIndex animated:YES];
        
        NSInteger pantIndex = arc4random() % pantArr.count;
        [pantCarousel scrollToItemAtIndex:pantIndex animated:YES];
    }
    else{
        if (shirtArr.count == 0 && pantArr.count ==0) {
            
            [self.view makeToast:@"Ahh! You have nothing to dislike\n(except you!)"
                        duration:3.0 position:CSToastPositionCenter];
        }
    }
}

- (void)checkForAutomaticScrolling{
    BOOL shouldScrollAutomatically = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isScrollingAutomatic"] boolValue];
    
    if (shouldScrollAutomatically && (shirtArr.count > 0) && (pantArr.count > 0)){
        [self performSelector:@selector(performScroll)];
    }
}

- (void)performScroll{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performScroll) object:nil];
    [self addToDislike:nil];
    [self performSelector:@selector(performScroll) withObject:nil afterDelay:5];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performScroll) object:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(checkForAutomaticScrolling) withObject:nil afterDelay:3];
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
        [self.view makeToast:@"Please first add a pair of shirt & pant to Share"
                    duration:3.0 position:CSToastPositionCenter];
    }
}


#pragma mark - Picker Helpers

- (void)showAddOptions:(id)sender{
    
    BOOL shouldUseDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isUsingDefaultAssets"] boolValue];
    
    if (!shouldUseDefaults){
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add Robes"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:ADD_SHIRTS style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            lastSelectedCarousel = shirtCarousel;
            [self showCameraOptionsWithTitle:ADD_SHIRTS];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:ADD_PANTS style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            lastSelectedCarousel = pantCarousel;
            [self showCameraOptionsWithTitle:ADD_PANTS];
        }]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    
    else{
        
        shirtCarousel.alpha = 0.5;
        pantCarousel.alpha  = 0.5;
        [self.view makeToast:@"Ah ah! You cannot add shirts/pants in defaults mode. Change it in your device settings"
                    duration:5.0
                    position:[NSValue valueWithCGPoint:self.view.center]
                       title:nil
                       image:[UIImage imageNamed:@"settings"]
                       style:nil
                  completion:^(BOOL didTap) {
                      
                      [UIView animateWithDuration:0.5 animations:^{
                          shirtCarousel.alpha = 1;
                          pantCarousel.alpha  = 1;
                      }];
                  }];
    }
}

static int shirtCounter = 0;
static int pantCounter = 0;

- (void)showCameraOptionsWithTitle:(NSString *)title{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title
                                                                         message:@""
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction *action) {
                                                      
                                                      if (shirtArr.count == 0) {
                                                          
                                                          [self.view makeToast:@"You can also add shirts via the camera button on top!"
                                                                      duration:4.0
                                                                      position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                                                                     (self.view.frame.size.height - self.view.center.y)/2)]
                                                                         title:@"You know!"
                                                                         image:[UIImage imageNamed:@"shirtImg"]
                                                                         style:nil
                                                                    completion:^(BOOL didTap) {
                                                                        [UIView animateWithDuration:0.5 animations:^{
                                                                            camBtn.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
                                                                        } completion:^(BOOL finished) {
                                                                            camBtn.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1];
                                                                        }];
                                                                    }];
                                                      }
                                                      else if (shirtArr.count < 3 && shirtCounter < 2){
                                                          shirtCounter++;
                                                          if (shirtArr.count > shirtCarousel.currentItemIndex) {
                                                              
                                                              Shirt *shirt = shirtArr[shirtCarousel.currentItemIndex];
                                                              
                                                              [self.view makeToast:@"Please add more shirts"
                                                                          duration:5.0
                                                                          position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                                                                         self.view.center.y + (self.view.frame.size.height - self.view.center.y)/2)]
                                                                             title:@"Hmmm! It's better if you add a few more shirts"
                                                                             image:[UIImage imageWithData:shirt.img]
                                                                             style:nil
                                                                        completion:^(BOOL didTap) {
                                                                            
                                                                            lastSelectedCarousel = shirtCarousel;
                                                                            [self showCameraOptionsWithTitle:ADD_SHIRTS];
                                                                        }];
                                                          }
                                                      }
                                                      else if (pantArr.count == 0){
                                                          
                                                          [self.view makeToast:@"You can also add pants via the camera button on top!"
                                                                      duration:4.0
                                                                      position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                                                                     (self.view.frame.size.height - self.view.center.y)/2)]
                                                                         title:@"You know!"
                                                                         image:[UIImage imageNamed:@"pantImg"]
                                                                         style:nil
                                                                    completion:^(BOOL didTap) {
                                                                        [UIView animateWithDuration:0.5 animations:^{
                                                                            camBtn.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
                                                                        } completion:^(BOOL finished) {
                                                                            camBtn.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1];
                                                                        }];
                                                                    }];
                                                      }
                                                      else if (pantArr.count < 3 && pantCounter < 2){
                                                          pantCounter++;
                                                          if (pantArr.count > pantCarousel.currentItemIndex) {
                                                              
                                                              Pant *pant = pantArr[pantCarousel.currentItemIndex];
                                                              
                                                              [self.view makeToast:@"Please add more pants"
                                                                          duration:5.0
                                                                          position:[NSValue valueWithCGPoint:CGPointMake(self.view.center.x,
                                                                                                                         self.view.center.y + (self.view.frame.size.height - self.view.center.y)/2)]
                                                                             title:@"Hmmm! It's better if you add a few more pants"
                                                                             image:[UIImage imageWithData:pant.img]
                                                                             style:nil
                                                                        completion:^(BOOL didTap) {
                                                                            
                                                                            lastSelectedCarousel = pantCarousel;
                                                                            [self showCameraOptionsWithTitle:ADD_PANTS];
                                                                        }];
                                                          }
                                                      }
                                                  }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      
                                                      ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
                                                      
                                                      elcPicker.maximumImagesCount = 100;
                                                      elcPicker.returnsOriginalImage = NO;
                                                      elcPicker.returnsImage = YES;
                                                      elcPicker.onOrder = YES;
                                                      elcPicker.mediaTypes = @[(NSString *)kUTTypeImage];
                                                      
                                                      elcPicker.imagePickerDelegate = self;
                                                      
                                                      [self presentViewController:elcPicker animated:YES completion:nil];
                                                  }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action) {
                                                      
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

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{

    [self dismissViewControllerAnimated:YES completion:nil];
    
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
              
                UIImage* image = [dict objectForKey:UIImagePickerControllerOriginalImage];
                
                if (lastSelectedCarousel == shirtCarousel) {
                    [SDDataHelper addToShirts:image];
                }
                else{
                    [SDDataHelper addToPants:image];
                }
            }
        }
    }
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
    if (carousel == shirtCarousel) {
        if (shirtArr.count == 1) {
            lastSelectedCarousel = shirtCarousel;
            [self showCameraOptionsWithTitle:ADD_SHIRTS];
        }
    }
    else{
        if (pantArr.count == 1) {
            lastSelectedCarousel = pantCarousel;
            [self showCameraOptionsWithTitle:ADD_PANTS];
        }
    }
}

@end
