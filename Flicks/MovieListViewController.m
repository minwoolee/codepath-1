//
//  ViewController.m
//  Flicks
//
//  Created by Min Lee on 1/23/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import "MovieListViewController.h"
#import "Constants.h"
#import "MovieTableViewCell.h"
#import "MovieCollectionViewCell.h"
#import "MovieDetailViewController.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MovieListViewController ()
    <UITableViewDataSource, UITableViewDelegate,
     UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
     UISearchBarDelegate>

@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (strong, nonatomic) NSArray<MovieModel *> *filteredMovies;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *moviesCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *moviesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.moviesTableView addSubview:self.refreshControl];

    self.networkErrorView.hidden = YES;
    [self.view addSubview:self.networkErrorView];

    self.moviesTableView.dataSource = self;
    self.moviesTableView.delegate = self;
    
    self.moviesCollectionView.dataSource = self;
    self.moviesCollectionView.delegate = self;

    // If setting up search bars programmatically
//    self.searchBar = [UISearchBar new];
//    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;

    [self.segmentedControl addTarget:self
                         action:@selector(segmentChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [self fetchMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat top = [self.topLayoutGuide length];
    CGFloat bottom = [self.bottomLayoutGuide length];
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0, bottom, 0);
    self.moviesCollectionView.contentInset = insets;
    self.moviesTableView.contentInset = insets;
    
    CGRect networkErrorViewFrame = self.networkErrorView.frame;
    networkErrorViewFrame.origin.y = top;
    self.networkErrorView.frame = networkErrorViewFrame;
}

#pragma mark -
#pragma mark UITableView delegates and data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.filteredMovies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MovieModel *movie = self.filteredMovies[indexPath.row];

    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    cell.movie = movie;     
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 135;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.moviesTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    // TODO: imporove? 
    MovieModel *movie = nil;
    if ([sender isKindOfClass:[MovieTableViewCell class]]) {
        movie = ((MovieTableViewCell *)sender).movie;
    } else if ([sender isKindOfClass:[MovieCollectionViewCell class]]) {
        movie = ((MovieCollectionViewCell *)sender).movie;
    }
    MovieDetailViewController *movieDetailViewController = segue.destinationViewController;
    movieDetailViewController.movie = movie;
}

#pragma mark -
#pragma mark UICollectionView delegates and data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.filteredMovies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    MovieModel *movie = self.filteredMovies[indexPath.row];

    MovieCollectionViewCell *cell = [self.moviesCollectionView dequeueReusableCellWithReuseIdentifier:@"movieCollectionCell" forIndexPath:indexPath];
    cell.movie = movie;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    int itemsPerRow = 3;
    CGFloat width = self.view.frame.size.width / itemsPerRow;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    return 0;
}


#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    NSString *input = searchBar.text;
    if (input.length == 0) {
        self.filteredMovies = self.movies;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSString *title = ((MovieModel*)evaluatedObject).title;
            NSRange range = [title rangeOfString:input options:NSCaseInsensitiveSearch];
            return range.location != NSNotFound;
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
    }
    [self reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
{
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;
{
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredMovies = self.movies;
    [self reloadData];
}

#pragma mark -
#pragma mark application methods

-(void) fetchMovies;
{
    NSDictionary *tapTitleUrlMap = @{
      @"Now Playing" : @"https://api.themoviedb.org/3/movie/now_playing?api_key=",
      @"Top Rated" : @"https://api.themoviedb.org/3/movie/top_rated?api_key="
    };
    NSString *tabTitle = self.navigationController.tabBarItem.title;
    NSString *urlString = [[tapTitleUrlMap objectForKey:tabTitle] stringByAppendingString:API_KEY];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                self.networkErrorView.hidden = (error == nil);
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
//                                                    NSLog(@"Response: %@", responseDictionary);
                                                    // TODO: verify return value
                                                    NSMutableArray *movies = [NSMutableArray new];
                                                    for (NSDictionary *movie in responseDictionary[@"results"]) {
                                                        [movies addObject:[[MovieModel alloc] initWithDictionary:movie]];
                                                    }
                                                    self.movies = movies;
                                                    self.filteredMovies = self.movies;
                                                    [self reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                                [self.refreshControl endRefreshing];
                                                [MBProgressHUD hideHUDForView:mainWindow animated:YES];
                                            }];
    [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    [task resume];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl;
{
    [self fetchMovies];
    [self reloadData];
    [self.refreshControl endRefreshing];
}

- (void)segmentChanged:(UISegmentedControl *)segmentedControl;
{
    self.moviesCollectionView.hidden = (segmentedControl.selectedSegmentIndex == 0);
    self.moviesTableView.hidden = !(self.moviesCollectionView.hidden);
    [self reloadData];
}

- (void)reloadData;
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.moviesTableView reloadData];
    } else {
        [self.moviesCollectionView reloadData];
    }
}

@end
