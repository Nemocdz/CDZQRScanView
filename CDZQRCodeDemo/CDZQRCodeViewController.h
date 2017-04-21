//
//  CDZQRCodeViewController.h
//  CDZQRCodeDemo
//
//  Created by Nemocdz on 2017/4/20.
//  Copyright © 2017年 Nemocdz. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CDZQRCodeDelegate<NSObject>
@required
- (void)pickUpMessage:(NSString *)message;

@optional
- (CGRect)interestedRect;

@end
@interface CDZQRCodeViewController : UIViewController

@property (nonatomic, weak) id <CDZQRCodeDelegate> delegate;
@property (nonatomic, copy) NSString *navigationTitle;
@property (nonatomic, strong) UIView *maskView;

@end
