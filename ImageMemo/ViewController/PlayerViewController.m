//
//  PlayerViewController.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/27.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "PlayerViewController.h"
#import "PhotoCollection.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 動画再生
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    PHAsset *asset = [assets objectAtIndex:[PhotoCollection getSelectNum]];

    NSString *path = [NSString stringWithFormat:@"file:///var/mobile/Media/%@/%@"
                      , [asset valueForKey:@"directory"], [asset valueForKey:@"filename"]];
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
