//
//  ImageViewController.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/28.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "ImageViewController.h"
#import "PhotoCollection.h"
#import "PhotoEntity.h"
#import "CoreDataManager.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic) NSTimer *timer;
@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView.delegate = self;
    
    // 画像タップイベント設定
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(touchUp:)]];
    // スワイプイベント設定
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selSwipeDownGesture:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownGesture];
    
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selSwipeRightGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selSwipeLeftGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];
    
    _closeButton.hidden = NO;
    _playButton.hidden = YES;
    
    // 画像表示
    [self changeImage:[PhotoCollection getSelectNum]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 画面タップイベント
 */
- (void)touchUp: (UITapGestureRecognizer *)sender{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    // タイマー再開
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                              target:self
                                            selector:@selector(timerComplete:)
                                            userInfo:nil
                                             repeats:NO];
    _closeButton.hidden = NO;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    PHAsset *asset = [assets objectAtIndex:[PhotoCollection getSelectNum]];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        _playButton.hidden = NO;
    }
}

/**
 * 右方向にスワイプ
 */
- (void)selSwipeRightGesture:(UISwipeGestureRecognizer *)sender {
    [self changeImage:[PhotoCollection getSelectNum] - 1];
}

/**
 * 左方向にスワイプ
 */
- (void)selSwipeLeftGesture:(UISwipeGestureRecognizer *)sender {
    [self changeImage:[PhotoCollection getSelectNum] + 1];
}

/**
 * 下方向にスワイプ
 */
- (void)selSwipeDownGesture:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/**
 * (delegate) 再生ボタンタップ
 */
- (IBAction)playTouchUpInside:(id)sender {
    [self performSegueWithIdentifier:@"toPlayerViewController" sender:self];
}

/**
 * 表示切り替え
 */
- (void) changeImage:(NSInteger) select {
    
    _closeButton.hidden = NO;
    _playButton.hidden = YES;
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    if (0 <= select && select < assets.count) {
        // 選択位置の更新
        [PhotoCollection setSelectNum:select];
        
        // 選択位置の画像表示
        PHAsset *asset = [assets objectAtIndex:select];
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(_photoImage.frame.size.width, _photoImage.frame.size.height)
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result != nil) {
                                                        _photoImage.image = result;
                                                    }
                                                }];
        // ボタン表示設定
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            _playButton.hidden = NO;
        }
        
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        // ボタン表示用タイマー開始
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                  target:self
                                                selector:@selector(timerComplete:)
                                                userInfo:nil repeats:NO];
    }
}

/**
 * タイマー完了イベント
 */
-(void)timerComplete:(NSTimer*)timer{
    _closeButton.hidden = YES;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    PHAsset *asset = [assets objectAtIndex:[PhotoCollection getSelectNum]];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        _playButton.hidden = YES;
    }
}

/**
 * (delegate) ズームイン用
 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImage;
}

/**
 * (delegate) 戻るボタンタップ
 */
- (IBAction)closeTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
