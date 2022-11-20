//
//  MCService.swift
//  SecretPine
//
//  Created by National Team on 12.11.2022.
//

import MultipeerConnectivity
import Combine

enum MCEvent: Codable {
  case message(message: Message), messages(messages: [Message])
}

private extension String {
  static let serviceType = "secret-pine-app"
}

class MCService: NSObject, ObservableObject {
  static let shared = MCService()
  
  var isHost = false
  var displayName: String = UIDevice.current.name
  
  var onDidReceivedEvent: ((MCEvent) -> Void)?
  
  @Published private(set) var foundPeers = Set<MCPeerID>()
  @Published private(set) var connectedPeers = Set<MCPeerID>()
  @Published private(set) var state: MCSessionState?
  
  private var peerID: MCPeerID?
  private var session: MCSession?
  private var advertiser: MCNearbyServiceAdvertiser?
  private var browser: MCNearbyServiceBrowser?
  
  @Published private(set) var messages: [Message] = []
  
  private override init() {
    if let data = UserDefaults.standard.data(forKey: "messages"),
       let messages = try? JSONDecoder().decode([Message].self, from: data) {
      self.messages = messages
    }
  }
  
  func start() {
    let peerID = MCPeerID(displayName: displayName)
    self.peerID = peerID
    
    foundPeers.removeAll()
    connectedPeers.removeAll()
    
    session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
    session?.delegate = self
    
    advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: .serviceType)
    advertiser?.delegate = self
    
    browser = MCNearbyServiceBrowser(peer: peerID, serviceType: .serviceType)
    browser?.delegate = self
    
    startObserving()
  }
  
  func startObserving() {
    if isHost {
      advertiser?.startAdvertisingPeer()
    } else {
      browser?.startBrowsingForPeers()
    }
  }
  
  func invite(peer: MCPeerID) {
    guard let session = session else { return }
    state = nil
    browser?.invitePeer(peer, to: session, withContext: nil, timeout: 10)
  }
  
  func send(event: MCEvent, peer: MCPeerID? = nil) {
    guard let data = try? JSONEncoder().encode(event) else {
      return
    }

    do {
      let peers: [MCPeerID]
      if let peer = peer {
        peers = [peer]
      } else {
        peers = Array(connectedPeers)
      }
      try session?.send(data, toPeers: peers, with: .reliable)
    } catch {
      print(error)
    }
  }
  
  func disconnect() {
    session?.disconnect()
    state = nil
  }
}

// MARK: - MCSessionDelegate

extension MCService: MCSessionDelegate {
  func session(_ session: MCSession,
               peer peerID: MCPeerID,
               didChange state: MCSessionState) {
    if isHost || peerID.displayName == Constants.hostName {
      self.state = state
    }
    
    if state == .notConnected {
      session.disconnect()
    }
    
    if state == .connected {
      connectedPeers.insert(peerID)
      
      if isHost {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self.send(event: .messages(messages: self.messages), peer: peerID)
        }
        //print("messages:::", peerID, messages)
      }
    }
  }
  
  func session(_ session: MCSession,
               didReceive data: Data,
               fromPeer peerID: MCPeerID) {
    guard let event = try? JSONDecoder().decode(MCEvent.self, from: data) else {
      return
    }
    if case .message(let message) = event, isHost {
      messages.append(message)
      if let data = try? JSONEncoder().encode(messages) {
        UserDefaults.standard.set(data, forKey: "messages")
      }
      send(event: .messages(messages: messages))
    } else {
      onDidReceivedEvent?(event)
      print("received:::", event)
    }
  }
  
  func session(_ session: MCSession,
               didReceive stream: InputStream,
               withName streamName: String,
               fromPeer peerID: MCPeerID) {
    
  }
  
  func session(_ session: MCSession,
               didStartReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID,
               with progress: Progress) {
    
  }
  
  func session(_ session: MCSession,
               didFinishReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID,
               at localURL: URL?,
               withError error: Error?) {
    
  }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MCService: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                  didReceiveInvitationFromPeer peerID: MCPeerID,
                  withContext context: Data?,
                  invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MCService: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    foundPeers.remove(peerID)
  }
  
  func browser(_ browser: MCNearbyServiceBrowser,
               foundPeer peerID: MCPeerID,
               withDiscoveryInfo info: [String : String]?) {
    foundPeers.insert(peerID)
    if !isHost, peerID.displayName == Constants.hostName, (state == nil || state == .notConnected) {
      invite(peer: peerID)
    }
  }
}
