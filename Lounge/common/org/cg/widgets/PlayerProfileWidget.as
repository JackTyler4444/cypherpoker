/**
* Used to manage the local (self) player's profile information.
* 
* This implementation uses a simple delay timer to establish the leader/dealer role.
*
* (C)opyright 2014 to 2017
*
* This source code is protected by copyright and distributed under license.
* Please see the root LICENSE file for terms and conditions.
*
*/

package org.cg.widgets {
	
	import feathers.controls.TextInput;	
	import flash.net.FileFilter;
	import org.cg.events.LoungeEvent;
	import org.cg.interfaces.ILounge;
	import org.cg.interfaces.IPanelWidget;
	import org.cg.SlidingPanel;
	import starling.events.Event;
	import feathers.events.FeathersEventType;
	import feathers.controls.Button;
	import org.cg.GlobalSettings;
	import org.cg.DebugView;
	import flash.filesystem.File;
		
	public class PlayerProfileWidget extends PanelWidget implements IPanelWidget {
		
		private var _iconFileBrowser:File; //file instance used to select and load profile icon image
		//UI components generated by StarlingViewManager:
		public var updatePlayerIconButton:Button;
		public var playerHandleInput:TextInput;
		
		/**
		 * Creates a new instance.
		 * 
		 * @param	loungeRef A reference to the main ILounge implementation instance.
		 * @param	panelRef A reference to the parent or containing SlidingPanel instance.
		 * @param	widgetData The widget's configuration data, usually from the global settings data.
		 */
		public function PlayerProfileWidget(loungeRef:ILounge, panelRef:SlidingPanel, widgetData:XML) {
			DebugView.addText("PlayerProfileWidget created");
			super(loungeRef, panelRef, widgetData);			
		}
		
		/**
		 * Initializes the new instance after it's been added to the display list and all child components have been fully created.
		 */
		override public function initialize():void {
			DebugView.addText("PlayerProfileWidget.initialize");
			this.updatePlayerIconButton.addEventListener(Event.TRIGGERED, this.onUpdatePlayerIconClick);
			if (lounge.currentPlayerProfile.iconLoaded) {
				this.updateProfileInfo(null);
			}
			lounge.addEventListener(LoungeEvent.UPDATED_PLAYERPROFILE, this.updateProfileInfo);
			this.playerHandleInput.addEventListener(FeathersEventType.FOCUS_OUT, this.onPlayerHandleInputLoseFocus);
		}
		
		/**
		 * Event listener invoked when the player icon button has been clicked, opening up a file selection dialog to allow
		 * the user to select a new player icon.
		 * 
		 * @param	eventObj An Event object.
		 */
		private function onUpdatePlayerIconClick(eventObj:Event):void {
			this._iconFileBrowser = File.desktopDirectory;
			this._iconFileBrowser.addEventListener("select", this.onIconFileSelect);
			var fileFilter:FileFilter = new FileFilter("Image", "*.jpg;*.png;*.gif");
			this._iconFileBrowser.browseForOpen("Select icon image", [fileFilter]);
		}
		
		/**
		 * Event listener invoked when the file open dialog has been closed with an icon file selected. The path to the newly-selected icon
		 * file is saved to the global settings.
		 * 
		 * @param	eventObj A generic "Event" object (used to prevent namespace collisions with Starling events).
		 */
		private function onIconFileSelect(eventObj:Object):void {
			this._iconFileBrowser.removeEventListener("select", this.onIconFileSelect);
			lounge.currentPlayerProfile.profileData.child("icon")[0].replace("*", new XML("<![CDATA[" + this._iconFileBrowser.nativePath + "]]>"));			
			GlobalSettings.saveSettings();
			lounge.currentPlayerProfile.load();
		}
		
		/**
		 * Updates the profile UI with the current icon image and player handle.
		 * 
		 * @param	eventObj A LoungeEvent object.
		 */
		private function updateProfileInfo(eventObj:LoungeEvent):void {			
			this.updatePlayerIconButton.defaultIcon = lounge.currentPlayerProfile.newIconImage;
			this.updatePlayerIconButton.invalidate();
			this.playerHandleInput.text = lounge.currentPlayerProfile.profileHandle;
		}
		
		/**
		 * Event listener invoked when the "player handle" text input field loses focus causing the data entered into the field to be
		 * save to the global settings.
		 * 
		 * @param	eventObj An Event object.
		 */
		private function onPlayerHandleInputLoseFocus(eventObj:Event):void {
			lounge.currentPlayerProfile.profileData.child("handle")[0].replace("*", new XML("<![CDATA[" + this.playerHandleInput.text + "]]>"));
			GlobalSettings.saveSettings();
			lounge.currentPlayerProfile.load();
		}
	}
}