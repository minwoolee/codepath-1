//
//  MovieDetailViewController.m
//  Flicks
//
//  Created by Min Lee on 1/24/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import "MovieDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MovieDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *labelGroupView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *runningTimeLabel;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.movie.backgroundImageUrl) {
        [self.backgroundImage setImageWithURL:self.movie.backgroundImageUrl];
    }
    
    [self.titleLabel setText:self.movie.title];
    [self.releaseDateLabel setText:self.movie.releaseDate];
    [self.ratingLabel setText:self.movie.ratings];
    [self.overviewLabel setText:self.movie.overview];
    [self.overviewLabel sizeToFit];

    CGFloat paddingY = 25;
    CGRect frame = self.detailView.frame;
    CGFloat newHeight = self.labelGroupView.frame.size.height + self.overviewLabel.frame.size.height + paddingY;
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, newHeight);
    self.detailView.frame = newFrame;
    
    CGFloat offsetY = 150;
    
//    self.scrollView.backgroundColor = [UIColor yellowColor];
    self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.detailView.frame),
                                             CGRectGetHeight(self.detailView.frame) + paddingY);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
