// cTab - Commander's Tablet with FBCB2 Blue Force Tracking
// Battlefield tablet to access real time intel and blue force tracker.
// By - Riouken
// http://forums.bistudio.com/member.php?64032-Riouken
// You may re-use any of this work as long as you provide credit back to me.

// keys.sqf parses the userconfig
#include "functions\keys.sqf"
#include "\cTab\shared\cTab_gui_macros.hpp"

//prep the arrays that will hold ctab data
cTabBFTmembers = [];
cTabBFTgroups = [];
cTabBFTvehicles = [];
cTabHcamlist = [];

if (isnil ("cTabSide")) then {cTabSide = west;}; 

// Get a rsc layer for for our displays
cTabrscLayer = ["cTab"] call BIS_fnc_rscLayer;
cTabRscLayerMailNotification = ["cTab_mailNotification"] call BIS_fnc_rscLayer;

/*
 figure out the scaling factor based on the map being played
 on Stratis we have a map scaling factor of 3.125 km per ctrlMapScale
 Stratis map size is 8192 (Altis is 30720)
 8192 / 3.125 = 2621.44
 Divide the actual mapSize by this factor to obtain the scaling factor
 It seems to work fine
 Unfortunately the map size is not configured properly for some custom maps,
 so these have to be hard-coded until that changes.
*/
_mapSize = (getNumber (configFile>>"CfgWorlds">>worldName>>"mapSize"));
if (_mapSize == 0) then {
	switch (worldName) do {
		case "Altis": {_mapSize = 30720};
		case "Bootcamp_ACR": {_mapSize = 3840}; //Bukovina
		case "Chernarus": {_mapSize = 15360};
		case "Desert_E": {_mapSize = 2048}; //Desert
		case "fallujah": {_mapSize = 10240}; //Fallujah
		case "fata": {_mapSize = 10240}; //PR FATA
		case "Intro": {_mapSize = 5120}; //Rahmadi
		case "j198_ftb": {_mapSize = 7168}; //Ft. Benning - US Army Infantry School
		case "mbg_celle2": {_mapSize = 12288}; //Celle 2
		case "Mountains_ACR": {_mapSize = 6400}; //Takistan Mountains
		case "Porto": {_mapSize = 5120}; //Porto
		case "ProvingGrounds_PMC": {_mapSize = 2048}; //Proving Grounds
		case "Sara": {_mapSize = 20480}; //Sahrani
		case "Sara_dbe1": {_mapSize = 20480}; //United Sahrani
		case "SaraLite": {_mapSize = 10240}; //Southern Sahrani
		case "Shapur_BAF": {_mapSize = 2048}; //Shapur
		case "Stratis": {_mapSize = 8192};
		case "Takistan": {_mapSize = 12800};
		case "utes": {_mapSize = 5120}; //Utes
		case "VR": {_mapSize = 8192}; //Virtual Reality
		case "Woodland_ACR": {_mapSize = 7680}; //Bystrica
		case "Zargabad": {_mapSize = 8192};
		default {_mapSize = 8192};
	};
};
cTabMapScaleFactor = _mapSize / 2621.44;
cTabMapScaleUAV = 0.8 / cTabMapScaleFactor;
cTabMapScaleHCam = 0.3 / cTabMapScaleFactor;

cTabDisplayPropertyGroups = [
	["cTab_Tablet_dlg","Tablet"],
	["cTab_Android_dlg","Android"],
	["cTab_Android_dsp","Android"],
	["cTab_FBCB2_dlg","FBCB2"],
	["cTab_TAD_dsp","TAD"],
	["cTab_TAD_dlg","TAD"],
	["cTab_microDAGR_dsp","MicroDAGR"],
	["cTab_microDAGR_dlg","MicroDAGR"]
];

cTabSettings = [];

[cTabSettings,"COMMON",[
	["mode","BFT"],
	["showIconText",true],
	["mapScaleMax",2 ^ round(sqrt(_mapSize / 1024))],
	["mapTypes",[["SAT",IDC_CTAB_SCREEN]]],
	["mapType","SAT"]
]] call BIS_fnc_setToPairs;

[cTabSettings,"Main",[
]] call BIS_fnc_setToPairs;

[cTabSettings,"Tablet",[
	["mode","DESKTOP"],
	["mapTypes",[["SAT",IDC_CTAB_SCREEN],["TOPO",IDC_CTAB_SCREEN_TOPO]]],
	["uavCam",""],
	["hCam",""],
	["mapTools",true]
]] call BIS_fnc_setToPairs;

[cTabSettings,"Android",[
	["mode","BFT"],
	["mapScale",0.4],
	["mapScaleMin",0.1],
	["mapTypes",[["SAT",IDC_CTAB_SCREEN],["TOPO",IDC_CTAB_SCREEN_TOPO]]],
	["showMenu",false],
	["mapTools",true]
]] call BIS_fnc_setToPairs;

[cTabSettings,"FBCB2",[
	["mapTypes",[["SAT",IDC_CTAB_SCREEN],["TOPO",IDC_CTAB_SCREEN_TOPO]]],
	["mapTools",true]
]] call BIS_fnc_setToPairs;

/*
TAD setup
*/
// set icon size of own vehicle on TAD
cTabTADownIconBaseSize = 18;
cTabTADownIconScaledSize = cTabTADownIconBaseSize / (0.86 / (safezoneH * 0.8));
// set TAD font colour to neon green
cTabTADfontColour = [57/255, 255/255, 20/255, 1];
// set TAD group colour to purple
cTabTADgroupColour = [255/255, 0/255, 255/255, 1];
// set TAD highlight colour to neon yellow
cTabTADhighlightColour = [243/255, 243/255, 21/255, 1];

[cTabSettings,"TAD",[
	["mapScale",2],
	["mapScaleMin",2],
	["mapTypes",[["SAT",IDC_CTAB_SCREEN],["TOPO",IDC_CTAB_SCREEN_TOPO],["BLK",IDC_CTAB_SCREEN_BLACK]]],
	["mapType","SAT"],
	["mapTools",true]
]] call BIS_fnc_setToPairs;

/*
microDAGR setup
*/
// set MicroDAGR font colour to neon green
cTabMicroDAGRfontColour = [57/255, 255/255, 20/255, 1];
// set MicroDAGR group colour to purple
cTabMicroDAGRgroupColour = [25/255, 25/255, 112/255, 1];
// set MicroDAGR highlight colour to neon yellow
cTabMicroDAGRhighlightColour = [243/255, 243/255, 21/255, 1];

