//
//  Pant+CoreDataProperties.h
//  Super Drobe
//
//  Created by yogesh singh on 12/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pant.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pant (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *img;
@property (nullable, nonatomic, retain) NSNumber *isBookmarked;
@property (nullable, nonatomic, retain) NSNumber *isDisliked;
@property (nullable, nonatomic, retain) NSNumber *isDefault;

@end

NS_ASSUME_NONNULL_END
