//
//  AdvertiserManager.swift
//  MultipeerDemo
//
//  Created by Leo on 2/27/24.
//

import Foundation
import MultipeerConnectivity
import Combine

struct Item : Codable, Identifiable {
    internal init(sourceID: Int, date: Date) {
        self.id = .init()
        self.sourceID = sourceID
        self.date = date
    }
    
    let sourceID : Int
    let date : Date
    let id : UUID
}

class AdvertiserManager : NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate,  MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session \(session.myPeerID) with \(peerID) chaged state to \(state)")
        
        guard let idString = peerID.displayName.components(separatedBy: .whitespaces).last else {
            return
        }
        
        guard let peerIDInt = Int(idString) else {
            return
        }
        
        switch state {
        case .connected:
            self.peers.formUnion([peerIDInt])
        case .notConnected:
            self.peers.remove(peerIDInt)
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("session \(session.myPeerID) with \(peerID) received \(data.count)")
        guard let item = try? jsonDecoder.decode(Item.self, from: data) else {
            return
        }
        self.items.insert(item, at: 0)
        
        let countToRemove = self.items.count - 5
        
        guard countToRemove > 0 else {
            return
        }
        self.items.removeLast(countToRemove)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("session \(session.myPeerID) with \(peerID) did receive stream \(streamName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
            print("session \(session.myPeerID) with \(peerID) did start receiving resource \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
            print("session \(session.myPeerID) with \(peerID) did start receive resource \(resourceName)")
    }
    
    let id : Int
    let advertiser : MCNearbyServiceAdvertiser
    let browser : MCNearbyServiceBrowser
    let session : MCSession
    
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    @Published var peers = Set<Int>()
    @Published var items = [Item]()
    
    var peersArray : [Int] {
        return .init(peers)
    }
    
    var timerCancellable : AnyCancellable?
    
    var peerID : MCPeerID {
        MCPeerID(displayName: "peer \(id)")
    }
    override init() {
        
        self.id = .random(in: 100...600)
        let peerID = MCPeerID(displayName: "peer \(id)")
        session = MCSession(peer: peerID)
        advertiser = .init(peer: peerID, discoveryInfo: nil, serviceType: "demo")
        browser = .init(peer: peerID, serviceType: "demo")
        super.init()
        advertiser.delegate = self
        browser.delegate = self
        session.delegate = self
        
        
            
    }
    
    func start () {
        self.timerCancellable =
        Timer.publish(every: 1.0, on: .current, in: .common).map {
            Item(sourceID: self.id, date: $0)
        }
        .encode(encoder: jsonEncoder)
        .assertNoFailure()
        .sink { data in
            do {
                try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
            } catch {
                dump(error)
            }
        }
        
        self.browser.startBrowsingForPeers()
        self.advertiser.startAdvertisingPeer()
        
        
    }
    
    func stop () {
        self.browser.stopBrowsingForPeers()
        self.advertiser.stopAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertiser did not strart \(advertiser.serviceType) error: \(error.localizedDescription)")
        dump(error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        session.connectPeer(peerID, withNearbyConnectionData: .init())
        invitationHandler(true, session)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Browser \(browser.serviceType) lost \(peerID.displayName)")
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browser did not strart \(browser.serviceType) error: \(error.localizedDescription)")
        dump(error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Browser \(browser.serviceType) found \(peerID.displayName)")
    }
}