[cTabSettings,"MicroDAGR",[
	["mapScale",0.4],
	["mapScaleMin",0.1],
	["mapTypes",[["SAT",IDC_CTAB_SCREEN],["TOPO",IDC_CTAB_SCREEN_TOPO]]],
	["mapTools",true]
]] call BIS_fnc_setToPairs;

// set base colors from BI -- Helps keep colors matching if user changes colors in options.
_r = profilenamespace getvariable ['Map_BLUFOR_R',0];
_g = profilenamespace getvariable ['Map_BLUFOR_G',0.8];
_b = profilenamespace getvariable ['Map_BLUFOR_B',1];
_a = profilenamespace getvariable ['Map_BLUFOR_A',0.8];
cTabColorBlue = [_r,_g,_b,_a];

_r = profilenamespace getvariable ['Map_OPFOR_R',0];
_g = profilenamespace getvariable ['Map_OPFOR_G',1];
_b = profilenamespace getvariable ['Map_OPFOR_B',1];
_a = profilenamespace getvariable ['Map_OPFOR_A',0.8];
cTabColorRed = [_r,_g,_b,_a];

_r = profilenamespace getvariable ['Map_Independent_R',0];
_g = profilenamespace getvariable ['Map_Independent_G',1];
_b = profilenamespace getvariable ['Map_Independent_B',1];
_a = profilenamespace getvariable ['Map_OPFOR_A',0.8];
cTabColorGreen = [_r,_g,_b,_a];

// define vehicles that have FBCB2 monitor
if (isNil "cTab_vehicleClass_has_FBCB2") then {
	if (!isNil "cTab_vehicleClass_has_FBCB2_server") then {
		cTab_vehicleClass_has_FBCB2 = cTab_vehicleClass_has_FBCB2_server;
	} else {
		cTab_vehicleClass_has_FBCB2 = ["MRAP_01_base_F","MRAP_02_base_F","MRAP_03_base_F","Wheeled_APC_F","Tank","Truck_01_base_F","Truck_03_base_F"];
	};
};
// strip list of invalid config names and duplicates to save time checking through them later
_classNames = [];
{
	if (isClass (configfile >> "CfgVehicles" >> _x) && _classNames find _x == -1) then {
		0 = _classNames pushBack _x;
	};
} count cTab_vehicleClass_has_FBCB2;
cTab_vehicleClass_has_FBCB2 = [] + _classNames;

// define vehicles that have TAD
if (isNil "cTab_vehicleClass_has_TAD") then {
	if (!isNil "cTab_vehicleClass_has_TAD_server") then {
		cTab_vehicleClass_has_TAD = cTab_vehicleClass_has_TAD_server;
	} else {
		cTab_vehicleClass_has_TAD = ["Helicopter","Plane"];
	};
};
// strip list of invalid config names and duplicates to save time checking through them later
_classNames = [];
{
	if (isClass (configfile >> "CfgVehicles" >> _x) && _classNames find _x == -1) then {
		0 = _classNames pushBack _x;
	};
} count cTab_vehicleClass_has_TAD;
cTab_vehicleClass_has_TAD = [] + _classNames;

// define items that enable head cam
if (isNil "cTab_helmetClass_has_HCam") then {
	if (!isNil "cTab_helmetClass_has_HCam_server") then {
		cTab_helmetClass_has_HCam = cTab_helmetClass_has_HCam_server;
	} else {
		cTab_helmetClass_has_HCam = ["H_HelmetB_light","H_Helmet_Kerry","H_HelmetSpecB","H_HelmetO_ocamo","BWA3_OpsCore_Fleck_Camera","BWA3_OpsCore_Schwarz_Camera","BWA3_OpsCore_Tropen_Camera"];
	};
};
// strip list of invalid config names and duplicates to save time checking through them later
_classNames = [];
{
	if (isClass (configfile >> "CfgWeapons" >> _x) && _classNames find _x == -1) then {
		0 = _classNames pushBack _x;
	};
} count cTab_helmetClass_has_HCam;
// iterate through all class names and add child classes, so we end up with a list of helmet classes that have the defined helmet classes as parents
{
	_childClasses = "inheritsFrom _x == (configfile >> 'CfgWeapons' >> '" + _x + "')" configClasses (configfile >> "CfgWeapons");
	{
		_childClassName = configName _x;
		if (_classNames find _childClassName == -1) then {
			0 = _classNames pushBack configName _x;
		};
	} count _childClasses;
} forEach _classNames;
cTab_helmetClass_has_HCam = [] + _classNames;

// add cTab_FBCB2_updatePulse event handler triggered periodically by the server
["cTab_FBCB2_updatePulse",cTab_fnc_updateLists] call CBA_fnc_addEventHandler;

// fnc to set various text and icon sizes
cTab_fnc_update_txt_size = {
	cTabIconSize = cTabTxtFctr * 2;
	cTabIconManSize = cTabIconSize * 0.75;
	cTabGroupOverlayIconSize = cTabIconSize * 1.625;
	cTabUserMarkerArrowSize = cTabTxtFctr * 8 * cTabMapScaleFactor;
	cTabTxtSize = cTabTxtFctr / 12 * 0.035;
	cTabAirContactGroupTxtSize = cTabTxtFctr / 12 * 0.060;
	cTabAirContactSize = cTabTxtFctr / 12 * 32;
	cTabAirContactDummySize = cTabTxtFctr / 12 * 20;
};
// Beginning text and icon size
cTabTxtFctr = 12;
call cTab_fnc_update_txt_size;
cTabBFTtxt = true;

// Draw Map Tolls (Hook)
cTabDrawMapTools = false;

// fnc to pre-Calculate TAD and MicroDAGR map scales
cTab_fnc_update_mapScaleFactor = {
	cTabTADmapScaleCtrl = (["cTab_TAD_dsp","mapScale"] call cTab_fnc_getSettings) / cTabMapScaleFactor;
	cTabMicroDAGRmapScaleCtrl = (["cTab_microDAGR_dsp","mapScale"] call cTab_fnc_getSettings) / cTabMapScaleFactor;
	cTabAndroidMapScaleCtrl = (["cTab_Android_dsp","mapScale"] call cTab_fnc_getSettings) / cTabMapScaleFactor;
	true
};
call cTab_fnc_update_mapScaleFactor;

