//
//  LocationResultViewController.h
//  PocketFackGPSDylib
//
//  Created by zz on 2017/11/16.
//  Copyright © 2017年 zz. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

typedef void(^DidSelectMapItemHandler)(MKMapItem *, NSString *);

@interface LocationResultViewController : UITableViewController

@property (nonatomic, copy) NSArray<MKMapItem *> *mapItems;

@property (nonatomic, copy) DidSelectMapItemHandler didSelectMapItemHandler;

@end
