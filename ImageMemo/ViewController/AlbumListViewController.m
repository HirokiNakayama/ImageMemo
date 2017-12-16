//
//  ViewController.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/17.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "AlbumListViewController.h"
#import "AlbumTableViewCell.h"
#import "PhotosViewController.h"
#import "PhotoCollection.h"

#import <Photos/Photos.h>

@interface AlbumListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *albumListView;
@property (nonatomic, copy) NSMutableArray *albumList;
@end

@implementation AlbumListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _albumListView.delegate = self;
    _albumListView.dataSource = self;
    
    // アルバム表示テーブルにカスタムセルを設定
    UINib *nib = [UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil];
    [_albumListView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    _albumList = [[NSMutableArray alloc] init];
    
    // システム管理 アルバム情報取得
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                               subtype:PHAssetCollectionSubtypeAny
                                                                               options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        if ([PhotoCollection isAllPhotos:assetCollection]) {
            [_albumList addObject:assetCollection];
        }
    }
    
    // ユーザ管理 アルバム情報取得
    assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                               subtype:PHAssetCollectionSubtypeAny
                                                                               options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        if (assets.count > 0) {
            [_albumList addObject:assetCollection];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * （delegate）tebleのcell描画
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // カスタムセルを取得
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PHAssetCollection *collection = [_albumList objectAtIndex:indexPath.row];
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    
    // タイトル設定
    cell.titleLabel.text = [NSString stringWithFormat:@"%@　(%lu)"
                            , [PhotoCollection getTitle:collection], (unsigned long) (NSInteger)assets.count];
    // サムネイル設定
    [[PHImageRequestOptions alloc] init].synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:assets.firstObject
                                               targetSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                if (result != nil) {
                                                    cell.thumbnailView.image = result;
                                                }
                                            }];
    // 選択された背景色を白に設定
    UIView *cellSelectedBgView = [[UIView alloc] init];
    cellSelectedBgView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = cellSelectedBgView;
    
    return cell;
}

/**
 * （delegate）tebleのカウント数
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_albumList count];
}

/**
 * （delegate）teble Cell選択
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 選択したアルバム情報を保存
    PhotoCollection *pc = [[PhotoCollection alloc] init];
    pc.collection = [_albumList objectAtIndex:indexPath.row];
    [PhotoCollection setCollectionInfo:pc];

    [self performSegueWithIdentifier:@"toPhotosViewController" sender:self];
}

@end
