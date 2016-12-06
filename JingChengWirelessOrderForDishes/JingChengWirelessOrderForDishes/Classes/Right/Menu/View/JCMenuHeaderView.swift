//
//  JCMenuHeaderView.swift
//  JingChengWirelessOrderForDishes
//
//  Created by zhangxu on 2016/11/23.
//  Copyright © 2016年 zhangxu. All rights reserved.
//

import UIKit

class JCMenuHeaderView: UIView {

    // cell标识
    fileprivate let menuHeaderCellIdentifier = "menuHeaderCellIdentifier";
    
    // collectionView
    fileprivate lazy var headerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout();
        layout.scrollDirection = .horizontal;
        layout.itemSize = CGSize(width: realValue(value: 180/2), height: realValue(value: 56/2));
        layout.minimumLineSpacing = realValue(value: 0);
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout);
        collectionView.backgroundColor = UIColor.clear;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.bounces = false;
        return collectionView;
    }();
    
    // 懒加载数组
    fileprivate lazy var menuHeaderModelArray: [JCMenuHeaderModel] = [JCMenuHeaderModel]();
    
    var updateCategoryDetailDataCallBack: ((_ model: JCMenuHeaderModel) -> ())?;
    
    deinit {
        print("JCMenuHeaderView 被释放了");
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        // 清除颜色
        backgroundColor = UIColor.clear;
        
        // 添加collectionView
        addSubview(headerCollectionView);
        
        // 注册cell
        headerCollectionView.register(JCMenuHeaderCell.self, forCellWithReuseIdentifier: menuHeaderCellIdentifier)
        
        let menuHeaderViewModel = JCMenuHeaderViewModel();
       menuHeaderViewModel.fetchMenuListDataFromServer(successCallBack: { [weak self] (result) in
            // 清空数组
            self?.menuHeaderModelArray.removeAll();
            // 请求成功
            self?.menuHeaderModelArray += result;
            // 刷新数组
            self?.headerCollectionView.reloadData();
            
            }, failureCallBack: {
                (error) in
                // 请求失败
                print(error);
        });
    }
    
    // 设置子控件的frame
    override func layoutSubviews() {
        super.layoutSubviews();
        
        // 设置collectionView的frame
        headerCollectionView.frame = bounds;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 数据源方法
extension JCMenuHeaderView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 返回行
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuHeaderModelArray.count;
    }
    
    // 返回cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuHeaderCellIdentifier, for: indexPath) as? JCMenuHeaderCell else {
            return JCMenuHeaderCell();
        };
        
        let menuHeaderModel = menuHeaderModelArray[indexPath.row];
        cell.menuHeaderModel = menuHeaderModel;
        cell.changeOtherBtnStatusCallBack = { [weak self]
            (model) in
            
            let _ = self?.menuHeaderModelArray.map({
                (element) in
                
                element.isSelected = (element == model) ? true : false;
            });
            // 更新状态
            self?.headerCollectionView.reloadData();
            
            if let updateCategoryDetailDataCallBack = self?.updateCategoryDetailDataCallBack {
                updateCategoryDetailDataCallBack(model);
            }
        }
        return cell;
    }
    
}