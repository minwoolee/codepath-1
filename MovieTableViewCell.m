//
//  MovieCell.m
//  Flicks
//
//  Created by Min Lee on 1/23/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import "MovieTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MovieTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;

@end

@implementation MovieTableViewCell

- (void)setMovie:(MovieModel *)movie;
{
    _movie = movie;
    [self.titleLabel setText:movie.title];
    [self.overviewLabel setText:movie.overview];
    [self.posterImage setImageWithURL:movie.posterUrl];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
