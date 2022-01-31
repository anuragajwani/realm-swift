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

#import "RLMTestCase.h"

#import "RLMSectionedResults.h"
#import "RLMTestObjects.h"

#import <Foundation/Foundation.h>

@interface SectionedResultsTests : RLMTestCase
@end

@implementation SectionedResultsTests

- (void)createObjects {
    RLMRealm *realm = self.realmWithTestPath;
    [realm transactionWithBlock:^{
        StringObject *strObj1 = [[StringObject alloc] initWithValue:@[@"foo"]];
        StringObject *strObj2 = [[StringObject alloc] initWithValue:@[@"bar"]];
        StringObject *strObj3 = [[StringObject alloc] initWithValue:@[@"apple"]];
        StringObject *strObj4 = [[StringObject alloc] initWithValue:@[@"apples"]];
        StringObject *strObj5 = [[StringObject alloc] initWithValue:@[@"zebra"]];

        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:1 stringObject:strObj5]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:1 stringObject:strObj5]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:1 stringObject:strObj5]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:2 stringObject:strObj4]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:2 stringObject:strObj4]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:2 stringObject:strObj3]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:3 stringObject:strObj2]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:3 stringObject:strObj1]];
        [AllTypesObject createInRealm:realm withValue:[AllTypesObject values:3 stringObject:strObj1]];
    }];
}

- (void)createPrimitiveObject {
    RLMRealm *realm = self.realmWithTestPath;
    [realm transactionWithBlock:^{
        AllPrimitiveArrays *arrObj = [AllPrimitiveArrays new];
        [arrObj.stringObj addObject:@"foo"];
        [arrObj.stringObj addObject:@"fab"];
        [arrObj.stringObj addObject:@"bar"];
        [arrObj.stringObj addObject:@"baz"];
        [realm addObject:arrObj];
    }];
}

- (void)testCreationFromResults {
    [self createObjects];
    RLMRealm *realm = self.realmWithTestPath;


    [realm transactionWithBlock:^{
        [StringObject createInRealm:realm withValue:@[@"apple"]];
        [StringObject createInRealm:realm withValue:@[@"any"]];
        [StringObject createInRealm:realm withValue:@[@"banana"]];
    }];

    RLMResults<AllTypesObject *> *results = [AllTypesObject allObjectsInRealm:realm];
    RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"objectCol.stringCol"
                                                                                  ascending:YES
                                                                                   keyBlock:^id<RLMValue>(AllTypesObject *value) {
        return [value.objectCol.stringCol substringToIndex:1];
    }];

    XCTAssertNotNil(sr);
    XCTAssertEqual(sr.count, 4);
    XCTAssertEqual(sr[0].count, 3);
    XCTAssertEqual(sr[1].count, 1);
    XCTAssertEqual(sr[2].count, 2);
    XCTAssertEqual(sr[3].count, 3);
}

- (void)testCreationFromPrimitiveResults {
    [self createPrimitiveObject];
    RLMRealm *realm = self.realmWithTestPath;

    AllPrimitiveArrays *obj = [AllPrimitiveArrays allObjectsInRealm:realm][0];
    RLMSectionedResults *sr = [obj.stringObj sectionedResultsSortedUsingKeyPath:@"self"
                                                                      ascending:YES
                                                                       keyBlock:^id<RLMValue> (NSString* value) {
        return [value substringToIndex:1];
    }];
    XCTAssertEqual(sr.count, 2);

    [realm transactionWithBlock:^{
        [obj.stringObj addObject:@"hello"];

    }];
    XCTAssertEqual(sr.count, 3);

    [realm transactionWithBlock:^{
        [obj.stringObj addObject:@"zebra"];
    }];
    XCTAssertEqual(sr.count, 4);
}

