//
//  AppDelegate.m
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/11/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

NSString * const kBaseUrl = @"http://api.themoviedb.org/3";
NSString * const kApiKey = @"87058d4d847d8079e15a17ec036011cb";

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleApiClientExample" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimpleApiClientExample.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
//      If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//      * Simply deleting the existing store:
        
        // CL: check to see if there is a planned schema change
        if ([self shouldDeleteOldDatabase] && [[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
            
            NSError* error = nil;
            
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
            
            if (error) {
                NSLog(@"Error:\n%@ // [%@ %@]",
                      error.userInfo,
                      NSStringFromClass([self class]),
                      NSStringFromSelector(_cmd));
            } else {
                NSLog(@"Previous CoreData store deleted! // [%@ %@]",
                      NSStringFromClass([self class]),
                      NSStringFromSelector(_cmd));
            }
            
        } else {
            // CL: otherwise.... something is seriously wrong.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)shouldDeleteOldDatabase
{
    BOOL result = NO;

    /*
     CL: here we're stashing a key in UserDefaults & comparing against
     a key in the -info.plist (CoreDataVersion in this case).
     This way we can explicitly update the schema and force 
     a CoreData refresh from a server database
     */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRecordedVersion = [defaults objectForKey:@"Version"];
    NSString *thisVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CoreDataVersion"];
    
    if (![lastRecordedVersion isEqualToString:thisVersion]) {
        
        NSLog(@"LAST Recorded Version: %@  THIS Version: %@ // [%@ %@]",
              lastRecordedVersion,
              thisVersion,
              NSStringFromClass([self class]),
              NSStringFromSelector(_cmd));
        
        [defaults setObject:thisVersion forKey:@"Version"];
        
        // you shouldn't need to explicitly synchronize here
        //[defaults synchronize];
        
        result = YES;
    }
    
    return result;
}

#pragma mark - ApiClient

- (ApiClient *)apiClient
{
    if (!_apiClient) {
        _apiClient = [[ApiClient alloc] initWithBaseUrl:kBaseUrl];
    }
    
    return _apiClient;
}

@end
