//
//  Array+RoutePoint.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/27/25.
//

import CoreLocation
import MapKit

extension Array where Element == RoutePoint {
  var routeCoordinates: [CLLocationCoordinate2D] {
    map(\.location.coordinate)
  }

  var routeRegion: MKCoordinateRegion? {
    guard !routeCoordinates.isEmpty else {
      return nil
    }

    let latitudes = routeCoordinates.map(\.latitude)
    let longitudes = routeCoordinates.map(\.longitude)

    let minLat = latitudes.min()!
    let maxLat = latitudes.max()!
    let minLon = longitudes.min()!
    let maxLon = longitudes.max()!

    let center = CLLocationCoordinate2D(
      latitude: (minLat + maxLat) / 2.0,
      longitude: (minLon + maxLon) / 2.0
    )
    let latDelta = Swift.max(0.001, (maxLat - minLat) * 1.3)
    let lonDelta = Swift.max(0.001, (maxLon - minLon) * 1.7)

    return MKCoordinateRegion(
      center: center,
      span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    )
  }
}