- (NSDictionary *)keyPathsAndValues {
    return @{
        @"intCol": @{
            @1: @[@1, @1, @1, @3, @3, @3],
            @0: @[@2, @2, @2]
        },
        @"longCol": @{
            @0: @[@((long long)1 * INT_MAX + 1), @((long long)1 * INT_MAX + 1), @((long long)1 * INT_MAX + 1),
                  @((long long)3 * INT_MAX + 1), @((long long)3 * INT_MAX + 1), @((long long)3 * INT_MAX + 1)],
            @-1: @[@((long long)2 * INT_MAX + 1), @((long long)2 * INT_MAX + 1), @((long long)2 * INT_MAX + 1)]
        },
        @"boolCol": @{
            @NO: @[@NO, @NO, @NO],
            @YES: @[@YES, @YES, @YES, @YES, @YES, @YES]
        },
        @"cBoolCol": @{
            @NO: @[@NO, @NO, @NO],
            @YES: @[@YES, @YES, @YES, @YES, @YES, @YES]
        },
        @"floatCol": @{
            @(1.1f): @[@(1.1f * 1), @(1.1f * 1), @(1.1f * 1)],
            @(2.2f): @[@(1.1f * 2), @(1.1f * 2), @(1.1f * 2), @(1.1f * 3), @(1.1f * 3), @(1.1f * 3)]
        },
        @"doubleCol": @{
            @(1.11): @[@(1.11 * 1), @(1.11 * 1), @(1.11 * 1)],
            @(2.2): @[@(1.11 * 2), @(1.11 * 2), @(1.11 * 2), @(1.11 * 3), @(1.11 * 3), @(1.11 * 3)]
        },
        @"stringCol": @{
            @"a": @[@"a", @"a", @"a"],
            @"b": @[@"b", @"b", @"b"],
            @"c": @[@"c", @"c", @"c"]
        },
        @"objectCol.stringCol": @{
            @"a": @[@"apple", @"apples", @"apples"],
            @"b": @[@"bar"],
            @"f": @[@"foo", @"foo"],
            @"z": @[@"zebra", @"zebra", @"zebra"]
        },
        @"dateCol": @{
            @5: @[[NSDate dateWithTimeIntervalSince1970:1], [NSDate dateWithTimeIntervalSince1970:1], [NSDate dateWithTimeIntervalSince1970:1],
                  [NSDate dateWithTimeIntervalSince1970:2], [NSDate dateWithTimeIntervalSince1970:2], [NSDate dateWithTimeIntervalSince1970:2],
                  [NSDate dateWithTimeIntervalSince1970:3], [NSDate dateWithTimeIntervalSince1970:3], [NSDate dateWithTimeIntervalSince1970:3]]
        },
        @"decimalCol": @{
            @"one": @[[[RLMDecimal128 alloc] initWithNumber:@(1)], [[RLMDecimal128 alloc] initWithNumber:@(1)], [[RLMDecimal128 alloc] initWithNumber:@(1)]],
            @"two": @[[[RLMDecimal128 alloc] initWithNumber:@(2)], [[RLMDecimal128 alloc] initWithNumber:@(2)], [[RLMDecimal128 alloc] initWithNumber:@(2)]],
            @"three": @[[[RLMDecimal128 alloc] initWithNumber:@(3)], [[RLMDecimal128 alloc] initWithNumber:@(3)], [[RLMDecimal128 alloc] initWithNumber:@(3)]]
        },
        @"uuidCol": @{
            @"a": @[[[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"],
                    [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"],
                    [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"]],
            @"b": @[[[NSUUID alloc] initWithUUIDString:@"137DECC8-B300-4954-A233-F89909F4FD89"],
                    [[NSUUID alloc] initWithUUIDString:@"137DECC8-B300-4954-A233-F89909F4FD89"],
                    [[NSUUID alloc] initWithUUIDString:@"137DECC8-B300-4954-A233-F89909F4FD89"]],
            @"c": @[[[NSUUID alloc] initWithUUIDString:@"b84e8912-a7c2-41cd-8385-86d200d7b31e"],
                    [[NSUUID alloc] initWithUUIDString:@"b84e8912-a7c2-41cd-8385-86d200d7b31e"],
                    [[NSUUID alloc] initWithUUIDString:@"b84e8912-a7c2-41cd-8385-86d200d7b31e"]]
        },
        @"anyCol": @{
            @1: @[@3, @3, @3],
            @0: @[@2, @2, @2, @4, @4, @4]
        }
    };
}

- (id<RLMValue>)sectionKeyForValue:(id<RLMValue>)value {
    switch (value.rlm_valueType) {
        case RLMPropertyTypeInt:
            return [NSNumber numberWithInt:(((NSNumber *)value).intValue % 2)];
        case RLMPropertyTypeBool:
            return value;
        case RLMPropertyTypeFloat:
            return [(NSNumber *)value isEqualToNumber:@(1.1f * 1)] ? @(1.1f) : @(2.2f);
        case RLMPropertyTypeDouble:
            return [(NSNumber *)value isEqualToNumber:@(1.11 * 1)] ? @(1.11) : @(2.2);
        case RLMPropertyTypeString:
            return [(NSString *)value substringToIndex:1];
        case RLMPropertyTypeDate: {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *comp = [calendar components:NSCalendarUnitWeekday fromDate:(NSDate *)value];
            return [NSNumber numberWithInt:comp.weekday];
        }
        case RLMPropertyTypeDecimal128:
            switch ((int)((RLMDecimal128 *)value).doubleValue) {
                case 1:
                    return @"one";
                case 2:
                    return @"two";
                case 3:
                    return @"three";
                default:
                    XCTFail();
            }
        case RLMPropertyTypeUUID:
            if ([(NSUUID *)value isEqualTo:[[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"]]) {
                return @"a";
            } else if ([(NSUUID *)value isEqualTo:[[NSUUID alloc] initWithUUIDString:@"137DECC8-B300-4954-A233-F89909F4FD89"]]) {
                return @"b";
            } else if ([(NSUUID *)value isEqualTo:[[NSUUID alloc] initWithUUIDString:@"b84e8912-a7c2-41cd-8385-86d200d7b31e"]]) {
                return @"c";
            }
        case RLMPropertyTypeAny:
            return [NSNumber numberWithInt:(((NSNumber *)value).intValue % 2)];;
        default:
            XCTFail();
    }
}

- (void)testAllSupportedTypes {
    [self createObjects];
    RLMRealm *realm = self.realmWithTestPath;
    RLMResults<AllTypesObject *> *results = [AllTypesObject allObjectsInRealm:realm];

    void(^testBlock)(NSString *) = ^(NSString *keyPath) {
        __block int algoRunCount = 0;
        RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:keyPath
                                                                                      ascending:YES
                                                                                       keyBlock:^id<RLMValue>(id value) {
            algoRunCount++;
            return [self sectionKeyForValue:[value valueForKeyPath:keyPath]];
        }];

        NSDictionary *values = [self keyPathsAndValues][keyPath];
        for (RLMSection *section in sr) {
            NSArray *a = values[section.key];
            for (NSUInteger i = 0; i < section.count; i++) {
                XCTAssertEqualObjects(a[i], [section[i] valueForKeyPath:keyPath]);
            }
        }
        XCTAssertEqual(algoRunCount, 9);
    };

    testBlock(@"intCol");
    testBlock(@"boolCol");
    testBlock(@"floatCol");
    testBlock(@"doubleCol");
    testBlock(@"stringCol");
    testBlock(@"objectCol.stringCol");
    testBlock(@"dateCol");
    testBlock(@"cBoolCol");
    testBlock(@"longCol");
    testBlock(@"decimalCol");
    testBlock(@"uuidCol");
    testBlock(@"anyCol");
}

- (void)testAllSupportedOptionalTypes {
    NSDictionary *values = @{
        @"intObj": @1,
        @"floatObj": @1.0f,
        @"doubleObj": @1.0,
        @"boolObj": @YES,
        @"string": @"foo",
        @"date": [NSDate dateWithTimeIntervalSince1970:1],
        @"decimal": [[RLMDecimal128 alloc] initWithNumber:@1],
        @"uuidCol": [[NSUUID alloc] initWithUUIDString:@"85d4fbee-6ec6-47df-bfa1-615931903d7e"]
    };
    RLMRealm *realm = self.realmWithTestPath;
    [realm transactionWithBlock:^{
        [AllOptionalTypes createInRealm:realm withValue:values];
        [realm addObject:[AllOptionalTypes new]];
    }];

    RLMResults<AllOptionalTypes *> *results = [AllOptionalTypes allObjectsInRealm:realm];

    void(^testBlock)(NSString *) = ^(NSString *keyPath) {
        __block int algoRunCount = 0;
        RLMSectionedResults<AllOptionalTypes *> *sr = [results sectionedResultsSortedUsingKeyPath:keyPath
                                                                                        ascending:YES
                                                                                         keyBlock:^id<RLMValue>(AllOptionalTypes *value) {
            algoRunCount++;
            if ([value valueForKeyPath:keyPath]) {
                return @"Not null";
            } else {
                return nil;
            }
        }];

        RLMSection *nullSection = sr[0];
        XCTAssertEqualObjects(nullSection.key, NSNull.null);
        XCTAssertNil([nullSection[0] valueForKeyPath:keyPath]);

        RLMSection *nonNullSection = sr[1];
        XCTAssertEqualObjects(nonNullSection.key, @"Not null");
        XCTAssertEqualObjects([nonNullSection[0] valueForKeyPath:keyPath], values[keyPath]);

        XCTAssertEqual(algoRunCount, 2);
    };

    testBlock(@"intObj");
    testBlock(@"floatObj");
    testBlock(@"doubleObj");
    testBlock(@"boolObj");
    testBlock(@"string");
    testBlock(@"date");
    testBlock(@"decimal");
    testBlock(@"uuidCol");
}

- (void)testObjectIdCol {
    RLMRealm *realm = self.realmWithTestPath;
    __block RLMObjectId *oid1;
    __block RLMObjectId *oid2;

    [realm transactionWithBlock:^{
        NSDictionary *ato1Values = [AllTypesObject values:0 stringObject:nil];
        oid1 = ato1Values[@"objectIdCol"];
        [AllTypesObject createInRealm:realm withValue:ato1Values];
        NSDictionary *ato2Values = [AllTypesObject values:0 stringObject:nil];
        oid2 = ato2Values[@"objectIdCol"];
        [AllTypesObject createInRealm:realm withValue:ato2Values];

        AllOptionalTypes *ot1 = [AllOptionalTypes new];
        ot1.objectId = oid1;
        AllOptionalTypes *ot2 = [AllOptionalTypes new];
        [realm addObjects:@[ot1, ot2]];
    }];

    RLMResults<AllTypesObject *> *results = [AllTypesObject allObjectsInRealm:realm];
    RLMResults<AllOptionalTypes *> *resultsOpt = [AllOptionalTypes allObjectsInRealm:realm];
    __block int sectionAlgoCount = 0;

    RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"objectIdCol"
                                                                                  ascending:YES
                                                                                   keyBlock:^id<RLMValue>(id value) {
        id v = [value valueForKeyPath:@"objectIdCol"];
        sectionAlgoCount++;
        return [((RLMObjectId *)v) isEqualTo:oid1] ? @"a" : @"b";
    }];

    NSDictionary *values = @{@"a": oid1, @"b": oid2};
    for (RLMSection *section in sr) {
        RLMObjectId *oid = values[section.key];
        for (NSUInteger i = 0; i < section.count; i++) {
            XCTAssertEqualObjects(oid, [section[i] valueForKeyPath:@"objectIdCol"]);
        }
    }
    XCTAssertEqual(sectionAlgoCount, 2);

    sectionAlgoCount = 0;
    RLMSectionedResults<AllOptionalTypes *> *srOpt = [resultsOpt sectionedResultsSortedUsingKeyPath:@"objectId"
                                                                                          ascending:YES
                                                                                           keyBlock:^id<RLMValue>(id value) {
        sectionAlgoCount++;
        id v = [value valueForKeyPath:@"objectId"];
        return !v ? @"b" : @"a";
    }];

    values = @{@"a": oid1, @"b": NSNull.null};
    for (RLMSection *section in srOpt) {
        RLMObjectId *oid = values[section.key];
        for (NSUInteger i = 0; i < section.count; i++) {
            id v = [section[i] valueForKeyPath:@"objectId"];
            if ([((NSString *)section.key) isEqualToString:@"b"]) {
                XCTAssertNil(v);
            } else {
                XCTAssertEqualObjects(oid, v);
            }
        }
    }
    XCTAssertEqual(sectionAlgoCount, 2);
}

- (void)testBinaryCol {
    RLMRealm *realm = self.realmWithTestPath;
    __block NSData *d1;
    __block NSData *d2;

    [realm transactionWithBlock:^{
        NSDictionary *ato1Values = [AllTypesObject values:0 stringObject:nil];
        d1 = ato1Values[@"binaryCol"];
        [AllTypesObject createInRealm:realm withValue:ato1Values];
        NSDictionary *ato2Values = [AllTypesObject values:0 stringObject:nil];
        d2 = ato2Values[@"binaryCol"];
        [AllTypesObject createInRealm:realm withValue:ato2Values];

        AllOptionalTypes *ot1 = [AllOptionalTypes new];
        ot1.data = d1;
        AllOptionalTypes *ot2 = [AllOptionalTypes new];
        [realm addObjects:@[ot1, ot2]];
    }];

    RLMResults<AllTypesObject *> *results = [AllTypesObject allObjectsInRealm:realm];
    RLMResults<AllOptionalTypes *> *resultsOpt = [AllOptionalTypes allObjectsInRealm:realm];
    __block int sectionAlgoCount = 0;

    // Sorting on binary col is unsupported
    RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"intCol"
                                                                                  ascending:YES
                                                                                   keyBlock:^id<RLMValue>(id value) {
        id v = [value valueForKeyPath:@"binaryCol"];
        sectionAlgoCount++;
        return [((NSData *)v) isEqualTo:d1] ? @"a" : @"b";
    }];

    NSDictionary *values = @{@"a": d1, @"b": d2};
    for (RLMSection *section in sr) {
        RLMObjectId *oid = values[section.key];
        for (NSUInteger i = 0; i < section.count; i++) {
            XCTAssertEqualObjects(oid, [section[i] valueForKeyPath:@"binaryCol"]);
        }
    }
    XCTAssertEqual(sectionAlgoCount, 2);

    sectionAlgoCount = 0;
    RLMSectionedResults<AllOptionalTypes *> *srOpt = [resultsOpt sectionedResultsSortedUsingKeyPath:@"intObj"
                                                                                          ascending:YES
                                                                                           keyBlock:^id<RLMValue>(id value) {
        sectionAlgoCount++;
        id v = [value valueForKeyPath:@"data"];
        return !v ? @"b" : @"a";
    }];

    values = @{@"a": d1, @"b": NSNull.null};
    for (RLMSection *section in srOpt) {
        NSData *d = values[section.key];
        for (NSUInteger i = 0; i < section.count; i++) {
            id v = [section[i] valueForKeyPath:@"data"];
            if ([((NSString *)section.key) isEqualToString:@"b"]) {
                XCTAssertNil(v);
            } else {
                XCTAssertEqualObjects(d, v);
            }
        }
    }
    XCTAssertEqual(sectionAlgoCount, 2);
}

- (void)testDescription {
    RLMRealm *realm = self.realmWithTestPath;

    [realm transactionWithBlock:^{
        [StringObject createInRealm:realm withValue:@[@"apple"]];
        [StringObject createInRealm:realm withValue:@[@"any"]];
        [StringObject createInRealm:realm withValue:@[@"banana"]];
    }];

    RLMResults<StringObject *> *results = [StringObject allObjectsInRealm:realm];
    RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"stringCol"
                                                                                  ascending:YES
                                                                                   keyBlock:^id<RLMValue>(StringObject *value) {
        return value.firstLetter;
    }];

    NSString *expDesc =
    @"(?s)RLMSectionedResults\\<StringObject\\> \\<0x[a-z0-9]+\\> \\(\n"
    @"\t\\[a\\] RLMSection \\<0x[a-z0-9]+\\> \\(\n"
    @"\t\t\\[0\\] StringObject \\{\n"
    @"\t\t\tstringCol = any;\n"
    @"\t\t\\},\n"
    @"\t\t\\[1\\] StringObject \\{\n"
    @"\t\t\tstringCol = apple;\n"
    @"\t\t\\}\n"
    @"\t\\),\n"
    @"\t\\[b\\] RLMSection \\<0x[a-z0-9]+\\> \\(\n"
    @"\t\t\\[0\\] StringObject \\{\n"
    @"\t\t\tstringCol = banana;\n"
    @"\t\t\\}\n"
    @"\t\\)\n"
    @"\\)";
    RLMAssertMatches(sr.description, expDesc);

    expDesc =
    @"RLMSection \\<0x[a-z0-9]+\\> \\(\n"
    @"\t\\[0\\] StringObject \\{\n"
    @"\t\tstringCol = any;\n"
    @"\t\\},\n"
    @"\t\\[1\\] StringObject \\{\n"
    @"\t\tstringCol = apple;\n"
    @"\t\\}\n"
    @"\\)";
    RLMAssertMatches(sr[0].description, expDesc);
}

- (void)testFastEnumeration {
    for (int i = 0; i < 10; i++) {
        [self createObjects];
    }
    RLMRealm *realm = self.realmWithTestPath;

    __block NSUInteger algoRunCount = 0;
    __block NSUInteger forLoopCount = 0;

    RLMResults<AllTypesObject *> *results = [AllTypesObject allObjectsInRealm:realm];
    RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"objectCol.stringCol"
                                                                                  ascending:YES
                                                                                   keyBlock:^id<RLMValue>(id value) {
        algoRunCount++;
        return value;
    }];

    for (RLMSection *section in sr) {
        for (AllTypesObject *o in section) {
            forLoopCount++;
        }
    }
    XCTAssertEqual(algoRunCount, results.count);
    XCTAssertEqual(forLoopCount, results.count);
    forLoopCount = 0;
    [self createObjects];
    algoRunCount = 0;

    for (RLMSection *section in sr) {
        for (AllTypesObject *o in section) {
            forLoopCount++;
        }
    }
    XCTAssertEqual(algoRunCount, results.count);
    XCTAssertEqual(forLoopCount, results.count);
    forLoopCount = 0;
    algoRunCount = 0;
    int originalCount = results.count;

    for (RLMSection *section in sr) {
        for (AllTypesObject *o in section) {
            forLoopCount++;
        }
        [self createObjects];
    }
    // transaction inside the 'for in' should not invoke the section key
    // callback until the next access of the SectionedResults collection.
    XCTAssertEqual(algoRunCount, 0);
    XCTAssertEqual(forLoopCount, originalCount);
}

static RLMSectionedResultsChange *getChange(SectionedResultsTests *self, void (^block)(RLMRealm *)) {
    __block RLMSectionedResultsChange *changes;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<StringObject *> *results = [StringObject allObjectsInRealm:realm];
    RLMSectionedResults<StringObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"stringCol"
                                                                                ascending:YES
                                                                                 keyBlock:^id<RLMValue>(StringObject *value) {
        return value.firstLetter;
    }];

    id token = [sr addNotificationBlock:^(RLMSectionedResults *sr,
                                          RLMSectionedResultsChange *c,
                                          NSError *e) {
        changes = c;
        XCTAssertNil(e);
        XCTAssertNotNil(sr);
        CFRunLoopStop(CFRunLoopGetCurrent());
    }];
    
    CFRunLoopRun();

    [self waitForNotification:RLMRealmDidChangeNotification realm:RLMRealm.defaultRealm block:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            block(realm);
        }];
    }];

    [(RLMNotificationToken *)token invalidate];
    token = nil;

    return changes;
}