// Base defines.
cTabUserIconList = [];
cTabUavViewActive = false;
cTabUAVcams = [];
cTabUavScriptHandle = scriptNull;
cTabCursorOnMap = false;
cTabMapCursorPos = [0,0];

// Initialize all uiNamespace variables
uiNamespace setVariable ["cTab_Tablet_dlg", displayNull];
uiNamespace setVariable ["cTab_Android_dlg", displayNull];
uiNamespace setVariable ["cTab_Android_dsp", displayNull];
uiNamespace setVariable ["cTab_FBCB2_dlg", displayNull];
uiNamespace setVariable ["cTab_TAD_dsp", displayNull];
uiNamespace setVariable ["cTab_TAD_dlg", displayNull];
uiNamespace setVariable ["cTab_microDAGR_dsp", displayNull];
uiNamespace setVariable ["cTab_microDAGR_dlg", displayNull];

// Set up the array that will hold text messages.
player setVariable ["ctab_messages",[]];

/*
Function handling post dialog / display load handling (register event handlers)
Parameter 0: Interface type, 0 = Main, 1 = Secondary
Parameter 1: Unit to register killed eventhandler for
Parameter 2: Vehicle to register GetOut eventhandler for
Parameter 3: Name of uiNameSpace variable for display / dialog (i.e. "cTab_Tablet_dlg")
No return

This function will define cTabIfOpen, using the following format:
Parameter 0: Interface type, 0 = Main, 1 = Secondary
Parameter 1: Name of uiNameSpace variable for display / dialog (i.e. "cTab_Tablet_dlg")
Parameter 2: Unit we registered the killed eventhandler for
Parameter 3: ID of registered eventhandler for killed event
Optional (only if unit is in a vehicle):
Parameter 4: Vehicle we registered the GetOut eventhandler for
Parameter 5: ID of registered eventhandler for GetOut event
*/
cTab_fnc_onIfOpen = {
	_interfaceType = _this select 0;
	_player = _this select 1;
	_vehicle = _this select 2;
	_interfaceName = _this select 3;
	_playerKilledEhId = _player addEventHandler ["killed",{call cTab_fnc_close}];
	if (_vehicle != _player) then {
		_vehicleGetOutEhId = _vehicle addEventHandler ["GetOut",{call cTab_fnc_close}];
		cTabIfOpen = [_interfaceType,_interfaceName,_player,_playerKilledEhId,_vehicle,_vehicleGetOutEhId];
	} else {
		cTabIfOpen = [_interfaceType,_interfaceName,_player,_playerKilledEhId,_vehicle,nil];
	};
	// move mouse cursor to the center of the screen if its a dialog
	if ([_interfaceName] call cTab_fnc_isDialog) then {
		setMousePosition [0.5,0.5];
	};
	call cTab_fnc_updateInterface;
};

/*
Function handling IF_Main keydown event
Based on player equipment and the vehicle type he might be in, open or close a cTab device as Main interface.
No Parameters
Returns TRUE when action was taken (interface opened or closed)
Returns FALSE when no action was taken (i.e. player has no cTab device / is not in cTab enabled vehicle)
*/
cTab_fnc_onIfMainPressed = {
	if (cTabUavViewActive) exitWith {
		objNull remoteControl ((crew cTabActUav) select 1);
		player switchCamera 'internal';
		cTabUavViewActive = false;
		true
	};
	if (!isNil "cTabIfOpen" && {cTabIfOpen select 0 == 0}) exitWith {
		// close Main
		call cTab_fnc_close;
		true
	};
	if !(isNil "cTabIfOpen") then {
		// close Secondary / Tertiary
		call cTab_fnc_close;
	};
	_player = player;
	_vehicle = vehicle _player;
	
	if ([_player,_vehicle,"TAD"] call cTab_fnc_unitInEnabledVehicleSeat) exitWith {
		cTabPlayerVehicleIcon = getText (configFile/"CfgVehicles"/typeOf _vehicle/"Icon");
		nul = [0,_player,_vehicle] execVM "cTab\TAD\cTab_TAD_display_start.sqf";
		true
	};
	
	if ([_player,["ItemAndroid"]] call cTab_fnc_checkGear) exitWith {
		nul = [0,_player,_vehicle] execVM "cTab\android\cTab_android_display_start.sqf";
		true
	};
	
	if ([_player,["ItemMicroDAGR"]] call cTab_fnc_checkGear) exitWith {
		nul = [0,_player,_vehicle] execVM "cTab\microDAGR\cTab_microDAGR_display_start.sqf";
		true
	};
	
	if ([_player,["ItemcTab"]] call cTab_fnc_checkGear) exitWith {
		nul = [0,_player,_vehicle] execVM "cTab\tablet\cTab_Tablet_dialog_start.sqf";
		true
	};
	
	if ([_player,_vehicle,"FBCB2"] call cTab_fnc_unitInEnabledVehicleSeat) exitWith {
		nul = [0,_player,_vehicle] execVM "cTab\FBCB2\cTab_FBCB2_dialog_start.sqf";
		true
	};
	
	false
};

