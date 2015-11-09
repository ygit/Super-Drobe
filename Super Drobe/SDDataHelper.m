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
    
    NSError *saveErr = nil;
    if([appDelegate.managedObjectContext save:&saveErr]){
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDED_NEW_SHIRT_UPDATE_VIEW object:nil];
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
    
    NSError *saveErr = nil;
    if([appDelegate.managedObjectContext save:&saveErr]){
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDED_NEW_PANT_UPDATE_VIEW object:nil];
    }
    else{
        NSLog(@"SDDataHelper addToPants save error : %@", saveErr.localizedDescription);
    }
}

+ (NSArray *)getAllShirtsByBookmark:(BOOL)option{

    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shirt"];
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (option) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"isBookmarked == %@", [NSNumber numberWithBool:YES]];
        [request setPredicate:pred];
    }
    
    if (fetchErr) {
        NSLog(@"SDDataHelper getAllShirts fetchErr : %@", fetchErr.localizedDescription);
    }
    
    return fetchedResults;
}

+ (NSArray *)getAllPantsByBookmark:(BOOL)option{
    
    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pant"];
    
    if (option) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"isBookmarked == %@", [NSNumber numberWithBool:YES]];
        [request setPredicate:pred];
    }
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"SDDataHelper getAllPants fetchErr : %@", fetchErr.localizedDescription);
    }
    
    return fetchedResults;
}

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
            shirt.isBookmarked = [NSNumber numberWithBool:(![shirt.isBookmarked boolValue])];
        }
    }
    
    NSError *saveErr = nil;
    if(![appDelegate.managedObjectContext save:&saveErr]){
        NSLog(@"SDDataHelper toggleShirtBookmark save error : %@", saveErr.localizedDescription);
    }
    
    return [shirt.isBookmarked boolValue];
}

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
            pant.isBookmarked = [NSNumber numberWithBool:(![pant.isBookmarked boolValue])];
        }
    }
    
    NSError *saveErr = nil;
    if(![appDelegate.managedObjectContext save:&saveErr]){
        NSLog(@"SDDataHelper togglePantBookmark save error : %@", saveErr.localizedDescription);
    }
    
    return [pant.isBookmarked boolValue];
}

@end
