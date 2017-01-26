//
//  ViewController.m
//  Flicks
//
//  Created by Min Lee on 1/23/17.
//  Copyright © 2017 Min Lee. All rights reserved.
//

#import "MovieListViewController.h"
#import "MovieTableViewCell.h"
#import "MovieDetailViewController.h"
#import "MovieModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (strong, nonatomic) NSArray<MovieModel *> *filteredMovies;
@property (strong, nonatomic) UIView *networkErrorView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *moviesTableView;

@end

@implementation MovieListViewController

NSString *const APIKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.moviesTableView addSubview:self.refreshControl];

    self.networkErrorView = [[[NSBundle mainBundle] loadNibNamed:@"NetworkErrorView" owner:self options:nil] lastObject];
    self.networkErrorView.hidden = YES;
    [self.moviesTableView addSubview:self.networkErrorView];

    self.moviesTableView.dataSource = self;
    self.moviesTableView.delegate = self;

    self.searchBar.delegate = self;

    [self fetchMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark TableView delegates and data source methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.filteredMovies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    
    MovieModel *movie = self.filteredMovies[indexPath.row];
    
    [cell.titleLabel setText:movie.title];
    [cell.overviewLabel setText:movie.overview];
    
    cell.posterImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.posterImage setImageWithURL:movie.posterUrl];
     
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
    NSIndexPath *indexPath = [self.moviesTableView indexPathForSelectedRow];
    MovieDetailViewController *movieDetailViewController = segue.destinationViewController;
    movieDetailViewController.movie = self.filteredMovies[indexPath.row];
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
    [self.moviesTableView reloadData];
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
    [self.moviesTableView reloadData];
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
    NSString *urlString = [[tapTitleUrlMap objectForKey:tabTitle] stringByAppendingString:APIKey];

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
                                                    [self.moviesTableView reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                                [self.refreshControl endRefreshing];
                                                [MBProgressHUD hideHUDForView:mainWindow animated:YES];
                                            }];
    [MBProgressHUD showHUDAddedTo:mainWindow animated:YES];
    [task resume];
}

-(void)handleRefresh:(UIRefreshControl *)refreshControl;
{
    [self fetchMovies];
    [self.moviesTableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
