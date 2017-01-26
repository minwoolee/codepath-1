//
//  MovieModel.m
//  Flicks
//
//  Created by Min Lee on 1/23/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

-(id) initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    if (self) {
        self.title = dictionary[@"original_title"];
        self.overview = dictionary[@"overview"];
        self.posterUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://image.tmdb.org/t/p/w45%@", dictionary[@"poster_path"]]];
        self.backgroundImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", dictionary[@"poster_path"]]];
        self.releaseDate = dictionary[@"release_date"];
        self.ratings = (dictionary[@"vote_average"])? [NSString stringWithFormat:@"%@", dictionary[@"vote_average"]] : @"N/A";
    }
    return self;
}

@end

