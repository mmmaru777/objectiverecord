//
//  EntityManager.m
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <objc/runtime.h>
#import "EntityManager.h"
#import "EntityManager+Local.h"
#import "Entity+Local.h"

@implementation EntityManager

- (id)initWithDataPath:(NSString *)path {
  self = [super init];
  if(self) {
    dbPath = [path copy];
    dbProvider = [[DatabaseProvider alloc] initWithPath:dbPath];
  }
  return self;
}

- (void)finalize {
  [dbProvider close];
  [super finalize];
}

- (void)dealloc {
  [dbProvider close];
  dbPath = nil;
  dbProvider = nil;
  [super dealloc];
}

- (NSString *)getdbPath {
  return dbPath;
}

- (NSString *)sqliteVersion {
  return [dbProvider sqliteVersion];
}

- (BOOL) removeDB:(NSString *)path
{
  NSFileManager* manager = [NSFileManager defaultManager];
  NSError *error = nil;
  if(![manager removeItemAtPath:path error:&error]) {
    NSLog(@"Failed remove database file due to error:%@", error);
    return FALSE;
  }
  return TRUE;
}

- (Entity *)create:(NSString *)className {
  
  Class clazz = NSClassFromString(className);
  unsigned int outCount;
  objc_property_t *properties = class_copyPropertyList(clazz, &outCount);
  NSMutableArray *column_name_array = [NSMutableArray array];
  NSMutableArray *column_type_array = [NSMutableArray array];
  
  for (int i = 0; i < outCount; i++) {
    
    objc_property_t property = properties[i];
    const char *property_name = property_getName(property);
    const char *property_type = property_getAttributes(property);
    
    NSString *property_nameString =[NSString stringWithUTF8String:property_name];
    NSString *property_typeString = [NSString stringWithUTF8String:property_type];
    NSArray *attributes = [property_typeString componentsSeparatedByString:@","];
    NSString *typeAttribute = [attributes objectAtIndex:0];
    
    [column_name_array addObject:property_nameString];
    //NSLog(@"type: %c", property_type[1]);
    switch(property_type[1]) {
      case 'i' : //int
        [column_type_array addObject:@"INTEGER"];
        break;
      case 'f' : //float
        [column_type_array addObject:@"REAL"];
        break;
      case 'd' : //double
        [column_type_array addObject:@"REAL"];
        break;
      case 'q' : //NSInteger
        [column_type_array addObject:@"INTEGER"];
        break;
      case 'c' : //BOOL
        [column_type_array addObject:@"BOOL"];
        break;
      case '@' : //ObjC object
      {
        NSString *typeClassString = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
        if ([typeClassString isEqualToString:@"NSString"]) {
          [column_type_array addObject:@"TEXT"];
        } else if ([typeClassString isEqualToString:@"NSDate"]) {
          [column_type_array addObject:@"DATETIME"];
        } else if ([typeClassString isEqualToString:@"NSData"]) {
          [column_type_array addObject:@"BLOB"];
        }
      }
      break;
    }
  } 
  
  NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",className];
  for (int i = 0; i < [column_name_array count]; i++) {
    sql = [NSString stringWithFormat:@"%@ %@ %@", sql, [column_name_array objectAtIndex:i], [column_type_array objectAtIndex:i]];
    if (i < [column_name_array count]-1) {
      sql = [NSString stringWithFormat:@"%@, ", sql];
    }
  }
  sql = [NSString stringWithFormat:@"%@ )", sql];
  
  [dbProvider open];
  [dbProvider executeQuery:sql withArgument:nil];
  
  id createdClass = [[clazz alloc] init];
  Entity *entity = (Entity *)createdClass;
  [entity setDbProvider: dbProvider];
  [entity setTable_name: className];
  [entity setColumn_name_array: column_name_array];
  [entity setColumn_type_array: column_type_array];
  
  createdClass = nil;
  column_name_array = nil;
  column_type_array = nil;
  
  return entity;
}

- (NSArray *)find:(NSString *)className {
  NSString* sql = [self or_buildFindSQL:className];
  return [self find: className withSql:sql];
}

- (NSArray *)find:(NSString *)className withArgument:(NSDictionary *) arg {
  NSString* sql = [self or_buildFindSQL:className];
  
  NSArray *keys = [arg allKeys];
  sql = [NSString stringWithFormat:@"%@ WHERE %@ %@ ", sql, [keys objectAtIndex:0], [arg objectForKey:[keys objectAtIndex:0]]];
  
  if([keys count] > 1) {
    for (int i = 1; i < [keys count]; i++) {
      sql = [NSString stringWithFormat:@"%@ AND %@ %@ ", sql, [keys objectAtIndex:i], [arg objectForKey:[keys objectAtIndex:i]]];
    }
  }
  return [self find: className withSql:sql];
}

- (void) delete:(NSString *)className {
  NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@",className];
  return [self delete:className withSql:sql];
}

- (void) delete:(NSString *)className withArgument:(NSDictionary *) arg {
  NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@",className];
  NSArray *keys = [arg allKeys];
  sql = [NSString stringWithFormat:@"%@ WHERE %@ %@ ", sql, [keys objectAtIndex:0], [arg objectForKey:[keys objectAtIndex:0]]];
  
  if([keys count] > 1) {
    for (int i = 1; i < [keys count]; i++) {
      sql = [NSString stringWithFormat:@"%@ AND %@ %@ ", sql, [keys objectAtIndex:i], [arg objectForKey:[keys objectAtIndex:i]]];
    }
  }
  return [self delete:className withSql:sql];
}

@end

