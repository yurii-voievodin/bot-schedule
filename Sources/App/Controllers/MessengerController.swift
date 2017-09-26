//
//  MessengerController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 18.09.17.
//
//

import HTTP
import Vapor
import Foundation

final class MessengerController {
    
    // MARK: - Properties
    
    let client: ClientFactoryProtocol
    let secret: String
    let token: String
    
    // MARK: - Initialization
    
    init(drop: Droplet) throws {
        // Client
        self.client = try drop.config.resolveClient()
        
        // Read Facebook Messenger secret key from Config/secrets/app.json.
        secret = drop.config["app", "messenger", "secret"]?.string ?? ""
        token = drop.config["app", "messenger", "token"]?.string ?? ""
        
        guard secret != "" && token != "" else {
            // Show errors in console.
            drop.console.error("Missing secret or token keys!")
            drop.console.error("Add almost one in Config/secrets/app.json")
            
            // Throw missing secret key error.
            throw MessengerBotError.missingAppSecrets
        }
        
        // Add routes
        
        // Setting up the GET request with Facebook Messenger secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // This is the Step 2 of Facebook Messenger Quick Start guide:
        // https://developers.facebook.com/docs/messenger-platform/guides/quick-start#setup_webhook
        drop.get("webhook", handler: getWebhook)
        
        // Setting up the POST request with Messenger secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // This is the Step 5 of Facebook Messenger Quick Start guide:
        // https://developers.facebook.com/docs/messenger-platform/guides/quick-start#receive_messages
        drop.post("webhook", handler: postWebhook)
    }
    
    func getWebhook(request: Request) throws -> ResponseRepresentable {
        let object = request.query?.object
        
        /// Check for "hub.mode", "hub.verify_token" & "hub.challenge" query parameters.
        guard object?["hub.mode"]?.string == "subscribe" && object?["hub.verify_token"]?.string == secret, let challenge = object?["hub.challenge"]?.string else {
            throw Abort(.badRequest, reason: "Missing Messenger verification data.")
        }
        
        /// Create a response with the challenge query parameter to verify the webhook.
        return Response(status: .ok, headers: ["Content-Type": "text/plain"], body: challenge)
    }
    
    func postWebhook(request: Request) throws -> ResponseRepresentable {
        /// Check that the request comes from a "page".
        guard request.json?["object"]?.string == "page" else {
            /// Throw an abort response, with a custom message.
            throw Abort(.badRequest, reason: "Message not generated by a page.")
        }
        
        let emptyResponseText = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"
        
        /// Prepare the response message text.
        var response: Node = ["text": "Unknown error."]
        
        /// Entries from request JSON.
        let entries: [JSON] = request.json?["entry"]?.array ?? []
        
        /// Iterate over all entries.
        for entry in entries {
            /// Page ID of the entry.
            let _: String = entry.object?["id"]?.string ?? "0"
            /// Messages from entry.
            let messaging: [JSON] = entry.object?["messaging"]?.array ?? []
            
            /// Iterate over all messaging objects.
            for event in messaging {
                /// Message of the event.
                let message: [String: JSON] = event.object?["message"]?.object ?? [:]
                /// Postback of the event.
                let postback: [String: JSON] = event.object?["postback"]?.object ?? [:]
                /// Sender of the event.
                let sender: [String: JSON] = event.object?["sender"]?.object ?? [:]
                /// Sender ID, it is used to make a response to the right user.
                let senderID: String = sender["id"]?.string ?? ""
                /// Text sent to bot.
                let text: String = message["text"]?.string ?? ""
                
                /// Check if is a postback action.
                if !postback.isEmpty {
                    /// Get payload from postback.
                    let payload: String = postback["payload"]?.string ?? "No payload provided by developer."

                    // Auditorium
                    if payload.hasPrefix(ObjectType.auditorium.prefix) {
                        
                        let result = try Auditorium.showForMessenger(for: payload, client: self.client)
                        if result.isEmpty {
                            try self.sendResponse(response: Messenger.message(emptyResponseText), senderID: senderID)
                        } else {
                            for item in result {
                                try self.sendResponse(response: Messenger.message(item), senderID: senderID)
                            }
                        }
                    }
                    /// Check if the message object is empty.
                } else if message.isEmpty {
                    /// Set the response message text.
                    response = Messenger.message("Webhook received unknown event.")
                    /// Check if the message text is empty
                } else if text.isEmpty {
                    /// Set the response message text.
                    response = Messenger.message("I'm sorry but your message is empty 😢")
                    /// The user greeted the bot.
                } else {
                    // Search
                    var responseText = emptyResponseText
                    
                    if text.characters.count <= 3 {
                        responseText = "Мінімальна кількість символів для пошуку рівна 4"
                        response = Messenger.message(responseText)
                    } else {
                        var searchResults: [Button] = []
                        
                        searchResults += try Auditorium.find(by: text)
                        
                        if !searchResults.isEmpty {
                            response = try Messenger.buttons(searchResults, title: "Аудиторії")
                        } else {
                            response = Messenger.message(responseText)
                        }
                    }
                }
            }
        }
        
        /// Sending an HTTP 200 OK response is required.
        /// https://developers.facebook.com/docs/messenger-platform/webhook-reference#response
        /// The header is added just to mute a Vapor warning.
        return Response(status: .ok, headers: ["Content-Type": "application/json"])
    }
    
    fileprivate func sendResponse(response: Node, senderID: String) throws {
        /// Creating the response JSON data bytes.
        /// At Step 6 of Facebook Messenger Quick Start guide, using Node.js demo, they told you to send back the "recipient.id", but the correct one is "sender.id".
        /// https://developers.facebook.com/docs/messenger-platform/guides/quick-start#send_text_message
        var responseData: JSON = JSON()
        try responseData.set("recipient", ["id": senderID])
        try responseData.set("message", response)
        
        /// Calling the Facebook API to send the response.
        let _: Response = try self.client.post("https://graph.facebook.com/v2.9/me/messages", query: ["access_token": token], ["Content-Type": "application/json"], Body.data(responseData.makeBytes()))
    }
}