/*
Function handling IF_Secondary keydown event
Based on player equipment and the vehicle type he might be in, open or close a cTab device as Secondary interface.
No Parameters
Returns TRUE when action was taken (interface opened or closed)
Returns FALSE when no action was taken (i.e. player has no cTab device / is not in cTab enabled vehicle)
*/
cTab_fnc_onIfSecondaryPressed = {
	if (cTabUavViewActive) exitWith {
		objNull remoteControl ((crew cTabActUav) select 1);
		player switchCamera 'internal';
		cTabUavViewActive = false;
		true
	};
	if (!isNil "cTabIfOpen" && {cTabIfOpen select 0 == 1}) exitWith {
		// close Secondary
		call cTab_fnc_close;
		true
	};
	if !(isNil "cTabIfOpen") then {
		// close Main / Tertiary
		call cTab_fnc_close;
	};
	_player = player;
	_vehicle = vehicle _player;
	if ([_player,_vehicle,"TAD"] call cTab_fnc_unitInEnabledVehicleSeat) exitWith {
		cTabPlayerVehicleIcon = getText (configFile/"CfgVehicles"/typeOf _vehicle/"Icon");
		nul = [1,_player,_vehicle] execVM "cTab\TAD\cTab_TAD_dialog_start.sqf";
		true
	};
	if ([_player,["ItemAndroid"]] call cTab_fnc_checkGear) exitWith {
		call {
			if ([_player,["ItemcTab"]] call cTab_fnc_checkGear) exitWith {
				nul = [1,_player,_vehicle] execVM "cTab\tablet\cTab_Tablet_dialog_start.sqf";
			};
			if ([_player,_vehicle,"FBCB2"] call cTab_fnc_unitInEnabledVehicleSeat) exitWith {
				nul = [1,_player,_vehicle] execVM "cTab\FBCB2\cTab_FBCB2_dialog_start.sqf";
			};
			nul = [1,_player,_vehicle] execVM "cTab\android\cTab_android_dialog_start.sqf";
		};
		true
	};
	if ([_player,["ItemMicroDAGR"]] call cTab_fnc_checkGear) exitWith {
		call {
			if ([_player,["ItemcTab"]] call cTab_fnc_checkGear) exitWith {
				nul = [1,_player,_vehicle] execVM "cTab\tablet\cTab_Tablet_dialog_start.sqf";
			};
			if ([_player,_vehicle,"FBCB2"] call cTab_fnc_unitInEnabledVehicleSeat) exitWith {
				nul = [1,_player,_vehicle] execVM "cTab\FBCB2\cTab_FBCB2_dialog_start.sqf";
			};
			nul = [1,_player,_vehicle] execVM "cTab\microDAGR\cTab_microDAGR_dialog_start.sqf";
		};
		true
	};
	false
};

/*
Function handling IF_Tertiary keydown event
Based on player equipment and the vehicle type he might be in, open or close a cTab device as Tertiary interface.
No Parameters
Returns TRUE when action was taken (interface opened or closed)
Returns FALSE when no action was taken (i.e. player has no cTab device / is not in cTab enabled vehicle)
*/
cTab_fnc_onIfTertiaryPressed = {
	if (cTabUavViewActive) exitWith {
		objNull remoteControl ((crew cTabActUav) select 1);
		player switchCamera 'internal';
		cTabUavViewActive = false;
		true
	};
	if (!isNil "cTabIfOpen" && {cTabIfOpen select 0 == 2}) exitWith {
		// close Tertiary
		call cTab_fnc_close;
		true
	};
	if !(isNil "cTabIfOpen") then {
		// close Main / Secondary
		call cTab_fnc_close;
	};
	_player = player;
	_vehicle = vehicle _player;
	if ([_player,_vehicle,"TAD"] call cTab_fnc_unitInEnabledVehicleSeat) exitWith {
		call {	
			if ([_player,["ItemcTab"]] call cTab_fnc_checkGear) exitWith {
				nul = [2,_player,_vehicle] execVM "cTab\tablet\cTab_Tablet_dialog_start.sqf";
			};
			if ([_player,["ItemAndroid"]] call cTab_fnc_checkGear) exitWith {
				nul = [2,_player,_vehicle] execVM "cTab\android\cTab_android_dialog_start.sqf";
			};
		};
		true
	};
	false
};

/*
Function handling Zoom_In keydown event
If supported cTab interface is visible, decrease map scale
Returns TRUE when action was taken
Returns FALSE when no action was taken (i.e. no interface open, or unsupported interface)
*/
cTab_fnc_onZoomInPressed = {
	if (isNil "cTabIfOpen") exitWith {false};
	_displayName = cTabIfOpen select 1;
	if (_displayName in ["cTab_TAD_dsp","cTab_microDAGR_dsp","cTab_Android_dsp"]) exitWith {
		_mapScale = [_displayName,"mapScale"] call cTab_fnc_getSettings;
		_mapScaleMin = [_displayName,"mapScaleMin"] call cTab_fnc_getSettings;
		if (_mapScale / 2 > _mapScaleMin) then {
			_mapScale = _mapScale / 2;
		} else {
			_mapScale = _mapScaleMin;
		};
		_mapScale = [_displayName,[["mapScale",_mapScale]]] call cTab_fnc_setSettings;
		call cTab_fnc_update_mapScaleFactor;
		true
	};
	false
};

/*
Function handling Zoom_Out keydown event
If supported cTab interface is visible, increase map scale
Returns TRUE when action was taken
Returns FALSE when no action was taken (i.e. no interface open, or unsupported interface)
*/
cTab_fnc_onZoomOutPressed = {
	if (isNil "cTabIfOpen") exitWith {false};
	_displayName = cTabIfOpen select 1;
	if (_displayName in ["cTab_TAD_dsp","cTab_microDAGR_dsp","cTab_Android_dsp"]) exitWith {
		_mapScale = [_displayName,"mapScale"] call cTab_fnc_getSettings;
		_mapScaleMax = [_displayName,"mapScaleMax"] call cTab_fnc_getSettings;
		if (_mapScale * 2 < _mapScaleMax) then {
			_mapScale = _mapScale * 2;
		} else {
			_mapScale = _mapScaleMax;
		};
		_mapScale = [_displayName,[["mapScale",_mapScale]]] call cTab_fnc_setSettings;
		call cTab_fnc_update_mapScaleFactor;
		true
	};
	false
};

/*
Function to close cTab interface
This function will close the currently open interface and remove any previously registered eventhandlers.
No Parameters.
No Return.
*/
cTab_fnc_close = {
	if (!isNil "cTabIfOpen") then {
		// [_ifType,_displayName,_player,_playerKilledEhId,_vehicle,_vehicleGetOutEhId]
		_ifType = cTabIfOpen select 0;
		_displayName = cTabIfOpen select 1;
		_player = cTabIfOpen select 2;
		_playerKilledEhId = cTabIfOpen select 3;
		_vehicle = cTabIfOpen select 4;
		_vehicleGetOutEhId = cTabIfOpen select 5;
		
		_display = uiNamespace getVariable _displayName;
		if (!isNil "_display") then {
			_display closeDisplay 0;
			uiNamespace setVariable [_displayName, displayNull];
		};
		if (!isNil "_playerKilledEhId") then {_player removeEventHandler ["killed",_playerKilledEhId]};
		if (!isNil "_vehicleGetOutEhId") then {_vehicle removeEventHandler ["GetOut",_vehicleGetOutEhId]};
		call cTab_fnc_deleteHelmetCam;
		[] spawn cTab_fnc_deleteUAVcam;
		cTabCursorOnMap = false;
		cTabIfOpen = nil;
	};
};

