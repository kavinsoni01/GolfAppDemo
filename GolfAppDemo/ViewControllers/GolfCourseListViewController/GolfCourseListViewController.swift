//
//  GolfCourseListViewController.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 21/05/25.
//

import UIKit

class GolfCourseListViewController: BaseViewController {
    
    // MARK: - Properties
    
    var arrFilteredCourses:[Course] = []
    private var viewModel:GolfCourseListViewModel!
    private let searchBar = UISearchBar()
    
    // MARK: - Outlets
    
    @IBOutlet weak var tblGolfCourceList: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewModel()
        self.setupUI()
        self.setupTableView()
        self.setupSearchBar()
    }
    
    //MARK: - setupViewModel
    
    private func setupViewModel() -> Void {
        self.viewModel = GolfCourseListViewModel(delegate: self)
        self.viewModel.loadPrefrenceSearch()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.title = AppConstants.Titles.golfCourses
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.sizeToFit()
    }
    // MARK: - setup tableview
    
    private func setupTableView() {
        self.tblGolfCourceList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.tblGolfCourceList.register(
            UINib(nibName: "GolfListTableCell", bundle: nil),
            forCellReuseIdentifier: "GolfListTableCell"
        )
        self.tblGolfCourceList.dataSource = self
        self.tblGolfCourceList.delegate = self
        self.tblGolfCourceList.separatorStyle = .none
        
        self.tblGolfCourceList.setEmptyView(
            title: AppConstants.Titles.searchPrompt,
            message: AppConstants.Messages.startTyping,
            image: UIImage(named: AppConstants.Images.golfField)
        )
        
    }
    
    private func setupSearchBar() {
        searchBar.placeholder =  AppConstants.Placeholder.searchGolf
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.addDoneButtonOnKeyboard()
        self.tblGolfCourceList.tableHeaderView = searchBar
    }
    
    
    // MARK: - Filtering Logic for Local (when search button not clicked it show result from Local)
    
    private func filterCourses(with searchText: String) {
        guard let allCourses = viewModel.arrAllCourseList else { return }
        
        if searchText.isEmpty {
            self.arrFilteredCourses = [] //self.viewModel.arrGolfCourseList ?? [] // uncoment for Set default filtered list to all courses

            self.tblGolfCourceList.setEmptyView(
                title: AppConstants.Titles.searchPrompt,
                message: AppConstants.Messages.startTyping,
                image: UIImage(named: AppConstants.Images.golfField)
            )
            
        } else {
            let lowercasedText = searchText.lowercased()
            self.arrFilteredCourses = allCourses.filter {
                $0.course_name?.lowercased().contains(lowercasedText) == true ||
                $0.club_name?.lowercased().contains(lowercasedText) == true ||
                $0.location?.city?.lowercased().contains(lowercasedText) == true
            }
            
            self.tblGolfCourceList.restore() //remove tableview background
        }
        
        DispatchQueue.main.async {
            self.tblGolfCourceList.reloadData()
        }
    }
}


// MARK: - ViewModel Delegate

extension GolfCourseListViewController: GolfCourseListProtocol {
    //it called got error from api 
    func getGolfCourseAPIFail(withMessage message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: AppConstants.Titles.alert, message: message, actions: [(AppConstants.button.ok, .default, nil)])
        }
    }
    
    func getGolfCourseAPISuccess() {
        DispatchQueue.main.async {
            if self.viewModel.arrGolfCourseList?.isEmpty ?? true {
                self.tblGolfCourceList.setEmptyView(
                    title: AppConstants.Titles.noResultsFound,
                    message: AppConstants.Messages.noMatches,
                    image: UIImage(named: AppConstants.Images.golfBall)
                )
            }
            self.arrFilteredCourses = self.viewModel.arrGolfCourseList ?? []
            self.viewModel.loadPrefrenceSearch()
            self.tblGolfCourceList.reloadData()
        }
    }
}


// MARK: - UISearchBarDelegate

extension GolfCourseListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterCourses(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.viewModel.callGetGolfCourseListAPI(searchText: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        filterCourses(with: "")
    }
}

// MARK: - UITableView DataSource & Delegate

extension GolfCourseListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrFilteredCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: GolfListTableCell = tableView.dequeueReusableCell(
            withIdentifier: "GolfListTableCell") as? GolfListTableCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configureCell(with: self.arrFilteredCourses[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GolfCourseDetailViewController") as? GolfCourseDetailViewController else { return }
        vc.golfCourse = self.arrFilteredCourses[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
