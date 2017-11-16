//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  PocketFakeGPSDylib.m
//  PocketFakeGPSDylib
//
//  Created by zz on 2017/11/16.
//  Copyright (c) 2017年 zz. All rights reserved.
//

#import "PocketFakeGPSDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import "LocationViewController.h"
@import CoreLocation;

static __attribute__((constructor)) void entry(){
    NSLog(@"\n               🎉!!！congratulations!!！🎉\n👍----------------insert dylib success----------------👍");
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        CYListenServer(6666);
    }];
}


#pragma mark - MOASettingViewController

CHDeclareClass(MOASettingViewController)

CHOptimizedMethod1(self, void, MOASettingViewController, viewWillAppear, BOOL, animated) {
    CHSuper1(MOASettingViewController, viewWillAppear, animated);
    UIButton *button = [objc_getClass("MOAHeadView") addRightButtonWithTitle:@"定位"];
    [button addTarget:self action:@selector(didTapLocatedButton) forControlEvents:UIControlEventTouchUpInside];
    MOAHeadView *headerView = [self valueForKey:@"headView"];
    [headerView addSubview: button];
}


CHDeclareMethod(0, void, MOASettingViewController, didTapLocatedButton) {
    LocationViewController *vc = [[LocationViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - WADSelectSignOutSideTypeViewController

CHDeclareClass(WADSelectSignOutSideTypeViewController)

CHOptimizedMethod1(self, void, WADSelectSignOutSideTypeViewController, viewDidAppear, BOOL, animated) {
    CHSuper1(WADSelectSignOutSideTypeViewController, viewDidAppear, animated);
    const char *name = object_getClassName(self);
    if (strcmp(name, "WADSelectSignOutSideTypeViewController") == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        double latitude = [ud doubleForKey:@"zz_latitude"];
        double longitude = [ud doubleForKey:@"zz_longitude"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self setValue:location forKey:@"currentUserCLLocation"];
    }
    
}


#pragma mark - CHConstructor

CHConstructor{
    CHLoadLateClass(MOASettingViewController);
    CHClassHook(1, MOASettingViewController, viewWillAppear);
    
    CHLoadLateClass(WADSelectSignOutSideTypeViewController);
    CHClassHook(1, WADSelectSignOutSideTypeViewController, viewDidAppear);
}










