//
//  MovieCell.h
//  Flicks
//
//  Created by Min Lee on 1/23/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;

@end
