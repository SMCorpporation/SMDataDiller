//
//  SMBaseCollectionViewDataSource.m
//  SMDataDiller
//
//  Created by Max Kuznetsov on 13.02.14.
//  Copyright (c) 2014 SM. All rights reserved.
//

#import "SMBaseCollectionViewDataSource.h"
#import "SMBaseDataProvider.h"
#import "NSIndexPath+SMIndexPath.h"

@implementation SMBaseCollectionViewDataSource

- (id)initWithDataProvider:(SMBaseDataProvider *)dataProvider collectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        self.dataProvider = dataProvider;
        self.collectionView = collectionView;
    }
    return self;
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self registerCells];
}


#pragma mark -
#pragma mark Data Managment

- (void)reload
{
    [super reload];
    
    [self.collectionView reloadData];
}

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [UICollectionViewCell class];
}

- (void)registerCells
{
    NSDictionary *classesOrNibs = [self classesAndNibsForRegistration];
    if (classesOrNibs.count) {
        for (NSString *cellReuseIdentifier in classesOrNibs) {
            
            NSArray *cellsNibsOrClasses = [classesOrNibs valueForKey:cellReuseIdentifier];
            for (id classOrNib in cellsNibsOrClasses) {
                if ([classOrNib isKindOfClass:[NSString class]]) {
                    
                    UINib *cellNib = [UINib nibWithNibName:classOrNib bundle:[NSBundle mainBundle]];
                    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:cellReuseIdentifier];
                } else {
                    [self.collectionView registerClass:classOrNib forCellWithReuseIdentifier:cellReuseIdentifier];
                }
            }
        }
    } else {
        NSIndexPath *indexPathZero = [NSIndexPath indexPathZero];
        [self.collectionView registerClass:[self classForCellAtIndexPath:indexPathZero] 
                forCellWithReuseIdentifier:[self cellReuseIdentifierAtIndexPath:indexPathZero]];
    }
}


#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataProvider numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataProvider numberOfSections];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = [self cellReuseIdentifierAtIndexPath:indexPath];
    UICollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier
                                                                                         forIndexPath:indexPath];
    [self fillCell:collectionViewCell atIndexPath:indexPath];
    return collectionViewCell;
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldAutoDeselectCells) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    [self didSelectedRowAtIndexPath:indexPath];
}


#pragma mark -
#pragma mark Helpers

- (UICollectionViewCell *)loadNibForClass:(Class)className
{
    NSString *classString = NSStringFromClass(className);
    if ([[NSBundle mainBundle] pathForResource:classString ofType:@"nib"].length) {
        return (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:classString owner:nil options:nil] firstObject];
    }
    return nil;
}

- (NSDictionary *)classesAndNibsForRegistration
{
    NSDictionary *cellsNibsOrClassesDictionary = [NSMutableDictionary new];
    
    for (int sectionIndex = 0; sectionIndex < [self.dataProvider numberOfSections]; sectionIndex++) {
        for (int rowIndex = 0; rowIndex < [self.dataProvider numberOfItemsInSection:sectionIndex]; rowIndex++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            NSString *cellReuseIdentifier = [self cellReuseIdentifierAtIndexPath:indexPath];
            
            NSMutableSet *cellsSet = [cellsNibsOrClassesDictionary valueForKey:cellReuseIdentifier];
            if (!cellsSet) {
                cellsSet = [NSMutableSet new];
                [cellsNibsOrClassesDictionary setValue:cellsSet forKey:cellReuseIdentifier];
            }
            
            Class cellClass = [self classForCellAtIndexPath:indexPath];
            NSString *nibName = NSStringFromClass(cellClass);
            
            if (nibName.length && cellClass != [UICollectionViewCell class]) {
                [cellsSet addObject:nibName];
            } else {
                [cellsSet addObject:cellClass];
            }
        }
    }
    return cellsNibsOrClassesDictionary;
}

@end
