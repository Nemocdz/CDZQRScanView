# CDZQRScanView
This is a small and configurable QRCode scanner with Animation.

## Demo Preview

![](http://ww4.sinaimg.cn/large/006tNc79ly1ffk9uaj3wrg30ku1127wj.gif)

## Changelog

- Add animation

## Installation

### Manual

Add "CDZQRScanView" files to your project

### CocoaPods

Add ``pod 'CDZQRScanView'`` in your Podfile

## Usage

``#import "CDZQRScanView.h"``

First,Init  the view, set the delegate ,and config if you want.

```objective-c
- (CDZQRScanView *)scanView{
    if (!_scanView) {
        _scanView = [[CDZQRScanView alloc]initWithFrame:self.view.bounds];
        _scanView.delegate = self;
        _scanView.showBorderLine = YES;
        _scanView.scanRect = ...
          ...
    }
    return _scanView;
}
```

And Than,add the view and start.

```objective-c
[self.view addSubview:self.scanView];
[self.scanView startScanning];
```

At last,,deal the result in delegate.

```objective-c
- (void)scanView:(CDZQRScanView *)scanView pickUpMessage:(NSString *)message{
  //do some thing you want,for example
    [scanView stopScanning];
    [self showAlert:message action:^{
        [scanView startScanning];
    }];
}
```

## Articles

[iOS实现原生的二维码扫描界面](http://www.jianshu.com/p/ad7827a8a0e6)

[iOS原生二维码界面的一些注意点](http://www.jianshu.com/p/52b68e41f120)

## Requirements

iOS 8.0 Above

## TODO

## Contact

- Open a issue
- QQ：757765420
- Email：nemocdz@gmail.com
- Weibo：[@Nemocdz](http://weibo.com/nemocdz)

## License

CDZQRScanView is available under the MIT license. See the LICENSE file for more info.