//
//  Entity.m
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import "Entity.h"

@implementation Entity

@synthesize lastRowId;
@synthesize dbProvider;
@synthesize table_name;
@synthesize column_name_array;
@synthesize column_type_array;


- (void)finalize {
  [dbProvider close];
  [super finalize];
}

- (void)dealloc{
  [dbProvider close];
  [super dealloc];
}

- (void) save {
  //if lastRowId is 0, insert, otherwise update
  NSString *sql = nil;
  if(lastRowId == 0) {
    sql = [NSString stringWithFormat:@"INSERT INTO %@ (",table_name];
    for (int i = 0; i < [column_name_array count]; i++) {
      sql = [NSString stringWithFormat:@"%@ %@", sql, [column_name_array objectAtIndex:i]];
      if (i < [column_name_array count]-1) {
        sql = [NSString stringWithFormat:@"%@, ", sql];
      }
    }
    sql = [NSString stringWithFormat:@"%@ ) VALUES (", sql];
    for (int i = 0; i < [column_name_array count]; i++) {
      if ([[column_type_array objectAtIndex:i] isEqualToString:@"TEXT"] || 
          [[column_type_array objectAtIndex:i] isEqualToString:@"DATETIME"] || 
          [[column_type_array objectAtIndex:i] isEqualToString:@"BLOB"]) {
        sql = [NSString stringWithFormat:@"%@ '%@'", sql, [self valueForKey:[column_name_array objectAtIndex:i]]];
      } else {
        sql = [NSString stringWithFormat:@"%@ %@", sql, [self valueForKey:[column_name_array objectAtIndex:i]]];
      }
      if (i < [column_name_array count]-1) {
        sql = [NSString stringWithFormat:@"%@, ", sql];
      }
    }
    sql = [NSString stringWithFormat:@"%@ );", sql];
  } else {
    sql = [NSString stringWithFormat:@"UPDATE %@ SET ",table_name];
    for (int i = 0; i < [column_name_array count]; i++) {
      if ([[column_type_array objectAtIndex:i] isEqualToString:@"TEXT"] || 
          [[column_type_array objectAtIndex:i] isEqualToString:@"DATETIME"] || 
          [[column_type_array objectAtIndex:i] isEqualToString:@"BLOB"]) {
        sql = [NSString stringWithFormat:@"%@ %@ = '%@'", sql, [column_name_array objectAtIndex:i], [self valueForKey:[column_name_array objectAtIndex:i]]];
      } else {
        sql = [NSString stringWithFormat:@"%@ %@ = %@", sql, [column_name_array objectAtIndex:i], [self valueForKey:[column_name_array objectAtIndex:i]]];
      }
      if (i < [column_name_array count]-1) {
        sql = [NSString stringWithFormat:@"%@, ", sql];
      }
    }
    sql = [NSString stringWithFormat:@"%@ WHERE rowid = %d;", sql, lastRowId];
  }
  lastRowId = [[dbProvider executeQuery:sql withArgument:nil] integerValue];
  // NSLog(@"lastRowId : %ld", lastRowId);
}

@end

