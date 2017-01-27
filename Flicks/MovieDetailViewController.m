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
    
    // load image from cache first
    [self.backgroundImage setImageWithURL:self.movie.posterUrl];
    
    [self.titleLabel setText:self.movie.title];
    [self.releaseDateLabel setText:self.movie.releaseDate];
    [self.ratingLabel setText:self.movie.ratings];
    [self.runningTimeLabel setText:self.movie.runningTime];
    [self.overviewLabel setText:self.movie.overview];
    [self.overviewLabel sizeToFit];

    CGFloat paddingY = 25;
    CGRect frame = self.detailView.frame;
    CGFloat newHeight = self.labelGroupView.frame.size.height + self.overviewLabel.frame.size.height + paddingY;
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, newHeight);
    self.detailView.frame = newFrame;
    
    CGFloat offsetY = 150;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.detailView.frame),
                                             CGRectGetHeight(self.detailView.frame) + paddingY);
    
    [self loadDetails];
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

- (void)loadDetails;
{
    NSString *const APIKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";

    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.movie.id, APIKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSString *runningTime = [NSString stringWithFormat:@"%@ minutes", responseDictionary[@"runtime"]];
                                                    if (runningTime) {
                                                        [self.runningTimeLabel setText:runningTime];
                                                    }
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];

    // also load high-res image here
    [self.backgroundImage setImageWithURL:self.movie.backgroundImageUrl];

}

@end
