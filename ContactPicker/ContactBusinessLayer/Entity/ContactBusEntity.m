//
//  ContactBusEntity.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBusEntity.h"

@implementation ContactBusEntity
- (id)initWithIdentifier:(NSString *)identifier
               givenName:(NSString *)givenName
              familyName:(NSString *)familyName
                  phones:(nonnull NSArray<NSString *> *)phones {
    self.identifier = identifier;
    self.givenName  = givenName;
    self.familyName = familyName;
    self.phones     = [[NSArray alloc] initWithArray:phones];
    return self;
}

- (id)initWithData:(id<ContactDALProtocol>)contactDAL {
    return [self initWithIdentifier:contactDAL.identifier
                          givenName:contactDAL.givenName
                         familyName:contactDAL.familyName
                             phones:contactDAL.contactPhones];
}

- (NSComparisonResult)compare:(ContactBusEntity *)other
{
    return [self.givenName compare:other.givenName];
}

- (BOOL)compareWithNameQuery:(NSString *)query {
    NSArray<NSString *> * queries = [query componentsSeparatedByString:@" "];
    NSString * fullName = [NSString stringWithFormat:@"%@ %@", self.givenName, self.familyName];
    NSArray<NSString *> * names = [fullName componentsSeparatedByString:@" "];
    NSInteger i = 0, j = 0;
    while (i < queries.count && j < names.count) {
        NSString * que = [queries[i] lowercaseString];
        NSString * nam = [names[j] lowercaseString];
        
        if (![nam hasPrefix:que])
            return NO;
        
        i++;
        j++;
    }
    
    if (i < queries.count)
        return NO;
    
    return YES;
}

@synthesize familyName;

@synthesize givenName;

@synthesize identifier;

@synthesize phones;
@end