/*
Function to toggle text next to BFT icons
Parameter 0: String of uiNamespace variable for which to toggle showIconText for
Returns TRUE
*/
cTab_fnc_iconText_toggle = {
	_displayName = _this select 0;
	if (cTabBFTtxt) then {cTabBFTtxt = false} else {cTabBFTtxt = true};
	[_displayName,[["showIconText",cTabBFTtxt]]] call cTab_fnc_setSettings;
	true
};

/*
Function to toggle mapType to the next one in the list of available map types
Parameter 0: String of uiNamespace variable for which to toggle to mapType for
Returns TRUE
*/
cTab_fnc_mapType_toggle = {
	_displayName = _this select 0;
	_mapTypes = [_displayName,"mapTypes"] call cTab_fnc_getSettings;
	_currentMapType = [_displayName,"mapType"] call cTab_fnc_getSettings;
	_currentMapTypeIndex = [_mapTypes,_currentMapType] call BIS_fnc_findInPairs;
	if (_currentMapTypeIndex == count _mapTypes - 1) then {
		[_displayName,[["mapType",_mapTypes select 0 select 0]]] call cTab_fnc_setSettings;
	} else {
		[_displayName,[["mapType",_mapTypes select (_currentMapTypeIndex + 1) select 0]]] call cTab_fnc_setSettings;
	};
	true
};

/*
Function to toggle showMenu
Parameter 0: String of uiNamespace variable for which to toggle showMenu for
Returns TRUE
*/
cTab_fnc_showMenu_toggle = {
	_displayName = _this select 0;
	_showMenu = [_displayName,"showMenu"] call cTab_fnc_getSettings;
	_showMenu = !_showMenu;
	[_displayName,[["showMenu",_showMenu]]] call cTab_fnc_setSettings;
	true
};

/*
Function to toggle mode
Parameter 0: String of uiNamespace variable for which to toggle mode for
Returns TRUE
*/
cTab_fnc_mode_toggle = {
	_displayName = _this select 0;
	_mode = [_displayName,"mode"] call cTab_fnc_getSettings;
	
	call {
		if (_displayName == "cTab_Android_dlg") exitWith {
			call {
				if (_mode != "BFT") exitWith {_mode = "BFT"};
				_mode = "MESSAGE";
			};
		};
	};
	[_displayName,[["mode",_mode]]] call cTab_fnc_setSettings;
	true
};

// fnc to increase icon and text size
cTab_fnc_txt_size_inc = {
	cTabTxtFctr = cTabTxtFctr + 1;
	call cTab_fnc_update_txt_size;
};

// fnc to decrease icon and text size
cTab_fnc_txt_size_dec = {
	if (cTabTxtFctr > 1) then {cTabTxtFctr = cTabTxtFctr - 1};
	call cTab_fnc_update_txt_size;
};

// This is drawn every frame on the tablet. fnc
cTabOnDrawbft = {
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;

	[_cntrlScreen,true] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,0] call cTab_fnc_drawBftMarkers;
	
	// draw directional arrow at own location
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on Tablet
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on Tablet
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on Tablet
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	(_display displayCtrl IDC_CTAB_OSD_DIR_OCTANT) ctrlSetText format ["%1",[_heading] call cTab_fnc_degreeToOctant];
	
	// update hook information
	if (cTabDrawMapTools) then {
		[_display,_cntrlScreen,_playerPos,cTabMapCursorPos,0,false] call cTab_fnc_drawHook;
	};
	
	true
};

// This is drawn every frame on the vehicle display. fnc
cTabOnDrawbftVeh = {
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	
	[_cntrlScreen,true] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,0] call cTab_fnc_drawBftMarkers;
	
	// draw directional arrow at own location
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on FBCB2
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on FBCB2
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on FBCB2
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	(_display displayCtrl IDC_CTAB_OSD_DIR_OCTANT) ctrlSetText format ["%1",[_heading] call cTab_fnc_degreeToOctant];
	
	// update hook information
	if (cTabDrawMapTools) then {
		[_display,_cntrlScreen,_playerPos,cTabMapCursorPos,0,false] call cTab_fnc_drawHook;
	};
	
	true
};

// This is drawn every frame on the TAD display. fnc
cTabOnDrawbftTAD = {
	// is disableSerialization really required? If so, not sure this is the right place to call it
	disableSerialization;
	
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	
	// current position
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	// change scale of map and centre to player position
	_cntrlScreen ctrlMapAnimAdd [0, cTabTADmapScaleCtrl, _playerPos];
	ctrlMapAnimCommit _cntrlScreen;
	
	[_cntrlScreen,false] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,1] call cTab_fnc_drawBftMarkers;
	
	// draw vehicle icon at own location
	_cntrlScreen drawIcon [cTabPlayerVehicleIcon,cTabTADfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// draw TAD overlay (two circles, one at full scale, the other at half scale + current heading)
	_cntrlScreen drawIcon ["\cTab\img\TAD_overlay_ca.paa",cTabTADfontColour,_playerPos,250,250,_heading,"",1,cTabTxtSize,"TahomaB"];
	
	// update time on TAD
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on TAD
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on TAD
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	
	// update current elevation (ASL) on TAD
	(_display displayCtrl IDC_CTAB_OSD_ELEVATION) ctrlSetText format ["%1m",[round (_playerPos select 2),3] call CBA_fnc_formatNumber];
	
	true
};

// This is drawn every frame on the TAD dialog. fnc
cTabOnDrawbftTADdialog = {
	// is disableSerialization really required? If so, not sure this is the right place to call it
	disableSerialization;
	
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	
	[_cntrlScreen,true] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,1] call cTab_fnc_drawBftMarkers;
	
	// draw vehicle icon at own location
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_cntrlScreen drawIcon [cTabPlayerVehicleIcon,cTabTADfontColour,_playerPos,cTabTADownIconScaledSize,cTabTADownIconScaledSize,direction _veh,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on TAD	
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position of the current player position
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on TAD
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	
	// update current elevation (ASL) on TAD
	(_display displayCtrl IDC_CTAB_OSD_ELEVATION) ctrlSetText format ["%1m",[round (_playerPos select 2),3] call CBA_fnc_formatNumber];
	
	// update hook information
	call {
		if (cTabDrawMapTools) exitWith {
			[_display,_cntrlScreen,_playerPos,[_cntrlScreen] call cTab_fnc_ctrlMapCenter,0,true] call cTab_fnc_drawHook;
		};
		[_display,_cntrlScreen,_playerPos,[_cntrlScreen] call cTab_fnc_ctrlMapCenter,1,true] call cTab_fnc_drawHook;
	};
	true
};

