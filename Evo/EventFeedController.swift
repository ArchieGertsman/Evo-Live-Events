//
//  EventFeedController.swift
//  Evo
//
//  Created by Admin on 6/11/17.
//  Copyright © 2017 Evo. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents
import CoreLocation

/* controller which contains an event feed */
class EventFeedController: DatasourceController {
    
    internal let time_mode: Time.Mode // determines how the events are sorted, i.e. by hour or by date
    
    // c-tor which initializes event sorting mode
    required init(time_mode: Time.Mode) {
        self.time_mode = time_mode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // sets the height of each event cell. If the event is the first in its time group
    // then add extra space for the time marker (it's part of the cell)
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if let event = self.datasource?.item(indexPath) as? Event, event.is_first_in_time_group {
            return CGSize(width: view.frame.width, height: EventFeedCell.height + EventFeedTimeMarkerView.height)
        }
        return CGSize(width: view.frame.width, height: EventFeedCell.height)
    }
    
}
