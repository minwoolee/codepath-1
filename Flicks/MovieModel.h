//
//  MovieModel.h
//  Flicks
//
//  Created by Min Lee on 1/23/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSURL *posterUrl;
@property (nonatomic, strong) NSURL *backgroundImageUrl;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *runningTime;
@property (nonatomic, strong) NSString *ratings;

-(id) initWithDictionary:(NSDictionary *)dictionary;

@end
