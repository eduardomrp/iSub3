//
//  SwipeAction.swift
//  iSub
//
//  Created by Benjamin Baron on 11/11/20.
//  Copyright © 2020 Ben Baron. All rights reserved.
//

import UIKit

@objc class SwipeAction: NSObject {
    @objc static func downloadAndQueueConfig(model: TableCellModel) -> UISwipeActionsConfiguration {
        let config = UISwipeActionsConfiguration.init(actions: [download(model: model), queue(model: model)])
        config.performsFirstActionWithFullSwipe = false;
        return config;
    }
    
    @objc static func downloadQueueAndDeleteConfig(model: TableCellModel, deleteHandler: @escaping () -> ()) -> UISwipeActionsConfiguration {
        let config = UISwipeActionsConfiguration.init(actions: [download(model: model), queue(model: model), delete(handler: deleteHandler)])
        config.performsFirstActionWithFullSwipe = false;
        return config;
    }
    
    @objc static func downloadQueueAndDeleteConfig(downloadHandler: (() -> ())?, queueHandler: (() -> ())?, deleteHandler: (() -> ())?) -> UISwipeActionsConfiguration {
        var actions = [UIContextualAction]()
        if let downloadHandler = downloadHandler {
            actions.append(download(handler: downloadHandler))
        }
        if let queueHandler = queueHandler {
            actions.append(queue(handler: queueHandler))
        }
        if let deleteHandler = deleteHandler {
            actions.append(delete(handler: deleteHandler))
        }
        
        let config = UISwipeActionsConfiguration.init(actions: actions)
        config.performsFirstActionWithFullSwipe = false;
        return config;
    }
    
    @objc static func download(model: TableCellModel) -> UIContextualAction {
        return download(handler: {
            model.download()
        })
    }
    
    @objc static func queue(model: TableCellModel) -> UIContextualAction {
        return queue(handler: {
            model.queue()
        })
    }
    
    @objc static func download(handler: @escaping () -> ()) -> UIContextualAction {
        let action = UIContextualAction.init(style: .normal, title: "Download") { _, _, completionHandler in
            handler()
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return action
    }
    
    @objc static func queue(handler: @escaping () -> ()) -> UIContextualAction {
        let action = UIContextualAction.init(style: .normal, title: "Queue") { _, _, completionHandler in
            handler()
            completionHandler(true)
        }
        action.backgroundColor = .systemGreen
        return action
    }
    
    @objc static func delete(handler: @escaping () -> ()) -> UIContextualAction {
        let action = UIContextualAction.init(style: .normal, title: "Delete") { _, _, completionHandler in
            handler()
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return action
    }
}
