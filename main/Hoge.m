//
//  Hoge.m
//  objectiverecord
//
//  Created by Kenji Maruyama on 12/04/19.
//  Copyright (c) 2012 org.iskm. All rights reserved.
//

#import "Hoge.h"

@implementation Hoge

@synthesize str;
@synthesize count;
@synthesize f;
@synthesize d;
@synthesize date;
@synthesize data;
@synthesize i;
@synthesize b;

- (void)dealloc
{
  self.str  = nil;
  self.date = nil;
  self.data = nil;
  [super dealloc];
}

@end

