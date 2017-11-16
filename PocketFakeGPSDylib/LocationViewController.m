//
//  TestViewController.m
//  PocketFackGPSDylib
//
//  Created by zz on 2017/11/15.
//  Copyright © 2017年 zz. All rights reserved.
//

#import "LocationViewController.h"
#import "LocationResultViewController.h"
@import MapKit;

@interface LocationViewController () <UISearchResultsUpdating, CLLocationManagerDelegate>

@property (nonatomic, strong) LocationResultViewController *resultVC;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKPointAnnotation *lastAnnotation;

@end

@implementation LocationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    __weak LocationViewController *weakSelf = self;
    self.resultVC.didSelectMapItemHandler = ^(MKMapItem *mapItem, NSString *title) {
        [weakSelf dismissViewControllerAnimated:true completion:nil];
        // 移动
        MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
        MKCoordinateRegion region = MKCoordinateRegionMake(mapItem.placemark.coordinate, span);
        [weakSelf.mapView setRegion:region animated:YES];
        // 添加
        CLLocationCoordinate2D newCoordinate = mapItem.placemark.coordinate;
        // 判重
        if (weakSelf.lastAnnotation.coordinate.latitude == newCoordinate.latitude && weakSelf.lastAnnotation.coordinate.longitude == newCoordinate.longitude) {
            return;
        }
        // 添加大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.coordinate;
        annotation.title = title;
        [weakSelf.mapView removeAnnotation:weakSelf.lastAnnotation];
        [weakSelf.mapView addAnnotation:annotation];
        weakSelf.lastAnnotation = annotation;
        // 弹框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"🎉定位成功啦" message:nil preferredStyle:UIAlertControllerStyleAlert];
        // 本地化
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setDouble:newCoordinate.latitude forKey:@"zz_latitude"];
        [ud setDouble:newCoordinate.longitude forKey:@"zz_longitude"];
        [ud setObject:title forKey:@"zz_title"];
        // dismiss
        [weakSelf presentViewController:alertController animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        });
    };
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"回到过去" style:UIBarButtonItemStylePlain target:self action:@selector(didTapRefreshItem)];
    self.navigationItem.rightBarButtonItem = refreshItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupUI {
    self.title = @"定位";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.locationManager startUpdatingLocation];
    [self.view addSubview:self.mapView];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController: self.resultVC];
    searchController.obscuresBackgroundDuringPresentation = NO;
    searchController.searchResultsUpdater = self;
    self.navigationItem.searchController = searchController;
    self.definesPresentationContext = YES;
    
}

#pragma mark - action

- (void)didTapRefreshItem {
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    [self.mapView setRegion:MKCoordinateRegionMake(_mapView.userLocation.coordinate, span) animated:YES];
    [self.mapView removeAnnotation:self.lastAnnotation];
    self.lastAnnotation = nil;
}


#pragma mark - getter

- (LocationResultViewController *)resultVC {
    if (!_resultVC) {
        _resultVC = [LocationResultViewController new];
    }
    return _resultVC;
}

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        double latitude = [ud doubleForKey:@"zz_latitude"];
        double longitude = [ud doubleForKey:@"zz_longitude"];
        NSString *title = [ud stringForKey:@"zz_title"];
        if (!title) {
            [_mapView setRegion:MKCoordinateRegionMake(_mapView.userLocation.coordinate, span) animated:YES];
        } else {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = coordinate;
            annotation.title = title;
            [_mapView addAnnotation:annotation];
            self.lastAnnotation = annotation;
            [_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), span) animated:YES];
        }
        
    }
    return _mapView;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = searchController.searchBar.text;
    MKLocalSearch *ls = [[MKLocalSearch alloc] initWithRequest:request];
    [ls startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        self.resultVC.mapItems = response.mapItems;
        [self.resultVC.tableView reloadData];
    }];
}

@end
