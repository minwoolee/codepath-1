//
//  MovieCollectionViewCell.h
//  Flicks
//
//  Created by Min Lee on 1/26/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieModel.h"

@interface MovieCollectionViewCell : UICollectionViewCell <MovieCell>

@property (strong, nonatomic) MovieModel *movie;

@end
