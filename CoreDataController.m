//
//  CoreDataController.m
//  CoreDataController
//
//  Created by Ken M. Haggerty on 9/9/15.
//  Copyright (c) 2015 Eureka Valley Co. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "CoreDataController.h"
#import "AKDebugger.h"
#import "AKGenerics.h"
#import <CoreData/CoreData.h>
#import "AKPrivateInfo.h"
#import "CentralDispatch.h"

#pragma mark - // DEFINITIONS (Private) //

#define CORE_DATA_FILENAME @"coredata.sqlite"
#define CORE_DATA_MODEL_NAME @"Kaiten"
#define CORE_DATA_MODEL_DIRECTORY_EXTENSION @"momd"
#define CORE_DATA_MODEL_FILE_EXTENSION @"mom"

@interface CoreDataController ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// GENERAL //

+ (id)sharedController;
- (void)setup;
- (void)teardown;

// CONVENIENCE //

+ (NSManagedObjectContext *)managedObjectContext;

@end

@implementation CoreDataController

#pragma mark - // SETTERS AND GETTERS //

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_DATA, AKD_CORE_DATA] message:nil];
    
    if (_managedObjectContext) return _managedObjectContext;
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_DATA, AKD_CORE_DATA] message:nil];
    
    if (_managedObjectModel) return _managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL_NAME withExtension:CORE_DATA_MODEL_DIRECTORY_EXTENSION];
    if (!modelURL)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(modelURL)]];
        return nil;
    }
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_DATA, AKD_CORE_DATA] message:nil];
    
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
    if (![NSThread isMainThread])
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            (void)[self persistentStoreCoordinator];
        });
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[AKPrivateInfo applicationDocumentsDirectory] URLByAppendingPathComponent:CORE_DATA_FILENAME];
    NSError *error;
    NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
        abort();
    }
    return _persistentStoreCoordinator;
}


#pragma mark - // INITS AND LOADS //

- (id)init
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    self = [super init];
    if (!self)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeCritical methodType:AKMethodTypeSetup customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not initialize %@", stringFromVariable(self)]];
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
    [self teardown];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:@[AKD_CORE_DATA] message:nil];
    
//    if ([CoreDataController isMigrationNeeded]) [CoreDataController migrate];
}

+ (BOOL)save
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSError *error;
    __block BOOL succeeded;
    [managedObjectContext performBlockAndWait:^{
        succeeded = [managedObjectContext save:&error];
    }];
    if (error)
    {
        NSArray *detailedErrors = [error.userInfo objectForKey:NSDetailedErrorsKey];
        if ((detailedErrors) && (detailedErrors.count))
        {
            for (NSError *detailedError in detailedErrors) [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@", [detailedError userInfo]]];
        }
        else [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@", error.userInfo]];
    }
    if (!succeeded)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeNotice methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:[NSString stringWithFormat:@"Could not %@", NSStringFromSelector(@selector(save))]];
        return NO;
    }
    
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeInfo methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:@"Save successful"];
    return YES;
}

#pragma mark - // PUBLIC METHODS (Creators) //

+ (id)createObjectWithClass:(NSString *)className block:(void (^)(id))block
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeCreator customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSManagedObject *object;
    [managedObjectContext performBlockAndWait:^{
        object = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:managedObjectContext];
        if (block) block(object);
    }];
    return object;
}

#pragma mark - // PUBLIC METHODS (Fetch Requests) //

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
                             error:(NSError *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSArray *foundObjects;
    __block NSError *fetchError;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext]];
        [request setResultType:NSManagedObjectResultType];
        if (predicate) [request setPredicate:predicate];
        if (sortDescriptors) [request setSortDescriptors:sortDescriptors];
        [request setFetchOffset:fetchOffset];
        if (fetchLimit) [request setFetchLimit:fetchLimit];
        [request setFetchBatchSize:batchSize];
        [request setIncludesSubentities:includeSubentities];
        [request setIncludesPropertyValues:includePropertyValues];
        [request setIncludesPendingChanges:includePendingChanges];
        [request setShouldRefreshRefetchedObjects:refresh];
        [request setReturnsObjectsAsFaults:returnObjectsAsFaults];
        foundObjects = [managedObjectContext executeFetchRequest:request error:&fetchError];
    }];
    error = fetchError;
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!foundObjects)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(foundObjects)]];
        return nil;
    }
    
    return foundObjects;
}

