//
//  MasterViewController.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/11/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
