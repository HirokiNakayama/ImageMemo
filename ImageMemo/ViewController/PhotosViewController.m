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
        if (_selectArray) {
            // 画像選択マーク設定
            if ([_selectArray containsObject:indexPath]) {
                selectView.hidden = YES;
            } else {
                selectView.hidden = NO;
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
 * メニュー選択時の処理
 */
-(void)selectedActionWith:(int)index{
    switch (index) {
        case MenuCancel:
            if (_selectingMode) {
                // 選択モードなら元に戻す
                _selectingMode = NO;
                [_collectionView reloadData];
            }
            if (_selectArray) {
                [_selectArray removeAllObjects];
                _selectArray = nil;
            }
            break;
        case MenuSelectImage:
            // 選択モード
            _selectingMode = YES;
            [_collectionView reloadData];
            [_selectArray removeAllObjects];
            if (!_selectArray) {
                _selectArray = [[NSMutableArray alloc] init];
            }
            break;
        default:
            break;
    }
}

/**
 * (delegate) 戻るボタンタップ
 */
- (IBAction)exitTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
