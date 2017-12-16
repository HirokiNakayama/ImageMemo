//
//  PhotoData.h
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/21.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#ifndef PhotoData_h
#define PhotoData_h

#import <CoreData/CoreData.h>

@interface PhotoEntity : NSManagedObject
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *memo;
@end

#endif /* PhotoData_h */
