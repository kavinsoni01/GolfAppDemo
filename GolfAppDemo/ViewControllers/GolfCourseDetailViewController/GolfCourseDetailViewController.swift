//
//  GolfCourseDetailViewController.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 22/05/25.
//

import UIKit
import MapKit
import Cosmos

class GolfCourseDetailViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var btnNavigation: UIButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblGolfCourseName: UILabel!
    @IBOutlet weak var viewMap: MKMapView!
    @IBOutlet weak var viewRating: CosmosView!
    @IBOutlet weak var lblClubName: UILabel!

    // MARK: - Properties
    var golfCourse: Course?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.viewMap.delegate = self
        self.setupData()
    }
    
    func setupUI() -> Void {
        self.title = AppConstants.Titles.courseDetail
        self.setLeftBarButton(img: UIImage.init(named: AppConstants.Images.back))
        self.btnNavigation.addDropShadow()
    }

    // MARK: - Setup Methods
    /// Populate UI with course data and display map pin
    private func setupData() {
        guard let model = golfCourse else { return }

        lblAddress.text = model.location?.address ?? "No address available"
        lblClubName.text = model.club_name
        lblGolfCourseName.text = model.course_name
        viewRating.rating = model.rating ?? 3.0 // Default rating if nil

        if let loc = model.location,
           let lat = loc.latitude,
           let lon = loc.longitude {
            showLocationOnMap(latitude: lat, longitude: lon, title: model.course_name)
        }
    }

    /// Add a pin to the map and center it
    private func showLocationOnMap(latitude: Double, longitude: Double, title: String?) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title ?? "Golf Course"

        viewMap.removeAnnotations(viewMap.annotations)
        viewMap.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        viewMap.setRegion(region, animated: true)
    }

    /// Opens Apple Maps for navigation to the selected course
    private func openInAppleMaps(latitude: Double, longitude: Double, placeName: String?) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName ?? "Golf Course Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    // MARK: - Actions
    @IBAction func btnNavigationClicked(_ sender: Any) {
        guard let course = golfCourse,
              let lat = course.location?.latitude,
              let lon = course.location?.longitude else {
            self.showAlert(title: AppConstants.Titles.noLocationFound,
                           message: AppConstants.Messages.noCordinates,
                           actions: [(AppConstants.button.ok, .default, nil)])
            return
        }

        openInAppleMaps(latitude: lat, longitude: lon, placeName: course.course_name)
    }
}

extension GolfCourseDetailViewController: MKMapViewDelegate {
    /// Customize pin appearance for map annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "golfPin"

        if annotation is MKUserLocation {
            return nil // Don’t show pin for user's own location
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = UIColor.systemGreen
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}
