//
//  MemoSelectViewController.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/28.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "MemoSelectViewController.h"
#import "CoreDataManager.h"
#import "PhotoEntity.h"
#import "PhotoCollection.h"
#import <Social/Social.h>

@interface MemoSelectViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectImageBorder;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UITextView *memoTextView;
@property (weak, nonatomic) IBOutlet UILabel *memoBackView;
@property (weak, nonatomic) IBOutlet UIButton *imputCompButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageMovieMark;
@property (weak, nonatomic) IBOutlet UITextView *createDateView;
@end

const NSUInteger MAX_HEADER_IMAGE_COUNT = 5;

@implementation MemoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;

    // 選択中の画像囲みボーダー設定
    _selectImageBorder.layer.borderColor = [UIColor greenColor].CGColor;
    _selectImageBorder.layer.borderWidth = 2.0;
    
    _imputCompButton.hidden = YES;
    _shareButton.hidden = NO;
    
    // 画像タップイベント設定
    _photoImage.userInteractionEnabled = YES;
    [_photoImage addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(imageViewTap:)]];
    // キーボード表示イベント設定
    [self registerForKeyboardNotifications];
    
    // スワイプイベント設定
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selSwipeRightGesture:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selSwipeLeftGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self collectionViewLoad:[PhotoCollection getSelectNum]];
}

- (void)viewWillDisappear:(BOOL)animated {
    // キーボードを閉じずにスワイプされると保存の機会を失うため画面終了時にも保存
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    PHAsset *asset = [assets objectAtIndex:[PhotoCollection getSelectNum]];
    
    PhotoEntity *photoData = [CoreDataManager insertNewObjectInContext];
    photoData.fileName = [asset valueForKey:@"filename"];
    photoData.memo = _memoTextView.text;
    [CoreDataManager saveCore:photoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

/**
 * (delegate) 入力完了ボタンタップ
 */
- (IBAction)imputCompTouchUpInside:(id)sender {
    
    // ファイル名取得
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    PHAsset *asset = [assets objectAtIndex:[PhotoCollection getSelectNum]];
    NSString *fileName = [asset valueForKey:@"filename"];
    
    // メモ情報保存
    PhotoEntity *photoData = [CoreDataManager insertNewObjectInContext];
    photoData.fileName = fileName;
    photoData.memo = _memoTextView.text;
    [CoreDataManager saveCore:photoData];
    
    // キーボードを閉じる
    [_memoTextView resignFirstResponder];
    
    // チェックマーク更新のためリロード
    [_collectionView reloadData];
}

/**
 * (delegate) シェアボタンタップ
 */
- (IBAction)shareTouchUpInside:(id)sender {
    
    NSArray *shareItems = nil;
    NSString *shareText = nil;
    UIImage *shareImage = _photoImage.image;
    
    if (_memoTextView.text.length > 0) {
        shareText = _memoTextView.text;
    }
    // 共有する項目
    if (shareText != nil && shareImage) {
        shareItems = @[shareText, shareImage];
    } else if (shareText != nil) {
        shareItems = @[shareText];
    } else if (shareImage != nil) {
        shareItems = @[shareImage];
    }
    UIActivityViewController *activityView = [[UIActivityViewController alloc]
                                              initWithActivityItems:shareItems
                                              applicationActivities:nil];
    // 使用しないアクティビティタイプ
    activityView.excludedActivityTypes = @[
                                 UIActivityTypePostToWeibo,
                                 UIActivityTypeSaveToCameraRoll,
                                 UIActivityTypePrint,
                                 UIActivityTypeCopyToPasteboard,
                                 UIActivityTypeAirDrop,
                                 UIActivityTypeAssignToContact,
                                 UIActivityTypeAddToReadingList,
                                 UIActivityTypeMail,
                                 UIActivityTypeMessage];

    [self presentViewController:activityView animated:YES completion:^{
        // 投稿後の処理
    }];
    
    /* Twitterへ直接投稿
     SLComposeViewController *composeView =
     [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
     
     [composeView addImage:shareImage];
     [composeView setInitialText:shareText];
     
     [composeView setCompletionHandler:^(SLComposeViewControllerResult result) {
     if (result == SLComposeViewControllerResultDone) {
        //投稿完了の処理
     }
     }];
     
     [self presentViewController:composeView animated:YES completion:nil];
     */
}

/**
 * イメージタップ
 */
- (void)imageViewTap: (UITapGestureRecognizer *)sender{
    if (sender.view.tag == 2) {
        [self performSegueWithIdentifier:@"toImageViewController" sender:self];
    }
}

/**
 * (delegate) CollectionView Cell 最大数
 */
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSUInteger count;
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    count = assets.count;
    // 最大５画像表示
    if (count > MAX_HEADER_IMAGE_COUNT) {
        count = MAX_HEADER_IMAGE_COUNT;
    }
    return count;
}

/**
 * (delegate) CollectionView Cell 描画
 */
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    // セルの出力先View生成
    __block UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:2];
    UIImageView *movieView = (UIImageView *)[cell viewWithTag:3];
    
    imageView.image = nil;
    checkView.hidden = YES;
    movieView.hidden = YES;
    
    // 表示位置計算
    NSInteger index = ([PhotoCollection getSelectNum] - ((MAX_HEADER_IMAGE_COUNT - 1) / 2)) + indexPath.row;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    if (assets.count > index) {
        PHAsset *asset = [assets objectAtIndex:index];
        // 表示画像取得
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result != nil) {
                                                        imageView.image = result;
                                                    }
                                                }];
        
        // メモ済みマーク設定
        PhotoEntity *photoData = [CoreDataManager readCore:[asset valueForKey:@"filename"]];
        if (photoData != nil) {
            checkView.hidden = NO;
        }
        // 動画マーク設定
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            movieView.hidden = NO;
        }
    }
    return cell;
}

