//
//  ApiClient+Movie.m
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient+Movie.h"
#import "ApiClient+AuthParams.h"

static NSString *moviePath = @"movie";

@implementation ApiClient (Movie)

//GET /3/movie/{id}
//Returns a specific movie
- (void)getMovieWithID:(NSNumber *)uniqueID
           andCallback:(CallbackHandlerBlock)handler
{
    [self requestWithPath:moviePath
                   method:[NSString stringWithFormat:@"%@",uniqueID]
                getParams:[ApiClient authorizationGetParams]
               postParams:nil
              andCallback:handler];
}

//GET /3/movie/upcoming
//Returns a list of Upcoming Movies
- (void)getUpcomingMoviesUsingCallback:(CallbackHandlerBlock)handler
{
    [self requestWithPath:moviePath
                   method:@"upcoming"
                getParams:[ApiClient authorizationGetParams]
               postParams:nil
              andCallback:handler];
}

@end
