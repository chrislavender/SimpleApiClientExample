//
//  Movie.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Movie : NSManagedObject

@property (nonatomic, retain) NSNumber * unique_id;
@property (nonatomic, retain) NSString * original_title;
@property (nonatomic, retain) NSDate * release_date;
@property (nonatomic, retain) NSString * poster_path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * vote_average;
@property (nonatomic, retain) NSNumber * vote_count;

@end
