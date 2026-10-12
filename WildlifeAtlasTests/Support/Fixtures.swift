//
//  Fixtures.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import Foundation
@testable import WildlifeAtlas

enum Fixtures {
    static let observationsPage = """
    {
      "total_results": 156371,
      "page": 1,
      "per_page": 30,
      "results": [
        {
          "id": 397478799,
          "quality_grade": "research",
          "observed_on": "2026-07-12",
          "time_observed_at": "2026-07-12T20:22:14-04:00",
          "place_guess": "Walton Ln, Ardmore, PA, US",
          "obscured": false,
          "geoprivacy": null,
          "taxon_geoprivacy": "open",
          "uri": "https://www.inaturalist.org/observations/397478799",
          "photos": [
            {
              "id": 729026846,
              "url": "https://static.inaturalist.org/photos/729026846/square.jpg",
              "attribution": "(c) Clara Stuligross, all rights reserved",
              "license_code": null
            },
            {
              "id": 729026847,
              "url": "https://static.inaturalist.org/photos/729026847/square.jpg",
              "attribution": "(c) Clara Stuligross, some rights reserved (CC BY-NC)",
              "license_code": "cc-by-nc"
            }
          ],
          "taxon": {
            "id": 42069,
            "name": "Vulpes vulpes",
            "rank": "species",
            "preferred_common_name": "Red Fox",
            "iconic_taxon_name": "Mammalia"
          },
          "user": {
            "id": 2089737,
            "login": "clarastuli",
            "name": "Clara Stuligross",
            "icon_url": "https://static.inaturalist.org/attachments/users/icons/2089737/medium.jpg"
          }
        }
      ]
    }
    """

    static let dateOnlyObservation = """
    {
      "total_results": 1, "page": 1, "per_page": 30,
      "results": [
        {
          "id": 1,
          "quality_grade": "needs_id",
          "observed_on": "2025-05-12",
          "time_observed_at": null,
          "photos": [],
          "obscured": false
        }
      ]
    }
    """

    static let minimalObservation = """
    {
      "total_results": 1, "page": 1, "per_page": 30,
      "results": [
        { "id": 2, "taxon": null, "photos": [], "obscured": false }
      ]
    }
    """

    static let unknownGradeObservation = """
    {
      "total_results": 1, "page": 1, "per_page": 30,
      "results": [
        { "id": 3, "quality_grade": "brand_new_grade", "photos": [], "obscured": false }
      ]
    }
    """

    static let obscuredObservations = """
    {
      "total_results": 3, "page": 1, "per_page": 30,
      "results": [
        { "id": 10, "place_guess": "Gyeongsangnam-do, KR", "geoprivacy": "obscured", "obscured": true, "photos": [] },
        { "id": 11, "place_guess": "Somewhere private", "geoprivacy": "private", "obscured": false, "photos": [] },
        { "id": 12, "place_guess": "Sensitive species site", "taxon_geoprivacy": "obscured", "obscured": false, "photos": [] }
      ]
    }
    """

    static let taxonDetails = """
    {
      "total_results": 1, "page": 1, "per_page": 30,
      "results": [
        {
          "id": 42069,
          "name": "Vulpes vulpes",
          "rank": "species",
          "preferred_common_name": "Red Fox",
          "iconic_taxon_name": "Mammalia",
          "observations_count": 156371,
          "ancestors": [
            { "id": 1, "name": "Animalia", "rank": "kingdom" },
            { "id": 355675, "name": "Vertebrata", "rank": "subphylum" },
            { "id": 40151, "name": "Mammalia", "rank": "class" },
            { "id": 41573, "name": "Carnivora", "rank": "order" },
            { "id": 42043, "name": "Canidae", "rank": "family" },
            { "id": 42064, "name": "Vulpes", "rank": "genus" }
          ]
        }
      ]
    }
    """

    static let taxaAutocomplete = """
    {
      "total_results": 722, "page": 1, "per_page": 3,
      "results": [
        {
          "id": 42069, "name": "Vulpes vulpes", "rank": "species",
          "preferred_common_name": "Red Fox", "iconic_taxon_name": "Mammalia",
          "observations_count": 156371,
          "default_photo": { "id": 1, "url": "https://static.inaturalist.org/photos/1/square.jpg" }
        },
        {
          "id": 67598, "name": "Solenopsis invicta", "rank": "species",
          "preferred_common_name": "Red Imported Fire Ant", "iconic_taxon_name": "Insecta",
          "observations_count": 38427
        }
      ]
    }
    """
}
