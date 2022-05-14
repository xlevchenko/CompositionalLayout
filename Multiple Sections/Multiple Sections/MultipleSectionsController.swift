//
//  MultipleSectionsController.swift
//  Multiple Sections
//
//  Created by Olexsii Levchenko on 5/14/22.
//

import UIKit

class MultipleSectionsController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //Step 2
    //both args has to conform  to Hashable
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
    private var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }


}


//Step 1
//MARK: Create Enum number section
extension MultipleSectionsController {
    enum Section: Int, CaseIterable {
        case grid
        case singl
        
        //ToDo: add a third section
        var columnCount: Int {
            switch self {
            case .grid:
                return 4 // 4 columns
            case .singl:
                return 1 // 1 columns
            }
        }
    }
}

//Step 4
extension MultipleSectionsController {
 
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .systemBackground
        
        //step 7
        //register the supplementary HeaderView
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
    }
}


//Step 3
extension MultipleSectionsController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            //find out what section we are working with
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            //how many colums
            let coulum = sectionType.columnCount // 1 or 4
            
            //create the layout:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            //add content insets  for item
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupHeight = coulum == 1 ? NSCollectionLayoutDimension.absolute(200) : NSCollectionLayoutDimension.fractionalWidth(0.25)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: coulum) // 1 or 4
            
            let section = NSCollectionLayoutSection(group: group)
            
            //scroling section
            section.orthogonalScrollingBehavior = .groupPaging
            
            //configure the header view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }
}


//Step 5
extension MultipleSectionsController {
    private func configureDataSource() {
       //1. setting up the data source
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            //configure our cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
                fatalError("Could not dequeue a LabelCell")
            }
            cell.textLabel.text = "\(itemIdentifier)"
            
            if indexPath.section == 0 {
                cell.backgroundColor = .systemOrange
                cell.layer.cornerRadius = 12
            } else {
                cell.backgroundColor = .systemPink
                cell.layer.cornerRadius = 0
            }
            return cell
        })
        
        //3.
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
                fatalError("Could not dequeue a HeaderView")
            }
            if indexPath.section == 0 {
                headerView.textLabel.text = "YouTube API"
            } else {
            headerView.textLabel.text = "\(Section.allCases[indexPath.section])"
            }
            return headerView
        }
        
        //2. setup initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.grid, .singl])
        snapshot.appendItems(Array(1...12), toSection: .grid)
        snapshot.appendItems(Array(13...14), toSection: .singl)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
