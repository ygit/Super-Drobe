//
//  SDDataHelper.h
//  Super Drobe
//
//  Created by yogesh singh on 09/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "Shirt+CoreDataProperties.h"
#import "Pant+CoreDataProperties.h"


@interface SDDataHelper : NSObject

+ (void)addToShirts:(UIImage *)image;

+ (void)addToPants:(UIImage *)image;

+ (NSArray *)getAllShirtsByBookmark:(BOOL)option;

+ (NSArray *)getAllPantsByBookmark:(BOOL)option;

+ (BOOL)toggleShirtBookmark:(Shirt *)shirt;

+ (BOOL)togglePantBookmark:(Pant *)pant;

+ (void)spawnBackgroundAssetSave;

+ (void)purgeDefaultAssets;

@end
