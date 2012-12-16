//
//  ApiClient+Movie.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient.h"

@interface ApiClient (Movie)

//GET /3/movie/{id}
//Returns a specific movie
- (void)getMovieWithID:(NSNumber *)uniqueID
           andCallback:(CallbackHandlerBlock)handler;

//GET /3/movie/upcoming
//Returns a list of Upcoming Movies
- (void)getUpcomingMoviesUsingCallback:(CallbackHandlerBlock)handler;

@end