+ (NSArray *)fetchObjectIdsWithClass:(NSString *)className
                           predicate:(NSPredicate *)predicate
                     sortDescriptors:(NSArray *)sortDescriptors
                         fetchOffset:(NSUInteger)fetchOffset
                          fetchLimit:(NSUInteger)fetchLimit
                           batchSize:(NSUInteger)batchSize
                  withPendingChanges:(BOOL)includePendingChanges
                               error:(NSError *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSArray *foundObjectIds;
    __block NSError *fetchError;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext]];
        [request setResultType:NSManagedObjectIDResultType];
        if (predicate) [request setPredicate:predicate];
        if (sortDescriptors) [request setSortDescriptors:sortDescriptors];
        [request setFetchOffset:fetchOffset];
        if (fetchLimit) [request setFetchLimit:fetchLimit];
        [request setFetchBatchSize:batchSize];
        [request setIncludesPendingChanges:includePendingChanges];
        foundObjectIds = [managedObjectContext executeFetchRequest:request error:&fetchError];
    }];
    error = fetchError;
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!foundObjectIds)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(foundObjectIds)]];
        return nil;
    }
    
    return foundObjectIds;
}

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
                                  error:(NSError *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSArray *foundDictionaries;
    __block NSError *fetchError;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext]];
        [request setResultType:NSDictionaryResultType];
        if (predicate) [request setPredicate:predicate];
        if (sortDescriptors) [request setSortDescriptors:sortDescriptors];
        [request setFetchOffset:fetchOffset];
        if (fetchLimit) [request setFetchLimit:fetchLimit];
        [request setFetchBatchSize:batchSize];
        if (propertiesToFetch)
        {
            [request setPropertiesToFetch:propertiesToFetch];
            [request setReturnsDistinctResults:returnDistinctResults];
        }
        [request setIncludesSubentities:includeSubentities];
        [request setShouldRefreshRefetchedObjects:refresh];
        [request setReturnsObjectsAsFaults:returnObjectsAsFaults];
        foundDictionaries = [managedObjectContext executeFetchRequest:request error:&fetchError];
    }];
    error = fetchError;
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    if (!foundDictionaries)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeWarning methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@ is nil", stringFromVariable(foundDictionaries)]];
        return nil;
    }
    
    return foundDictionaries;
}

+ (NSUInteger)countObjectsWithClass:(NSString *)className
                          predicate:(NSPredicate *)predicate
                    sortDescriptors:(NSArray *)sortDescriptors
                        fetchOffset:(NSUInteger)fetchOffset
                         fetchLimit:(NSUInteger)fetchLimit
                          batchSize:(NSUInteger)batchSize
                 withPendingChanges:(BOOL)includePendingChanges
                              error:(NSError *)error
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    __block NSUInteger count;
    __block NSError *countError;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext]];
        [request setResultType:NSCountResultType];
        if (predicate) [request setPredicate:predicate];
        if (sortDescriptors) [request setSortDescriptors:sortDescriptors];
        [request setFetchOffset:fetchOffset];
        if (fetchLimit) [request setFetchLimit:fetchLimit];
        [request setFetchBatchSize:batchSize];
        [request setIncludesPendingChanges:includePendingChanges];
        count = [managedObjectContext countForFetchRequest:request error:&countError];
    }];
    error = countError;
    if (error)
    {
        [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeError methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:[NSString stringWithFormat:@"%@, %@", error, error.userInfo]];
    }
    
    return count;
}

#pragma mark - // PUBLIC METHODS (Deletors) //

+ (void)deleteObject:(NSManagedObject *)object
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeUnspecified customCategories:@[AKD_DATA, AKD_CORE_DATA] message:nil];
    
    NSManagedObjectContext *managedObjectContext = [CoreDataController managedObjectContext];
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext deleteObject:object];
    }];
}

#pragma mark - // CATEGORY METHODS //

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

#pragma mark - // PRIVATE METHODS (General) //

+ (id)sharedController
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:nil message:nil];
    
    static dispatch_once_t once;
    static CoreDataController *_sharedController;
    dispatch_once(&once, ^{
        _sharedController = [[CoreDataController alloc] init];
    });
    return _sharedController;
}

- (void)setup
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
}

- (void)teardown
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeSetup customCategories:nil message:nil];
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (NSManagedObjectContext *)managedObjectContext
{
    [AKDebugger logMethod:METHOD_NAME logType:AKLogTypeMethodName methodType:AKMethodTypeGetter customCategories:@[AKD_CORE_DATA] message:nil];
    
    return [[CoreDataController sharedController] managedObjectContext];
}

@end