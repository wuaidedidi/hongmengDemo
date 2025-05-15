import router from '@ohos.router';

interface RouterParams {
  action: string;
  todoId: number;
}

@Entry
@Component
export default struct TodoOperation {
  @State todoId: number = -1;
  
  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      const paramsObj = params as Record<string, string | number>;
      if (paramsObj.todoId !== undefined) {
        this.todoId = paramsObj.todoId as number;
      }
    }
  }
  
  build() {
    Stack() {
      Column() {
        // 顶部显示待办号码
        Row() {
          Text('22')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .margin({ left: 16 })
          
          Blank()
          
          Row({ space: 16 }) {
            Column() {
              Text('⏰')
                .fontSize(26)
                .fontColor('#03A9F4')
              Text('定时提醒/专注')
                .fontSize(12)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            
            Column() {
              Text('🖼️')
                .fontSize(26)
                .fontColor('#03A9F4')
              Text('更换背景')
                .fontSize(12)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            
            Column() {
              Text('📋')
                .fontSize(26)
                .fontColor('#03A9F4')
              Text('独立白名单')
                .fontSize(12)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
            .margin({ right: 16 })
          }
        }
        .width('100%')
        .height(100)
        .backgroundColor('#FFFFFF')
        .padding({ top: 20 })
        
        // 操作按钮行
        Row() {
          Button('编辑')
            .fontSize(16)
            .fontColor('#03A9F4')
            .backgroundColor('#E1F5FE')
            .borderRadius(20)
            .height(40)
            .width('33.3%')
            .margin(5)
          
          Button('排序 | 移动')
            .fontSize(16)
            .fontColor('#03A9F4')
            .backgroundColor('#E1F5FE')
            .borderRadius(20)
            .height(40)
            .width('33.3%')
            .margin(5)
          
          Button('删除')
            .fontSize(16)
            .fontColor('#FF5252')
            .backgroundColor('#FFEBEE')
            .borderRadius(20)
            .height(40)
            .width('33.3%')
            .margin(5)
            .onClick(() => {
              // 删除后返回首页，并传递删除信息
              try {
                router.pushUrl({
                  url: 'pages/Index',
                  params: {
                    action: 'delete',
                    todoId: this.todoId
                  }
                });
              } catch (error) {
                console.error(`返回首页出错: ${JSON.stringify(error)}`);
                router.back(); // 如果跳转失败则简单返回
              }
            })
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 10, bottom: 10 })
        
        // 功能区域
        Row() {
          Column() {
            Text('📊')
              .fontSize(32)
              .fontColor('#03A9F4')
            Text('专注历史记录')
              .fontSize(14)
              .fontColor('#03A9F4')
              .margin({ top: 8 })
          }
          .width('50%')
          .backgroundColor('#E1F5FE')
          .borderRadius(8)
          .padding(20)
          .margin(5)
          
          Column() {
            Text('📈')
              .fontSize(32)
              .fontColor('#03A9F4')
            Text('数据统计')
              .fontSize(14)
              .fontColor('#03A9F4')
              .margin({ top: 8 })
          }
          .width('50%')
          .backgroundColor('#E1F5FE')
          .borderRadius(8)
          .padding(20)
          .margin(5)
        }
        .width('100%')
        .padding({ left: 10, right: 10 })
        
        // 统计信息区域
        Column() {
          Text('累计专注')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 16, bottom: 16 })
          
          Row() {
            Text('0')
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor('#03A9F4')
            Text('次')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ left: 4, bottom: 8 })
              .alignSelf(ItemAlign.End)
          }
          .justifyContent(FlexAlign.Center)
          .width('50%')
          
          Row() {
            Text('0')
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor('#03A9F4')
            Text('分钟')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ left: 4, bottom: 8 })
              .alignSelf(ItemAlign.End)
          }
          .justifyContent(FlexAlign.Center)
          .width('50%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        
        // 定时提醒信息
        Column() {
          Text('定时提醒 | 定时学霸模式')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#03A9F4')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 16, bottom: 8 })
          
          Text('没有设置定时提醒或定时学霸')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
          
          Text('目标截止日期 2025-05-14 剩余 1天')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#03A9F4')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
          
          Row() {
            Column() {
              Text('计划内已完成')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ bottom: 4 })
              
              Row() {
                Text('0')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Text('分钟')
                  .fontSize(12)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.End)
                  .margin({ left: 4, bottom: 4 })
              }
            }
            .width('33.3%')
            .alignItems(HorizontalAlign.Center)
            
            Column() {
              Text('长期计划完成度')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ bottom: 4 })
              
              Row() {
                // 圆形进度条（简化表示）
                Stack() {
                  Circle()
                    .width(50)
                    .height(50)
                    .fill('#EEEEEE')
                    .strokeWidth(5)
                    .stroke('#03A9F4')
                  
                  Text('0')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                }
              }
            }
            .width('33.3%')
            .alignItems(HorizontalAlign.Center)
            
            Column() {
              Text('计划总数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ bottom: 4 })
              
              Row() {
                Text('1980')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Text('分钟')
                  .fontSize(12)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.End)
                  .margin({ left: 4, bottom: 4 })
              }
            }
            .width('33.3%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ left: 10, right: 10 })
          
          // 底部信息行
          Row() {
            Text('📅')
              .fontSize(20)
              .fontColor('#666666')
            Text('总共坚持天数')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 8 })
            
            Blank()
            
            Text('0 天')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          
          Row() {
            Text('🔄')
              .fontSize(20)
              .fontColor('#666666')
            Text('连续坚持天数')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 8 })
            
            Blank()
            
            Text('0 天')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          
          Row() {
            Text('📝')
              .fontSize(20)
              .fontColor('#666666')
            Text('创建日期')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 8 })
            
            Blank()
            
            Text('2025年05月13日')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
        .margin({ top: 16 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      
      // 关闭按钮
      Button('×')
        .width(40)
        .height(40)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#8A2BE2')
        .borderRadius(20)
        .position({ x: '85%', y: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
  }
} 