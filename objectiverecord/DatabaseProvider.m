//
//  DatabaseProvider.m
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import "DatabaseProvider.h"

@implementation DatabaseProvider

static int MAX_RETRY_NUMBER = 10;

- (id)initWithPath:(NSString *)path {
  self = [super init];
  if(self) {
    dbPath = [path copy];
    db  = nil;
  }
  return self;
}

- (void)finalize {
  [self close];
  [super finalize];
}

- (void)dealloc {
  [self close];
  [super dealloc];
}

- (NSString *)sqliteVersion {
  return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

- (BOOL)open {
  if(db) {
    statement = nil;
    return YES;
  }
  int error = sqlite3_open((dbPath ? [dbPath fileSystemRepresentation] : ":memory:"), &db );
  if(error != SQLITE_OK) {
    NSLog(@"Database opening error is : %d", error);
    return NO;
  }
  statement = nil;
  return YES;
}

- (BOOL)close {
  if (!db) {
    return YES;
  }
  
  BOOL retry;
  int  retryCount = 0;
  
  do {
    retry   = NO;
    int status      = sqlite3_close(db);
    if (SQLITE_BUSY == status || SQLITE_LOCKED == status) {
      retry = YES;
      usleep(20);
      if (retryCount++ > MAX_RETRY_NUMBER) {
        NSLog(@"%s:%d", __FUNCTION__, __LINE__);
        NSLog(@"Database unable to close");
        return NO;
      }
    }
    else if (SQLITE_OK != status) {
      NSLog(@"Database can't close(fatal error): %d", status);
    }
  }
  while (retry);
  
  
  db = nil;
  NSLog(@"Database successful closing");
  return YES;
}

- (id)executeQuery:(NSString *)sql withArgument:(id)arg {
  
  NSInteger lastRowId = 0;
  NSInteger res = 0;
  
  BOOL retry;
  int  retryCount = 0;
  
  if (!statement) {
    do {
      retry = NO;
      int status = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL);
      if (SQLITE_BUSY == status || SQLITE_LOCKED == status) {
        retry = YES;
        usleep(20);
        if (retryCount++ > MAX_RETRY_NUMBER) {
          NSLog(@"%s:%d Database busy (%@)", __FUNCTION__, __LINE__, dbPath);
          NSLog(@"Database busy");
          sqlite3_finalize(statement);
          return nil;
        }
      }else if (SQLITE_OK != status) {
        NSLog(@"Database can't execute(fatal error): %d", status);
        sqlite3_finalize(statement);
        return nil;
      }
    } while (retry); 
  }
  
  sqlite3_reset(statement);
  int resultCode = -1;
  NSMutableArray *selectArray = [[[NSMutableArray alloc]init]autorelease];
  
  do { 
    retry = NO;
    resultCode = sqlite3_step(statement);
    
    if (SQLITE_BUSY == resultCode || SQLITE_LOCKED == resultCode) {
      retry = YES;
      usleep(20);
      if (retryCount++ > MAX_RETRY_NUMBER) {
        NSLog(@"%s:%d Database busy (%@)", __FUNCTION__, __LINE__, dbPath);
        NSLog(@"Database busy");
        sqlite3_finalize(statement);
        return nil;
      }
    } else if (resultCode == SQLITE_DONE) {
      // create or update or delete
      if([[sql substringToIndex:1] isEqualToString:@"I"] || 
         [[sql substringToIndex:1] isEqualToString:@"U"] || 
         [[sql substringToIndex:1] isEqualToString:@"D"]) {
        lastRowId = sqlite3_last_insert_rowid(db);
        sqlite3_finalize(statement);
        statement = nil;
        NSNumber *ns_lastRowId = [[[NSNumber alloc] initWithLong:lastRowId] autorelease];
        return ns_lastRowId;
      }
    } else if(resultCode == SQLITE_ROW)    {
      //sqlite3_step() has another row ready 
      // check if a table exists
      if ([arg isKindOfClass:[NSString class]] && [arg isEqualToString:@"0x00"]) {
        res = sqlite3_column_int64(statement, 0);
        sqlite3_finalize(statement);
        statement = nil;
        NSNumber *ns_result = [[[NSNumber alloc] initWithLong:res] autorelease];
        return ns_result;
      }
      else if ([arg isKindOfClass:[NSArray class]]) {
        NSMutableDictionary *selectDic  = [NSMutableDictionary dictionary];
        for (int i=0; i<[arg count]; i++) {
          [selectDic setObject:[NSString stringWithCString:(const char*) sqlite3_column_text(statement,i) encoding:NSUTF8StringEncoding] forKey:[arg objectAtIndex:i]];
        }
        [selectArray addObject:selectDic];
        selectDic = nil;
      }
    } else {
      NSLog(@"Unknown error calling sqlite3_step (%d: %s) ", resultCode, sqlite3_errmsg(db));
      NSLog(@"DB Query: %@", sql);
    }
  } while (retry || resultCode == SQLITE_ROW);
  
  sqlite3_finalize(statement);
  statement = nil;
  return selectArray;
}

@end
