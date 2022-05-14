//
//  GridViewController.swift
//  Introduction to UICollectionViewCompositionalLayout
//
//  Created by Olexsii Levchenko on 5/14/22.
//

import UIKit

class GridViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //declare our data source, which will be using Diffable Data Source
    //review: both the SectionIdentifier and ItemIdentifier needs to be Hashable objects
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
    }
}


//MARK: 3. Setup enum to hold sections for Collection view
extension GridViewController {
    enum Section {
        case main
    }
}


//MARK: 2. Configure Collection View
extension GridViewController {
    private func configureCollectionView(){
        ///do this if you create layout collectionview programmatically
        ///collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        
        //do this if you using storyboard to layout collection view
        collectionView.collectionViewLayout = createLayout() //from flow layout to compositional laout
        collectionView.backgroundColor = .systemBackground
    }
}


//MARK: 1. Create and configure layout
extension GridViewController {
    private func createLayout() -> UICollectionViewLayout {
        //1
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let spacing: CGFloat = 5
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        //2
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        //let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
        //3
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}


//MARK: 5. Diffable Data Source
extension GridViewController {
    private func configureDataSource() {
        //1.
        // setting up  the data  source
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lableCell", for: indexPath) as? LabelCell else {
                fatalError("could not dequeue a LabelCell")
            }
            cell.textLabel.text = "\(itemIdentifier)"
            cell.backgroundColor = .systemOrange
            return cell
        })
        
        //2
        //setting the initial snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main]) //only one section
        snapshot.appendItems(Array(1...100))
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