static void ExpectChange(id self,
                         NSArray<NSIndexPath *> *insertions,
                         NSArray<NSIndexPath *> *deletions,
                         NSArray<NSIndexPath *> *modifications,
                         NSArray<NSNumber *> *sectionsToInsert,
                         NSArray<NSNumber *> *sectionsToRemove,
                         void (^block)(RLMRealm *)) {
    RLMSectionedResultsChange *changes = getChange(self, block);
    XCTAssertNotNil(changes);
    if (!changes) {
        return;
    }

    XCTAssertEqualObjects(insertions, changes.insertions);
    XCTAssertEqualObjects(deletions, changes.deletions);
    XCTAssertEqualObjects(modifications, changes.modifications);
    XCTAssertEqualObjects(sectionsToInsert, changes.sectionsToInsert);
    XCTAssertEqualObjects(sectionsToRemove, changes.sectionsToRemove);
}

- (void)testNotifications {
    StringObject *o1 = [[StringObject alloc] initWithValue:@[@"any"]];
    StringObject *o2 = [[StringObject alloc] initWithValue:@[@"zebra"]];
    StringObject *o3 = [[StringObject alloc] initWithValue:@[@"apple"]];
    StringObject *o4 = [[StringObject alloc] initWithValue:@[@"zulu"]];
    StringObject *o5 = [[StringObject alloc] initWithValue:@[@"banana"]];
    StringObject *o6 = [[StringObject alloc] initWithValue:@[@"beans"]];

    // Insertions
    ExpectChange(self,
                 @[[NSIndexPath indexPathForItem:0 inSection:0],
                   [NSIndexPath indexPathForItem:1 inSection:0],
                   [NSIndexPath indexPathForItem:0 inSection:1],
                   [NSIndexPath indexPathForItem:0 inSection:2],
                   [NSIndexPath indexPathForItem:1 inSection:2]],
                 @[], @[], @[@0, @1, @2], @[], ^(RLMRealm *realm) {
        [realm addObjects:@[o1, o2, o3, o4, o5]];
    });

    ExpectChange(self,
                 @[[NSIndexPath indexPathForItem:1 inSection:1]],
                 @[], @[], @[], @[], ^(RLMRealm *realm) {
        [realm addObject:o6];
    });

    // Deletions
    ExpectChange(self,
                 @[], @[[NSIndexPath indexPathForItem:0 inSection:1]],
                 @[], @[], @[], ^(RLMRealm *realm) {
        StringObject *o = [[[StringObject allObjectsInRealm:realm] objectsWhere:@"stringCol = 'banana'"] firstObject];
        [realm deleteObject:o]; // o5 will now be invalidated.
    });

    // Modifications
    ExpectChange(self,
                 @[], @[],
                 @[[NSIndexPath indexPathForItem:0 inSection:1]],
                 @[], @[], ^(RLMRealm *realm) {
        StringObject *o = [[[StringObject allObjectsInRealm:realm] objectsWhere:@"stringCol = 'beans'"] firstObject];
        o.stringCol = @"breakfast";
    });

    // Move object from one section to another
    ExpectChange(self,
                 @[[NSIndexPath indexPathForItem:0 inSection:0]],
                 @[],
                 @[],
                 @[], @[@1], ^(RLMRealm *realm) {
        StringObject *o = [[[StringObject allObjectsInRealm:realm] objectsWhere:@"stringCol = 'breakfast'"] firstObject];
        o.stringCol = @"all";
    });

    // Move object from one section to a new section
    ExpectChange(self,
                 @[[NSIndexPath indexPathForItem:0 inSection:0],
                   [NSIndexPath indexPathForItem:1 inSection:0],
                   [NSIndexPath indexPathForItem:2 inSection:0]],
                 @[],
                 @[],
                 @[@0], @[@0], ^(RLMRealm *realm) {
        RLMResults<StringObject *> *objs = [[StringObject allObjectsInRealm:realm] objectsWhere:@"stringCol BEGINSWITH 'a'"];
        for(StringObject *o in objs) {
            o.stringCol = @"max";
        }
    });
}

