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
    return [self.identifier isEqualToString: other.identifier];
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

- (BOOL)isEqualToOther:(ContactBusEntity *)other {
    BOOL stringCompare = ([self.givenName isEqualToString:other.givenName] &&
                          [self.familyName isEqualToString:other.familyName] &&
                          (self.phones.count == other.phones.count));
    
    if (!stringCompare)
        return NO;
    
    for (int i = 0; i < self.phones.count; i++) {
        if (![[self.phones objectAtIndex:i] isEqualToString:[other.phones objectAtIndex:i]] ) {
            return NO;
        }
    }
    return YES;
}

- (void)update:(ContactBusEntity *)other {
    self.givenName  = other.givenName;
    self.familyName = other.familyName;
    self.phones     = [[NSArray alloc] initWithArray:other.phones];
}

@synthesize familyName;

@synthesize givenName;

@synthesize identifier;

@synthesize phones;
@end
