//
//  DiskService.swift
//  SimpleWidgetExtension
//
//  Created by Itamar Biton on 14/07/2021.
//

import Foundation
import os

class DiskService {
    private static let dataDirName = "WidgetData"
    private static let locationDataFileName = "LocationData"
    private static let fetchedDataFileName = "FetchedData"

    private static var documentsDirUrl: URL? {
        try? FileManager.default.url(
            for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false)
    }

    private static var dataDirUrl: URL? {
        documentsDirUrl?.appendingPathComponent(dataDirName)
    }

    private static var locationDataFileUrl: URL? {
        dataDirUrl?.appendingPathComponent(locationDataFileName)
    }

    private static var fetchedDataFileUrl: URL? {
        dataDirUrl?.appendingPathComponent(fetchedDataFileName)
    }

    private static func createDataDirIfNeeded() {
        guard let dataDirUrl = dataDirUrl,
              !FileManager.default.fileExists(atPath: dataDirUrl.path)
        else { return }

        os_log("@@ DISK SERVICE: COULDN'T FIND THE DATA DIRECTORY, CREATING... ")

        do {
            try FileManager.default.createDirectory(at: dataDirUrl, withIntermediateDirectories: false, attributes: nil)
        } catch {
            os_log("@@ DISK SERVICE: FAILED TO CREATE DATA DIRECTORY, \(error.localizedDescription)")
        }
    }

    static func writeLocationDataToDisk(_ locationData: LocationService.LocationData) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(locationData)

        guard let url = locationDataFileUrl,
              let data = data
        else { return }

        do {
            createDataDirIfNeeded()
            try data.write(to: url)
        } catch {
            os_log("@@ DISK SERVICE: FAILED TO WRITE DATA, \(error.localizedDescription)")
        }
    }

    static func getLocationData() -> LocationService.LocationData? {
        guard let url = locationDataFileUrl,
              let data = FileManager.default.contents(atPath: url.path)
        else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode(LocationService.LocationData.self, from: data)
    }

    static func deleteLocationData() {
        guard let url = locationDataFileUrl else { return }
        do {
            try FileManager.default.removeItem(at: url)
            os_log("@@ DISK SERVICE: DELETED LOCATION DATA")
        } catch {
            os_log("@@ DISK SERVICE: FAILED TO DELETE LOCATION DATA, \(error.localizedDescription)")
        }
    }

    static func moveFetchedDataToDataDirectory(from fromUrl: URL) {
        guard let destFileUrl = fetchedDataFileUrl else { return }

        if FileManager.default.fileExists(atPath: destFileUrl.path) {
            do {
                createDataDirIfNeeded()
                try FileManager.default.removeItem(at: destFileUrl)
            } catch {
                os_log("@@ DISK SERVICE: FAILED TO DELETE OLD FETCHED FILE, \(error.localizedDescription)")
            }
        }

        do {
            try FileManager.default.moveItem(at: fromUrl, to: destFileUrl)
        } catch {
            os_log("@@ DISK SERVICE: FAILED TO MOVE FETCHED DATA FILE, \(error.localizedDescription)")
        }
    }

    static func getFetchedData() -> Data? {
        guard let url = fetchedDataFileUrl else { return nil }
        return FileManager.default.contents(atPath: url.path)
    }

    static func deleteFetchedData() {
        guard let url = fetchedDataFileUrl else { return }

        do {
            try FileManager.default.removeItem(at: url)
            os_log("@@ DISK SERVICE: DELETED FETCHED DATA")
        } catch {
            os_log("@@ DISK SERVICE: FAILED TO DELETE FETCHED DATA, \(error.localizedDescription)")
        }
    }
}
