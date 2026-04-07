import SwiftUI
import UIKit
import MapKit

struct MapViewControllerRepresentable: UIViewControllerRepresentable {
    let cards: [CardDTO]

    func makeUIViewController(context: Context) -> MapViewController {
        let controller = MapViewController()
        controller.update(with: cards)
        return controller
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.update(with: cards)
    }
}

final class MapViewController: UIViewController {
    private let mapView = MKMapView()
    private let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
        span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }

    func update(with cards: [CardDTO]) {
        let annotations = cards.compactMap(MapCarAnnotation.init(card:))

        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)

        guard !annotations.isEmpty else {
            mapView.setRegion(defaultRegion, animated: false)
            return
        }

        if annotations.count == 1, let annotation = annotations.first {
            let region = MKCoordinateRegion(
                center: annotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
            )
            mapView.setRegion(region, animated: true)
            return
        }

        mapView.setVisibleMapRect(
            mapRect(for: annotations),
            edgePadding: UIEdgeInsets(top: 120, left: 48, bottom: 48, right: 48),
            animated: true
        )
    }
}

private extension MapViewController {
    func configureMapView() {
        view.backgroundColor = .systemBackground
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.setRegion(defaultRegion, animated: false)

        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func mapRect(for annotations: [MapCarAnnotation]) -> MKMapRect {
        annotations.reduce(.null) { partialResult, annotation in
            let point = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(
                x: point.x,
                y: point.y,
                width: 0.1,
                height: 0.1
            )

            return partialResult.isNull ? rect : partialResult.union(rect)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MapCarAnnotation else { return nil }

        let identifier = "car-pin"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        view.annotation = annotation
        view.canShowCallout = true
        view.markerTintColor = .systemBlue
        view.glyphImage = UIImage(systemName: "car.fill")
        view.displayPriority = .required

        return view
    }
}

private final class MapCarAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init?(card: CardDTO) {
        guard let latitude = card.latitude,
              let longitude = card.longitude else {
            return nil
        }

        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        title = "\(card.make) \(card.model)"

        var subtitleParts: [String] = []
        if let year = card.year, !year.isEmpty {
            subtitleParts.append(year)
        }
        subtitleParts.append("Grade \(card.numGrade)")
        subtitle = subtitleParts.joined(separator: " • ")
    }
}
