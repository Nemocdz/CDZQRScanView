//
//  ViewController.m
//  CDZQRCodeDemo
//
//  Created by Nemocdz on 2017/4/18.
//  Copyright © 2017年 Nemocdz. All rights reserved.
//

#import "ViewController.h"
#import "CDZQRCodeViewController.h"

@interface ViewController ()<CDZQRCodeDelegate>
- (IBAction)selectScan:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectScan:(UIButton *)sender {
    CDZQRCodeViewController *vc = [[CDZQRCodeViewController alloc]init];
    vc.delegate = self;
    vc.navigationTitle = @"自定义";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pickUpMessage:(NSString *)message{
    self.resultLabel.text = message;
}

@end
