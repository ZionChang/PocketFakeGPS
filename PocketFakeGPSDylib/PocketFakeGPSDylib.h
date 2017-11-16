//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  PocketFakeGPSDylib.h
//  PocketFakeGPSDylib
//
//  Created by zz on 2017/11/16.
//  Copyright (c) 2017年 zz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MOAHeadView: UIView

+ (id)addRightButtonWithTitle:(NSString *)title;

@end

@interface MeViewController: UIViewController


@end


@interface MOASettingViewController: MeViewController

- (void)viewWillAppear:(BOOL)animated;
- (void)didTapLocatedButton;

@end

@interface WADSelectSignOutSideTypeViewController: UIViewController

@end

