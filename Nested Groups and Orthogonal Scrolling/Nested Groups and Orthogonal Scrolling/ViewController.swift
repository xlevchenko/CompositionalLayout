//
//  ViewController.swift
//  Nested Groups and Orthogonal Scrolling
//
//  Created by Olexsii Levchenko on 5/13/22.
//

import UIKit

enum SectionKind: Int, CaseIterable {
    case first
    case second
    case third
    
    //computed property will return the number of
    //item to vertically stack
    var itemCount: Int {
        switch self { //sectionKind
        case .first:
            return 1
        case .second:
            return 3
        case .third:
            return 3
        }
    }
        
    var nestedGroupHeigt: NSCollectionLayoutDimension {
        switch self {
        case .first:
            return .fractionalWidth(0.6)
        case .second:
            return .fractionalWidth(0.5)
        case .third:
            return .fractionalWidth(0.5)
        }
    }
    
    var sectionTitle: String {
        switch self {
        case .first:
            return "Top Chanale"
        case .second:
            return "Second section"
        case .third:
            return "Third section"
            
        }
    }
    
//    var itemSize: NSCollectionLayoutDimension {
//        switch self {
//        case .first:
//            return .fractionalWidth(1.0)
//        case .second:
//            return .fractionalHeight(0.33)
//        case .third:
//            return .fractionalHeight(0.33)
//        }
//    }
}

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
    
    private var dataSource: DataSource!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        navigationItem.title = "Nested Groups and Orthogonal Scrolling"
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
      //item -> group -> section -> layout
        
        //two ways  to create a layout
        //1. use a given section
        //2. use a section provider which takes a closure
        //      - the section provaider closure gets called
        //      - for ech section
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            //figure out what section we are dealing with
            guard let sectionKinde = SectionKind(rawValue: sectionIndex) else {
            fatalError("error")
            }
            
            //item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            
            //group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: innerGroupSize, subitem: item, count: sectionKinde.itemCount) // 1 or 2
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: sectionKinde.nestedGroupHeigt)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
            
            //section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            
            
            //section header
            //we can setup size using: .fractical, .absolute, .estimated
            
            //steps to add a section header to a section
            //1. define the size and add to the section
            //2. register  the supplementary view
            //3. dequeue the supplementary view
            let hendlerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: hendlerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        //loyout
        return layout
    }
    
    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            //configure cell and return cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
            fatalError("could not dequeue a LableCell")
            }
            //item is a an Int
            cell.textLabel.text = "\(itemIdentifier)" //e.g. 1, 2
            cell.backgroundColor = .systemYellow
            cell.layer.cornerRadius = 10
            return cell
        })
        
        //dequeue the header supplementary view
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView, let sectionKind = SectionKind(rawValue: indexPath.section)
            else {
                fatalError("coud not dequeue a HeaderView")
            }
            //configure the headerView
            headerView.textLabel.text = sectionKind.sectionTitle
            headerView.textLabel.textAlignment = .left
            headerView.textLabel.font = .preferredFont(forTextStyle: .headline)
            return headerView
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
        
        snapshot.appendSections([.first, .second, .third])
        
        //populate the sections (3)
        snapshot.appendItems(Array(1...4), toSection: .first)
        snapshot.appendItems(Array(5...10), toSection: .second)
        snapshot.appendItems(Array(11...23), toSection: .third)
        
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

