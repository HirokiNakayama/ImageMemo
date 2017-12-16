//
//  AlbumTableViewCell.h
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/17.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
