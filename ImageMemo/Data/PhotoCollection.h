//
//  PhotoCorrection.h
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/22.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#ifndef PhotoCorrection_h
#define PhotoCorrection_h

#import <Photos/Photos.h>

@interface PhotoCollection : NSObject
@property (nonatomic) PHAssetCollection *collection;
@property (nonatomic) NSUInteger selectNum;

+ (PhotoCollection *) getCorrectionInfo;
+ (void) setCollectionInfo:(PhotoCollection *) photoCollection;
+ (PHAssetCollection *) getCorrection;
+ (void) setCorrection:(PHAssetCollection *) collection;
+ (NSUInteger) getSelectNum;
+ (void) setSelectNum:(NSUInteger) select;
+ (NSString *) getTitle:(PHAssetCollection *) collection;
+ (BOOL) isAllPhotos:(PHAssetCollection *) collection;

@end

#endif /* PhotoCorrection_h */
