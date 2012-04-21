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
  NSNumber *rowId;
  // private property
  DatabaseProvider *dbProvider;
  NSString *table_name;
  NSArray *column_name_array;
  NSArray *column_type_array;
  // end of private property
}

@property(retain) NSNumber *rowId;
- (void) save;

@end




