//
//  ViewController.m
//  CustomKeyboardDemo
//
//  Created by maxmoo on 16/9/27.
//  Copyright © 2016年 maxmoo. All rights reserved.
//

#import "ViewController.h"
#import "YYKeyboardManager.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define KBOARDVIEW_HEIGHT  216
#define CUSTOM_KEY_COUNT    2

@interface ViewController ()<YYKeyboardObserver>

@property (nonatomic, strong) UIView *customToolbar;
@property (nonatomic, strong) UIView *customKeyboardView;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *keyboardChangeButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取键盘管理器
    YYKeyboardManager *manager = [YYKeyboardManager defaultManager];
    // 监听键盘动画
    [manager addObserver:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self initCustomToolbarView];
    [self initCustomKeyboardView];
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        _customToolbar.frame = CGRectMake(0, kbFrame.origin.y-49,SCREEN_WIDTH, 49);
        NSLog(@"y:%f",kbFrame.origin.y);
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"finish");
        }
    }];
}

#pragma mark - action
- (void)keyboardChanged{
    if ( _inputTextField.inputView) {
        _inputTextField.inputView = nil;
        [_inputTextField reloadInputViews];
        [_inputTextField becomeFirstResponder];
        [_keyboardChangeButton setBackgroundImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
    }else{
        _inputTextField.inputView = _customKeyboardView;
        [_inputTextField  reloadInputViews];
        [_inputTextField becomeFirstResponder];
        [_keyboardChangeButton setBackgroundImage:[UIImage imageNamed:@"keyboard_keyboard@2x"] forState:UIControlStateNormal];
    }
}

- (void)hidKeyboard{
    [_inputTextField resignFirstResponder];
}

//选择额外信息按钮
- (void)selectMediaAction:(UIButton *)button{
    
}

#pragma mark - UI
- (void)initCustomToolbarView{
    _customToolbar = [[UIView alloc] initWithFrame:CGRectMake(-1,SCREEN_HEIGHT-49, SCREEN_WIDTH+2, 49)];
    _customToolbar.backgroundColor = [UIColor whiteColor];
    _customToolbar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _customToolbar.layer.borderWidth = 0.5f;
    [self.view addSubview:_customToolbar];
    
    _keyboardChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _keyboardChangeButton.frame = CGRectMake(10, 8, 33, 33);
    [_keyboardChangeButton setBackgroundImage:[UIImage imageNamed:@"keyboard_add@2x.png"] forState:UIControlStateNormal];
    [_keyboardChangeButton addTarget:self action:@selector(keyboardChanged) forControlEvents:UIControlEventTouchUpInside];
    [_customToolbar addSubview:_keyboardChangeButton];
    
    _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(_keyboardChangeButton.frame.origin.x+_keyboardChangeButton.frame.size.width+10, _keyboardChangeButton.frame.origin.y, SCREEN_WIDTH-10*3-33, 33)];
    _inputTextField.backgroundColor = [UIColor lightGrayColor];
    [_customToolbar addSubview:_inputTextField];
}

//初始化自定义键盘视图
- (void)initCustomKeyboardView{
    _customKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, KBOARDVIEW_HEIGHT)];
    _customKeyboardView.backgroundColor = [UIColor whiteColor];
    
    //将整个宽度分为13份，每行四个button，5个间隔，间隔＊2=button.width。一共5+4*2＝13份。确定每个间隔的宽度为width／13，每个button的宽度为width／13*2.
    CGFloat halfWidth = SCREEN_WIDTH/13;
    
    NSMutableArray *titleArray = [NSMutableArray arrayWithObjects:@"相册",@"拍照", nil];
    NSMutableArray *imageNameArray = [NSMutableArray arrayWithObjects:@"keyboard_add_photo@2x",@"keyboard_add_camera@2x", nil];
    
    while (titleArray.count < CUSTOM_KEY_COUNT) {
        [titleArray addObject:@"新增"];
        [imageNameArray addObject:@" "];
    }
    
    for (int i = 0;  i < CUSTOM_KEY_COUNT; i ++) {
        //每行的第几个button，与4取余
        NSInteger index = i%4;
        //第几行的button,除4取整
        NSInteger s_index = floor(i/4);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(halfWidth+(3*halfWidth*index), 10+s_index*(35+halfWidth*2), 2*halfWidth, 2*halfWidth);
        button.layer.cornerRadius = 5.0f;
        button.layer.masksToBounds = YES;
        button.tag = KBOARDVIEW_HEIGHT+i;
        [button setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        [button addTarget: self action:@selector(selectMediaAction:) forControlEvents:UIControlEventTouchUpInside];
        [_customKeyboardView addSubview:button];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(halfWidth+(3*halfWidth*index), 8+s_index*(35+halfWidth*2)+2*halfWidth, 2*halfWidth,halfWidth)];
        titleLabel.text = titleArray[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_customKeyboardView addSubview:titleLabel];
    }
}

@end
