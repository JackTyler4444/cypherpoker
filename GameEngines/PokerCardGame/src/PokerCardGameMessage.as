/**
* Peer message sent and received by PokerCardGame and related instances.
*
* (C)opyright 2014 to 2017
*
* This source code is protected by copyright and distributed under license.
* Please see the root LICENSE file for terms and conditions.
*
*/

package  {	
	
	import p2p3.PeerMessage;
	import p2p3.interfaces.IPeerMessage;
	
	public class PokerCardGameMessage extends PeerMessage {
				
		private static const version:String = "2.0"; //included with each message for future compatibility
		private static const messageHeader:String = "PokerCardGameMessage";
		
		//Game has started.
		public static const GAME_START:String = "PeerMessage.PokerCardGameMessage.GAME_START";		
		//Sent intermitently while player is doing something in the background (encryption, etc.)
		public static const PLAYER_PROGRESS:String = "PeerMessage.PokerCardGameMessage.PLAYER_PROGRESS";
		//Public/shared modulus has been generated by the dealer.
		public static const DEALER_MODGENERATED:String = "PeerMessage.PokerCardGameMessage.DEALER_MODGENERATED";
		//"face-up" cards have been generated by the dealer.
		public static const DEALER_CARDSGENERATED:String = "PeerMessage.PokerCardGameMessage.DEALER_CARDSGENERATED";
		//Dealer or player has completed encrypting cards and is relaying to next target.
		public static const PLAYER_CARDSENCRYPTED:String = "PeerMessage.PokerCardGameMessage.PLAYER_CARDSENCRYPTED";
		//Player is instructed to pick some private cards from the dealer deck (dealer is usually also included).
		public static const DEALER_PICKPRIVATECARDS:String = "PeerMessage.PokerCardGameMessage.DEALER_PICKPRIVATECARDS";
		//Dealer has selected new public/community cards.
		public static const DEALER_PICKPUBLICCARDS:String = "PeerMessage.PokerCardGameMessage.DEALER_PICKPUBLICCARDS";
		//Request to decrypt community / dealer cards. These should become public after final decryption.
		public static const DEALER_DECRYPTCARDS:String = "PeerMessage.PokerCardGameMessage.DEALER_DECRYPTCARDS";
		//"face-up" community cards have been decrypted by the dealer (or player).
		public static const DEALER_CARDSDECRYPTED:String = "PeerMessage.PokerCardGameMessage.DEALER_CARDSDECRYPTED";
		//Request to decrypt player cards. These should be held in private until end of game (unless discarding).
		//Requesting player MUST ALWAYS be the last to decrypt!
		public static const PLAYER_DECRYPTCARDS:String = "PeerMessage.PokerCardGameMessage.PLAYER_DECRYPTCARDS";
		//Comparison deck has been generated as a result of a rekey operation. Final deck is in message to all peers (*).
		public static const PLAYER_DECKRENECRYPTED:String = "PeerMessage.PokerCardGameMessage.PLAYER_DECKRENECRYPTED";
		//Player has chosen not to continue game (at end of round), or game can no longer continue (only one player has chips remaining)
		public static const GAME_END:String = "PeerMessage.PokerCardGameMessage.GAME_END";
		
		private var _pokerMessageType:String;
		
		/**
		 * Creates a PokerCardGameMessage.
		 * 
		 * @param	incomingMessage An optional incoming message to attempt to consume into this instance. If
		 * null or not supplied the "createPokerMessage" function should be called to populate the instance's data.
		 */
		public function PokerCardGameMessage(incomingMessage:*= null) {
			super(incomingMessage);
		}
		
		/**
		 * Validates a (usually incoming) peer message as a valild poker game message.
		 * 
		 * @param	peerMessage The peer message to validate.
		 * 
		 * @return A new instance containing all of the data of the source peer message, or null
		 * if the source peer message can't be validated as a poker game message.
		 */
		public static function validatePokerMessage(peerMessage:IPeerMessage):PokerCardGameMessage {
			if (peerMessage == null) {
				return (null);
			}
			try {
				//must match structure in createPokerMessage...
				var messageType:String = peerMessage.data.type;
				var messageSplit:Array = messageType.split("/");
				var headerStr:String = messageSplit[0] as String;
				var versionStr:String = messageSplit[1] as String;
				var messageTypeStr:String = messageSplit[2] as String;
				if (headerStr != messageHeader) {
					return (null);
				}
				if (versionStr != version) {
					return (null);
				}
				var pcgMessage:PokerCardGameMessage = new PokerCardGameMessage(peerMessage);
				pcgMessage.pokerMessageType = messageTypeStr;
				if ((peerMessage.data["payload"] != undefined) && (peerMessage.data["payload"] != null)) {
					pcgMessage.data = peerMessage.data["payload"];
				}
				pcgMessage.timestampGenerated = peerMessage.timestampGenerated;
				pcgMessage.timestampSent = peerMessage.timestampSent;
				pcgMessage.timestampReceived = peerMessage.timestampReceived;
				return (pcgMessage);
			} catch (err:*) {
				return (null);
			}
			return (null);
		}
		
		/** 
		 * Creates a poker game message (for sending) encapsulated within a standard peer message.
		 * 
		 * @param	messageType The type of poker game message to create,  usually one of the defined class constants.		 
		 * @param	payload An optional payload to include with the message.
		 */
		public function createPokerMessage(messageType:String, payload:*= null):void {
			var dataObj:Object = new Object();
			dataObj.type = messageHeader+"/" + version + "/" + messageType;			
			if (payload != null) {
				dataObj.payload = payload;
			}
			super.data = dataObj;
		}
		
		/**
		 * The message type of this instance, usually one of the defined class constants.
		 */
		public function set pokerMessageType(typeSet:String):void {
			_pokerMessageType = typeSet;
		}
		
		public function get pokerMessageType():String {
			return (_pokerMessageType);
		}
	}
}