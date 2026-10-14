//
//  AppDelegate+CrashConfig.swift
//  RxStudy
//
//  Created by dy on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import KSCrash

extension AppDelegate {

    /// 设置崩溃处理
    func setupCrashHandler() {
        let installation = makeEmailInstallation()
        let config = KSCrashConfiguration()
        try? installation.install(with: config)

        installation.sendAllReports { array, error in
            if array?.isNotEmpty == true {
                print("Sent \(array?.count ?? 0) reports")
            } else {
                let store = try? CrashReportStore.init(configuration: CrashReportStoreConfiguration())
                store?.deleteAllReports()
                print("Failed to send reports: \(error.debugDescription)")
            }
        }
    }

    private func makeEmailInstallation() -> CrashInstallation {
        let emailAddress = "zhujilong1987@163.com"
        let email = CrashInstallationEmail.shared
        email.recipients = [emailAddress]
        email.subject = "Crash Report"
        email.message = "This is a crash report"
        email.filenameFmt = "crash-report-%d.txt.gz"

        email.addConditionalAlert(
            withTitle: "Crash Detected",
            message: "The app crashed last time it was launched. Send a crash report?",
            yesAnswer: "Sure!",
            noAnswer: "No thanks"
        )

        email.setReportStyle(.JSON, useDefaultFilenameFormat: true)

        return email
    }
}
