/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <WCDB/Interface.h>
#import <WCDB/WCTCore+Private.h>
#import <WCDB/WCTError+Private.h>
#import <WCDB/WCTTable+Private.h>
#import <WCDB/WCTUnsafeHandle+Private.h>

@implementation WCTHandle (Table)

- (BOOL)isTableExists:(NSString *)tableName
{
    WCDB::Handle *handle = [self getOrGenerateHandle];
    if (!handle) {
        return NO;
    }
    return handle->isTableExists(tableName.UTF8String).second;
}

- (BOOL)isTableExists:(NSString *)tableName
            withError:(WCTError **)error
{
    WCDB::Handle *handle = [self getOrGenerateHandle];
    std::pair<bool, bool> result(true, false);
    if (handle) {
        result = handle->isTableExists(tableName.UTF8String);
    }
    if (error) {
        if (result.first) {
            *error = nil;
        } else {
            *error = [self getError];
        }
    }
    return result.second;
}

- (BOOL)createTableAndIndexes:(NSString *)tableName
                    withClass:(Class<WCTTableCoding>)cls
{
    return [self runNestedTransaction:^BOOL(WCTHandle *handle) {
      return [handle rebindTable:tableName toClass:cls];
    }];
}

- (WCTTable *)getTable:(NSString *)tableName
             withClass:(Class<WCTTableCoding>)cls
{
    return [[WCTTable alloc] initWithDatabase:_database
                                 andTableName:tableName
                                     andClass:cls];
}

- (BOOL)createVirtualTable:(NSString *)tableName
                 withClass:(Class<WCTTableCoding>)cls
{
    WCDB::Handle *handle = [self getOrGenerateHandle];
    if (!handle) {
        return NO;
    }
    return handle->execute([cls objectRelationalMappingForWCDB]->generateVirtualCreateTableStatement(tableName.UTF8String));
}

- (BOOL)dropTable:(NSString *)tableName
{
    WCDB::Handle *handle = [self getOrGenerateHandle];
    if (!handle) {
        return NO;
    }
    return handle->execute(WCDB::StatementDropTable().dropTable(tableName.UTF8String));
}

- (BOOL)dropIndex:(NSString *)indexName
{
    WCDB::Handle *handle = [self getOrGenerateHandle];
    if (!handle) {
        return NO;
    }
    return handle->execute(WCDB::StatementDropIndex().dropIndex(indexName.UTF8String));
}

@end
