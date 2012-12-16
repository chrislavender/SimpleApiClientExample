//
//  Movie+Create.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "Movie.h"

@interface Movie (Create)

// Returns an NSArray of upcoming movies
+ (void)getUpcomingMoviesInManagedObjectContext:(NSManagedObjectContext *)context
                                      withBlock:(void(^)(NSArray *, NSError *))handler;

// returns a specific movie
+ (void)getMovieWithID:(NSNumber *)uniqueID
inManagedObjectContext:(NSManagedObjectContext *)context
             withBlock:(void(^)(Movie *, NSError *))handler;
@end
