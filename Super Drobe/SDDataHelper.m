//
//  SDDataHelper.m
//  Super Drobe
//
//  Created by yogesh singh on 09/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "SDDataHelper.h"
#import "SDAppDelegate.h"
#import "SDUtils.h"

@implementation SDDataHelper

+ (void)addToShirts:(UIImage *)image{

    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];

    Shirt *newShirt = [NSEntityDescription insertNewObjectForEntityForName:@"Shirt"
                                                    inManagedObjectContext:appDelegate.managedObjectContext];
    newShirt.img = UIImagePNGRepresentation(image);
    newShirt.isBookmarked = [NSNumber numberWithBool:NO];
    newShirt.isDisliked   = [NSNumber numberWithBool:NO];
    newShirt.isDefault    = [NSNumber numberWithBool:NO];
    
    NSError *saveErr = nil;
    if([appDelegate.managedObjectContext save:&saveErr]){
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_UPDATE_SHIRTS_VIEW object:nil];
    }
    else{
        NSLog(@"SDDataHelper addToShirts save error : %@", saveErr.localizedDescription);
    }
}

+ (void)addToPants:(UIImage *)image{
    
    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Pant *newPant = [NSEntityDescription insertNewObjectForEntityForName:@"Pant"
                                                    inManagedObjectContext:appDelegate.managedObjectContext];
    newPant.img = UIImagePNGRepresentation(image);
    newPant.isBookmarked = [NSNumber numberWithBool:NO];
    newPant.isDisliked   = [NSNumber numberWithBool:NO];
    newPant.isDefault    = [NSNumber numberWithBool:NO];
    
    NSError *saveErr = nil;
    if([appDelegate.managedObjectContext save:&saveErr]){
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_UPDATE_PANTS_VIEW object:nil];
    }
    else{
        NSLog(@"SDDataHelper addToPants save error : %@", saveErr.localizedDescription);
    }
}

+ (NSArray *)getAllShirtsByBookmark:(BOOL)option{

    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shirt"];
    
    BOOL shouldUseDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isUsingDefaultAssets"] boolValue];
    
    NSPredicate *defaultsPred  = [NSPredicate predicateWithFormat:@"isDefault == %@", [NSNumber numberWithBool:shouldUseDefaults]];
    
    if (option) {
        NSPredicate *bookmarksPred = [NSPredicate predicateWithFormat:@"isBookmarked == %@", [NSNumber numberWithBool:option]];
        
        NSCompoundPredicate *compoundPred = [NSCompoundPredicate andPredicateWithSubpredicates:@[defaultsPred, bookmarksPred]];
        [request setPredicate:compoundPred];
    }
    else{
        [request setPredicate:defaultsPred];
    }
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) NSLog(@"SDDataHelper getAllShirts fetchErr : %@", fetchErr.localizedDescription);
    
    return fetchedResults;
}

+ (NSArray *)getAllPantsByBookmark:(BOOL)option{
    
    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pant"];
    
    BOOL shouldUseDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isUsingDefaultAssets"] boolValue];
    
    NSPredicate *defaultsPred  = [NSPredicate predicateWithFormat:@"isDefault == %@", [NSNumber numberWithBool:shouldUseDefaults]];
    
    if (option) {
        NSPredicate *bookmarksPred = [NSPredicate predicateWithFormat:@"isBookmarked == %@", [NSNumber numberWithBool:option]];
        
        NSCompoundPredicate *compoundPred = [NSCompoundPredicate andPredicateWithSubpredicates:@[defaultsPred, bookmarksPred]];
        [request setPredicate:compoundPred];
    }
    else{
        [request setPredicate:defaultsPred];
    }
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr)  NSLog(@"SDDataHelper getAllPants fetchErr : %@", fetchErr.localizedDescription);
    
    return fetchedResults;
}

