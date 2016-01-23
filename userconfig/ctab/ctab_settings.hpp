class cTab_settings {
	// define vehicle classes that are equipped with FBCB2 devices
	cTab_vehicleClass_has_FBCB2[] = {"MRAP_01_base_F","MRAP_02_base_F","MRAP_03_base_F","Wheeled_APC_F","Tank","Truck_01_base_F","Truck_03_base_F"};

	// define vehicle classes that are equipped with TAD devices
	cTab_vehicleClass_has_TAD[] = {"Helicopter","Plane"};

	// define helmet classes that are equipped with a helmet cam
	cTab_helmetClass_has_HCam[] = {"H_HelmetB_light","H_Helmet_Kerry","H_HelmetSpecB","H_HelmetO_ocamo","BWA3_OpsCore_Fleck_Camera","BWA3_OpsCore_Schwarz_Camera","BWA3_OpsCore_Tropen_Camera"};
};

// define the default key setup; can be altered in-game using CBA's keybinding system
class cTab_keys {

	class if_main {
		key = 35; // H
		ctrl = 0;
		shift = 0;
		alt = 0;
	};

	class if_secondary {
		key = 35; // H
		ctrl = 1;
		shift = 0;
		alt = 0;
	};

	class if_tertiary {
		key = 35; // H
		ctrl = 0;
		shift = 0;
		alt = 1;
	};

	class zoom_in {
		key = 201; // PAGE_UP
		ctrl = 1;
		shift = 1;
		alt = 0;
	};

	class zoom_out {
		key = 209; // PAGE_DOWN
		ctrl = 1;
		shift = 1;
		alt = 0;
	};

	class toggleIfPosition {
		key = 199; // HOME / POS1
		ctrl = 1;
		shift = 1;
		alt = 0;
	};

};

/* KEY LIST // US keyboard layout*/
/* ================================================================================================================= */
/*
shift
ctrl
alt

ESC = 1
F1 = 59
F2 = 60
F3 = 61
F4 = 62
F5 = 63
F6 = 64
F7 = 65
F8 = 66
F9 = 67
F10 = 68
F11 = 87
F12 = 88
PRINT = 183
SCROLL = 70
PAUSE = 197
^ = 41
1 = 2
2 = 3
3 = 4
4 = 5
5 = 6
6 = 7
7 = 8
8 = 9
9 = 10
0 = 11
? = 12
? = 13
? = 26
? = 39
? = 40
# = 43
< = 86
, = 51
. = 52
- = 53
+ = NOT DEFINED
POS1 = 199
TAB = 15
ENTER = 28
DELETE = 211
BACKSPACE = 14
INSERT = 210
END = 207
PAGEUP = 201
PAGEDOWN = 209
CAPS = 58
A = 30
B = 48
C = 46
D = 32
E = 18
F = 33
G = 34
H = 35
I = 23
J = 36
K = 37
L = 38
M = 50
N = 49
O = 24
P = 25
Q = 16
U = 22
R = 19
S = 31
T = 20
V = 47
W = 17
X = 45
Y = 44
Z = 21
SHIFTL = 42
SHIFTR = 54
UP = 200
DOWN = 208
LEFT = 203
RIGHT = 205
NUM_0 = 82
NUM_1 = 79
NUM_2 = 80
NUM_3 = 81
NUM_4 = 75
NUM_5 = 76
NUM_6 = 77
NUM_7 = 71
NUM_8 = 72
NUM_9 = 73
NUM_+ = 78
NUM = 69
NUM_/ = 181
NUM_* = 55
NUM_- = 74
NUM_, = 83
NUM_ENTER = 156
STRGL = 29
STRGR = 157
WINL = 220
WINR = 219
ALT = 56
SPACE = 57
ALTGR = 184
APP = 221
*/

/* KEY LIST // English (US) 104-key    provided by tcp */
/* ================================================================================================================= */
/*
ESC = 1
F1 = 59
F2 = 60
F3 = 61
F4 = 62
F5 = 63
F6 = 64
F7 = 65
F8 = 66
F9 = 67
F10 = 68
F11 = 87
F12 = 88
PRINT = 183
SCROLL = 70
PAUSE = 197
` = 41
1 = 2
2 = 3
3 = 4
4 = 5
5 = 6
6 = 7
7 = 8
8 = 9
9 = 10
0 = 11
- = 12
= = 13
, = 51
. = 52
/ = 53
; = 39
' = 40
[ = 26
] = NOT DEFINED
\ = 43
HOME = 199
TAB = 15
ENTER = 28
DELETE = 211
BACKSPACE = 14
INSERT = 210
END = 207
PAGEUP = 201
PAGEDOWN = 209
CAPS = 58
A = 30
B = 48
C = 46
D = 32
E = 18
F = 33
G = 34
H = 35
I = 23
J = 36
K = 37
L = 38
M = 50
N = 49
O = 24
P = 25
Q = 16
R = 19
S = 31
T = 20
U = 22
V = 47
W = 17
X = 45
Y = 21
Z = 44
SHIFTL = 42
SHIFTR = 54
UP = 200
DOWN = 208
LEFT = 203
RIGHT = 205
NUM_0 = 82
NUM_1 = 79
NUM_2 = 80
NUM_3 = 81
NUM_4 = 75
NUM_5 = 76
NUM_6 = 77
NUM_7 = 71
NUM_8 = 72
NUM_9 = 73
NUM_+ = 78
NUM = 69
NUM_/ = 181
NUM_* = 55
NUM_- = 74
NUM_. = 83
NUM_ENTER = 156
CTRLL = 29
CTRLR = 157
WINL = 219
WINR = 220
ALTL = 56
ALTR = 184
SPACE = 57
APP = 221
*/
