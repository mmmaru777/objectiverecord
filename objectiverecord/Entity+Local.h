//
//  Entity+Local.h
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/21.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"

// private property
@interface Entity() 

@property(retain) DatabaseProvider* dbProvider;
@property(retain) NSString *table_name;
@property(retain) NSArray *column_name_array;
@property(retain) NSArray *column_type_array;

@end
