#  ZXDataHandle使用方法
GitHub:https://github.com/SmileZXLee/ZXDataHandle
## 数据转换-ZXDataConvert
注：浮点数精度问题内部已自动处理

概要：使用方法三句话就可以概括：  
a.有东西要转模型，调用模型类的+zx_modelWithObj:方法，并把这个东西传给它即可。    
b.有东西要转字典，调用它的-zx_toDic方法即可。  
c.有东西要转Json字符串，调用它的-zx_toJsonStr方法即可。  

下面是详细的例子：  

1. 字典、字典数组、Json字符串或NSData -> 模型：  
```
[Class zx_modelWithObj:obj];
```
例：[Bird zx_modelWithObj:dic];  
注：Class为目标模型类，obj可以是单一字典、字典数组、Json字符串或NSData。  

2. 模型、模型数组、Json字符串或NSData -> 字典
```
[obj zx_toDic];
```
例：[bird zx_toDic];
注：obj可以是单一模型、模型数组、Json字符串或NSData

3. 字典、字典数组、模型、模型数组或NSData -> Json 字符串
```
[obj zx_toJsonStr];
```
例：[bird zx_toJsonStr];
注：obj可以是字典，字典数组，模型、模型数组或NSData

4. 数据转换特殊情况  
* 属性替换1（指定属性修改）
```
+(NSDictionary *)zx_replaceProName{
    return @{@"uid" : @"id"};
}
```
注：模型中的uid属性将会被字典中key：id对应的value赋值

* 属性替换2（全部属性修改）
```
+(NSString *)zx_replaceProName121:(NSString *)proName{
    return [proName strToUnderLine];
}
```
注1：模型中处理前的属性为proName，若返回的字符串长度大于0，则使用返回的字符串，示例代码中的操作会将当前对象中所有属性名由驼峰形式转为下划线的形式。

注2：属性替换1和属性替换2都涉及属性的替换操作，当二者发生冲突时，属性替换1的方法优先级高于属性替换2，也就是说，属性替换1中（+zx_replaceProName）修改的属性，在属性替换2中（+zx_replaceProName121）不会被修改。


* 模型中包含数组，需要声明数组中存储的Class  
```
+(NSDictionary *)zx_inArrModelName{
    return @{@"boysArray" : @"Boy"};
}
```

## 数据存储-ZXDataStore
1. 文件，数据直接存储
* 用户偏好存储与读取（无法直接对自定义类进行操作）

```
//存储用户偏好数据
//注意 如果saveObj的对象为自定义对象，则ZXDataStoreCache会将其转为字典再存储
[ZXDataStoreCache saveObj:@"123" forKey:@"pwd"];
```

```
//读取用户偏好数据
id data = [ZXDataStoreCache readObjForKey:@"123"];
```
* 数据归档与读档（可以直接对自定义类进行操作）
注:归档读档的类需要继承ZXClassArchived，即可直接进行归档读档操作
@interface Apple : ZXClassArchived

```
//数据归档，将数据存储至当前沙盒document/apple目录下
Apple *apple = [[Apple alloc]init];
apple.name = @"嘻哈苹果";
apple.dec = @"很好吃吧234";
apple.soldMoney = 1001;
[ZXDataStoreCache arcObj:apple pathComponent:@"apple"];
```
```
//数据读档，将数据从当前沙盒document/apple目录下读取出来
Apple *apple = [[Apple alloc]init];
apple.name = @"嘻哈苹果";
apple.dec = @"很好吃吧234";
apple.soldMoney = 1001;
id data = [ZXDataStoreCache unArcObjPathComponent:@"apple"];
```

2. Sqlite3数据库操作  
注：ZXDataStore采取的是对象映射数据表的操作措施，因此所有操作都是面向对象的，您几乎不用写sql语句直接对数据库进行操作。

* 存储一条数据

```
//创建一个对象
Apple *apple = [[Apple alloc]init];
apple.name = @"嘻哈苹果";
apple.dec = @"很好吃哦";
apple.soldMoney = 100;

//保存
BOOL res = [apple zx_dbSave];
NSLog("操作结果-%i",res);
```
注：您只需创建一个需要存储的对象，调用其-zx_dbSave方法即可，ZXDataStore会自动为当前项目创建一个数据库，并根据对象的属性创建同名的表，同时将数据插入到表中。

* 存储多条数据

```
//创建一个对象数组
NSMutableArray *appleArr = [NSMutableArray array];
for (NSUInteger i = 0; i < 10; i++) {
    Apple *apple = [[Apple alloc]init];
    apple.name = @"嘻哈苹果";
    apple.dec = @"很好吃哦";
    apple.soldMoney = 100 + i;
    [appleArr addObject:apple];
}

//保存
BOOL res = [appleArr zx_dbSave];
NSLog("操作结果-%i",res);
```
注：调用对象数组的-zx_dbSave即可批量存储数据，ZXDataStore进行了数据库事务优化，加快存储速度。

* 删除一条数据(包含where语句使用示例，以下不再赘述)

