//
//  PhotosViewController.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/17.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoCollection.h"
#import "CoreDataManager.h"
#import "PhotoEntity.h"

@interface PhotosViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic) BOOL selectingMode;
@property (nonatomic) BOOL selectingCell;
@property (nonatomic, copy) NSMutableArray *selectArray;

typedef NS_ENUM (NSInteger, MenuSelect) {
    MenuCancel,
    MenuSelectImage
};

@end

@implementation PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:
                             [PhotoCollection getCorrection] options:nil];
    // ヘッダタイトル設定
    _titleLabel.text = [NSString stringWithFormat:@"%@　(%lu)",
                        [PhotoCollection getTitle:[PhotoCollection getCorrection]]
                        , (unsigned long)(NSInteger)assets.count];
    
    _selectingMode = NO;
    _selectingCell = NO;
    _selectArray = nil;
    
    _shareButton.hidden = YES;
    _settingButton.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // メモ有りチェック振り直しのためリロード
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * (delegate) CollectionView Cell 最大数
 */
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section {
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    return assets.count;
}

/**
 * (delegate) CollectionView Cell 描画
 */
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *) indexPath {
    
    UICollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    // セルの出力先View生成
    __block UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UIImageView *checkView = (UIImageView *)[cell viewWithTag:2];
    UIImageView *movieView = (UIImageView *)[cell viewWithTag:3];
    UIImageView *selectView = (UIImageView *)[cell viewWithTag:4];
    
    // 表示画像取得
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
    PHAsset *asset = [assets objectAtIndex:indexPath.row];
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                imageView.image = result;
                                            }];
    
    checkView.hidden = YES;
    movieView.hidden = YES;
    
    if (!_selectingMode) {
        selectView.hidden = YES;
        // メモ済みマーク設定
        PhotoEntity *photoData = [CoreDataManager readCore:[asset valueForKey:@"filename"]];
        if (photoData != nil) {
            checkView.hidden = NO;
        }
        // 動画マーク設定
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            movieView.hidden = NO;
        }
    } else {
        if (_selectArray && ([_selectArray count] > 0)) {
            // 画像選択マーク設定
            if ([_selectArray containsObject:indexPath]) {
                selectView.hidden = NO;
            } else {
                selectView.hidden = YES;
            }
            _selectingCell = NO;
        } else {
            selectView.hidden = YES;
        }
    }
    return cell;
}

/**
 * (delegate) CollectionView Cellタップ
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_selectingMode) {
        // 選択画像の保存
        [PhotoCollection setSelectNum:indexPath.row];
        
        [self performSegueWithIdentifier:@"toMemoSelectViewController" sender:self];
        
    } else {
        if ([_selectArray containsObject:indexPath]) {
            [_selectArray removeObject:indexPath];
        } else {
            [_selectArray addObject:indexPath];
        }

        // 選択画像のcellを更新
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}

/**
 * (delegate) 設定ボタンタップ
 */
- (IBAction)settingTouchUpInside:(id)sender {
    
    // メニュー出力
    UIAlertController *alart = [UIAlertController alertControllerWithTitle:nil message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alart addAction:[UIAlertAction actionWithTitle:@"画像選択" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectedActionWith:MenuSelectImage];
    }]];
    [alart addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectedActionWith:MenuCancel];
    }]];
    
    [self presentViewController:alart animated:YES completion:nil];
}

/**
 * (delegate) シェアボタンタップ
 */
- (IBAction)shareTouchUpInside:(id)sender {
    
    if ([_selectArray count] > 0) {
        
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[PhotoCollection getCorrection] options:nil];
        for (NSIndexPath *indexPath in _selectArray) {
            // 表示画像取得
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.synchronous = YES;
            
            [[PHImageManager defaultManager] requestImageDataForAsset:[assets objectAtIndex:indexPath.row]
                                                              options:options
                                                        resultHandler:^(NSData * imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                            UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                            [imageArray addObject:image];
                                                            [deleteArray addObject:[assets objectAtIndex:indexPath.row]];
                                                        }];
        }
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc]
                                                  initWithActivityItems:imageArray
                                                  applicationActivities:nil];
        // 使用しないアクティビティタイプ
        activityView.excludedActivityTypes = @[
                                               UIActivityTypePostToFacebook,
                                               UIActivityTypePostToTwitter,
                                               UIActivityTypePostToWeibo,
                                               UIActivityTypeMessage,
                                               UIActivityTypeMail,
                                               UIActivityTypePrint,
                                               UIActivityTypeAssignToContact,
                                               UIActivityTypeCopyToPasteboard,
                                               UIActivityTypeSaveToCameraRoll,
                                               UIActivityTypeAddToReadingList,
                                               UIActivityTypePostToFlickr,
                                               UIActivityTypePostToVimeo,
                                               UIActivityTypePostToTencentWeibo,
                                               UIActivityTypeAirDrop,
                                               UIActivityTypeOpenInIBooks,
                                               ];
        
        activityView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            NSRange range = [activityType rangeOfString:@"google.Drive"];
            if (range.location) {
                for (PHAsset *asset in deleteArray) {
                    if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
                        // 変更をリクエストするblockを実行
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            // Assetをlibraryから削除
                            [PHAssetChangeRequest deleteAssets:@[asset]];
                        } completionHandler:^(BOOL success, NSError *error) {
                            if (success) {
                                // main thread で実行
                                dispatch_async(
                                               dispatch_get_main_queue(),
                                               ^{
                                                   [_collectionView reloadData];
                                               });
                            }
                        }];
                    }
                }
            }
            // 投稿後は選択モード解除
            [self changeSelectMode:NO];
        };
        
        [self presentViewController:activityView animated:YES completion:nil];
    }
}

/**
 * メニュー選択時の処理
 */
-(void)selectedActionWith:(int)index{
    switch (index) {
        case MenuCancel:
            [self changeSelectMode:NO];
            break;
        case MenuSelectImage:
            // 選択モード
            [self changeSelectMode:YES];
            break;
        default:
            break;
    }
}

/**
 * 選択モード切り替え
 */
-(void)changeSelectMode:(BOOL)selectMode {
    if (selectMode) {
        // 選択モード
        _selectingMode = YES;
        _shareButton.hidden = NO;
        _settingButton.hidden = YES;
        
        [_collectionView reloadData];
        [_selectArray removeAllObjects];
        if (!_selectArray) {
            _selectArray = [[NSMutableArray alloc] init];
        }
    } else {
        // 選択モードなら元に戻す
        if (_selectingMode) {
            _selectingMode = NO;
            _shareButton.hidden = YES;
            _settingButton.hidden = NO;
        }
        if (_selectArray) {
            [_selectArray removeAllObjects];
            _selectArray = nil;
        }
        [_collectionView reloadData];
    }
}
/**
 * (delegate) 戻るボタンタップ
 */
- (IBAction)exitTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
