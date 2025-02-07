//
//  ServicesProvider.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-06-23.
//
//  ---------------------------------------------------------------------------
//
//  © 2015-2022 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

final class ServicesProvider: NSObject {
    
    // MARK: Public Methods
    
    /// open new document with string via Services
    @objc func openSelection(_ pboard: NSPasteboard, userData: String, error errorPointer: AutoreleasingUnsafeMutablePointer<NSString?>) {
        
        guard let selection = pboard.string(forType: .string) else { return assertionFailure() }
        
        let document: NSDocument
        do {
            document = try NSDocumentController.shared.openUntitledDocumentAndDisplay(false)
            
        } catch {
            errorPointer.pointee = error.localizedDescription as NSString
            NSApp.presentError(error)
            return
        }
        
        if let document = document as? Document {
            document.textStorage.replaceCharacters(in: NSRange(0..<0), with: selection)
            document.makeWindowControllers()
            document.showWindows()
        }
    }
    
    
    /// open files via Services
    @objc func openFile(_ pboard: NSPasteboard, userData: String, error errorPointer: AutoreleasingUnsafeMutablePointer<NSString?>) {
        
        guard let fileURLs = pboard.readObjects(forClasses: [NSURL.self]) as? [URL] else { return assertionFailure() }
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                for fileURL in fileURLs {
                    group.addTask {
                        do {
                            try await NSDocumentController.shared.openDocument(withContentsOf: fileURL, display: true)
                        } catch {
                            await NSApp.presentError(error)
                        }
                    }
                }
            }
        }
    }
    
}
