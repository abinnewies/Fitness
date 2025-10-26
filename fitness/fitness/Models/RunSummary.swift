//
//  RunSummary.swift
//  Fitness
//
//  Created by Andreas Binnewies on 10/26/25.
//

import MapKit

struct RunSummary: Identifiable {
  let id: String
  let distanceMeters: Double?
  let duration: TimeInterval
  let elevationAscendedMeters: Double?
  let routePoints: [RoutePoint]

  var routeCoordinates: [CLLocationCoordinate2D] {
    routePoints.map(\.location.coordinate)
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
    let latDelta = max(0.001, (maxLat - minLat) * 1.2)
    let lonDelta = max(0.001, (maxLon - minLon) * 1.2)

    return MKCoordinateRegion(
      center: center,
      span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    )
  }
}
