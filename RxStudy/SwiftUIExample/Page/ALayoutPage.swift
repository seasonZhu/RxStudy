//
//  ALayoutPage.swift
//  RxStudy
//
//  Created by dy on 2022/9/30.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI

import SVProgressHUD

struct ALayoutPage: View {
    
    @EnvironmentObject var appState: AppState
    
    let vipTitles = [
        "全场出版书畅读",
        "全场有声书畅听",
        "书架无上限",
        "离线下载无上限",
        "时长可兑换体验卡和书币",
        "专属阅读背景和字体"
    ]
    
    let experienceTitles = [
        "部分出版书畅读",
        "仅可收盘 AI 朗读",
        "书架 500 本上限",
        "每月可下载 3 本",
        "仅可兑换体验卡",
        "-"
    ]
    
    @Binding var isActive: Bool
    
    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                ZStack {
                    /// 设置页面背景色
                    Color(red: 39/255, green: 46/255, blue: 71/255)
                        .edgesIgnoringSafeArea(.all)
                    
                    /// ScrollView
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("付费会员卡")
                                    .bold()
                                    .padding(.bottom, 4)
                                    .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                            }
                            
                            /// 填充中间空白区域，使文字上下靠边
                            Spacer()
                            
                            HStack(alignment: .bottom) {
                                Text("3")
                                    .bold()
                                    .padding(.bottom, -4)
                                    .font(.system(size: 24))
                                
                                Text("天·9月27日到期")
                                    .font(.system(size: 10))
                                
                                /// 空白区域填充，使文字居左
                                Spacer(minLength: 0)
                            }
                            .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                        }
                        .padding()
                        .frame(height: 180)
                        /// 会员卡背景色渐变
                        .background(RadialGradient(
                            gradient: Gradient(
                                colors: [
                                    Color(red: 56/255, green: 81/255, blue: 116/255),
                                    Color(red: 39/255, green: 46/255, blue: 71/255),
                                    Color(red: 231/255, green: 200/255, blue: 153/255),
                                    Color(red: 39/255, green: 46/255, blue: 71/255)
                                ]
                            ),
                            center: .center,
                            startRadius: 2,
                            endRadius: 650)
                        )
                        /// 圆角边框
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 231/255, green: 200/255, blue: 153/255), lineWidth: 1)
                            
                        )
                        .padding(.bottom, 10)
                        
                        VStack(alignment: .leading) {
                            HStack(alignment: .top, spacing: 0) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack {
                                        Image(systemName: "infinity")
                                        Text("付费会员卡")
                                            .bold()
                                    }
                                    .padding(.bottom, -5)
                                    
                                    Divider()
                                        .overlay(Color.gray)
                                    
                                    ForEach(vipTitles) {
                                        Text($0)
                                    }
                                }
                                .padding()
                                .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack {
                                        Image(systemName: "infinity")
                                        Text("体验卡")
                                    }
                                    .padding(.bottom, -5)
                                    
                                    Divider()
                                        .overlay(Color.gray)
                                    
                                    ForEach(experienceTitles) {
                                        Text($0)
                                    }
                                }
                                .padding()
                                .foregroundColor(Color.gray)
                            }.font(.system(size: 12))
                        }
                        .background(Color(red: 47/255, green: 54/255, blue: 77/255))
                        .cornerRadius(12)
                        
                        VStack {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("连续包月 19.00").bold().padding(.bottom, 6)
                                        Text("19元/月-自动续费可随时取消").font(.system(size: 10))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("立即开通")
                                        .font(.system(size: 14))
                                        .bold()
                                        .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                        .background(Color(red: 52/255, green: 58/255, blue: 78/255))
                                        .cornerRadius(16)
                                }
                                .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                            }
                            .padding()
                            /// 背景线性渐变，从左到右
                            .background(LinearGradient(gradient: Gradient(colors:
                                                                            [Color.blue,
                                                                             Color.green]),
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            .cornerRadius(12)
                            .padding(.bottom, 10)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("购买年卡")
                                            .padding(.bottom, 1)
                                        
                                        HStack {
                                            Text("228.00")
                                                .font(.headline)
                                            Text("(19元/月)")
                                                .font(.subheadline)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                                    .padding()
                                    .background(Color(red: 52/255, green: 58/255, blue: 78/255))
                                    .cornerRadius(12)
                                    
                                    HStack {
                                        Image(systemName: "gift")
                                            .font(.system(size: 20))
                                        VStack(alignment: .leading) {
                                            Text("赠送年卡给好友")
                                                .padding(.bottom, 1)
                                            
                                            VStack(alignment: .leading) {
                                                Text("228.00")
                                                    .font(.headline)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                                    .padding()
                                    .background(Color(red: 52/255, green: 58/255, blue: 78/255))
                                    .cornerRadius(12)
                                }
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("购买季卡")
                                            .padding(.bottom, 1)
                                        HStack {
                                            Text("60.00").font(.headline)
                                            Text("(20元/月)").font(.subheadline)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                                    .padding()
                                    .background(Color(red: 52/255, green: 58/255, blue: 78/255))
                                    .cornerRadius(12)
                                    
                                    VStack(alignment: .leading) {
                                        Text("购买月卡").padding(.bottom, 1)
                                        VStack(alignment: .leading) {
                                            Text("30.00").font(.headline)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                                    .padding()
                                    .background(Color(red: 52/255, green: 58/255, blue: 78/255))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .background(
                            Color(red: 41/255, green: 50/255, blue: 75/255)
                        )
                    }
                    .padding([.top, .leading, .trailing])
                }
                /// 设置一个底部固定区域，然后自定义其内部子视图
                .safeAreaInset(edge: .bottom) {
                    Text("确认购买后，将向您的 iTunes 账户收款。购买连续包月项目，将自动续订，iTunes 账户会在到期前 24 小时内扣费。在此之前，您可以在系统[设置] -> [iTunes Store 与 App Store] -> [Apple ID] 里面进行退订。")
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray)
                        .background(Color(red: 39/255, green: 46/255, blue: 71/255))
                        .padding(.top, 10)
                }
                /// 设置导航栏为行内模式
                .navigationBarTitleDisplayMode(.inline)
                /// 自定义导航栏标题内容
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("会员卡")
                                .font(.headline)
                                .padding(.bottom, 2)
                            Text("已使用 517 天·累计节省 839.76 元")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                    }
                }
                /// 自定义导航栏左右两边的按钮
                .navigationBarItems(
                    leading: Button(action: {
                        isActive = false
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                    }),
                    trailing: Button(action: {
                        /// 点击按钮时的操作
                        appState.isBack.toggle()
                        SVProgressHUD.showText("\(appState.isBack)")
                    }, label: {
                        Text("明细")
                            .foregroundColor(Color(red: 231/255, green: 200/255, blue: 153/255))
                    })
                )
            } else {
                Text("这个UI用于iOS 15版本的SwiftUI")
            }
        }
        /// 这种配置会出现,侧滑跳过CoinRankListPage,直接回My,只能通过点击返回按钮回CoinRankListPage,还是需要一个纯SwiftUI去验证与尝试
        .navigationBarHidden(true)
    }
}

struct ALayoutPage_Previews: PreviewProvider {
    static var previews: some View {
        ALayoutPage(isActive: .constant(true))
    }
}

extension String: Identifiable {
    public var id: String { self }
}
