////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import <Realm/RLMCollection.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RLMValue;
@class RLMResults<RLMObjectType>;

@interface RLMSectionedResultsChange : NSObject
@property (nonatomic, readonly) NSArray<NSIndexPath *> *deletions;
@property (nonatomic, readonly) NSArray<NSIndexPath *> *insertions;
@property (nonatomic, readonly) NSArray<NSIndexPath *> *modifications;

@property (nonatomic, readonly) NSArray<NSNumber *> *sectionsToInsert;
@property (nonatomic, readonly) NSArray<NSNumber *> *sectionsToRemove;


/// Returns the index paths of the deletion indices in the given section.
- (NSArray<NSIndexPath *> *)deletionsInSection:(NSUInteger)section;

/// Returns the index paths of the insertion indices in the given section.
- (NSArray<NSIndexPath *> *)insertionsInSection:(NSUInteger)section;

/// Returns the index paths of the modification indices in the given section.
- (NSArray<NSIndexPath *> *)modificationsInSection:(NSUInteger)section;
@end

@interface RLMSection<RLMObjectType> : NSObject<NSFastEnumeration, RLMThreadConfined>
/// The count of objects in this section.
@property (nonatomic, readonly, assign) NSUInteger count;

@property (nonatomic, readonly) id<RLMValue> key;
/// Returns the object for a given index in the section.
- (RLMObjectType)objectAtIndexedSubscript:(NSUInteger)index;
/// Returns the object for a given index in the section.
- (id)objectAtIndex:(NSUInteger)index;

- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSection *, RLMSectionedResultsChange *, NSError *))block __attribute__((warn_unused_result));
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSection *, RLMSectionedResultsChange *, NSError *))block
                                         queue:(dispatch_queue_t)queue __attribute__((warn_unused_result));
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSection *, RLMSectionedResultsChange *, NSError *))block
                                      keyPaths:(NSArray<NSString *> *)keyPaths __attribute__((warn_unused_result));
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSection *, RLMSectionedResultsChange *, NSError *))block
                                      keyPaths:(NSArray<NSString *> *)keyPaths
                                         queue:(dispatch_queue_t)queue __attribute__((warn_unused_result));

@end

@interface RLMSectionedResults<RLMObjectType> : NSObject<NSFastEnumeration, RLMThreadConfined>
/// The total amount of sections in this collection.
@property (nonatomic, readonly, assign) NSUInteger count;
/// Returns the section at a given index.
- (RLMSection *)objectAtIndexedSubscript:(NSUInteger)index;
/// Returns the section at a given index.
- (RLMSection *)objectAtIndex:(NSUInteger)index;

- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSectionedResults *, RLMSectionedResultsChange *, NSError *))block __attribute__((warn_unused_result));
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSectionedResults *, RLMSectionedResultsChange *, NSError *))block
                                         queue:(dispatch_queue_t)queue __attribute__((warn_unused_result));
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSectionedResults *, RLMSectionedResultsChange *, NSError *))block
                                      keyPaths:(NSArray<NSString *> *)keyPaths __attribute__((warn_unused_result));
- (RLMNotificationToken *)addNotificationBlock:(void (^)(RLMSectionedResults *, RLMSectionedResultsChange *, NSError *))block
                                      keyPaths:(NSArray<NSString *> *)keyPaths
                                         queue:(dispatch_queue_t)queue __attribute__((warn_unused_result));

@end

NS_ASSUME_NONNULL_END