// This is drawn every frame on the android dialog. fnc
cTabOnDrawbftAndroid = {
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;

	[_cntrlScreen,true] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,0] call cTab_fnc_drawBftMarkers;
	
	// draw directional arrow at own location
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on android	
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on android
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on android
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	(_display displayCtrl IDC_CTAB_OSD_DIR_OCTANT) ctrlSetText format ["%1",[_heading] call cTab_fnc_degreeToOctant];
	
	// update hook information
	if (cTabDrawMapTools) then {
		[_display,_cntrlScreen,_playerPos,cTabMapCursorPos,0,false] call cTab_fnc_drawHook;
	};
	
	true
};

// This is drawn every frame on the android display. fnc
cTabOnDrawbftAndroidDsp = {
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	
	// change scale of map and centre to player position
	_cntrlScreen ctrlMapAnimAdd [0, cTabAndroidMapScaleCtrl, _playerPos];
	ctrlMapAnimCommit _cntrlScreen;
	
	[_cntrlScreen,true] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,0] call cTab_fnc_drawBftMarkers;
	
	// draw directional arrow at own location
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on android	
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on android
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on android
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	(_display displayCtrl IDC_CTAB_OSD_DIR_OCTANT) ctrlSetText format ["%1",[_heading] call cTab_fnc_degreeToOctant];
	
	true
};

// This is drawn every frame on the microDAGR display. fnc
cTabOnDrawbftmicroDAGRdsp = {
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	
	// current position
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	// change scale of map and centre to player position
	_cntrlScreen ctrlMapAnimAdd [0, cTabMicroDAGRmapScaleCtrl, _playerPos];
	ctrlMapAnimCommit _cntrlScreen;
	
	[_cntrlScreen,false] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,2] call cTab_fnc_drawBftMarkers;
	
	// draw directional arrow at own location
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on MicroDAGR
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on MicroDAGR
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on MicroDAGR
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	(_display displayCtrl IDC_CTAB_OSD_DIR_OCTANT) ctrlSetText format ["%1",[_heading] call cTab_fnc_degreeToOctant];
	
	true
};

// This is drawn every frame on the microDAGR dialog. fnc
cTabOnDrawbftMicroDAGRdlg = {
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	
	// current position
	_veh = vehicle player;
	_playerPos = getPosASL _veh;
	_heading = direction _veh;
	
	[_cntrlScreen,false] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,2] call cTab_fnc_drawBftMarkers;
	
	// draw directional arrow at own location
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,_playerPos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,_heading,"", 1,cTabTxtSize,"TahomaB"];
	
	// update time on MicroDAGR	
	(_display displayCtrl IDC_CTAB_OSD_TIME) ctrlSetText call cTab_fnc_currentTime;
	
	// update grid position on MicroDAGR
	(_display displayCtrl IDC_CTAB_OSD_GRID) ctrlSetText format ["%1", mapGridPosition _playerPos];
	
	// update current heading on MicroDAGR
	(_display displayCtrl IDC_CTAB_OSD_DIR_DEGREE) ctrlSetText format ["%1°",[_heading,3] call CBA_fnc_formatNumber];
	(_display displayCtrl IDC_CTAB_OSD_DIR_OCTANT) ctrlSetText format ["%1",[_heading] call cTab_fnc_degreeToOctant];
	
	// update hook information
	if (cTabDrawMapTools) then {
		[_display,_cntrlScreen,_playerPos,cTabMapCursorPos,0,false] call cTab_fnc_drawHook;
	};
	
	true
};

// This is drawn every frame on the tablet uav screen. fnc
cTabOnDrawUAV = {
	if (isNil 'cTabActUav') exitWith {};
	if (cTabActUav == player) exitWith {};
	
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	_pos = getPosASL cTabActUav;
	
	[_cntrlScreen,false] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,0] call cTab_fnc_drawBftMarkers;
	
	// draw icon at own location
	_veh = vehicle player;
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,getPosASL _veh,cTabTADownIconBaseSize,cTabTADownIconBaseSize,direction _veh,"", 1,cTabTxtSize,"TahomaB"];
	
	// draw icon at UAV location
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabTADhighlightColour,_pos,cTabIconSize,cTabIconSize,0,"",0,cTabTxtSize,"TahomaB"];
	
	_cntrlScreen ctrlMapAnimAdd [0,cTabMapScaleUAV,_pos];
	ctrlMapAnimCommit _cntrlScreen;
	true
};

// This is drawn every frame on the tablet helmet cam screen. fnc
cTabOnDrawHCam = {
	if (isNil 'cTabHcams') exitWith {};
	_camHost = cTabHcams select 2;
	
	_cntrlScreen = _this select 0;
	_display = ctrlParent _cntrlScreen;
	_pos = getPosASL _camHost;
	
	[_cntrlScreen,false] call cTab_fnc_drawUserMarkers;
	[_cntrlScreen,0] call cTab_fnc_drawBftMarkers;
	
	// draw icon at own location
	_veh = vehicle player;
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabMicroDAGRfontColour,getPosASL _veh,cTabTADownIconBaseSize,cTabTADownIconBaseSize,direction _veh,"", 1,cTabTxtSize,"TahomaB"];
	
	// draw icon at helmet cam location
	_cntrlScreen drawIcon ["\A3\ui_f\data\map\VehicleIcons\iconmanvirtual_ca.paa",cTabTADhighlightColour,_pos,cTabTADownIconBaseSize,cTabTADownIconBaseSize,direction _camHost,"",0,cTabTxtSize,"TahomaB"];
	
	_cntrlScreen ctrlMapAnimAdd [0,cTabMapScaleHCam,_pos];
	ctrlMapAnimCommit _cntrlScreen;
	true
};