*以下操作等同于SQL语句：DELETE FROM Apple WHERE soldMoney = 100*
```
//zx_dbDropWhere:可以传入一个字典，where语句多个键值对之间默认使用AND连接，键值之间使用等号连接，其他情况请使用以下两种

BOOL res = [Apple zx_dbDropWhere:@{@"soldMoney":@"100"}];
NSLog("操作结果-%i",res);
```
或

```
//zx_dbDropWhere:可以传入一段where语句，以及where之后的运算符

BOOL res = [Apple zx_dbDropWhere:@"id=100"];
NSLog("操作结果-%i",res);
```
或

```
//zx_dbDropWhereArg:可以传入多个参数，多个参数拼接成where语句，以及where之后的运算符

BOOL res = [Apple zx_dbDropWhereArg:@"id=",@"100"];
NSLog("操作结果-%i",res);
```
* 修改（更新）数据

```
//创建一个更新之后的对象，若对象属性未赋值，则对应字段不会被修改
Apple *apple = [[Apple alloc]init];
apple.name = @"坏掉的苹果";
apple.dec = @"不好吃哦";
apple.soldMoney = 10;

//将Apple表中name等于“嘻哈苹果”的数据的name值改为“坏掉的苹果”，dec改为“不好吃哦”，soldMoney改为10
BOOL res = [apple zx_dbUpdateWhere:@"name='嘻哈苹果'"];
NSLog("操作结果-%i",res);
```
* 查询数据

```
//查询Apple表中soldMoney大于等于100的所有数据
NSArray *resArr = [Apple zx_dbQuaryWhere:@"soldMoney >= 100"];

//resArr即为查询结果数组，resArr中是Apple对象
NSLog(@"resArr--%@",resArr);
```
* Sqlite3数据库操作进阶及注意事项

Ⅰ.where语句后面可以有多种运算符表示方式，如WHERE NAME LIKE 'ap%'，您可以使用where或whereArg拼接所需参数。  

Ⅱ.您可以通过对象或字典来更新数据，以下是范例。  

通过自定义对象更新数据
```
NSNumber *updateSoldMoney = @104;
Apple *updateApp = [[Apple alloc]init];
updateApp.dec = @"这是通过自定义对象更新的数据测试";
BOOL res  = [updateApp zx_dbUpdateWhereArg:@"soldMoney=",updateSoldMoney,nil];
NSLog(@"结果--%i",res);
```
通过字典更新数据
```
NSNumber *updateSoldMoney = @104;
NSDictionary *updateDic = @{@"dec":@"这是通过字典更新的数据测试",@"soldMoney":@"+=66",@"testAdd":@"测试的后来新增的字段"};
BOOL res = [Apple zx_dbUpdateDic:updateDic whereArg:@"soldMoney=",updateSoldMoney,nil];
NSLog(@"结果--%i",res);
```
注：通过自定义对象更新数据有一些弊端，此次需要说明：  
a.假如您需要通过自定义对象把表中的例如soldMoney置为0是无法做到的，因为ZXSQliteHandle无法获知soldMoney=0是对象本身初始化时候就为0还是您设置成0的，当然有很多方法可以添加设置，但是考虑到操作简便性和易用性统一规定对象中数值类型的0不纳入update范围。  
b.您无法进行对应字段自增自减，字段赋值等操作。 

通过字典来更新数据可以解决这些弊端，依据您的具体需求和习惯而定，下面是一些例子： 

```
//将soldMoney的值在原本基础上加66
NSDictionary *updateDic = @{@"soldMoney":@"+=66"};
//另一种写法
NSDictionary *updateDic2 = @{@"soldMoney":@"soldMoney+66"};
```

```
//将dec的值赋值给name
NSDictionary *updateDic = @{@"name":@"dec"};

```
Ⅲ.关于数据库表的修改问题  

在实际开发中存在例如后期增加需求，对应的数据库表的模型需要增加字段，修改字段，删除字段的情况，由于数据库表的建立只是第一次不存在表的时候创建，因此此时需要考虑数据库表的修改。  

Sqlite3操作仅允许对表进行更改表名，增加列的操作，我们可以通过备份表，重新进行表设计和数据赋值达到“修改表字段”或“删除表字段”的目的，但是在ZXSQliteHandle设计的时候考虑到具体的开发需求一般是增加字段，以及具体的效率等等原因，综合考虑仅自动进行数据库表的自动增加字段操作。

若您在数据库表的模型中增加了一个属性（NSString或数值类型），在您进行数据存储或更新操作时，ZXSQliteHandle会自动为表新增一个对应类型的属性并继续执行存储或更新操作，您无需进行任何额外处理。  

Ⅳ.其他
ZXSQliteHandle默认为您当前项目创建一个您当前项目的BundleId.sqlite的数据库，数据库中的表名与对应对象一一对应，主键名为id且自增，您无需关心数据库如何创建，表如何设计，SQL语句如何写，但是如此也必然有弊端，ZXSQliteHandle可以满足绝大部分需求，但诸如外键，多表关联等等不常用的功能需要您额外处理。考虑到易用性等方面，ZXSQliteHandle仅提供核心的数据库处理，还望谅解。

### 任何问题欢迎随时issue我




        
        
        