//can be extended to include add & remove bookmarks function
+ (BOOL)toggleShirtBookmark:(Shirt *)shirt{
    
    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shirt"];
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"SDDataHelper toggleShirtBookmark fetchErr : %@", fetchErr.localizedDescription);
    }
    
    for (Shirt *fetchedShirt in fetchedResults) {
        if (fetchedShirt == shirt) {
            shirt.isBookmarked = [NSNumber numberWithBool:YES];    //use : (![shirt.isBookmarked boolValue]) for toggling
        }
    }
    
    NSError *saveErr = nil;
    if(![appDelegate.managedObjectContext save:&saveErr]){
        NSLog(@"SDDataHelper toggleShirtBookmark save error : %@", saveErr.localizedDescription);
    }
    
    return [shirt.isBookmarked boolValue];
}

//can be extended to include add & remove bookmarks function
+ (BOOL)togglePantBookmark:(Pant *)pant{
   
    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pant"];
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"SDDataHelper togglePantBookmark fetchErr : %@", fetchErr.localizedDescription);
    }
    
    for (Pant *fetchedPant in fetchedResults) {
        if (fetchedPant == pant) {
            pant.isBookmarked = [NSNumber numberWithBool:YES];     //use : (![pant.isBookmarked boolValue]) for toggling
        }
    }
    
    NSError *saveErr = nil;
    if(![appDelegate.managedObjectContext save:&saveErr]){
        NSLog(@"SDDataHelper togglePantBookmark save error : %@", saveErr.localizedDescription);
    }
    
    return [pant.isBookmarked boolValue];
}

+ (void)spawnBackgroundAssetSave{

    BOOL assetsExist = [[[NSUserDefaults standardUserDefaults] objectForKey:@"assetsExist"] boolValue];
    
    if (!assetsExist) {
     
        SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        for (int i = 1; i <= 7; i++) {
            
            NSLog(@"spawnBackgroundAssetSave creating pair %d of 7", i);
            
            Shirt *newShirt = [NSEntityDescription insertNewObjectForEntityForName:@"Shirt"
                                                        inManagedObjectContext:appDelegate.managedObjectContext];
            
            newShirt.img = UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"shirt%d",i]]);
            newShirt.isBookmarked = [NSNumber numberWithBool:NO];
            newShirt.isDisliked   = [NSNumber numberWithBool:NO];
            newShirt.isDefault    = [NSNumber numberWithBool:YES];
            
            Pant *newPant   = [NSEntityDescription insertNewObjectForEntityForName:@"Pant"
                                                            inManagedObjectContext:appDelegate.managedObjectContext];
            
            newPant.img = UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"pant%d",i]]);
            newPant.isBookmarked  = [NSNumber numberWithBool:NO];
            newPant.isDisliked    = [NSNumber numberWithBool:NO];
            newPant.isDefault     = [NSNumber numberWithBool:YES];
        }
    
        if (appDelegate.managedObjectContext.hasChanges) {

            NSError *saveErr;
            if ([appDelegate.managedObjectContext save:&saveErr]) {
                NSLog(@"spawnBackgroundAssetSave assets saved successfully");
            }
            else{
                NSLog(@"SDDataHelper spawnBackgroundAssetSave error : %@",saveErr.localizedDescription);
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"assetsExist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)purgeDefaultAssets{
    
    BOOL shouldUseDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isUsingDefaultAssets"] boolValue];
    
    if (!shouldUseDefaults) {
        
        SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        for (NSString *item in @[@"Shirt", @"Pant"]) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:item];
            
            NSPredicate *defaultsPred  = [NSPredicate predicateWithFormat:@"isDefault == %@", [NSNumber numberWithBool:YES]];
            
            [request setPredicate:defaultsPred];
            
            NSError *fetchErr = nil;
            NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
            
            if (fetchErr) NSLog(@"SDDataHelper purgeDefaultAssets fetchErr : %@", fetchErr.localizedDescription);
            
            for (NSManagedObject *obj in fetchedResults) {
                
                [appDelegate.managedObjectContext deleteObject:obj];
            }
        }
        
        if (appDelegate.managedObjectContext.hasChanges) {
            
            NSError *saveErr;
            if ([appDelegate.managedObjectContext save:&saveErr]) {
                NSLog(@"purgeDefaultAssets assets purged successfully");
            }
            else{
                NSLog(@"SDDataHelper purgeDefaultAssets error : %@",saveErr.localizedDescription);
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"assetsExist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end














