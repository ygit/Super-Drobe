//
//  SDLoginVC.m
//  Super Drobe
//
//  Created by yogesh singh on 04/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import Accelerate;
@import QuartzCore;
@import FBSDKCoreKit;
@import FBSDKLoginKit;

#import "SDLoginVC.h"
#import "SDHomeVC.h"
#import "SDUtils.h"

@interface SDLoginVC () <UITextFieldDelegate>

@property (strong, nonatomic) UIColor *avgColor;

@property (strong, nonatomic) UILabel *introLab;

@property (strong, nonatomic) UIButton *fbLogin;

@property (strong, nonatomic) UIView *loginView;

@property (strong, nonatomic) UILabel *usernameLab;
@property (strong, nonatomic) UILabel *passwordLab;

@property (strong, nonatomic) UITextField *usernameField;
@property (strong, nonatomic) UITextField *passwordField;

@property (strong, nonatomic) UIButton *loginBtn;

@end

@implementation SDLoginVC

@synthesize avgColor;
@synthesize introLab, loginView;
@synthesize usernameLab, passwordLab;
@synthesize usernameField, passwordField;
@synthesize loginBtn, fbLogin;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    avgColor = [SDUtils getAverageColorFromImage:BG_IMAGE];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [titleLab setTextAlignment:NSTextAlignmentCenter];
    [titleLab setText:@"Super Drobe"];
    [titleLab setFont:FONT_LRG];
    [titleLab setTextColor:[UIColor lightGrayColor]];
    [titleLab sizeToFit];
    self.navigationItem.titleView = titleLab;
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:BG_IMAGE forBarMetrics:UIBarMetricsDefault];
    [fbLogin setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    //background image
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [BG_IMAGE drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    //drop shadow
    UIBezierPath *loginViewShadow = [UIBezierPath bezierPathWithRect:loginView.bounds];
    loginView.layer.masksToBounds = NO;
    loginView.layer.shadowColor   = [UIColor blackColor].CGColor;
    loginView.layer.shadowOffset  = CGSizeMake(0.0f, 5.0f);
    loginView.layer.shadowOpacity = 0.5f;
    loginView.layer.shadowPath    = loginViewShadow.CGPath;
    
    UIBezierPath *loginBtnShadow = [UIBezierPath bezierPathWithRect:loginBtn.bounds];
    loginBtn.layer.masksToBounds = NO;
    loginBtn.layer.shadowColor   = [UIColor blackColor].CGColor;
    loginBtn.layer.shadowOffset  = CGSizeMake(0.0f, 5.0f);
    loginBtn.layer.shadowOpacity = 0.5f;
    loginBtn.layer.shadowPath    = loginBtnShadow.CGPath;
    
    UIBezierPath *fbLoginShadow = [UIBezierPath bezierPathWithRect:fbLogin.bounds];
    fbLogin.layer.masksToBounds = NO;
    fbLogin.layer.shadowColor   = [UIColor blackColor].CGColor;
    fbLogin.layer.shadowOffset  = CGSizeMake(0.0f, 5.0f);
    fbLogin.layer.shadowOpacity = 0.5f;
    fbLogin.layer.shadowPath    = fbLoginShadow.CGPath;
    
    //border effect
    loginView.layer.borderWidth  = 2.0f;
    loginView.layer.cornerRadius = 10.0f;
    loginView.layer.borderColor  = [UIColor blackColor].CGColor;
    
    loginBtn.layer.borderWidth  = 2.0f;
    loginBtn.layer.cornerRadius = 5.0f;
    loginBtn.layer.borderColor  = [UIColor blackColor].CGColor;
    
    fbLogin.layer.borderWidth  = 2.0f;
    fbLogin.layer.cornerRadius = 10.0f;
    fbLogin.layer.borderColor  = [UIColor blackColor].CGColor;
    
    [self setupFinalView:NO];
}

- (void)setupFinalView:(BOOL)option{
    
    //set view frames
    if (option) {
        loginView.frame  = CGRectMake(30, 0, self.view.frame.size.width-60, 90);
        loginView.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
        
        introLab.frame  = CGRectMake(15, 0, self.view.frame.size.width - 30, 60);
        introLab.center = CGPointMake(introLab.center.x, loginView.frame.origin.y - 45);
    }
    else{
        loginView.frame = CGRectMake(30, self.view.frame.size.height, self.view.frame.size.width-60, 90);
        introLab.frame  = CGRectMake(15, 0, self.view.frame.size.width - 30, 60);
        introLab.center = self.view.center;
    }
    
    usernameLab.frame   = CGRectMake(0, 0, 120, 45);
    usernameField.frame = CGRectMake(usernameLab.frame.size.width, 0,
                                     loginView.frame.size.width - usernameLab.frame.size.width, 45);
    
    passwordLab.frame   = CGRectMake(0, usernameLab.frame.size.height, usernameLab.frame.size.width, 45);
    passwordField.frame = CGRectMake(passwordLab.frame.size.width, passwordLab.frame.origin.y,
                                     loginView.frame.size.width - passwordLab.frame.size.width, 45);
    
    loginBtn.frame  = CGRectMake(0, 0, 120, 45);
    loginBtn.center = CGPointMake(self.view.center.x, loginView.center.y + 90);
    
    fbLogin.frame  = CGRectMake(0, 0, 240, 40);
    fbLogin.center = CGPointMake(self.view.center.x, loginBtn.center.y + 90);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(animateLoginPresentation:)
               withObject:nil afterDelay:2.0];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    usernameField.text = @"";
    passwordField.text = @"";
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UI Helpers

- (void)initViews{
    
    //init intro label
    introLab = [[UILabel alloc] init];
    [introLab setTextColor:[UIColor blackColor]];
    [introLab setTextAlignment:NSTextAlignmentCenter];
    [introLab setNumberOfLines:0];
    [introLab setFont:FONT_MED];
    [introLab setText:@"Super Drobe helps to get the best out of you (your wardrobe actually)"];
    
    //blur & vibrancy
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.view.bounds];
    
    [[vibrancyEffectView contentView] addSubview:introLab];
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
    [self.view addSubview:blurEffectView];
    
    //init login view
    loginView = [[UIView alloc] init];
    [loginView setClipsToBounds:YES];
    [loginView setBackgroundColor:[UIColor clearColor]];
    
    usernameLab = [[UILabel alloc] init];
    [usernameLab setTextColor:[UIColor whiteColor]];
    [usernameLab setTextAlignment:NSTextAlignmentCenter];
    [usernameLab setFont:FONT_MED];
    [usernameLab setText:@"Username"];
    
    passwordLab = [[UILabel alloc] init];
    [passwordLab setTextColor:[UIColor whiteColor]];
    [passwordLab setTextAlignment:NSTextAlignmentCenter];
    [passwordLab setFont:FONT_MED];
    [passwordLab setText:@"Password"];
    
    usernameField = [[UITextField alloc] init];
    [usernameField setDelegate:self];
    [usernameField setTag:1000];
    [usernameField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [usernameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [usernameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [usernameField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [usernameField setReturnKeyType:UIReturnKeyNext];
    [usernameField setEnablesReturnKeyAutomatically:YES];
    [usernameField setPlaceholder:@"example@icloud.com"];
    [usernameField setTextColor:[UIColor whiteColor]];
    
    passwordField = [[UITextField alloc] init];
    [passwordField setDelegate:self];
    [passwordField setTag:2000];
    [passwordField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [passwordField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [passwordField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [passwordField setReturnKeyType:UIReturnKeyGo];
    [passwordField setEnablesReturnKeyAutomatically:YES];
    [passwordField setSecureTextEntry:YES];
    [passwordField setPlaceholder:@"required"];
    [passwordField setTextColor:[UIColor whiteColor]];
    
    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = FONT_MED;
    [loginBtn addTarget:self action:@selector(performLogin:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    fbLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    fbLogin.backgroundColor = avgColor;
    fbLogin.titleLabel.font = FONT_MED;
    [fbLogin addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    //add to superview
    [loginView addSubview:usernameLab];
    [loginView addSubview:passwordLab];
    [loginView addSubview:usernameField];
    [loginView addSubview:passwordField];
    [self.view addSubview:loginView];
    [self.view addSubview:loginBtn];
    [self.view addSubview:fbLogin];
}

- (void)animateLoginPresentation:(id)sender{

    [UIView animateWithDuration:1.0 delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         [self setupFinalView:YES];
                     } completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 1000) {
        [passwordField becomeFirstResponder];
    }
    else{
        [self performLogin:nil];
    }
    return YES;
}


#pragma mark - Action Helpers

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (void)performLogin:(UIButton *)sender{

    SDHomeVC *homeVC = [[SDHomeVC alloc] init];
    [self.navigationController pushViewController:homeVC animated:YES];
}

- (void)loginWithFacebook:(UIButton *)sender{
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"Process error : %@", error.localizedDescription);
                                }
                                else if (result.isCancelled) {
                                    NSLog(@"Cancelled result : %@",result);
                                }
                                else {
                                    NSLog(@"logged in result : %@", result);
                                    [fbLogin setTitle:@"Logged in with Facebook" forState:UIControlStateNormal];
                                    [self performSelector:@selector(performLogin:) withObject:nil afterDelay:1];
                                }
     }];
}

@end
