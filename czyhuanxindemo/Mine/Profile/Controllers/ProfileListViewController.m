//
//  ProfileListViewController.m
//  czyhuanxindemo
//
//  Created by macOfEthan on 17/8/30.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "ProfileListViewController.h"
#import <EaseUI.h>

@interface ProfileListViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
//保存在本地的用户模型
@property (nonatomic, strong) UserModel *model;
//imagePicker
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation ProfileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self loadProfileInfo];
}

- (void)loadProfileInfo
{
    //获取本地数据库保存的用户信息（头像等从app服务器拿 环信不管理）
    //从app服务器拿到头像之后 缓存到本地数据库 用户在简介界面操作头像 只是拿环信id跟自己的app服务器做交互 比如头像上传等
    _model = [[DataManaget share] searchAllModels].firstObject;
    
    DLog(@"_model = %@", _model);
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString *reusedId = @"profileImage";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60/2-30/2, 30, 30)];
        [cell.contentView addSubview:imageView];
        
        if (_model.avatorUrl.length == 0) {
            //默认头像
            imageView.image = [UIImage imageNamed:@"图层-8"];
        }
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(FULL_WIDTH-80, 60/2-25/2, 70, 25)];
        lab.text = @"头像";
        lab.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:lab];
        
        return cell;
    }else if(indexPath.row == 1){
    
        NSString *reusedId = @"profileAccount";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 44/2-25/2, 70, 25)];
        lab.text = @"个人用户";
        [cell.contentView addSubview:lab];
        
        return cell;
        
    }else{
    
        NSString *reusedId = @"profileNickname";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 44/2-25/2, 70, 25)];
        lab.text = @"昵称";
        [cell.contentView addSubview:lab];
        
        UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(FULL_WIDTH-80, 44/2-25/2, 70, 25)];
        nickname.text = _model.nickname;
        nickname.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:nickname];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:nil, nil];
        [sheet addButtonWithTitle:@"相册"];
        
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }else if (indexPath.row == 2){
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改推送显示名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.placeholder = @"输入推送显示名称";
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self showHudInView:[UIApplication sharedApplication].keyWindow hint:@"正在修改..."];
            
            //修改推送显示名称
            [[EMClient sharedClient] updatePushNotifiationDisplayName:[alertController.textFields.firstObject text] completion:^(NSString *aDisplayName, EMError *aError) {
                
                if (!aError) {
                    
                    [self hideHud];
                    
                    //保存导数据库
                    [[DataManaget share] updateApnsPushNameWithModel:_model andApnsPushName:aDisplayName];
                }
                
                DLog(@"aDisplayName = %@", aDisplayName);
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:sure];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    }
    
    return 44;
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    DLog(@"info = %@", info);
    
//    UIImage *avatorImage = info[@"UIImagePickerControllerEditedImage"];
    
    //压缩 上传到app服务器
//    NSData *imageData = UIImageJPEGRepresentation(avatorImage, 0.1);
//
//    AVFile *file = [AVFile fileWithData:imageData];
//    AVObject *userWebInfo = [AVObject objectWithClassName:@"UserWebInfo"];
//    [userWebInfo setObject:file forKey:@"avatorUrl"];
////    [userWebInfo setObject:_model.apnsPushName forKey:@"nickname"];
//    [userWebInfo setObject:[AVUser currentUser] forKey:@"owner"];
//    
//    [userWebInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        
//        DLog(@"succeeded = %d", succeeded);
//    }];
    
    //返回
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"buttonIndex = %ld", buttonIndex);
    
    if (buttonIndex == 0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
    }else if (buttonIndex == 2){
    
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.mediaTypes = @[(NSString *)(kUTTypeImage)];
        _imagePicker.allowsEditing = YES;
        [self presentViewController:_imagePicker animated:YES completion:nil];

    }
    
}

@end
