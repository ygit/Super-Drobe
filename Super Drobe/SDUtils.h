//
//  SDUtils.h
//  Super Drobe
//
//  Created by yogesh singh on 04/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import Foundation;
@import UIKit;

#define BG_IMAGE [UIImage imageNamed:@"background"]

#define FONT_MED [UIFont fontWithName:@"Futura-Medium" size:16]
#define FONT_LRG [UIFont fontWithName:@"Futura-Medium" size:20]

#define NAVBAR_HEIGHT (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)

#define ADDED_NEW_SHIRT_UPDATE_VIEW @"ADDED_NEW_SHIRT_UPDATE_VIEW"

#define ADDED_NEW_PANT_UPDATE_VIEW @"ADDED_NEW_PANT_UPDATE_VIEW"

#define BOOKMARKED_SHIRTS_UPDATED @"BOOKMARKED_SHIRTS_UPDATED"

#define BOOKMARKED_PANTS_UPDATED @"BOOKMARKED_PANTS_UPDATED"

/**
    Super Drobe utilities class containing app skin helpers, constant declarations & general helper functions.
*/

@interface SDUtils : NSObject

/** 
    Returns average color from the provided image
    @param image Image to get average color from
*/

+ (UIColor *)getAverageColorFromImage:(UIImage *)image;

@end
