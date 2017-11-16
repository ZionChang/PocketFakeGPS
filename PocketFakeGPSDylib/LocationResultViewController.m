//
//  LocationResultViewController.m
//  PocketFackGPSDylib
//
//  Created by zz on 2017/11/16.
//  Copyright © 2017年 zz. All rights reserved.
//

#import "LocationResultViewController.h"

@interface LocationResultViewController ()

@end

@implementation LocationResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MKMapItem *item = self.mapItems[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [item.placemark.addressDictionary[@"FormattedAddressLines"] firstObject], item.placemark.addressDictionary[@"Name"]];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *item = self.mapItems[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.didSelectMapItemHandler) {
        self.didSelectMapItemHandler(item, cell.textLabel.text);
    }
}


@end
