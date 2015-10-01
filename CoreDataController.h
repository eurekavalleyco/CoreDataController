//
//  CoreDataController.h
//  CoreDataController
//
//  Created by Ken M. Haggerty on 9/9/15.
//  Copyright (c) 2015 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

@interface CoreDataController : NSObject

// GENERAL //

+ (void)setup;
+ (BOOL)save;

// CREATORS //

+ (id)createObjectWithClass:(NSString *)className block:(void (^)(id))block;

// FETCH REQUESTS //

+ (NSArray *)fetchObjectsWithClass:(NSString *)className
                         predicate:(NSPredicate *)predicate
                   sortDescriptors:(NSArray *)sortDescriptors
                       fetchOffset:(NSUInteger)fetchOffset
                        fetchLimit:(NSUInteger)fetchLimit
                         batchSize:(NSUInteger)batchSize
                includeSubentities:(BOOL)includeSubentities
                    propertyValues:(BOOL)includePropertyValues
                withPendingChanges:(BOOL)includePendingChanges
                           refresh:(BOOL)refresh
             returnObjectsAsFaults:(BOOL)returnObjectsAsFaults
                             error:(NSError *)error;

+ (NSArray *)fetchObjectIdsWithClass:(NSString *)className
                           predicate:(NSPredicate *)predicate
                     sortDescriptors:(NSArray *)sortDescriptors
                         fetchOffset:(NSUInteger)fetchOffset
                          fetchLimit:(NSUInteger)fetchLimit
                           batchSize:(NSUInteger)batchSize
                  withPendingChanges:(BOOL)includePendingChanges
                               error:(NSError *)error;

+ (NSArray *)fetchDictionariesWithClass:(NSString *)className
                              predicate:(NSPredicate *)predicate
                        sortDescriptors:(NSArray *)sortDescriptors
                            fetchOffset:(NSUInteger)fetchOffset
                             fetchLimit:(NSUInteger)fetchLimit
                              batchSize:(NSUInteger)batchSize
                      propertiesToFetch:(NSArray *)propertiesToFetch
                  returnDistinctResults:(BOOL)returnDistinctResults
                     includeSubentities:(BOOL)includeSubentities
                                refresh:(BOOL)refresh
                  returnObjectsAsFaults:(BOOL)returnObjectsAsFaults
                                  error:(NSError *)error;

+ (NSUInteger)countObjectsWithClass:(NSString *)className
                          predicate:(NSPredicate *)predicate
                    sortDescriptors:(NSArray *)sortDescriptors
                        fetchOffset:(NSUInteger)fetchOffset
                         fetchLimit:(NSUInteger)fetchLimit
                          batchSize:(NSUInteger)batchSize
                 withPendingChanges:(BOOL)includePendingChanges
                              error:(NSError *)errorValue;

// DELETORS //

+ (void)deleteObject:(id)object;

@end