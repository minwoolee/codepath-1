//
//  MovieCollectionViewCell.m
//  Flicks
//
//  Created by Min Lee on 1/26/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import "MovieCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MovieCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MovieCollectionViewCell

- (void)setMovie:(MovieModel *)movie
{
    _movie = movie;
    self.titleLabel.text = movie.title;
    [self.posterImage setImageWithURL:movie.posterUrl];
}

@end
