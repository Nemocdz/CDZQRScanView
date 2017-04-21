//
//  CDZQRCodeViewController.m
//  CDZQRCodeDemo
//
//  Created by Nemocdz on 2017/4/20.
//  Copyright © 2017年 Nemocdz. All rights reserved.
//

#import "CDZQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSString *const defaultTitle = @"扫描二维码";

@interface CDZQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation CDZQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    if (![self statusCheck]) {
        return;
    }
    [self startScan];
}

- (BOOL)statusCheck{
    if (![self isCameraAvailable]){
        [self showWarn:@"设备无相机" shouldPop:YES];
        return NO;
    }
    
    if (![self isRearCameraAvailable] && ![self isFrontCameraAvailable]) {
        [self showWarn:@"设备相机错误" shouldPop:YES];
        return NO;
    }
    
    if (![self isCameraAuthStatusCorrect]) {
        [self showPermissionAlert];
        return NO;
    }
    
    return YES;
}

- (void)startScan{
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    [self.session startRunning];
}


- (void)setupViews{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.maskView];
    UIBarButtonItem *libaryItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openLibary)];
    self.navigationItem.rightBarButtonItem = libaryItem;
    self.navigationItem.title = self.navigationTitle;
}


- (void)openLibary{
    if (![self isLibaryAuthStatusCorrect]) {
        [self showPermissionAlert];
        return;
    }
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


- (void)showPermissionAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"需要相机/相册的权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *requestAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:requestAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showWarn:(NSString *)message shouldPop:(BOOL)pop{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        if (!pop) {
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}



- (NSString *)messageFromQRCodeImage:(UIImage *)image{
    if (!image) {
        return nil;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    
    if (features.count == 0) {
        return nil;
    }
    
    CIQRCodeFeature *feature = features.firstObject;
    return feature.messageString;
}



- (CGRect)scanRectOfInterest{
    CGRect scanRect = [self scanRect];
    scanRect = CGRectMake(scanRect.origin.y/SCREEN_HEIGHT, scanRect.origin.x/SCREEN_WIDTH, scanRect.size.height/SCREEN_HEIGHT,scanRect.size.width/SCREEN_WIDTH);
    return scanRect;
}

- (CGRect)scanRect{
    if ([self.delegate respondsToSelector:@selector(interestedRect)]) {
        return [self.delegate interestedRect];
    }
    CGSize scanSize = CGSizeMake(SCREEN_WIDTH * 3/4, SCREEN_WIDTH * 3/4);
    CGRect scanRect = CGRectMake((SCREEN_WIDTH - scanSize.width)/2, (SCREEN_HEIGHT - scanSize.height)/2, scanSize.width, scanSize.height);
    return scanRect;
}

- (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)isCameraAuthStatusCorrect{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }
    return NO;
}

- (BOOL)isLibaryAuthStatusCorrect{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusNotDetermined || authStatus == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray<AVMetadataMachineReadableCodeObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count == 0) {
        return;
    }
    [self.session stopRunning];
    NSString *result = [metadataObjects.firstObject stringValue];
    if ([self.delegate respondsToSelector:@selector(pickUpMessage:)]) {
        [self.delegate pickUpMessage:result];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - imagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *result = [self messageFromQRCodeImage:image];
    if (!result) {
        [self showWarn:@"未识别到二维码" shouldPop:NO];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(pickUpMessage:)]) {
        [self.delegate pickUpMessage:result];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter&setter
- (NSString *)navigationTitle{
    if (!_navigationTitle) {
        _navigationTitle = defaultTitle;
    }
    return _navigationTitle;
}


- (AVCaptureDeviceInput *)deviceInput{
    if (!_deviceInput) {
        NSError *error;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }
    return _deviceInput;
}

- (AVCaptureMetadataOutput *)dataOutput{
    if (!_dataOutput) {
        _dataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _dataOutput.rectOfInterest = [self scanRectOfInterest];
    }
    return _dataOutput;
}

- (AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:(SCREEN_HEIGHT < 500) ? AVCaptureSessionPreset640x480:AVCaptureSessionPreset1920x1080];
        if ([_session canAddInput:self.deviceInput]) {
            [_session addInput:self.deviceInput];
        }
        
        if ([_session canAddOutput:self.dataOutput]){
            [_session addOutput:self.dataOutput];
            self.dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = [UIScreen mainScreen].bounds;
    }
    return _previewLayer;
}


- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.8;
        UIBezierPath *bpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) ];
        [bpath appendPath:[[UIBezierPath bezierPathWithRect:[self scanRect]] bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bpath.CGPath;
        _maskView.layer.mask = shapeLayer;
    }
    return _maskView;
}

- (UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}
@end
