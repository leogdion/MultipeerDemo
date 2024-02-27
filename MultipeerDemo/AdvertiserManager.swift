//
//  AdvertiserManager.swift
//  MultipeerDemo
//
//  Created by Leo on 2/27/24.
//

import Foundation
import MultipeerConnectivity

class AdvertiserManager : NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate,  MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session \(session.myPeerID) with \(peerID) chaged state to \(state)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("session \(session.myPeerID) with \(peerID) received \(data.count)")
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
