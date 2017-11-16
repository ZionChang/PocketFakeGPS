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
@property (nonatomic, strong) NSMutableArray *annotations;

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
        for (MKPointAnnotation *annotation in weakSelf.annotations) {
            if (annotation.coordinate.latitude == newCoordinate.latitude && annotation.coordinate.longitude == newCoordinate.longitude) {
                return;
            }
        }
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.coordinate;
        annotation.title = title;
        [weakSelf.mapView addAnnotation:annotation];
        [weakSelf.annotations addObject:annotation];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"你确定是不是这个位置" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不是" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"就是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setDouble:newCoordinate.latitude forKey:@"zz_latitude"];
            [ud setDouble:newCoordinate.longitude forKey:@"zz_longitude"];
            [ud setObject:title forKey:@"zz_title"];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"重新定位" style:UIBarButtonItemStylePlain target:self action:@selector(didTapRefreshItem)];
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
    [self.mapView removeAnnotations:self.annotations];
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
            [self.annotations addObject:annotation];
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

- (NSMutableArray *)annotations {
    if (!_annotations) {
        _annotations = [NSMutableArray array];
    }
    return _annotations;
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
