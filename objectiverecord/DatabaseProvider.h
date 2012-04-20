//
//  DatabaseProvider.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DatabaseProvider : NSObject {
  NSString *dbPath;  
  sqlite3 *db;
  sqlite3_stmt *statement;
}

- (id)initWithPath:(NSString *)path;
- (NSString *)sqliteVersion;
- (BOOL)open;
- (BOOL)close;
- (id)executeQuery:(NSString *)sql withArgument:(id)arg;

@end