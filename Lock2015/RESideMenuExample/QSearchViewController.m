
//  MainViewController.m
//  UISearchDisplayControllerDemo
//
//  Created by Enwaysoft on 14-8-20.
//  Copyright (c) 2014年 Enway. All rights reserved.
//

#import "QSearchViewController.h"

@interface QSearchViewController ()

@property CLGeocoder *geocoder;
@property UISearchBar *searchBar;
@property UITableView *resultTableview;
@property int recordcount;
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
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate=self;
    _searchBar.placeholder = @"点击搜索";
    self.tableView.tableHeaderView = _searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    recordData=[[NSMutableArray alloc]init];
    searchResults=[[NSDictionary alloc]init];
    Resultarray=[[NSMutableArray alloc]init];
    Resultname=[[NSMutableArray alloc]init];
    Resultaddr=[[NSMutableArray alloc]init];
    _geocoder = [[CLGeocoder alloc] init];
    
    [self getRecordData];
}

-(void)getRecordData{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"RecordCount"]==nil) {
        NSLog(@"没有搜索记录");
        _recordcount=0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"0" forKey:@"RecordCount"];
        [defaults synchronize];//这句话的意义在于写入硬盘，必须。
    }else{
        _recordcount=[[[NSUserDefaults standardUserDefaults] valueForKey:@"RecordCount"] intValue];
        NSLog(@"共有搜索记录%d条",_recordcount);
        for (int i=0;i<10;i++) {
            if (_recordcount-i>0) {
                NSMutableDictionary *navidic=[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"RecordData_%d",_recordcount-i]];
                if (navidic!=nil) {
                    [recordData addObject:navidic];
                    NSLog(@"%@",navidic);
                }
            }else
                break;
        }
    }
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
        return Resultarray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"mycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    if (tableView == self.tableView) {
        cell.textLabel.text = [[recordData objectAtIndex:indexPath.row] objectForKey:@"region"];
    }else{
        cell.imageView.image=[UIImage imageNamed:@"anjuke_icon_itis_position"];
        cell.textLabel.text=Resultname[indexPath.row];
        cell.detailTextLabel.text=Resultaddr[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        NSMutableDictionary *navidic=[recordData objectAtIndex:[indexPath row]];
        [self.delegate updateAlert:navidic];
    }else{
        NSLog(@"number:%d",Resultarray.count);
        
        NSMutableDictionary *thisresult=[Resultarray objectAtIndex:indexPath.row];
        NSDictionary *localtion=[thisresult objectForKey:@"location"];
        
        NSMutableDictionary *navidic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                    [thisresult objectForKey:@"address"],@"address",
                                    [thisresult objectForKey:@"address"],@"city",
                                    @"baidu",@"from_map_type",
                                    [NSString stringWithFormat:@"%@",[localtion objectForKey:@"lat"]],@"baidu_lat",
                                    [NSString stringWithFormat:@"%@",[localtion objectForKey:@"lng"]],@"baidu_lng",
                                    [thisresult objectForKey:@"name"],@"region", nil];
        _recordcount++;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSString stringWithFormat:@"%d",_recordcount] forKey:@"RecordCount"];
        [defaults setValue:navidic forKey:[NSString stringWithFormat:@"RecordData_%d",_recordcount]];
        [defaults synchronize];//这句话的意义在于写入硬盘，必须。
        [self.delegate updateAlert:navidic];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    NSLog(@"Begin search");
}

-(void)requestforplace:(NSString*)string{
    NSString *urlstr=[NSString stringWithFormat:@"http://api.map.baidu.com/place/search"];
    
    NSDictionary *searchdic=[NSDictionary dictionaryWithObjectsAndKeys:
                       string, @"query",
                       self.city==nil?@"杭州":self.city, @"region",
                       @"json", @"output",
                       @"bqApldE1oh6oBb98VYyIfy9S", @"key",nil];
    
    [[ShenAFN shenInstance] JSONDataWithUrl:urlstr parameter:searchdic success:^(id jsondata) {
        //NSLog(@"%@",jsondata);
        [Resultarray removeAllObjects];
        [Resultname removeAllObjects];
        [Resultaddr removeAllObjects];
        
         NSString *status=(NSString *)jsondata[@"status"];
         if([status isEqualToString:@"OK"]){
             searchResults=jsondata[@"results"];

             for(NSDictionary *thisresult in searchResults){
                 if([thisresult objectForKey:@"address"]!=nil){
                     [Resultarray addObject:thisresult];
                     [Resultname addObject:[thisresult objectForKey:@"name"]];
                     [Resultaddr addObject:[thisresult objectForKey:@"address"]];
                 }
             }
             [searchDisplayController.searchResultsTableView reloadData];
          }
    } fail:^{
        NSLog(@"请求失败");
    }];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self requestforplace:searchText];
}
@end
