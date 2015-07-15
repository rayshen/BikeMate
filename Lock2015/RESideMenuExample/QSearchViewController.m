//
//  MainViewController.m
//  UISearchDisplayControllerDemo
//
//  Created by Enwaysoft on 14-8-20.
//  Copyright (c) 2014年 Enway. All rights reserved.
//

#import "QSearchViewController.h"

@interface QSearchViewController ()

@property NSString *thiswinfo;

@end

@implementation QSearchViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationItem.title=@"目的地搜索";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(quitsearching:)];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"点击搜索";
    self.tableView.tableHeaderView = searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [self setcontent];
}

-(void)setcontent{
    recordData = [[NSMutableArray alloc]initWithObjects:@"没有搜索记录", nil];
    searchResult =[[NSMutableArray alloc]init];
}

-(void)searchwithText:(NSString*)string{
    [searchResult removeAllObjects];
    [searchResult addObject:@"西溪印象城"];
    [searchResult addObject:@"西溪湿地"];
    [searchResult addObject:@"西溪别墅园"];
}

-(void)quitsearching:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 * 如果原 TableView 和 SearchDisplayController 中的 TableView 的 delete 指向同一个对象
 * 需要在回调中区分出当前是哪个 TableView
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return recordData.count;
    }else{
        [self searchwithText:searchDisplayController.searchBar.text];
        return searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"mycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (tableView == self.tableView) {
        cell.textLabel.text = recordData[indexPath.row];
    }else{
        cell.textLabel.text = searchResult[indexPath.row];
    }
    cell.textLabel.numberOfLines=2;
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"you click %ld",(long)indexPath.row);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    NSLog(@"Begin search");
}

@end
