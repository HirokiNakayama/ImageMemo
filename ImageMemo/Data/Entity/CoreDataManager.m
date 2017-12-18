//
//  CoreDataManager.m
//  ImageMemo
//
//  Created by HirokiNakayama on 2017/11/21.
//  Copyright © 2017年 HirokiNakayama. All rights reserved.
//

#import "CoreDataManager.h"
#import "PhotoEntity.h"
#import <CoreData/CoreData.h>

@interface CoreDataManager()

@end

static NSManagedObjectContext *managedObjectContext;
static NSManagedObjectModel *managedObjectModel;
static NSPersistentStoreCoordinator *persistentStoreCoordinator;

@implementation CoreDataManager {

}

+ (id)insertNewObjectInContext {
    return [NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:[self getManagedObjectContext]];
}

+ (NSManagedObjectModel *)getManagedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ImageMemo" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

+ (NSPersistentStoreCoordinator *)getPersistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ImageMemo.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self getManagedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

+ (NSManagedObjectContext *)getManagedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self getPersistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSError *) saveCore:(PhotoEntity *) data {
    
    NSError *error;
    
    NSManagedObjectContext *context = [self getManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity"
                                                         inManagedObjectContext:context];
    
    if (entityDescription != nil) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(fileName = %@)", data.fileName];
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setEntity:entityDescription];
        
        NSArray *objects = [context executeFetchRequest:fetchRequest
                                                  error:&error];
        
        for (NSManagedObject * object in objects) {
            [context deleteObject:object];
        }

        if (data.memo.length > 0) {
            NSManagedObject *managedObj = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                                                        inManagedObjectContext:context];
            
            [managedObj setValue: data.fileName forKeyPath: @"fileName"];
            [managedObj setValue: data.memo forKeyPath: @"memo"];
            
            [context save:&error];
        }
    }
    
    return error;
}

+ (PhotoEntity *) readCore:(NSString *) fileName {
    PhotoEntity *data = nil;
    
    NSManagedObjectContext *context = [self getManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Entity"
                                                          inManagedObjectContext:context];
    
    if (entityDescription != nil) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(fileName = %@)", fileName];
        [fetchRequest setPredicate:predicate];
        
        [fetchRequest setEntity:entityDescription];
        
        NSError *error;
        NSArray *objects = [context executeFetchRequest:fetchRequest
                                                   error:&error];
        if (objects != nil && objects.count > 0) {
            data = (objects.firstObject);
        }
    }
    return data;
}

@end