- (void)testNotificationOnQueue {
    __block RLMSectionedResultsChange *changes;
    RLMRealm *realm = self.realmWithTestPath;
    [self createObjects];
    RLMResults<AllTypesObject *> *results = [AllTypesObject allObjectsInRealm:realm];
    RLMSectionedResults<AllTypesObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"stringCol"
                                                                                  ascending:YES
                                                                                   keyBlock:^id<RLMValue>(AllTypesObject *value) {
        return [value.stringCol substringToIndex:1];
    }];

    dispatch_queue_t notificationQueue = dispatch_queue_create("notificationQueue", DISPATCH_QUEUE_SERIAL);

    id token = [sr addNotificationBlock:^(RLMSectionedResults *r, RLMSectionedResultsChange *c, NSError *e) {
        changes = c;
        XCTAssertNil(e);
    }
                               keyPaths:@[@"stringCol"]
                                  queue:notificationQueue];

    [self waitForNotification:RLMRealmDidChangeNotification realm:self.realmWithTestPath block:^{
        RLMRealm *r = self.realmWithTestPath;
        [r transactionWithBlock:^{
            AllTypesObject *o = [AllTypesObject allObjectsInRealm:r][0];
            o.stringCol = @"app";
        }];
    }];

    dispatch_sync(notificationQueue, ^{});
    XCTAssertEqualObjects(changes.insertions, @[[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssertEqualObjects(changes.deletions, @[[NSIndexPath indexPathForItem:0 inSection:0]]);
}

- (void)testNotificationsOnSection {

    __block RLMSectionedResultsChange *changes;
    RLMRealm *realm = self.realmWithTestPath;
    [self createObjects];
    RLMResults<StringObject *> *results = [StringObject allObjectsInRealm:realm];
    RLMSectionedResults<StringObject *> *sr = [results sectionedResultsSortedUsingKeyPath:@"stringCol"
                                                                                ascending:YES
                                                                                 keyBlock:^id<RLMValue>(StringObject *value) {
        return value.firstLetter;
    }];

    RLMSection<StringObject *> *section = sr[0];
    dispatch_queue_t notificationQueue = dispatch_queue_create("notificationQueue", DISPATCH_QUEUE_SERIAL);

    id token = [section addNotificationBlock:^(RLMSection *r, RLMSectionedResultsChange *c, NSError *e) {
        changes = c;
        XCTAssertNil(e);
    }
                                    keyPaths:@[@"stringCol"]
                                       queue:notificationQueue];

    [self waitForNotification:RLMRealmDidChangeNotification realm:self.realmWithTestPath block:^{
        RLMRealm *r = self.realmWithTestPath;
        [r transactionWithBlock:^{
            StringObject *o = [StringObject allObjectsInRealm:r][0];
            o.stringCol = @"app";
        }];
    }];

    dispatch_sync(notificationQueue, ^{});
    XCTAssertEqualObjects(changes.insertions, @[[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssertEqualObjects(changes.modifications, @[]);
    XCTAssertEqualObjects(changes.deletions, @[]);
    XCTAssertEqualObjects(changes.sectionsToInsert, @[]);
    XCTAssertEqualObjects(changes.sectionsToRemove, @[]);

    [self waitForNotification:RLMRealmDidChangeNotification realm:self.realmWithTestPath block:^{
        RLMRealm *r = self.realmWithTestPath;
        [r transactionWithBlock:^{
            [r deleteAllObjects];
        }];
    }];

    dispatch_sync(notificationQueue, ^{});
    XCTAssertEqualObjects(changes.insertions, @[]);
    XCTAssertEqualObjects(changes.modifications, @[]);
    XCTAssertEqualObjects(changes.deletions, @[]);
    XCTAssertEqualObjects(changes.sectionsToInsert, @[]);
    XCTAssertEqualObjects(changes.sectionsToRemove, @[@0]);
}

static RLMSectionedResultsChange *getChangePrimitive(SectionedResultsTests *self, void (^block)(RLMRealm *)) {
    __block RLMSectionedResultsChange *changes;
    RLMRealm *realm = [RLMRealm defaultRealm];

    AllPrimitiveArrays *obj = [AllPrimitiveArrays allObjectsInRealm:realm][0];
    RLMSectionedResults *sr = [obj.stringObj sectionedResultsSortedUsingKeyPath:@"self"
                                                                      ascending:YES
                                                                       keyBlock:^id<RLMValue> (id value) {
        return [value substringToIndex:1];
    }];

    id token = [sr addNotificationBlock:^(RLMSectionedResults *sr,
                                          RLMSectionedResultsChange *c,
                                          NSError *e) {
        changes = c;
        XCTAssertNil(e);
        XCTAssertNotNil(sr);
        CFRunLoopStop(CFRunLoopGetCurrent());
    }];

    CFRunLoopRun();

    [self waitForNotification:RLMRealmDidChangeNotification realm:RLMRealm.defaultRealm block:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            block(realm);
        }];
    }];

    [(RLMNotificationToken *)token invalidate];
    token = nil;

    return changes;
}

static void ExpectChangePrimitive(id self,
                                  NSArray<NSIndexPath *> *insertions,
                                  NSArray<NSIndexPath *> *deletions,
                                  NSArray<NSIndexPath *> *modifications,
                                  NSArray<NSNumber *> *sectionsToInsert,
                                  NSArray<NSNumber *> *sectionsToRemove,
                                  void (^block)(RLMRealm *)) {
    RLMSectionedResultsChange *changes = getChangePrimitive(self, block);
    XCTAssertNotNil(changes);
    if (!changes) {
        return;
    }

    XCTAssertEqualObjects(insertions, changes.insertions);
    XCTAssertEqualObjects(deletions, changes.deletions);
    XCTAssertEqualObjects(modifications, changes.modifications);
    XCTAssertEqualObjects(sectionsToInsert, changes.sectionsToInsert);
    XCTAssertEqualObjects(sectionsToRemove, changes.sectionsToRemove);
}

- (void)testNotificationsPrimitive {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        AllPrimitiveArrays *arrObj = [AllPrimitiveArrays new];
        [realm addObject:arrObj];
    }];

    // Insertions
    ExpectChangePrimitive(self,
                          @[[NSIndexPath indexPathForItem:0 inSection:0],
                            [NSIndexPath indexPathForItem:0 inSection:1],
                            [NSIndexPath indexPathForItem:0 inSection:2]],
                          @[], @[], @[@0, @1, @2], @[], ^(RLMRealm *r) {
        AllPrimitiveArrays *o = [AllPrimitiveArrays allObjectsInRealm:r][0];
        [o.stringObj addObjects:@[@"apple", @"banana", @"orange"]];
    });

    // Deletions
    ExpectChangePrimitive(self,
                          @[], @[],
                          @[], @[], @[@0], ^(RLMRealm *r) {
        AllPrimitiveArrays *o = [AllPrimitiveArrays allObjectsInRealm:r][0];
        [o.stringObj removeObjectAtIndex:0];
    });

    // Modifications
    ExpectChangePrimitive(self,
                          @[], @[],
                          @[[NSIndexPath indexPathForItem:0 inSection:0]], @[], @[], ^(RLMRealm *r) {
        AllPrimitiveArrays *o = [AllPrimitiveArrays allObjectsInRealm:r][0];
        o.stringObj[0] = @"box"; // banana -> box
    });

    // Remove elements from one section, insert into another.
    ExpectChangePrimitive(self,
                          @[[NSIndexPath indexPathForItem:0 inSection:1]],
                          @[],
                          @[], @[@1], @[@0], ^(RLMRealm *r) {
        AllPrimitiveArrays *o = [AllPrimitiveArrays allObjectsInRealm:r][0];
        o.stringObj[0] = @"zebra"; // open -> zebra
    });
}

- (void)testSortDescriptors {

}

- (void)testDescending {

}

- (void)testFrozen {

}

- (void)testHandlesLargeCollection {

}

- (void)testInitFromRLMArray {

}

- (void)testInitFromRLMSet {

}

/*

 test plan:

 add sort descriptors
 large set ~10000 objects - 10000 sections, 10000 in one section
 ascending / decending
 test on frozen results
 */

@end
