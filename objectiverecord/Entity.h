//
//  Entity.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseProvider.h"

@interface Entity : NSObject {
  NSInteger lastRowId;
  DatabaseProvider *dbProvider;
  NSString *table_name;
  NSArray *column_name_array;
  NSArray *column_type_array;
}

@property NSInteger lastRowId; 
@property(retain) DatabaseProvider* dbProvider;
@property(retain) NSString *table_name;
@property(retain) NSArray *column_name_array;
@property(retain) NSArray *column_type_array;

- (void) save;

@end

