//
//  Movie+Create.m
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "Movie+Create.h"
#import "ApiClient+Movie.h"
#import "AppDelegate.h"

@implementation Movie (Create)

// returns a specific movie
+ (void)getMovieWithID:(NSNumber *)uniqueID
inManagedObjectContext:(NSManagedObjectContext *)context
             withBlock:(void(^)(Movie *, NSError *))handler
{
    __block NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    request.predicate = [NSPredicate predicateWithFormat:@"unique_id == %@", uniqueID];
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
        NSLog(@"Error: nil matches. // [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    } else {
        
        if ([matches count] > 1) {
            
            // WTF?  Best to just dump both and re-fetch
            NSLog(@"Error: multiple matches. // [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            
            for (id object in matches) {
                [context deleteObject:object];
            }
        }
        
        /*
         Here you would do any kind of checks for "data freshness".
         You should always return data at this point so somthing can be displayed.
         However, if need be you can also send a request to get the latest stuff.
         */

        CallbackHandlerBlock callback = [self movieCallbackUsingManagedObjectContext:context
                                                                            andBlock:handler];
        
        [((AppDelegate *)[UIApplication sharedApplication].delegate).apiClient getMovieWithID:uniqueID
                                                                                  andCallback:callback];
        
        if (handler) handler([matches lastObject], error);
    }
}

// Returns an NSArray of upcoming movies
+ (void)getUpcomingMoviesInManagedObjectContext:(NSManagedObjectContext *)context
                                      withBlock:(void(^)(NSArray *, NSError *))handler
{
    /*
     In this case the presumption is that an NSFetchedResultsController is being used
     by the requesting ViewController.  In this case the view controller will have 
     already fetched data from the database.  However, if an NSFetchedResultsController
     is not being used, you can manually fetch here before making the api request.
     */
    
    CallbackHandlerBlock callback = [self movieArrayCallbackUsingManagedObjectContext:context
                                                                             andBlock:handler];
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate).apiClient getUpcomingMoviesUsingCallback:callback];
}

#pragma mark- Server Callbacks
// For returning a single Object
+ (CallbackHandlerBlock)movieCallbackUsingManagedObjectContext:(NSManagedObjectContext *)context
                                                      andBlock:(void(^)(Movie *, NSError *))handler
{
    CallbackHandlerBlock callback = ^ (id response)
    {
        /*
         since NSManagedObjectContext is not thread safe and
         it's likely that we're updating the UI, make sure
         we jump back onto the main thread here.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            Movie *newMovie = nil;
            
            if ([response isKindOfClass:[NSError class]]) {
                error = response;
            
            } else if ([response isKindOfClass:[NSDictionary class]]) {
                newMovie = [[self class] movieWithDictionary:response
                                      inManagedObjectContext:context];
            } else {
                // if it isn't a dictionary than return an error.
                NSString *description = @"The api did not return a dictionary";
                NSDictionary *userDict = [NSDictionary dictionaryWithObject:description
                                                                     forKey:NSLocalizedDescriptionKey];
                
                error = [[NSError alloc] initWithDomain:@"API"
                                                   code:0
                                               userInfo:userDict];

            }
            
            if(handler)handler(newMovie, error);
        });
    };
    
    return callback;
}

// For returning an NSArray
+ (CallbackHandlerBlock)movieArrayCallbackUsingManagedObjectContext:(NSManagedObjectContext *)context
                                                           andBlock:(void(^)(NSArray *, NSError *))handler
{
    CallbackHandlerBlock callback = ^ (id response)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            NSArray *movieArray = nil;
            
            if ([response isKindOfClass:[NSError class]]) {
                error = response;
            
            } else if ([response isKindOfClass:[NSDictionary class]]) {
                
                NSArray *rawMovies = [response objectForKey:@"results"];
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[rawMovies count]];
                
                for (NSDictionary *rawMovie in rawMovies) {
                    
                    Movie *newMovie = [[self class] movieWithDictionary:rawMovie
                                                 inManagedObjectContext:context];
                    
                    if (newMovie)[tempArray addObject:newMovie];
                }
                
                movieArray = [NSArray arrayWithArray:tempArray];

            } else {
                // if it isn't a dictionary than return an error.
                NSString *description = @"The api did not return an array";
                NSDictionary *userDict = [NSDictionary dictionaryWithObject:description
                                                                     forKey:NSLocalizedDescriptionKey];
                
                error = [[NSError alloc] initWithDomain:@"API"
                                                   code:0
                                               userInfo:userDict];
                
            }
            
            if(handler)handler(movieArray, error);
        });
    };
    
    return callback;
}


#pragma mark- CoreData
+ (Movie *)movieWithDictionary:(NSDictionary *)jsonObject
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    Movie *newObj = nil;
    
    NSNumber *uniqueID = [NSNumber numberWithInt:[[jsonObject valueForKey:@"id"]intValue]];
    
    // check for preexisting instance before creating or fetching a new one.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    request.predicate = [NSPredicate predicateWithFormat:@"unique_id == %@", uniqueID];
    
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
        NSLog(@"Error: nil matches. // [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
    } else if ([matches count] > 1) {
        NSLog(@"Error: multiple matches. // [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        // WTF?  Probably switching servers here so just get rid of the stored data
        for (id object in matches) {
            [context deleteObject:object];
        }
        // and create a fresh one from the what the server gives us
        newObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
        [[self class] parseJSON:jsonObject forObj:newObj inContext:context];
        
    } else if ([matches count] == 0) {
        newObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
        [[self class] parseJSON:jsonObject forObj:newObj inContext:context];
        
    } else {
        newObj = [matches lastObject];
        // CL: if there's one already in the DataBase update it anyway.
        [[self class] parseJSON:jsonObject forObj:newObj inContext:context];
    }
    
    return newObj;
}

+ (void)parseJSON:(NSDictionary *)jsonObject forObj:(Movie *)newObj inContext:(NSManagedObjectContext *)context
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    newObj.unique_id        = [NSNumber numberWithInt:[[jsonObject valueForKey:@"id"]intValue]];
    newObj.release_date     = [dateFormatter dateFromString:[jsonObject valueForKey:@"release_date"]];
    newObj.original_title   = [jsonObject valueForKey:@"original_title"];
    newObj.title            = [jsonObject valueForKey:@"title"];
    newObj.poster_path      = [NSString stringWithFormat: @"http://cf2.imgobject.com/t/p/w342/%@", [jsonObject valueForKey:@"poster_path"]];
    newObj.vote_average     = [NSNumber numberWithInt:[[jsonObject valueForKey:@"vote_average"]intValue]];
    newObj.vote_count       = [NSNumber numberWithInt:[[jsonObject valueForKey:@"vote_count"]intValue]];
}

@end
