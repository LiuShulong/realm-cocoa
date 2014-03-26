/*************************************************************************
 *
 * TIGHTDB CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2014] TightDB Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of TightDB Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to TightDB Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from TightDB Incorporated.
 *
 **************************************************************************/

#include <tightdb/table.hpp>

#import <tightdb/objc/TDBRow.h>
#import <tightdb/objc/TDBTable.h>
#import <tightdb/objc/TDBTable_noinst.h>
#import <tightdb/objc/PrivateTDB.h>

#include <tightdb/objc/util_noinst.hpp>

using namespace std;

// TODO: Concept for cursor invalidation (when table updates).

@interface TDBRow()
@property (nonatomic, weak) TDBTable *table;
@property (nonatomic) NSUInteger ndx;
@end
@implementation TDBRow
@synthesize table = _table;
@synthesize ndx = _ndx;

-(id)initWithTable:(TDBTable *)table ndx:(NSUInteger)ndx
{
    if (ndx >= [table rowCount])
        return nil;

    self = [super init];
    if (self) {
        _table = table;
        _ndx = ndx;
    }
    return self;
}
-(NSUInteger)TDBIndex
{
    return _ndx;
}
-(void)TDBSetNdx:(NSUInteger)ndx
{
    _ndx = ndx;
}
-(void)dealloc
{
#ifdef TIGHTDB_DEBUG
    NSLog(@"TDBRow dealloc");
#endif
    _table = nil;
}

-(id)objectAtIndexedSubscript:(NSUInteger)colNdx
{
    TDBType columnType = [_table columnTypeOfColumn:colNdx];
    switch (columnType) {
        case TDBBoolType:
            return [NSNumber numberWithBool:[_table TDB_boolInColumnWithIndex:colNdx atRowIndex:_ndx]];
        case TDBIntType:
            return [NSNumber numberWithLongLong:[_table TDB_intInColumnWithIndex:colNdx atRowIndex:_ndx]];
        case TDBFloatType:
            return [NSNumber numberWithFloat:[_table TDB_floatInColumnWithIndex:colNdx atRowIndex:_ndx]];
        case TDBDoubleType:
            return [NSNumber numberWithLongLong:[_table TDB_doubleInColumnWithIndex:colNdx atRowIndex:_ndx]];
        case TDBStringType:
            return [_table TDB_stringInColumnWithIndex:colNdx atRowIndex:_ndx];
        case TDBDateType:
            return [_table TDB_dateInColumnWithIndex:colNdx atRowIndex:_ndx];
        case TDBBinaryType:
            return [_table TDB_binaryInColumnWithIndex:colNdx atRowIndex:_ndx];
        case TDBTableType:
            return [_table TDB_tableInColumnWithIndex:colNdx atRowIndex:_ndx];
        case TDBMixedType:
            return [_table TDB_mixedInColumnWithIndex:colNdx atRowIndex:_ndx];
    }
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    NSUInteger colNdx = [_table indexOfColumnWithName:(NSString *)key];
    return [self objectAtIndexedSubscript:colNdx];
}

-(void)setObject:(id)obj atIndexedSubscript:(NSUInteger)colNdx
{

    tightdb::Table& t = [_table getNativeTable];
    tightdb::ConstDescriptorRef descr = t.get_descriptor();
    if (!verify_cell(*descr, size_t(colNdx), (NSObject *)obj)) {
        NSException* exception = [NSException exceptionWithName:@"tightdb:wrong_column_type"
                                                         reason:[NSString stringWithFormat:@"colName %@ with index: %lu is of type %u",
                                                                 to_objc_string(t.get_column_name(colNdx)), colNdx, t.get_column_type(colNdx) ]
                                                       userInfo:[NSMutableDictionary dictionary]];
        [exception raise];
        
    }
    set_cell(size_t(colNdx), size_t(_ndx), t, (NSObject *)obj);
}   

-(void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    NSUInteger colNdx = [_table indexOfColumnWithName:(NSString*)key];
    [self setObject:obj atIndexedSubscript:colNdx];
}


-(int64_t)intInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_intInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(NSString *)stringInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_stringInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(NSData *)binaryInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_binaryInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(BOOL)boolInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_boolInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(float)floatInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_floatInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(double)doubleInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_doubleInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(NSDate *)dateInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_dateInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(TDBTable *)tableInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_tableInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(id)mixedInColumnWithIndex:(NSUInteger)colNdx
{
    return [_table TDB_mixedInColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setInt:(int64_t)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setInt:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setString:(NSString *)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setString:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setBinary:(NSData *)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setBinary:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setBool:(BOOL)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setBool:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setFloat:(float)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setFloat:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setDouble:(double)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setDouble:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setDate:(NSDate *)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setDate:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setTable:(TDBTable *)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setTable:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

-(void)setMixed:(id)value inColumnWithIndex:(NSUInteger)colNdx
{
    [_table TDB_setMixed:value inColumnWithIndex:colNdx atRowIndex:_ndx];
}

@end


@implementation TDBAccessor
{
    __weak TDBRow *_cursor;
    size_t _columnId;
}

-(id)initWithRow:(TDBRow *)cursor columnId:(NSUInteger)columnId
{
    self = [super init];
    if (self) {
        _cursor = cursor;
        _columnId = columnId;
    }
    return self;
}

-(BOOL)getBool
{
    return [_cursor.table TDB_boolInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setBool:(BOOL)value
{
    [_cursor.table TDB_setBool:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(int64_t)getInt
{
    return [_cursor.table TDB_intInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setInt:(int64_t)value
{
    [_cursor.table TDB_setInt:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(float)getFloat
{
    return [_cursor.table TDB_floatInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setFloat:(float)value
{
    [_cursor.table TDB_setFloat:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(double)getDouble
{
    return [_cursor.table TDB_doubleInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setDouble:(double)value
{
    [_cursor.table TDB_setDouble:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(NSString *)getString
{
    return [_cursor.table TDB_stringInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setString:(NSString *)value
{
    [_cursor.table TDB_setString:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(NSData *)getBinary
{
    return [_cursor.table TDB_binaryInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setBinary:(NSData *)value
{
    [_cursor.table TDB_setBinary:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}
// FIXME: should it be setBinaryWithBuffer / setBinaryWithBinary ?
// -(BOOL)setBinary:(const char *)data size:(size_t)size
// {
//    return [_cursor.table setBinary:_columnId ndx:_cursor.ndx data:data size:size error:error];
// }

-(NSDate *)getDate
{
    return [_cursor.table TDB_dateInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setDate:(NSDate *)value
{
    [_cursor.table TDB_setDate:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(id)getSubtable:(Class)obj
{
    return [_cursor.table TDB_tableInColumnWithIndex:_columnId atRowIndex:_cursor.ndx asTableClass:obj];
}

-(void)setSubtable:(TDBTable *)value
{
    [_cursor.table TDB_setTable:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(id)getMixed
{
    return [_cursor.table TDB_mixedInColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

-(void)setMixed:(id)value
{
    [_cursor.table TDB_setMixed:value inColumnWithIndex:_columnId atRowIndex:_cursor.ndx];
}

@end
