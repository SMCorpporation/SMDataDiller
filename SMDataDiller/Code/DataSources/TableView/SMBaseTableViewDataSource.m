//
//  SMBaseDataSource.m
//  Serg And Max
//
//  Created by SM on 01.02.14.
//  Copyright (c) 2014 SP. All rights reserved.
//

#import "SMBaseTableViewDataSource.h"
#import "SMBaseDataSource+PrivateAddons.h"
#import "SMCell.h"
#import "SMDataSourceDelegate.h"
#import "SMBaseDataProvider.h"


@implementation SMBaseTableViewDataSource

- (id)initWithDataProvider:(SMBaseDataProvider *)dataProvider tableView:(UITableView *)tableView
{
    self = [self init];
    if (self) {
        self.dataProvider = dataProvider;
        self.tableView = tableView;        
    }
    return self;
}

- (void)initialConfigure
{
    [super initialConfigure];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}


#pragma mark -
#pragma mark Data Managment

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell class];
}

- (void)reload
{
    [super reload];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataProvider numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataProvider numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentefier = [self cellReuseIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentefier];
    if (!cell) {
        Class cellClass = [self classForCellAtIndexPath:indexPath];
        if(!(cell = (UITableViewCell *)[self loadNibForClass:cellClass])) {
            cell = [[cellClass alloc] initWithStyle:self.cellsStyle reuseIdentifier:cellReuseIdentefier];
        }
        [self setupCell:cell atIndexPath:indexPath];
    }
    
    [self fillCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self sizeForCellAtIndexPath:indexPath].height;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.shouldAutoDeselectCells) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [self didSelectedRowAtIndexPath:indexPath];
}


@end
