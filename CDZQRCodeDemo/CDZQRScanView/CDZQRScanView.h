//
//  ONEQRScanView.h
//  Pods
//
//  Created by Nemocdz on 2017/5/2.
//
//

#import <UIKit/UIKit.h>
@class CDZQRScanView;
@protocol CDZQRScanDelegate<NSObject>
@required

/**
 扫描有结果回调方法，如需结束在回调里调用stopScanning方法

 @param scanView 回调的View
 @param message 结果字符串
 */
- (void)scanView:(CDZQRScanView *)scanView pickUpMessage:(NSString *)message;

@end

@interface CDZQRScanView : UIView

@property (nonatomic, weak) id<CDZQRScanDelegate> delegate;

/**
 扫描区域的Frame，默认长宽为Frame的宽度3/4，位置为Frame中心
 */
@property (nonatomic, assign) CGRect scanRect;

/**
 第一次调用会初始化相机相关并开始扫描
 之后调用，可在暂停后恢复
 */
- (void)startScanning;

/**
 暂停扫描
 */
- (void)stopScanning;

/**
 可自定义的蒙版View，可在上面添加自定义控件,也可以改变背景颜色，透明度
 默认为50%透明度黑色，遮盖区域依赖scanRect,需先指定scanRect，否则为默认
 */
@property (nonatomic, strong) UIView *maskView;

/**
 上下移动的扫描线的颜色，默认为橙色
 */
@property (nonatomic, strong) UIColor *scanLineColor;

/**
 四角的线的颜色，默认为橙色
 */
@property (nonatomic, strong) UIColor *cornerLineColor;

/**
 扫描边框的颜色，默认为白色
 */
@property (nonatomic, strong) UIColor *borderLineColor;

/**
 是否显示上下移动的扫描线，默认为YES
 */
@property (nonatomic, assign, getter=isShowScanLine) BOOL showScanLine;

/**
 是否显示边框，默认为NO
 */
@property (nonatomic, assign, getter=isShowBorderLine) BOOL showBorderLine;

/**
 是否显示四角，默认为YES
 */
@property (nonatomic, assign, getter=isShowCornerLine) BOOL showCornerLine;

@end
