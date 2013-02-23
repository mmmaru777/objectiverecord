//
//  EntityManager.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import "Entity.h"

@interface EntityManager : NSObject {
  NSString* dbPath;
}

- (id)initWithDataPath:(NSString *)path;
- (BOOL) removeDB:(NSString *)path;
- (NSString *)sqliteVersion;
- (Entity *)create:(NSString *)className;
- (void) delete:(NSString *)className;
- (void) delete:(NSString *)className withArgument:(NSDictionary *) arg;
- (NSArray *)find:(NSString *)className;
- (NSArray *)find:(NSString *)className withArgument:(NSDictionary *) arg;
- (NSString *)getdbPath;

@end

