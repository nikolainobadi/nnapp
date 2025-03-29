//
//  DeleteFolderMethod.swift
//  nnapp
//
//  Created by Nikolai Nobadi on 3/28/25.
//

import Files

public func deleteFolderContents(_ folder: Folder, retries: Int = 0) {
    for file in folder.files {
        do {
            try file.delete()
        } catch {
            print("could not delete file at path", file.path)
            if retries < 3 {
                deleteFolderContents(folder, retries: retries + 1)
            } else {
                fatalError()
            }
        }
    }
    
    for subfolder in folder.subfolders {
        deleteFolderContents(subfolder)
        
        do {
            try subfolder.delete()
        } catch {
            print("could not delete file at path", subfolder.path)
            
            if retries < 3 {
                deleteFolderContents(subfolder, retries: retries + 1)
            } else {
                fatalError()
            }
        }
    }
}

