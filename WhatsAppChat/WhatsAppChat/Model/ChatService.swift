//
//  ChatService.swift
//  WhatsAppChat
//
//  Created by Anand Suthar on 18/01/19.
//  Copyright © 2019 Anand Suthar. All rights reserved.
//

import Foundation
import Scaledrone

class ChatService {
    private let scaledrone: Scaledrone
    private let messageCallback: (Messagee)-> Void
    
    private var room: ScaledroneRoom?
    
    init(member: Member, onRecievedMessage: @escaping (Messagee)-> Void) {
        self.messageCallback = onRecievedMessage
        self.scaledrone = Scaledrone(
            channelID: "rx97kzxA9bEjs5qf",
            data: member.toJSON)
        scaledrone.delegate = self as ScaledroneDelegate
    }
    
    func connect() {
        scaledrone.connect()
    }
    func sendMessage(_ message: String) {
        room?.publish(message: message)
    }
}
extension ChatService: ScaledroneDelegate {
    func scaledroneDidConnect(scaledrone: Scaledrone, error: NSError?) {
        print("Connected to Scaledrone")
        room = scaledrone.subscribe(roomName: "observable-room")
        room?.delegate = self as? ScaledroneRoomDelegate
    }
    
    func scaledroneDidReceiveError(scaledrone: Scaledrone, error: NSError?) {
        print("Scaledrone error", error ?? "")
    }
    
    func scaledroneDidDisconnect(scaledrone: Scaledrone, error: NSError?) {
        print("Scaledrone disconnected", error ?? "")
    }
}
extension ChatService: ScaledroneRoomDelegate {
    func scaledroneRoomDidConnect(room: ScaledroneRoom, error: NSError?) {
        print("Connected to room!")
    }
    
    func scaledroneRoomDidReceiveMessage(
        room: ScaledroneRoom,
        message: Any,
        member: ScaledroneMember?) {
        
        guard
            let text = message as? String,
            let memberData = member?.clientData,
            let member = Member(fromJSON: memberData)
            else {
                print("Could not parse data.")
                return
        }
        
        let message = Messagee(
            member: member,
            text: text,
            messageId: UUID().uuidString)
        messageCallback(message)
    }
}
