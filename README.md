# CMS

## 权限

1. 外部特权（比如学校对社团的管理属于外部特权，而社团主席对社团的管理就不属于外部特权）权限操作通过合约进行，存储合约地址，比如社团存储MasterManager合约地址，赋予合约操作权限，由合约检查个人的权限。比如，任命主席操作由MasterManager合约发起，由MasterManager合约检查个人权限。
2. 普通操作由个人进行，存储个人地址，比如社团成员列表存储成员的个人地址，而非个人信息合约地址

## 消息系统

### 社团消息&活动消息

1. 使用event进行发送通知
2. 使用结构体+数组进行存储
3. 主席拥有发送权限，其他成员有查看的权限
4. 消息不能修改，不能删除

### 私信

1. 授权开关+授权列表控制私信权限
2. 结构体+数组存储私信
3. 对外方法提供读写

## 格式

1. date: yyyy-MM-dd-hh-mm-ss

## 流程

### 创建社团

1. User向ClubManager发出申请
2. ClubManager将申请存入申请队列
3. master检查申请队列，通过/拒绝申请
4. 如果被拒绝，申请人将得到通知
5. 如果通过，申请人将得到通知(一并获得创建的club合约的地址)，并且Club合约被创建(MasteManager通过调用ClubManager的创建合约方法)，且申请人的clubs列表中会加入这个club

### 部署

1. 首先部署MasterManager
2. 然后部署ClubManager
3. 然后部署UserManager
4. 部署ManagerCenter（传入已经创建的三个manager）

### 加入社团

1. User向club发出申请,并将club加入applyClub
2. club将申请存储队列
3. 主席检查队列，通过/拒绝申请
4. 申请人将得到通知并进行对应操作

## 一些注意事项

### drizzle

1. 官网安装命令错误，应当使用`npm i @drizzle/store`安装核心，使用`npm i @drizzle/vue-plugin`安装vue的插件