//
//  AppDelegate.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/11/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiClient.h"

NSString * const kBaseUrl;
NSString * const kApiKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ApiClient *apiClient;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
