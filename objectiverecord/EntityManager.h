//
//  EntityManager.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"
#import "DatabaseProvider.h"

@interface EntityManager : NSObject {
  NSString* dbPath;
  DatabaseProvider* dbProvider;
}

- (id)initWithDataPath:(NSString *)path;
- (NSString *)sqliteVersion;
- (Entity *)create:(NSString *)className;
- (void) delete:(NSString *)className;
- (void) delete:(NSString *)className withArgument:(NSDictionary *) arg;
- (void) delete:(NSString *)className withSql:(NSString *)sqlString;
- (NSArray *)find:(NSString *)className withSql:(NSString *)sqlString;
- (NSArray *)find:(NSString *)className;
- (NSArray *)find:(NSString *)className withArgument:(NSDictionary *) arg;
- (NSString *)getdbPath;

@end

