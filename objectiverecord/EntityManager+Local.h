//
//  EntityManager+Local.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/21.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityManager.h"
#import "DatabaseProvider.h"

DatabaseProvider* dbProvider;

@interface EntityManager(Local)

-(NSString *) or_buildFindSQL:(NSString *)className;
- (NSArray *)find:(NSString *)className withSql:(NSString *)sqlString;
- (void) delete:(NSString *)className withSql:(NSString *)sqlString;

@end