//Main loop to add the key handler to the unit.
[] spawn {
	waitUntil {sleep 0.1;!(IsNull (findDisplay 46))};
	
	if (cTab_key_if_main_scancode != 0) then {
		["cTab","Toggle Main Interface",{call cTab_fnc_onIfMainPressed},[cTab_key_if_main_scancode] + cTab_key_if_main_modifiers] call cba_fnc_registerKeybind;
		["cTab","Toggle Secondary Interface",{call cTab_fnc_onIfSecondaryPressed},[cTab_key_if_secondary_scancode] + cTab_key_if_secondary_modifiers] call cba_fnc_registerKeybind;
		["cTab","Toggle Tertiary Interface",{call cTab_fnc_onIfTertiaryPressed},[cTab_key_if_tertiary_scancode] + cTab_key_if_tertiary_modifiers] call cba_fnc_registerKeybind;
		["cTab","Zoom In",{call cTab_fnc_onZoomInPressed},[cTab_key_zoom_in_scancode] + cTab_key_zoom_in_modifiers] call cba_fnc_registerKeybind;
		["cTab","Zoom Out",{call cTab_fnc_onZoomOutPressed},[cTab_key_zoom_out_scancode] + cTab_key_zoom_out_modifiers] call cba_fnc_registerKeybind;
	} else {
		["cTab","Toggle Main Interface",{call cTab_fnc_onIfMainPressed},[actionKeys "User12" select 0,false,false,false]] call cba_fnc_registerKeybind;
		["cTab","Toggle Secondary Interface",{call cTab_fnc_onIfSecondaryPressed},[actionKeys "User12" select 0,false,true,false]] call cba_fnc_registerKeybind;
		["cTab","Toggle Tertiary Interface",{call cTab_fnc_onIfTertiaryPressed},[actionKeys "User12" select 0,false,false,true]] call cba_fnc_registerKeybind;
		["cTab","Zoom In",{call cTab_fnc_onZoomInPressed},[201,true,true,false]] call cba_fnc_registerKeybind;
		["cTab","Zoom Out",{call cTab_fnc_onZoomOutPressed},[209,true,true,false]] call cba_fnc_registerKeybind;
	};
};

// fnc for user menu opperation.
cTabUsrMenuSelect = {
	disableSerialization;
	_type = _this select 0;
	_dlg = cTabIfOpen select 1;
	_display = (uiNamespace getVariable _dlg);
	_return = True;
	
	switch (_type) do
	{
		case 0:
		{
			{ctrlShow [_x, False];} forEach [3300,3301,3302,3303,3304,3305,3306,3307];
		};
		
		case 11:
		{
			ctrlShow [3300, False];
			_control = _display displayCtrl 3301;
			ctrlShow [3301, True];
			_control ctrlSetPosition cTabUserPos;
			_control ctrlCommit 0;
		};

		case 12:
		{
			ctrlShow [3301, False];		
			_control = _display displayCtrl 3303;
			ctrlShow [3303, True];
			_control ctrlSetPosition cTabUserPos;
			_control ctrlCommit 0;
		};
		
		case 13:
		{
			ctrlShow [3303, False];
			ctrlShow [3307, False];
			_control = _display displayCtrl 3304;
			ctrlShow [3304, True];
			_control ctrlSetPosition cTabUserPos;
			_control ctrlCommit 0;
		};
		
		case 14:
		{
			if (cTabUserSelIcon select 1 != "\A3\ui_f\data\map\markers\nato\o_inf.paa") exitWith {
				cTabUserSelIcon set [2,""];
				[13] call cTabUsrMenuSelect;
			};
			ctrlShow [3303, False];
			_control = _display displayCtrl 3307;
			ctrlShow [3307, True];
			_control ctrlSetPosition cTabUserPos;
			_control ctrlCommit 0;
		};
		
		case 10:
		{
			ctrlShow [3304, False];
		};
		
		case 21:
		{
			ctrlShow [3300, False];
			_control = _display displayCtrl 3305;
			ctrlShow [3305, True];
			_control ctrlSetPosition cTabUserPos;
			_control ctrlCommit 0;
		};
		
		case 20:
		{
			ctrlShow [3305, False];
		};
		
		case 31:
		{
			ctrlShow [3300, False];
			_control = _display displayCtrl 3306;
			ctrlShow [3306, True];
			_control ctrlSetPosition cTabUserPos;
			_control ctrlCommit 0;
		};
			
		case 30:
		{
			ctrlShow [3306, False];
		};			
				
	};

_return;

};

// fnc to push out data from the user placed icon to all clents.
cTabUserIconPush = {
	0 = cTabUserIconList pushBack cTabUserSelIcon;
	publicVariable "cTabUserIconList";
	true
};

cTabUavTakeControl = {
	_uav = cTabActUav;
	if (isNil '_uav') exitWith {false};
	_controlArray = uavControl _uav;
	_canControl = true;
	_return = true;
	
	if (count _controlArray > 0) then 
	{
		if (_controlArray select 1 == "GUNNER") then
			{
				_canControl = false;
			};
	};	
	
	if (count _controlArray > 2) then 
	{	
		if (_controlArray select 1 == "GUNNER") then
			{
				_canControl = false;
			};
		if (_controlArray select 3 == "GUNNER") then
			{
				_canControl = false;
			};	
	};
	
	if (_canControl) then
	{
		player remoteControl ((crew _uav) select 1);
		_uav switchCamera "Gunner";
		closeDialog 0;
		cTabUavViewActive = true;
		[_uav] spawn {
			_remote = _this select 0;
			waitUntil {cameraOn != _remote};
			cTabUavViewActive = false;
		};
	}else
	{
	
		["cTabUavNotAval",["Unable to access the UAV stream... Another user is streaming"]] call BIS_fnc_showNotification;
	
	};
_return;
};

