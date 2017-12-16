//
//  CoreDataManager.h
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/21.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#ifndef CoreDataManager_h
#define CoreDataManager_h

#import "PhotoEntity.h"

@interface CoreDataManager : NSObject
+ (NSError *) saveCore:(PhotoEntity *) data;
+ (PhotoEntity *) readCore:(NSString *) fileName;
+ (NSManagedObjectContext *) getManagedObjectContext;
+ (id) insertNewObjectInContext;
@end

#endif /* CoreDataManager_h */
