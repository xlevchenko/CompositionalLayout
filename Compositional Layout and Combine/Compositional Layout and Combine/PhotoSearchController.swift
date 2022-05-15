//
//  PhotoSearchController.swift
//  Compositional Layout and Combine
//
//  Created by Olexsii Levchenko on 5/15/22.
//

import UIKit
import Combine //asynchronous programming framework introduction in IOS 13
import Kingfisher

class PhotoSearchController: UIViewController {
    
    //declare collection view
    private var collectionView: UICollectionView!
    
    //declare data source
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Hits>
    private var dataSource: DataSource!
    
    //declare a search controller
    private var searchController: UISearchController!
    
    //declare a search text property that will be a `Publisher`
    //that emits for changes from the searchBar on the search controller
    //in order to make any property a `Publisher` you need to append
    //the `@Published` property wrapper
    //to subscribe to the searchText's `Publisher` a $ need to be prefixed
    //to searchText => $searchText
    @Published private var searchText = ""
    
    //store sabscriptions
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Photo Search"
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        
        let cancellabel = $searchText
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.searchPhoto(for: text)
            }
            .store(in: &subscriptions)
    }
}


//MARK: Configure SearchController
extension PhotoSearchController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        
        searchText = text
        //opon asigning a new value to the searchText
        //the subscriber in the viewDidLoad will receiver that  value
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self //delegate
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
    }
}


//MARK: Configure Collection View
extension PhotoSearchController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }
}


//MARK: Section Kind
extension PhotoSearchController {
    enum SectionKind: Int, CaseIterable {
        case main
    }
}


//MARK: Create layout
extension PhotoSearchController {
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            //item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSpacing: CGFloat = 5
            item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
            
            //group (leadingGroup, trailingGroup, nestedGroup)
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            
            let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 2)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 3)
            
            //nested group
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1000))
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [leadingGroup, trailingGroup])
            
            //section
            let section = NSCollectionLayoutSection(group: nestedGroup)
            
            return section
        }
        return layout
    }
}


//MARK: Configure DataSource
extension PhotoSearchController {
    private func configureDataSource() {
        //setup the initial data source and configure cell
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, photo in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else { fatalError("Could not deqqueue an ImageCell")
            }
            cell.backgroundColor = .systemTeal
            cell.imageView.kf.setImage(with: URL(string: photo.webformatURL))
            cell.imageView.contentMode = .scaleAspectFill
            return cell
        })
        
        //setup initial snapshot
        var snapshot = dataSource.snapshot() // current snapshot
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


//MARK: Featch Photo
extension PhotoSearchController {
    private func searchPhoto(for query: String) {
        //searchPhoto ia a `Pablisher`
        APIClient().searchPhotos(for: query)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] photo in
                self?.updateSnapshot(with: photo)
            }
            .store(in: &subscriptions)
    }
    
    private func updateSnapshot(with photos: [Hits]) {
       var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