cTab_msg_gui_load = {
	disableSerialization;
	_return = true;
	_display = uiNamespace getVariable (cTabIfOpen select 1);
	_msgarry = player getVariable ["ctab_messages",[]];
	_msgControl = _display displayCtrl IDC_CTAB_MSG_LIST;
	_plrlistControl = _display displayCtrl IDC_CTAB_MSG_RECIPIENTS;
	lbClear _msgControl;
	lbClear _plrlistControl;
	_plrList = playableUnits;
	
	// turn this on for testing, otherwise not really usefull, since sending to an AI controlled, but switchable unit will send the message to the player himself
	/*if (count _plrList < 1) then { _plrList = switchableUnits;};*/
	
	uiNamespace setVariable ['cTab_msg_playerList', _plrList];
	// Messages
	{
		_title =  _x select 0;
		_msgState = _x select 2;
		_img = call {
			if (_msgState == 0) exitWith {"\cTab\img\icoUnopenedmail.paa"};
			if (_msgState == 1) exitWith {"\cTab\img\icoOpenmail.paa"};
			if (_msgState == 2) exitWith {"\cTab\img\icon_sentMail_ca.paa"};
		};
		_index = _msgControl lbAdd _title;
		_msgControl lbSetPicture [_index,_img];
		_msgControl lbSetTooltip [_index,_title];
	} count _msgarry;
	
	{
		if ((_x != player) && ([_x,["ItemcTab","ItemAndroid"]] call cTab_fnc_checkGear)) then {
			_index = _plrlistControl lbAdd name _x;
			_plrlistControl lbSetData [_index,str _x];
		};
	} count _plrList;
	
	_return;
};

cTab_msg_get_mailTxt = {
	disableSerialization;
	_return = true;
	_index = _this select 1;
	_display = uiNamespace getVariable (cTabIfOpen select 1);
	_msgArray = player getVariable ["ctab_messages",[]];
	_msgName = (_msgArray select _index) select 0;
	_msgtxt = (_msgArray select _index) select 1;
	_msgState = (_msgArray select _index) select 2;
	if (_msgState == 0) then {
		_msgArray set [_index,[_msgName,_msgtxt,1]];
		player setVariable ["ctab_messages",_msgArray];
	};
	
	_nop = [] call cTab_msg_gui_load;
	
	_txtControl = _display displayCtrl IDC_CTAB_MSG_CONTENT;

	_nul = _txtControl ctrlSetText  _msgtxt;
	
	_return;
};

cTab_msg_Send = {
	private ["_return","_display","_plrLBctrl","_msgBodyctrl","_plrList","_indices","_time","_msgTitle","_msgBody","_recip","_recipientNames","_msgarry"];
	disableSerialization;
	_return = true;
	_display = uiNamespace getVariable (cTabIfOpen select 1);
	_plrLBctrl = _display displayCtrl IDC_CTAB_MSG_RECIPIENTS;
	_msgBodyctrl = _display displayCtrl IDC_CTAB_MSG_COMPOSE;
	_plrList = (uiNamespace getVariable "cTab_msg_playerList");
	
	_indices = lbSelection _plrLBctrl;
	
	if (_indices isEqualTo []) exitWith {false};
	
	_time = call cTab_fnc_currentTime;
	_msgTitle = format ["%1 - %2",_time,name player];
	_msgBody = ctrlText _msgBodyctrl;
	if (_msgBody isEqualTo "") exitWith {false};
	_recipientNames = "";
	
	{
		_data = _plrLBctrl lbData _x;
		_recip = objNull;
		{
			if (_data == str _x) exitWith {_recip = _x;};
		} count _plrList;
		
		if !(IsNull _recip) then {
			if (_recipientNames isEqualTo "") then {
				_recipientNames = name _recip;
			} else {
				_recipientNames = format ["%1; %2",_recipientNames,name _recip];
			};
			
			["cTab_msg_receive", [_recip,_msgTitle,_msgBody]] call CBA_fnc_whereLocalEvent;
		};
	} forEach _indices;
	
	_msgarry = player getVariable ["ctab_messages",[]];
	_msgarry pushBack [format ["%1 - %2",_time,_recipientNames],_msgBody,2];
	
	if (!isNil "cTabIfOpen" && {[cTabIfOpen select 1,"mode"] call cTab_fnc_getSettings == "MESSAGE"}) then {
		call cTab_msg_gui_load;
	};
	
	_return;
};

["cTab_msg_receive",
	{
		_msgTitle = _this select 1;
		_msgBody = _this select 2;
		_msgarry = player getVariable ["ctab_messages",[]];
		_msgarry pushBack [_msgTitle,_msgBody,0];
		
		player setVariable ["ctab_messages",_msgarry];
		
		if ([player,["ItemcTab","ItemAndroid"]] call cTab_fnc_checkGear) then 
		{
			playSound "cTab_phoneVibrate";
			
			if (!isNil "cTabIfOpen" && {[cTabIfOpen select 1,"mode"] call cTab_fnc_getSettings == "MESSAGE"}) then 
			{
				_nop = [] call cTab_msg_gui_load;
			}
			else
			{
				cTabRscLayerMailNotification cutRsc ["cTab_Mail_ico_disp", "PLAIN"]; //show
			};
		};
	}
] call CBA_fnc_addLocalEventHandler;
	
cTab_msg_delete_all = {
	player setVariable ["ctab_messages",[]];
};

/*
Function to execute the correct action when btnACT is pressed on Tablet
No Parameters
Returns TRUE
*/
cTab_Tablet_btnACT = {
	_mode = ["cTab_Tablet_dlg","mode"] call cTab_fnc_getSettings;
	call {
		if (_mode == "UAV") exitWith {_nop = [] call cTabUavTakeControl;};
		if (_mode == "HCAM") exitWith {["cTab_Tablet_dlg",[["mode","HCAM_FULL"]]] call cTab_fnc_setSettings;};
		if (_mode == "HCAM_FULL") exitWith {["cTab_Tablet_dlg",[["mode","HCAM"]]] call cTab_fnc_setSettings;};
	};
	true
};

/*
Function called when DELETE button is pressed in messaging mode
Parameter 0: Name of uiNameSpace variable of display
Returns false if nothing was selected for deletion, else returns true
*/
cTab_fnc_onMsgBtnDelete = {
	_displayName = _this select 0;
	_display = uiNamespace getVariable _displayName;
	_msgLbCtrl = _display displayCtrl IDC_CTAB_MSG_LIST;
	_msgLbSelection = lbSelection _msgLbCtrl;
	
	if (count _msgLbSelection == 0) exitWith {false};
	_msgArray = player getVariable ["ctab_messages",[]];
	
	// run through the selection backwards as otherwise the indices won't match anymore
	for "_i" from (count _msgLbSelection) to 0 step -1 do {
		_msgArray deleteAt (_msgLbSelection select _i);
	};
	player setVariable ["ctab_messages",_msgArray];
	
	_msgTextCtrl = _display displayCtrl IDC_CTAB_MSG_CONTENT;
	_msgTextCtrl ctrlSetText "No Message Selected";
	_nop = [] call cTab_msg_gui_load;
	true
};