/**
 * (delegate) CollectionView Cellタップ
 */
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_photoImage.frame.origin.y == _memoBackView.frame.origin.y) {
        // キーボード入力中はタップ不可
        return;
    }
    
    NSInteger select = ([PhotoCollection getSelectNum] - ((MAX_HEADER_IMAGE_COUNT - 1) / 2)) + indexPath.row;
    if (0 <= select) {
        [self collectionViewLoad:select];
    }
}

/**
 * 右方向にスワイプ
 */
- (void)selSwipeRightGesture:(UISwipeGestureRecognizer *)sender {
    if (_photoImage.frame.origin.y == _memoBackView.frame.origin.y) {
        // キーボード入力中は不可
        return;
    }
    
    [self collectionViewLoad:[PhotoCollection getSelectNum] - 1];
}

/**
 * 左方向にスワイプ
 */
- (void)selSwipeLeftGesture:(UISwipeGestureRecognizer *)sender {
    if (_photoImage.frame.origin.y == _memoBackView.frame.origin.y) {
        // キーボード入力中は不可
        return;
    }
    [self collectionViewLoad:[PhotoCollection getSelectNum] + 1];
}

/**
 * CollectionView 操作時のロード処理
 */
- (void) collectionViewLoad:(NSInteger) select {
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    if (0 <= select && select < assets.count) {
    
        // 選択位置の更新
        [PhotoCollection setSelectNum:select];
        
        // 表示画像取得
        PHAsset *asset = [assets objectAtIndex:[PhotoCollection getSelectNum]];
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(_photoImage.frame.size.width, _photoImage.frame.size.height)
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result != nil) {
                                                        _photoImage.image = result;
                                                    }
                                                }];
        
        // メモ済みマーク設定
        PhotoEntity *photoData = [CoreDataManager readCore:[asset valueForKey:@"filename"]];
        if (photoData != nil) {
            _memoTextView.text = photoData.memo;
        } else {
            _memoTextView.text = @"";
        }
        
        // 動画マーク設定
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            _photoImageMovieMark.hidden = NO;
        } else {
            _photoImageMovieMark.hidden = YES;
        }
        
        // ファイル生成日表示
        if (asset.creationDate != nil) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
            _createDateView.text = [formatter stringFromDate:asset.creationDate];
        }
        
        [_collectionView reloadData];
    }
}

/**
 * キーボード表示イベント
 */
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    // メモ関連ViewをphotoImageのtopまで移動
    _memoTextView.frame = CGRectMake(_memoTextView.frame.origin.x,
                                     _photoImage.frame.origin.y + 10,
                                     _memoTextView.frame.size.width,
                                     _memoTextView.frame.size.height);
    
    _memoBackView.frame = CGRectMake(_memoBackView.frame.origin.x,
                                     _photoImage.frame.origin.y,
                                     _memoBackView.frame.size.width,
                                     _memoBackView.frame.size.height);
    _imputCompButton.hidden = NO;
    _shareButton.hidden = YES;
}

/**
 * キーボード非表示イベント
 */
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    // メモ関連Viewを元の位置に戻す
    _memoTextView.frame = CGRectMake(_memoTextView.frame.origin.x,
                                     _photoImage.frame.origin.y + _photoImage.frame.size.height + 20,
                                     _memoTextView.frame.size.width,
                                     _memoTextView.frame.size.height);
    
    _memoBackView.frame = CGRectMake(_memoBackView.frame.origin.x,
                                     _photoImage.frame.origin.y +
                                     _photoImage.frame.size.height + 10,
                                     _memoBackView.frame.size.width,
                                     _memoBackView.frame.size.height);
    _imputCompButton.hidden = YES;
    _shareButton.hidden = NO;
}

/**
 * (delegate) 戻るボタンタップ
 */
- (IBAction)backButtonTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
