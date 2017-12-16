//
//  PhotoCorrection.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/22.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "PhotoCollection.h"

@interface PhotoCollection ()

@end

static PhotoCollection *photoCollectionInfo;

@implementation PhotoCollection

+ (PhotoCollection *) getCorrectionInfo {
    return photoCollectionInfo;
}

+ (void) setCollectionInfo:(PhotoCollection *) photoCollection {
    photoCollectionInfo = photoCollection;
}

+ (NSUInteger) getSelectNum {
    return photoCollectionInfo.selectNum;
}

+ (void) setSelectNum:(NSUInteger) select {
    photoCollectionInfo.selectNum = select;
}

+ (PHAssetCollection *) getCorrection {
    return photoCollectionInfo.collection;
}

+ (void) setCorrection:(PHAssetCollection *) collection {
    photoCollectionInfo.collection = collection;
}

+ (NSString *) getTitle:(PHAssetCollection *) collection {
    NSString *title = collection.localizedTitle;
    
    if ([title isEqualToString:@"All Photos"]
        || [title isEqualToString:@"Camera Roll"]) {
        title = @"すべての写真";
    }
    return title;
}

+ (BOOL) isAllPhotos:(PHAssetCollection *) collection {
    NSString *title = collection.localizedTitle;
    
    if ([title isEqualToString:@"All Photos"]
        || [title isEqualToString:@"Camera Roll"]) {
        return YES;
    }
    return NO;
}

@end
