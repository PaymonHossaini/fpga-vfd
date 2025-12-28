Vacuum Fluorescent Display Module
Type 3900B series
“General Function”
Software Specification
Model:GU-3900B series
Specification No: DS-1600-0008-00
Date of Issue: October 27, 2010 (00)
Revision:
Published by
NORITAKE ITRON Corp. / Japan
http://www.noritake-itron.jp
This specification is subject to change without prior notice.

GU-3900B series “General Function” Software Specification
Contents
1 General Description ........................................................................................................................................................ 4
1.1Scope........................................................................................................................................................................ 4
1.2Functions.................................................................................................................................................................. 4
2 Operating Mode............................................................................................................................................................... 4
2.1Normal command mode ........................................................................................................................................... 4
2.2Graphic DMA mode.................................................................................................................................................. 4
2.3User setup mode...................................................................................................................................................... 4
2.4Memory re-write mode.............................................................................................................................................. 4
2.5Test mode................................................................................................................................................................. 4
2.6Power-on setting....................................................................................................................................................... 4
3 VFD Module model-specific information ...................................................................................................................... 5
3.1Timing Unit................................................................................................................................................................ 5
3.2Display Memory configuration .................................................................................................................................. 5
4 Normal command mode and User setup mode (Applicable for Parallel and RS-232) .............................................. 6
4.1Displayable image types ........................................................................................................................................... 64.1.1Graphic display................................................................................................................................................. 64.1.2Character display.............................................................................................................................................. 6
4.2Memory..................................................................................................................................................................... 64.2.1Display Memory................................................................................................................................................ 64.2.2Bit image and font definition memory ............................................................................................................... 74.2.3General-purpose memory ................................................................................................................................. 7
4.3Cursor....................................................................................................................................................................... 8
4.4Window..................................................................................................................................................................... 94.4.1Base-Window.................................................................................................................................................... 94.4.2User-Window.................................................................................................................................................... 9
4.5Write screen mode.................................................................................................................................................. 104.5.1Display screen mode...................................................................................................................................... 104.5.2All screen mode.............................................................................................................................................. 10
4.6Protocol................................................................................................................................................................... 114.6.1Direct mode..................................................................................................................................................... 114.6.2Packet mode................................................................................................................................................... 11
4.7Commands.............................................................................................................................................................. 114.7.1Code set.......................................................................................................................................................... 114.7.1.1Character code...................................................................................................................................... 114.7.1.2Control code........................................................................................................................................... 114.7.2Detail of code set............................................................................................................................................ 124.7.2.1Character display................................................................................................................................... 124.7.2.2BS (Back Space)................................................................................................................................... 154.7.2.3HT (Horizontal Tab)................................................................................................................................ 154.7.2.4LF (Line Feed)....................................................................................................................................... 164.7.2.5HOM (Home Position)............................................................................................................................ 164.7.2.6CR (Carriage Return)............................................................................................................................. 164.7.2.7CLR (Display Clear)............................................................................................................................... 164.7.2.8CAN (Line Clear)................................................................................................................................... 164.7.2.9RCLR (Line end Clear) .......................................................................................................................... 164.7.3Command Set................................................................................................................................................. 174.7.3.1General setting commands .................................................................................................................... 174.7.3.2Character display setting commands ..................................................................................................... 174.7.3.3Display action setting commands .......................................................................................................... 184.7.3.4Bit image display setting commands ..................................................................................................... 194.7.3.5General display setting commands ........................................................................................................ 214.7.3.6Window display setting commands ........................................................................................................ 214.7.3.7Download character setting commands ................................................................................................. 214.7.3.8User setup mode setting commands ..................................................................................................... 224.7.3.9General-purpose I/O Port control commands ........................................................................................ 224.7.3.10Macro setting commands ....................................................................................................................... 234.7.3.11Other setting commands ........................................................................................................................ 234.7.4Command Set Details..................................................................................................................................... 254.7.4.1US X n (Brightness level setting) ........................................................................................................... 254.7.4.2ESC @ (Initialize Display) ...................................................................................................................... 254.7.4.3US $ x y (Cursor Set)............................................................................................................................. 254.7.4.4US C n (Cursor display ON/OFF) .......................................................................................................... 254.7.4.5US ( w 10h a (Write screen mode select) .............................................................................................. 264.7.4.6ESC R n (International font set) ............................................................................................................. 264.7.4.7ESC t n (Character table type) ............................................................................................................... 274.7.4.8US MD1 (Over-write mode) ................................................................................................................... 274.7.4.9US MD2 (Vertical scroll mode) ............................................................................................................... 274.7.4.10US MD3 (Horizontal scroll mode) .......................................................................................................... 274.7.4.11US MD5 (Horizontal scroll mode, scroll ON) ......................................................................................... 274.7.4.12US s n (Horizontal scroll speed) ............................................................................................................ 274.7.4.13US ( g 01h m (Font size select) ............................................................................................................. 284.7.4.14US ( g 02h m (2-byte character) ............................................................................................................ 284.7.4.15US ( g 03h m,  US ( g 0Fh m (2-byte character type) ............................................................................ 284.7.4.16US ( g 04h m (Font Width) ..................................................................................................................... 294.7.4.17US ( g 05h n (FROM Extended Font) .................................................................................................... 304.7.4.18US ( g 40h x y (Font Magnification) ....................................................................................................... 30
- 2 -

GU-3900B series “General Function” Software Specification
4.7.4.19US ( g 41h b (Bold character) ................................................................................................................ 304.7.4.20US ( a 01h t (Wait)................................................................................................................................. 304.7.4.21US ( a 02h t (Short Wait) ........................................................................................................................ 304.7.4.22US ( a 10h wL wH cL cH s (Scroll display action) .................................................................................. 314.7.4.23US ( a 11h p t1 t2 c (Blink) ..................................................................................................................... 314.7.4.24US ( a 12h v s p (Curtain display action) ............................................................................................... 324.7.4.25US ( a 13h v s pL pH (Spring display action) ......................................................................................... 324.7.4.26US ( a 14h s pL pH (Random display action) ........................................................................................ 334.7.4.27US ( a 40h p (Display power ON/OFF/auto-OFF) .................................................................................. 344.7.4.28US ( a 40h 11h t (Display power auto-OFF time) ................................................................................... 344.7.4.29US ( d 10h pen xL xH yL yH (Dot drawing) ............................................................................................ 344.7.4.30US ( d 11h mode pen x1L x1H y1L y1H x2L x2H y2L y2H (Line/Box pattern drawing) .........................344.7.4.31US ( f 20h xPL xPH yPL yPH m aL aH aE ySL ySH xOL xOH yOL yOH xL xH yL yH g)    (Dot unit  downloaded bit image display) ....................................................................................................... 364.7.4.32US ( d 21h xPL xPH yPL yPH xL xH yL yH g d(1)...d(k) (Dot unit real-time bit image display) .............394.7.4.33US ( d 30h xPL xPH yPL yPH m bLen d(1)...d(bLen) (Dot unit character display) ................................414.7.4.34US ( f 11h xL xH yL yH g d(1)...d(k) (Real-time bit image display) ........................................................ 424.7.4.35US (f 01h aL aH aE sL sH sE d(1)...d(s) (RAM bit image definition) ..................................................... 434.7.4.36US ( e 10h aL aH aE sL sH sE d(1)...d(s) (FROM bit image definition) ................................................. 444.7.4.37US ( f 10h m aL aH aE ySL ySH xL xH yL yH g) (Downloaded bit image display) ................................464.7.4.38US ( f 90h m aL aH aE ySL ySH xL xH yL yH g s) (Downloaded bit image scroll display) ....................484.7.4.39US m n (Horizontal scroll display quality select) .................................................................................... 504.7.4.40US r n (Reverse display) ........................................................................................................................ 504.7.4.41US w n (Write mixture display mode) .................................................................................................... 504.7.4.42US ( w 01h a (Window select) ............................................................................................................... 504.7.4.43US ( w 02h a b[xPL xPH yPL yPH  xSL  xSH ySL ySH] (User Window define / cancel) .......................514.7.4.44ESC % n (Download character ON/OFF) .............................................................................................. 524.7.4.45ESC & a c1 c2 [x1 d1...d(y×x1)]...[xk d1...d(y×xk)] (Download character definition) .............................524.7.4.46ESC ? a c (Download character delete) ................................................................................................ 524.7.4.47US ( g 10h c1 c2 d1...d32 (16×16 Download character definition) ........................................................ 534.7.4.48US ( g 11h c1 c2 (16×16 Downloaded character delete) ....................................................................... 534.7.4.49US ( g 14h c1 c2 d1...d128 (32×32 Download character definition) ...................................................... 534.7.4.50US ( g 15h c1 c2 (32×32 Downloaded character delete) ....................................................................... 544.7.4.51US ( e 11h a (Download character save) ............................................................................................... 544.7.4.52US ( e 21h a (Download character restore) ........................................................................................... 544.7.4.53US ( e 13h m P(80h-1) P(80h-2)...P(FFh-n) (FROM User font definition) ............................................. 554.7.4.54US ( e 15h a b p(1)…p(65536) (FROM extension font definition) ......................................................... 554.7.4.55US ( e 01h d1 d2 (User setup mode start) ............................................................................................. 554.7.4.56US ( e 02h d1 d2 d3 (User setup mode end) ......................................................................................... 554.7.4.57US ( p 01h n a (I/O Port Input / Output setting) ..................................................................................... 564.7.4.58US ( p 10h n a (I/O Port Output) ............................................................................................................ 564.7.4.59US ( p 20h n (I/O Port Input) .................................................................................................................. 564.7.4.60US : pL pH [d1...dk] (RAM Macro define / delete) ................................................................................. 574.7.4.61US ( e 12h a pL pH t1 t2 [ d(1)...d(p) ] (FROM Macro define / delete) ................................................... 574.7.4.62US ^ n t1 t2 (Macro execution) .............................................................................................................. 584.7.4.63US ( i 20h a b c (Macro end condition) .................................................................................................. 594.7.4.64US ( e 03h a b (Memory SW setting) ..................................................................................................... 594.7.4.65US ( e 04h a (Memory SW data send) ................................................................................................... 604.7.4.66US ( e 18h sL sH sE m1 a1L a1H a1E d[1]...d[s] (General-purpose memory store) .............................604.7.4.67US ( e 19h sL sH sE m1 a1L a1H a1E m2 a2L a2H a2E (General-purpose memory transfer) .............614.7.4.68US ( e 28h sL sH sE m1 a1L a1H a1E (General-purpose memory send) ............................................. 614.7.4.69US ( e 40h a [b c ] (Display status send) ............................................................................................... 624.7.4.70US ( i 10h a b (RS-232 serial settings) .................................................................................................. 624.7.4.71FS | M m d1...d6 (Memory re-write mode) ............................................................................................. 62
4.8Bit image data format.............................................................................................................................................. 63
4.9Download character format ..................................................................................................................................... 63
5 Graphic DMA mode  (Applicable for Parallel interface only) .................................................................................... 64
5.1Displayable image types ......................................................................................................................................... 645.1.1Graphic display............................................................................................................................................... 64
5.2Display Memory...................................................................................................................................................... 64
5.3Protocol................................................................................................................................................................... 64
5.4Commands ............................................................................................................................................................ 655.4.1Command Details........................................................................................................................................... 655.4.1.1STX 44h DAD 46h aL aH sL sH d(1)...d(s) (Bit image write) ................................................................. 655.4.1.2STX 44h DAD 42h aL aH sXL sXH sYL sYH d(1)...d(s) (BOX Area Bit image write) ............................665.4.1.3STX 44h DAD 53h aL aH (Display start address) .................................................................................. 675.4.1.4STX 44h DAD 57h 01h (Display synchronous) ...................................................................................... 675.4.1.5STX 44h DAD 58h n (Brightness level) ................................................................................................. 67
6 Setup.............................................................................................................................................................................. 68
6.1DIP-Switch (SW1)................................................................................................................................................... 686.1.1Display address (for Packet mode and Graphic DMA mode) ......................................................................... 686.1.2RS-232 communication settings ..................................................................................................................... 686.1.3Command Mode............................................................................................................................................. 686.1.4Operating Mode.............................................................................................................................................. 696.1.5Protocol mode................................................................................................................................................. 69
6.2Memory SW............................................................................................................................................................ 69
 Notice for the Cautious Handling of VFD Modules ...................................................................................................... 70
 Revision history.............................................................................................................................................................. 71
- 3 -

GU-3900B series “General Function” Software Specification
1General Description
1.1Scope
This specification covers the software aspects of the GU-3900B series vacuum fluorescent graphic  
display modules.
Related specifications: Hardware specification for specific GU-3900B VFD module.
Program Macro specification: (Refer to 4.7.4.60 RAM Macro define / delete)
(Refer to 4.7.4.61 FROM Macro define / delete)
Character fonts specification: (Refer to 4.7.2.1 Character display)
1.2Functions
Character display, Graphic display,
Control command, Display action command,
Download (user-definable) font, User-definable font table function,
Draw command, Window function, General-purpose I/O port control,
Macro, Program Macro function, Bit Image download function,
Memory SW, Data storage.
2Operating Mode
The operating modes are as follows, selected by DIP-SW, TEST terminal, or software command.
2.1Normal command mode
Normal operation mode in which the module can receive commands and data via the various  
interfaces.  There are two types of protocol for commands and data, selected by DIP-SW.
2.2Graphic DMA mode
Normal operation mode in which the module can receive graphic data and commands via the parallel  
interface with high-speed data writing.  High-speed graphic display is possible using this mode.
2.3User setup mode
This mode is used for saving Memory-SW and various data to FROM.
2.4Memory re-write mode
Mode for re-writing firmware and built-in font data.  Do not use unless necessary.
2.5Test mode
Test for display and internal operation.  Used for factory test.
2.6Power-on setting
At power-on, the various display settings are set to default value, or value stored in Memory SW (refer  
to 6.2 Memory SW).
If “Restore at power-on” is enabled, the various content in FROM is transferred to RAM before  
starting standard operation.
If “Macro execution at power-on” in enabled, Macro or Program Macro is automatically executed.
- 4 -Power 
ONPower 
ONMemory re-write 
modeMemory re-write 
mode
Test modeTest modeNormal 
command modeNormal 
command modeUser setup modeUser setup modeOFF
Graphic DMA 
modeGraphic DMA 
modeON
TEST SW6SW7
ONOFF
01

GU-3900B series “General Function” Software Specification
3VFD Module model-specific information
3.1Timing Unit
Timing unit length varies between different modules.  The timing unit length for each module display  
dot size is shown below.
ModuleTiming unit (Typ.) ± 5%
128X12814ms
256X1614ms
256X3214ms
256X6414ms
256X12815ms
320X3214ms
384X3213ms
512X3214ms
Timing unit affects the timing of the following commands and operations:
4.7.4.12 US s n (Horizontal scroll speed)
4.7.4.21 US ( a 02h t (Short Wait)
4.7.4.23 US ( a 11h p t1 t2 c (Blink)
4.7.4.24 US ( a 12h v s p (Curtain display action)
4.7.4.25 US ( a 13h v s pL pH (Spring display action)
4.7.4.26 US ( a 14h s pL pH (Random display action)
4.7.4.38 US ( f 90h m aL aH aE ySL ySH xL xH yL yH g s) (Downloaded bit image scroll display)
4.7.4.61 US ( e 12h a pL pH t1 t2 [ d(1)...d(p) ] (FROM Macro define / delete)
4.7.4.62 US ^ n t1 t2 (Macro execution)
3.2Display Memory configuration
Display Memory size and configuration varies between different modules.  The configuration for each  
module display dot size is shown below.  For each module, the following eight module-specific  
values, referred to throughout this specification, are also stated:
Xdots:The number of dots in the X-direction (horizontal) for the entire Display Memory.
Ydots:The number of dots in the Y-direction (vertical) for the entire Display Memory.
Ybytes:Ydots÷8. Used when specifying Y-parameter in bytes (8-dot units).
Max_Xdot:Xdots−1. Valid X-coordinate values range from 0 to Max_Xdot.
Max_Ydot:Ydots−1. Valid Y-coordinate values range from 0 to Max_Ydot.
Max_Ybyte:Ybytes−1. Valid Y-coordinate 8-dot unit values range from 0 to Max_Ydot.
DispMemSize:Size of Display Memory in bytes.
Max_DispMemAddr:DispMemSize−1.  Valid Display Memory addresses range from 0 to Max_DispMemAddr.
Refer also to 4.2.1 Display Memory.
Display area(Module size)Hidden areaTotal area Display Memory
XdotsYdotsYbytesMax_XdotMax_YdotMax_YbyteMax_DispMemAddrDispMemSize
128×128128×128256×128100h80h10h0FFh7Fh0Fh0FFFh1000h
256×161792×162048×16800h10h02h7FFh0Fh01h0FFFh1000h
256×32768×321024×32400h20h04h3FFh1Fh03h0FFFh1000h
256×64256×64512×64200h40h08h1FFh3Fh07h0FFFh1000h
256×128256×128512×128200h80h10h1FFh7Fh0Fh1FFFh2000h
320×32704×321024×32400h20h04h3FFh1Fh03h0FFFh1000h
384×32640×321024×32400h20h04h3FFh1Fh03h0FFFh1000h
512×32512×321024×32400h20h04h3FFh1Fh03h0FFFh1000h
- 5 -

GU-3900B series “General Function” Software Specification
4Normal command mode and User setup mode (Applicable for Parallel and RS-232)
4.1Displayable image types
4.1.1Graphic display
Number of dots: Depends on VFD module.
(Refer to 3 VFD Module model-specific information )
4.1.2Character display
Character mode: 1-byte character: 6×8 dot, 8×16 dot, 12×24 dot, 16×32 dot mode
2-byte character: 16×16 dot, 32×32 dot mode
Built-in Character font type: 1-byte character: 6×8 dot, 8×16 dot, 12×24 dot, 16×32 dot 
– ANK, International font (specification DS-1600-0004-XX)
2-byte character:
16×16 dot
– Japanese Kanji (specification DS-906-0002-XX)
– Simplified Chinese (specification DS-954-0006-XX)
– Traditional Chinese (specification DS-954-0007-XX)
– Korean (specification DS-954-0008-XX)
32×32 dot
– Japanese Kanji (specification DS-906-0003-XX)
Standard fonts:
Font 
size1-byte character 2-byte character
InternationalJapaneseKoreanSimplified Chinese Traditional Chinese
6×8○××× ×
8×16○○(16×16)○(16×16)○(16×16) ○(16×16)
12×24○××× ×
16×32○○(32×32)×× ×
4.2Memory
4.2.1Display Memory
Display Memory is comprised of Display area and Hidden area (refer to 3.2 Display Memory
configuration).
By using “User Window” function, the memory area can be separated, and each separate window  
can be controlled independently (refer to 4.7.4.43 User Window define / cancel).
Hidden area can be displayed by using scroll or other action commands.
Example:  Display Memory configuration for 256 ×64 dot module.
- 6 -x
01255256510511
Display area 256 dots Hidden area 256 dots
Total Display Memory 512 dots64 dotsD7
D6
D5
D4
D3
D2
D1
D0y  0 
1 
7 . . . 0000h0001h0008h0009h07F8h07F9h0800h0801h0FF0h0FF1h0FF8h0FF9h
0007h000Fh07FFh0807h0FF7h0FFFh

GU-3900B series “General Function” Software Specification
4.2.2Bit image and font definition memory
Bit image definition
Arbitrary bit image data can be defined and saved using bit image definition commands.
RAM: 4096 bytes
FROM: 32768 bytes + Extension area 262144 bytes
(Refer to 4.7.4.35 RAM bit image definition and 4.7.4.36 FROM bit image definition)
User-defined fonts
Memory for arbitrary user-defined fonts is available as follows.
Download character
For each of the font sizes 6×8, 8×16, 12×24, and 16×32 dot (1-byte character), and 16×16  
and 32×32 dot (2-byte character), a maximum of 16 characters can be defined to memory  
space in RAM.
FROM user font
For each of the font sizes 6×8, 8×16, 12×24, and 16×32 dot (1-byte character), a maximum  
of 128 characters can be defined to memory space in FROM.
FROM extension font
For each of the font sizes 6×8, 8×16, 12×24, and 16×32 dot (1-byte character), an arbitrary  
font can be defined to memory space in FROM.
Refer to 4.7.4.45 Download character definition, 4.7.4.47 16×16 dot download character  
definition, 4.7.4.49 32×32 dot download character definition, 4.7.4.53 FROM User Font 
definition, 4.7.4.54 FROM extension font definition.
User-defined fonts summary:
Font size 1-byte character 2-byte character
Download character FROM user fontFROM extension 
fontDownload 
character
6×8 dot mode ○ ○○×
8×16 dot mode ○ ○○○(16×16)
12×24 dot mode ○ ○○×
16×32 dot mode ○ ○○○(32×32)
4.2.3General-purpose memory
Arbitrary data can be stored to and retrieved from the memory.
General-purpose RAM: 1024 bytes
General-purpose FROM: 4096 bytes × 16 areas
General-purpose RAM
000000h – 003FFh
General-purpose FROM
000000h – 000FFFh
001000h – 001FFFh
002000h – 002FFFh
...
00F000h – 00FFFFh
Note: Operation which exceeds a FROM area is not possible.
- 7 -

GU-3900B series “General Function” Software Specification
4.3Cursor
Cursor indicates the write start position for displaying a character or bit image.
Cursor consists of 1 dot horizontally and 8 dots vertically.
Character and Bit image is written to the right in the X direction and downwards in the Y direction  
from and including the Cursor position.
Cursor position can be moved by “Cursor set” command (refer to 4.7.4.3 Cursor set).
The cursor is normally not displayed, but can be displayed by 4.7.4.4 Cursor display ON/OFF  
command.
Cursor position relates to Display Memory as shown below.
Light grey:Cursor
Dark grey:Character
Thick line frame:Space for one character ( 6×8 dot)
- 8 -   X
   00h 01h 02h 03h 04h 05h 06h 07h
y=00h
MAXy =Max_Yby te. . .  . . .MAX 
Max_Xdot
Example: Vertically 2× character

GU-3900B series “General Function” Software Specification
4.4Window
Window function enables the display screen to be divided into “windows” each of which can be  
controlled and displayed independently.
Display Memory is shared by all windows; individual windows do not have their own display memory.
There are 2 types of “window”: Base-Window and User-Window.
Refer to 4.7.4.43 User Window define / cancel.
4.4.1Base-Window
Base-Window covers the entire display screen.  If no User-Windows are defined, all display  
operation is processed on this window.  If one or more User-Windows are defined, display operation  
on any area not covered by a User-Window is done by selecting Base-Window.  When Base-Window  
is selected, even if User-Window(s) are defined, all display operation is processed under Base-
Window.  Therefore the current display contents of User-Window(s) is overwritten.
Operation on Base-Window depends on the setting of “Write screen mode” (refer to 4.5 Write screen
mode).
4.4.2User-Window
User-Window is defined by User-Window definition command.  Display operation is processed on the  
window selected by Current Window select command.
A maximum of 4 User-Windows can be defined.
- 9 -　Base-Window Base-Window ABCDEFG
HIJKLMN
OPQRSTU    User-Window 01234567
User-Window  2
User-Window  3User-Window  1 User-Window  4

GU-3900B series “General Function” Software Specification
4.5Write screen mode
This setting is only applicable for Base-Window.
There are two Write screen modes, Display screen mode and All screen mode.  The mode is set by  
command (refer to 4.7.4.5 Write screen mode select).
4.5.1Display screen mode
When the cursor is located in the Display area, all operation will be done within Display area, and  
when cursor is located in the Hidden area, it will be done within Hidden area.
Character write depends on the specified character display mode.
Bit image is written within the current area, and any data outside the area is ignored.
4.5.2All screen mode
Regardless of the cursor position, o peration will be done over the entire area.
Character write depends on the specified character display mode.
Bit image is written within the entire memory area, and any data outside the area is ignored.
- 10 -Display area Hidden area 
Display area Hidden area 

GU-3900B series “General Function” Software Specification
4.6Protocol
One of two protocols is selected by DIP-SW.
4.6.1Direct mode
The module processes all received data; the display address setting is ignored.
Direct mode is applicable for all interfaces.
4.6.2Packet mode
The module only processes data in packets with an address that matches the display's address set  
by DIP-SW + MSW.
Using this mode, a maximum of 255 displays can be controlled individually.
Data in packets addressed to FFh is processed by all connected displays.
Packet mode is applicable for Parallel and RS-232 serial interface.
HeaderAddressData lengthDataFooterBCC
STX (02h)00h–FFh01h–80h00h–FFhETX (03h)00h–FFh
1 byte1 byte1 byte1–128 byte(s)1 byte1 byte
BCC: XOR value from Header to Footer inclusive.
Packet response can be sent, depending on MSW setting.
If packet address and display address matches, and packet is correctly received, ACK reply is sent  
from display.
For packets addressed to FFh, only the display with address 00h sends a response.
If a BCC or other error occurs, no response is sent.
The packet response is sent with priority, which may corrupt any data remaining in the display's  
transmit buffer, so the host should wait until all data has been received before sending the next  
packet.
Response
ACK (06h)
1 byte
4.7Commands
This section describes the operation of each command.
Within these explanations, Character (x-dot) and Line (y-dot) refer to the number of dots determined  
by the “Font size select” and “Font magnification” settings, etc.
For commands that produce response data from the display, this data is placed in the send buffer,  
then transmitted.  When DSR=MARK (BUSY), data transmission is halted, and during any time when  
there is no space in the send buffer, command processing is halted.  Caution is needed when using  
these commands via the parallel interface.
4.7.1Code set
4.7.1.1Character code
Command Name Hex Code Operation Page
Character display 20h – FFh
or 2-byte character 
codeDisplay character at the current cursor position. p12
4.7.1.2Control code
Command Name Hex Code Operation Page
BS Back Space 08hCursor moves left by one character. p15
HT Horizontal Tab 09hCursor moves right by one character. p15
LF Line Feed 0AhCursor moves down by one line. p16
HOM Home Position 0BhCursor moves to home position (top left). p16
CR Carriage Return 0DhCursor moves to left end of the current line.  p16
CLR Display Clear 0ChDisplay screen is cleared, cursor moves to home position. p16
CAN Line clear 18hCurrent line is cleared and cursor moves to left end. p16
RCLR Line end clear 19hCurrent line is cleared from cursor position to right end. p16
- 11 -

GU-3900B series “General Function” Software Specification
4.7.2Detail of code set
4.7.2.1Character display
Code:20h – FFh or 2-byte character code
Function:Display character at cursor position.
Font size can be selected, 6×8, 8×16, 12×24, or 16×32 (refer to 4.7.4.13 “Font size select”).
To display a 2-byte character, the following settings are required:
Font size select = 8×16 dot or 16×32 dot, (m=02h or 04h)
2-byte character = ON (m=01h)
2-byte character type = Japanese, Korean, Simplified or Traditional Chinese
Refer to 4.7.4.14 “2-byte character”, and 4.7.4.15 “2-byte character type” for details.
The 2-byte character code depends on the type of built-in character fonts.  This module has the 
following built-in 2-byte character fonts.
Font typeCode typeFirst byteSecond byte
JapaneseJIS X0208(Shift-JIS)81h ≤ c1 ≤9Fh,E0h ≤ c1 ≤ EFh40h ≤ c2 ≤ 7Eh,80h ≤ c2 ≤ FCh
KoreanKSC5601-87A1h ≤ c1 ≤ FEhA1h ≤ c2 ≤ FEh
Simplified Chinese GB2312-80A1h ≤ c1 ≤ FEhA1h ≤ c2 ≤ FEh
Traditional Chinese Big-5A1h ≤ c1 ≤ FEh40h ≤ c2 ≤ 7Eh,A1h ≤ c2 ≤ FEh
This command operates on the currently-selected window (refer to Current window select).
Regardless of the cursor position, if the character size (x and/or y) exceeds the window size, the  
command is ignored.
Details of operation are as follows:
MD1 (Over-write mode)
Cursor position Figure NumberOperationX direction Y direction
Space for character on right side.Space for character at current cursor position.①Display character at cursor.Horizontal Tab (HT).
No space for character at current cursor position.②Cursor moves to the left end of top line (OP3).Display character at cursor.Horizontal Tab (HT).
No space for character on right side.Space for character in next  lower line.③Display space at cursor (OP1).Cursor moves to left end of next lower line (OP4).Display character at cursor.Horizontal Tab (HT).
No space for character in next lower line. ④Display space at cursor (OP1).Cursor moves to left end of top line (OP2).Display character at cursor.Horizontal Tab (HT).
No space for character at current cursor position.⑤Cursor moves to the left end of top line (OP2).Display character at cursor.Horizontal Tab (HT).
Note:  HT operation depends on cursor position (refer to 4.7.2.3 Horizontal Tab).
- 12 -②
CursorSpace (Blank)Space (for 1 character)③
OP1
④
OP1
⑤OP4①
OP2
OP3

GU-3900B series “General Function” Software Specification
MD2 (Vertical scroll mode)
Cursor position Figure NumberDisplay OperationX direction Y direction
Space for character on right  side.Space for character at current  cursor position.①Display character at cursor.Horizontal Tab (HT) (OP4).
No space for character at current cursor position.②Display contents are scrolled up the  required number of dots, and the  bottom line is cleared.Cursor moves to the displayable upper  position (OP3).Display character at cursorHorizontal Tab (HT)
No space for character on  right side.Space for character in next  lower line.③Display space at cursor (OP1).Cursor moves to the left end of next  lower line (OP2).Display character at cursor.Horizontal Tab (HT).
No space for character in next  lower line.④Display space at cursor (OP1).Display contents are scrolled up the  required number of dots, and the  bottom line is cleared.Cursor moves to left end of bottom line  (OP5).Display character at cursor.Horizontal Tab (HT).
No space for character at current cursor position.⑤Display contents are scrolled up the  required number of dots, and the  bottom line is cleared.Cursor moves to left end of bottom line  (OP5)Display character at cursor.Horizontal Tab (HT).Note:  HT operation depends on cursor position (refer to 4.7.2.3 Horizontal Tab).
- 13 -OP2
OP5③
OP1
④
OP1①
OP3
②OP4
⑤
CursorSpace (Blank)Space (for 1 character)

GU-3900B series “General Function” Software Specification
MD3 (Horizontal scroll mode)
Cursor positionFigure NumberDisplay Operation
X direction Y direction
Space for 
character on 
right side.Not right end.
-①Display character at cursor.
Horizontal Tab (HT) (OP2).
Right end (refer 
to Figure 2).-Display character at cursor.
Shift to Scroll ON*.
-No space for character at 
current cursor position.②No action.
Cursor does not move.
No space for character on right side.--③Contents of current line scroll left until  
sufficient space for character is  
available at the right end (OP3).
Cursor moves to the left edge of newly-
created space (OP1).
Display character at cursor.
Shift to Scroll ON*.
-No space for character at 
current cursor position.④No action.
Cursor does not move.
* Note:  Operation during “Scroll ON”:
Contents of current line scroll left until sufficient space for character is available at the right end, then  
character is displayed at cursor.
“Scroll ON” condition is cancelled by any command that moves the cursor except Character Display  
or Horizontal Tab.
- 14 -A
Figure 2③
OP1
④OP3①
OP2
②
CursorSpace (Blank)Space (for 1 character)

GU-3900B series “General Function” Software Specification
4.7.2.2BS(Back Space)
Code:08h
Function:Cursor moves to the left by one character.
This command has effect for the currently-selected window.
MD1 (Over-write mode) and MD2 (Vertical scroll mode)
Cursor positionDisplay OperationX direction Y directionSpace for character on left side. -Cursor moves left by one character.
No space for character on left  side.Space for one line above.Cursor moves to right end of next upper  line.No space for one line above. Cursor does not move.
MD3 (Horizontal scroll mode)
Cursor positionDisplay OperationX direction Y directionSpace for character on left side. -Cursor moves left by one character.
No space for character on left  side.-Cursor does not move.
4.7.2.3HT(Horizontal Tab)
Code:09h
Function:Cursor moves to the right by one character.
This command has effect for the currently-selected window.
MD1 (Over-write mode)
Cursor positionDisplay OperationX direction Y directionSpace for character on right side. -Cursor moves right by one character.
No space for character on right  side.Space for character in next  lower line.Cursor moves to left end of next lower  line.No space for character in next  lower line.Cursor moves to left end of top line.
MD2 (Vertical scroll mode)
Cursor positionDisplay OperationX direction Y direction
Space for character on right side. -Cursor moves right by one character.
No space for character on right  side.Space for character in next  lower line.Cursor moves to left end of next lower  line.
No space for character in next  lower line.Display contents are scrolled up the  required number of dots, and the bottom  line is cleared.Cursor moves to left end of bottom line.
MD3 (Horizontal scroll mode)
Cursor positionDisplay OperationX direction Y direction
Space for character on right  
side.Not right end.
-Cursor moves right by one character.
Right end (refer to 
Figure 2, page 13).Shift to Scroll ON*
No space for character on  right side.--Contents of current line scroll left until  
sufficient space for character is available  
at the right end.
Cursor moves to the left edge of newly-
created space.
Shift to Scroll ON*.
* Note:  Operation during “Scroll ON”:
Contents of current line scroll left until sufficient space for character is available at the right end  
(cursor does not move).
“Scroll ON” condition is cancelled by any command that moves the cursor except Character Display  
or Horizontal Tab.
- 15 -

GU-3900B series “General Function” Software Specification
4.7.2.4LF(Line Feed)
Code:0Ah
Function:Cursor moves to next lower line.
This command has effect for the currently-selected window.
MD1 (Over-write mode)
Cursor positionDisplay OperationX direction Y direction
-Space for character in next  lower line.Cursor moves to the same position on next  lower line.No space for character in next  lower line.Cursor moves to the same position on top  line.
MD2 (Vertical scroll mode)
Cursor positionDisplay OperationX direction Y direction
-Space for character in next  lower line.Cursor moves to the same position on next  lower line.
No space for character in next  lower line.Display contents are scrolled up the  required number of dots, and the bottom  line is cleared.Cursor does not move.
MD3 (Horizontal scroll mode)
Cursor positionDisplay OperationX direction Y direction
- -Cursor does not move.
4.7.2.5HOM(Home Position)
Code:0Bh
Function:Cursor moves to home position (top left).
This command has effect for the currently-selected window.
4.7.2.6CR(Carriage Return)
Code:0Dh
Function:Cursor moves to left end of current line.
This command has effect for the currently-selected window.
4.7.2.7CLR(Display Clear)
Code:0Ch
Function:Display screen is cleared and cursor moves to home position.
This command has effect for the currently-selected window.
4.7.2.8CAN(Line Clear)
Code:18h
Function:Current line is cleared and cursor moves to left end of current line.
This command has effect for the currently-selected window.
4.7.2.9RCLR(Line end Clear)
Code:19h
Function:Current line is cleared from cursor position to end of line (right end).
This command has effect for the currently-selected window.
- 16 -

GU-3900B series “General Function” Software Specification
4.7.3Command Set
4.7.3.1General setting commands
Command Name Hex Code Operation Page
Brightness level setting 1Fh,58h,n
Default: n=04h or 
Memory SW 
setting.Set brightness level for entire display screen.
n=00h:0%n=01h:25%n=02h:50%
n=03h:75%n=04h:100%
n=10h:0%n=11h:12.5%n=12h:25%
n=13h:37.5%n=14h:50%n=15h:62.5%
n=16h:75%n=17h:87.5%n=18h:100%p25
Initialize Display 1Bh,40hClear entire display screen and initialize all settings. p25
Cursor set 1Fh,24h,xL,xH,
yL,yHCursor moves to specified x,y position on Display  
Memory.
xL:Cursor position x, lower byte
xH:Cursor position x, upper byte
yL:Cursor position y, lower byte
yH:Cursor position y, upper bytep25
Cursor display 1Fh,43h,n
Default: n=00hCursor display ON/OFF select.
n=00h: Cursor OFF
n=01h: Cursor ONp25
4.7.3.2Character display setting commands
Command Name Hex Code Operation Page
Write screen mode select 1Fh,28h,77h,10h,a
Default: a=00h or 
Memory SW 
setting.Sets the write screen mode for base window.
a=00h: Display screen mode
a=01h: All screen modep26
International font set 1Bh,52h,n
Default: n=00h or 
Memory SW 
setting.Some characters codes within the range 20h – 7Fh are  
selected from the types listed below.
n=00h: America n=01h: France
n=02h: Germany n=03h: England
n=04h: Denmark 1 n=05h: Sweden
n=06h: Italy n=07h: Spain1
n=08h: Japan n=09h: Norway
n=0Ah: Denmark2 n=0Bh: Spain2
n=0Ch: Latin America n=0Dh: Koreap26
Character Table type 1Bh,74h,n
Default: n=00h or 
Memory SW 
setting.Character codes in the range 80h – FFh are selected  
from the types listed below.
n=00h: PC437 (USA: Standard Europe)
n=01h: Katakana
n=02h: PC850 (Multilingual)
n=03h: PC860 (Portuguese)
n=04h: PC863 (Canadian-French)
n=05h: PC865 (Nordic)
n=10h: WPC1252
n=11h: PC866 (Cyrillic #2)
n=12h: PC852 (Latin 2),
n=13h: PC858
n=FFh: User tablep27
Over-write mode 1Fh,01hSet Over-write mode. p27
Vertical scroll mode 1Fh,02hSet Vertical scroll mode. p27
Horizontal scroll mode 1Fh,03hSet Horizontal scroll mode. p27
Horizontal scroll mode Scroll  
ON1Fh,05hSet Horizontal scroll mode Scroll ON. p27
Horizontal scroll speed 1Fh,73h,n
Default: n=00h or 
Memory SW 
setting.Set Horizontal scroll speed. p27
Font size select 1Fh,28h,67h,01h,
m
Default: m=01h or 
Memory SW 
setting.Select font size of a character.
m=01h:  6×8 font
m=02h:  8×16 font
m=03h:  12×24 font
m=04h:  16×32 fontp28
2-byte character 1Fh,28h,67h,02h,
m
Default: m=00h or 
Memory SW 
setting.Sets 2-byte character ON/OFF.
m=01h: 2-byte character mode ON
m=00h: 2-byte character mode OFFp28
- 17 -

GU-3900B series “General Function” Software Specification
Command Name Hex Code Operation Page
2-byte character type 1Fh,28h,67h,03h,
m
Default: m=00h or 
Memory SW 
setting.Sets 2-byte character type.
m=00h: Japanese
m=01h: Korean
m=02h: Simplified Chinese
m=03h: Traditional Chinesep28
Font width 1Fh,28h,67h,04h,
m
Default: m=00hCharacter width select.
m=00h: Fixed width
m=02h: Proportional 1
m=03h: Proportional 2
m=04h: Proportional 3p29
FROM extended font 1Fh,28h,67h,05h,n
Default: n=00hFROM extended font select.
n=00h: Normal font
n=01h – FFh: FROM extended fontp30
Font magnification 1Fh,28h,67h,40h,
x,y
Default: x=01h, 
y=01h or Memory 
SW setting.Magnify the character by x times on the right, y times  
downward. 
x: X magnification factor
y: Y magnification factorp30
Bold character 1Fh,28h,67h,41h,b
Default: b=00h or 
Memory SW 
setting.Set or cancel cancel boldface character.
b = 00h: Cancels Bold
b = 01h: Selects Boldp30
4.7.3.3Display action setting commands
Command Name Hex Code Operation Page
Wait 1Fh,28h,61h,01h,tProcessing is stopped for the specified time.
t:Wait time (× approximately 0.5s)p30
Short Wait 1Fh,28h,61h,02h,tProcessing is stopped for the specified time.
t:Wait time (× module timing unit) (Ref: 3.1 Timing Unit)p30
Scroll display action 1Fh,28h,61h,10h,
wL,wH,cL,cH,sShifts the display screen, enabling horizontal display  
screen scroll action.
wL:Display screen shift byte count, lower byte
wH:Display screen shift byte count, upper byte
cL:Number of cycles, lower byte
cH:Number of cycles, upper byte
s:Scroll speedp31
Blink 1Fh,28h,61h,11h,
p,t1,t2,cBlink display action on display screen.
p:Blink pattern
t1:Normal display time
t2:Blank or Reverse display time
c:Number of cyclesp31
Curtain display action 1Fh,28h,61h,12h,
v,s,pCurtain display action on display screen.
v:Direction of Curtain action
s:Curtain action speed
p:Curtain action patternp32
Spring display action 1Fh,28h,61h,13h,
v,s,pL,pHSpring display action on display screen.
v:Direction of spring action
s:Spring action speed
pL:Display Memory pattern address, lower byte
pH:Display Memory pattern address, upper bytep32
Random display action 1Fh,28h,61h,14h,
s,pL,pHRandom display action on display screen.
s:Random display action speed
pL:Display Memory pattern address, lower byte
pH:Display Memory pattern address, upper bytep33
Display power ON/OFF/auto-
OFF1Fh,28h,61h,40h,p
Default: p=01hControls display power ON/OFF/auto-OFF.
p=00h: Display power OFF
p=01h: Display power ON
p=10h: Display power auto-OFFp34
Display power auto-OFF time 1Fh,28h,61h,40h,
11h,t
Default: t=1EhSets the display power auto-OFF time.
t:Auto-OFF timep34
- 18 -

GU-3900B series “General Function” Software Specification
4.7.3.4Bit image display setting commands
Command Name Hex Code Operation Page
Dot drawing 1Fh,28h,64h,10h,
pen,xL,xH,yL,yHDisplay the dot pattern on a drawing position or delete the  
dot pattern already displayed.
pen:Dot display ON or OFF
xL:Dot pattern drawing position x, lower byte
xH:Dot pattern drawing position x, upper byte
yL:Dot pattern drawing position y, lower byte
yH:Dot pattern drawing position y, upper bytep34
Line/Box pattern drawing 1Fh,28h,64h,11h,
mode,pen,
x1L,x1H,y1L,y1H,
x2L,x2H,y2L,y2HDisplay the Line, Box, Box FILL on the drawing area  
specified by x1,y1,x2,y2 or delete the dot pattern already  
displayed.
mode:Drawing mode select
pen:Dot ON or OFF
x1L:Line/Box pattern drawing start position x1, lower byte
x1H:Line/Box pattern drawing start position x1, upper byte
y1L:Line/Box pattern drawing start position y1, lower byte
y1H:Line/Box pattern drawing start position y1, upper byte
x2L:Line/Box pattern drawing end position x2, lower byte
x2H:Line/Box pattern drawing end position x2, upper byte
y2L:Line/Box pattern drawing end position y2, lower byte
y2H:Line/Box pattern drawing end position y2, upper bytep34
Dot unit downloaded bit image  
display1Fh,28h,64h,20h,
xPL,xPH,yPL,yPH,
m,
aL,aH,aE,
ySL,ySH,
xOL,xOH,
yOL,yOH,
xL,xH,yL,yH,01hDisplay the bit image defined in RAM or FROM at the  
specified (x,y) position.
xPL:Display position x, lower byte (by 1 dot)
xPH:Display position x, upper byte (by 1 dot)
yPL:Display position y, lower byte (by 1 dot)
yPH:Display position y, upper byte (by 1 dot)
m:Image data display memory select
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
ySL:Bit image defined, Y size, lower byte (by 8 dots)
ySH:Bit image defined, Y size, upper byte (by 8 dots)
xOL:Image data offset x, lower byte (by 1 dot)
xOH:Image data offset x, upper byte (by 1 dot)
yOL:Image data offset y, lower byte (by 1 dot)
yOH:Image data offset y, upper byte (by 1 dot)
xL:Bit image display X size, lower byte (by 1 dot)
xH:Bit image display X size, upper byte (by 1 dot)
yL:Bit image display Y size, lower byte (by 1 dot)
yH:Bit image display Y size, upper byte (by 1 dot)p36
Dot unit real-time bit image  
display1Fh,28h,64h,21h,
xPL,xPH,yPL,yPH,
xL,xH,yL,yH,
01h,d(1)...d(k)Display the bit image data at the specified (x,y) position in  
real-time.
xPL:Display position x, lower byte (by 1 dot)
xPH:Display position x, upper byte (by 1 dot)
yPL:Display position y, lower byte (by 1 dot)
yPH:Display position y, upper byte (by 1 dot)
xL:Bit image display X size, lower byte (by 1 dot)
xH:Bit image display X size, upper byte (by 1 dot)
yL:Bit image display Y size, lower byte (by 1 dot)
yH:Bit image display Y size, upper byte (by 1 dot)
d(1)...d(k):Image datap39
Dot unit character display 1Fh,28h,64h,30h,
xPL,xPH,yPL,yPH,
m,bLen,
d(1)...d(bLen)Display the specified text characters at the specified (x,y)  
position.
xPL:Display position x, lower byte (by 1 dot)
xPH:Display position x, upper byte (by 1 dot)
yPL:Display position y, lower byte (by 1 dot)
yPH:Display position y, upper byte (by 1 dot)
m:Response select
bLen:Character data length
d(1)...d(bLen):Character data / reverse selectp41
Real-time bit image display 1Fh,28h,66h,11h,
xL,xH,yL,yH,01h,
d(1)...d(k)Display the supplied bit image data on the cursor position in  
real-time.
xL:Bit image X size, lower byte (by 1 dot)
xH:Bit image X size, upper byte (by 1 dot)
yL:Bit image Y size, lower byte (by 8 dots)
yH:Bit image Y size, upper byte (by 8 dots)
d(1)...d(k):Image datap42
- 19 -

GU-3900B series “General Function” Software Specification
Command Name Hex Code Operation Page
RAM bit image definition 1Fh,28h,66h,01h,
aL,aH,aE,sL,sH,sE,
d(1)...d(s)Define user bit image to RAM.
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
sL:Bit image data length, lower byte
sH:Bit image data length, upper byte
sE:Bit image data length, extension byte
d(1)...d(s):Image datap43
FROM bit image definition
(Only valid in User setup 
mode)1Fh,28h,65h,10h,
aL,aH,aE,sL,sH,sE,
d(1)...d(s)Define user bit image to FROM.
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
sL:Bit image data length, lower byte
sH:Bit image data length, upper byte
sE:Bit image data length, extension byte
d(1)...d(s):Image datap44
Downloaded bit image display 1Fh,28h,66h,10h,m,
aL,aH,aE,
ySL,ySH,
xL,xH,yL,yH,01hDisplay the RAM or FROM bit image defined on cursor  
position.
m:Select bit image data memory
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
ySL:Bit image defined Y size, lower byte (by 8 dots)
ySH:Bit image defined Y size, upper byte (by 8 dots)
xL:Bit image display X size, lower byte (by 1 dot)
xH:Bit image display X size, upper byte (by 1 dot)
yL:Bit image display Y size, lower byte (by 8 dots)
yH:Bit image display Y size, upper byte (by 8 dots)p46
Downloaded bit image scroll 
display1Fh,28h,66h,90h,m,
aL,aH,aE,
ySL,ySH,
xL,xH,yL,yH,01h,sScroll display the RAM, FROM or Display Memory bit image  
from the right end of current window.
m:Select bit image data memory
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
ySL:Bit image defined Y size, lower byte (by 8 dots)
ySH:Bit image defined Y size, upper byte (by 8 dots)
xL:Bit image scroll display X size, lower byte (by 1 dot)
xH:Bit image scroll display X size, upper byte (by 1 dot)
yL:Bit image scroll display Y size, lower byte (by 8 dots)
yH:Bit image scroll display Y size, upper byte (by 8 dots)
s:Scroll speedp48
- 20 -

GU-3900B series “General Function” Software Specification
4.7.3.5General display setting commands
Command Name Hex Code Operation Page
Horizontal scroll display 
quality select1Fh,60h,n
Default:  n=00h or 
Memory SW 
setting.Sets the visual quality of horizontal scroll.
n=00h:Scroll speed-priority
n=01h:Visual quality-priorityp50
Reverse display 1Fh,72h,n
Default:  n=00h or 
Memory SW 
setting.Reverse display setting ON/OFF.
n=00h:Reverse display OFF
n=01h:Reverse display ONp50
Write mixture display mode 1Fh,77h,n
Default:  n=00h or 
Memory SW 
setting.Sets the write mixture mode.  New character or graphic  
image data is mixed with the current display image when  
written to the Display Memory.
n=00h: Normal display write (not mixture display)
n=01h: OR display write,  n=02h: AND display write
n=03h: EX-OR display writep50
4.7.3.6Window display setting commands
Command Name Hex Code Operation Page
Window select 1Fh,28h,77h,01h,aSelects current window.
a=00h:Base-Window,a=01h:User-Window 1
a=02h:User-Window 2,a=03h:User-Window 3
a=04h:User-Window 4p50
User Window 
define / cancel1Fh,28h,77h,02h, 
a,b,
xPL,xPH,yPL,yPH,
xSL,xSH,ySL,ySHDefine or Cancel User-Window
a:Definable window No.
b:Define or Cancel
xPL:Left position of window, lower byte (by 1 dot)
xPH:Left position of window, upper byte (by 1 dot)
yPL:Top position of window, lower byte (by 8 dots)
yPH:Top position of window, upper byte (by 8 dots)
xSL:X size of window, lower byte (by 1 dot)
xSH:X size of window, upper byte (by 1 dot)
ySL:Y size of window, lower byte (by 8 dots)
ySH:Y size of window, upper byte (by 8 dots)p51
4.7.3.7Download character setting commands
Command Name Hex Code Operation Page
Download character ON/OFF 1Bh,25h,n
Default:  n=00hEnable or disable display of download characters.
n=01h: Enable,  n=00h: Disablep52
Download character definition 1Bh,26h,a,c1,c2, 
x[1,d1...dx1,xk
,d1...dxk]Define 6×8, 8×16, 12×24, or 16×32 dot download  
characters into RAM.
a:Select character type
c1:Start character code
c2:End character code
x:Number of dots for X direction
d1...dxk:Definition datap52
Download character delete 1Bh,3Fh,a,cDelete defined 6×8, 8×16, 12×24, or 16×32 dot download  
character.
a:Select character type
c:Delete character codep52
16×16 Download character  
definition1Fh,28h,67h,10h, 
c1,c2,d1...d32Define 16×16 dot download characters into RAM.
c1:Character code, upper byte
c2:Character code, lower byte
d:Definition datap53
16×16 Downloaded character  
delete1Fh,28h,67h,11h, 
c1,c2Delete defined 16×16 dot download character.
c1:Delete character code, upper byte
c2:Delete character code, lower bytep53
32×32 Download character  
definition1Fh,28h,67h,14h, 
c1,c2,d1...d128Define 32×32 dot download characters into RAM.
c1:Character code, upper byte
c2:Character code, lower byte
d:Definition datap53
32×32 Downloaded character  
delete1Fh,28h,67h,15h, 
c1,c2Delete defined 32×32 dot download character.
c1:Delete character code, upper byte
c2:Delete character code, lower bytep54
- 21 -

GU-3900B series “General Function” Software Specification
Command Name Hex Code Operation Page
Download character save
(Only valid in User setup mode)1Fh,28h,65h,11h,aSave the download characters defined on RAM to FROM.
a:Font size
a=01h:6×8 dot
a=02h:8×16 dot
a=03h:16×16 dot
a=04h:16×32 dot
a=05h:32×32 dot
a=06h:12×24 dotp54
Download character restore 1Fh,28h,65h,21h,aTransfer the download characters saved in FROM to RAM.
a:Font size
a=01h:6×8 dot
a=02h:8×16 dot
a=03h:16×16 dot
a=04h:16×32 dot
a=05h:32×32 dot
a=06h:12×24 dotp54
FROM user font definition
(Only valid in User setup mode)1Fh,28h,65h,13h,m,
P(80h-1),P(80h-2),–
P(FFh-n)Define the user font for each size of 1-byte code to the user  
table.
m:User table
m=01h:6×8 dot
m=02h:8×16 dot
m=03h:12×24 dot
m=04h:16×32 dot
p:Definition datap55
FROM extension font definition 1Fh,28h,65h,15h, 
a,b,p(1)...p(65536)Define or delete FROM extension font
a: Bank
b: Define / Delete
p: Definition data (if Define)p55
4.7.3.8User setup mode setting commands
Command Name Hex Code Operation Page
User setup mode start 1Fh,28h,65h,01h, 
49h,4EhUser setup mode start. p55
User setup mode end
(Only valid in User setup 
mode)1Fh,28h,65h,02h, 
4Fh,55h,54hUser setup mode end. p55
4.7.3.9General-purpose I/O Port control commands
Command Name Hex Code Operation Page
I/O Port Input / Output setting 1Fh,28h,70h,01h, 
n,aSet input or output for general-purpose I/O ports.
n: I/O port number
n=00h: Port 0, n=01h: Port 1
a: Set Input / Output (bit-wise)
 bit = 0: Input
 bit = 1: Outputp56
I/O Port Output 1Fh,28h,70h,10h, 
n,aOutput data to general-purpose I/O port.
n: I/O port number
n=00h: Port 0, n=01h: Port 1
a: Output data valuep56
I/O Port Input 1Fh,28h,70h,20h,nThe state of a general-purpose I/O port is transmitted via  
returned.
n: I/O port number
n=00h: Port 0, n=01h: Port 1p56
- 22 -

GU-3900B series “General Function” Software Specification
4.7.3.10Macro setting commands
Command Name Hex Code Operation Page
RAM Macro define / delete 1Fh,3Ah,pL,pH, 
d1...dkDefine or delete RAM Macro or RAM Program Macro.
pL:RAM Macro data length, lower byte
pH:RAM Macro data length, upper byte
d1...dk:RAM Macro datap57
FROM Macro define / delete
(Only valid in User setup 
mode)1Fh,28h,65h,12h, 
a,pL,pH,t1,t2, 
d(1)...d(p)Define or delete FROM Macro or FROM Program Macro.
a:FROM Macro definition number
pL:FROM Macro data length, lower byte
pH:FROM Macro data length, upper byte
t1:Display time interval
t2:Idle time for Macro repetition
d(1)...d(P):FROM Macro datap57
Macro execution 1Fh,5Eh,a,t1,t2Continuously execute Macro.
a:Macro processing definition number
a=00h:RAM Macro
a=01h–04h:FROM Macro 1–4
a=80h:RAM Program Macro
a=81h–84h:FROM Program Macro 1–4
t1:Display time interval
t2:Idle time for Macro repetitionp58
Macro end condition 1Fh,28h,69h,20h,
a,b,c
Default:  a=00h, 
b=00h, c=00h or 
Memory SW 
setting.Macro end condition set.
(Not applicable for Program Macro)
a: Macro end code Enable/Disable
b: Macro end code
c: Macro end Clear Screen settingp59
4.7.3.11Other setting commands
Command Name Hex Code Operation Page
Memory SW setting
(Only valid in User setup 
mode)1Fh,28h,65h,03h,
a,b
1Fh,28h,65h,03h,
a,b,c[1],d[1] 
[...c[b],d[b]]Set Memory SW.
Single setting:
a: Memory SW number
b: Setting value
Multiple setting (a=FFh):
b: Number of settings
c: Memory SW number
d: Setting valuep59
Memory SW data send 1Fh,28h,65h,04h,a
1Fh,28h,65h,04h,
a,b,c[1] [...c[b]]Send the contents of Memory SW data.
Single read:
a: Memory SW number
Multiple read: (a=FFh)
b: No. of reads
c: Memory SW numberp60
General-purpose memory  
store1Fh,28h,65h,18h, 
sL,sH,sE,m1, 
a1L,a1H,a1E, 
d[1]...d[s]Store the supplied data into general-purpose memory.
sL:Data size, lower byte
sH:Data size, upper byte
sE:Data size, extension byte
m1:Memory select
a1L:Memory address, lower byte
a1H:Memory address, upper byte
a1E:Memory address, extension byte
d:Data to storep60
General-purpose memory  
transfer1Fh,28h,65h,19h, 
sL,sH,sE,m1, 
a1L,a1H,a1E,m2, 
a2L,a2H,a2ETransfer data between general-purpose memory areas.
sL:Transfer size, lower byte
sH:Transfer size, upper byte
sE:Transfer size, extension byte
m1:Destination memory select
a1L:Destination address, lower byte
a1H:Destination address, upper byte
a1E:Destination address, extension byte
m2:Source memory select
a2L:Source address, lower byte
a2H:Source address, upper byte
a2E:Source address, extension bytep61
- 23 -

GU-3900B series “General Function” Software Specification
Command Name Hex Code Operation Page
General-purpose memory  
send1Fh,28h,65h,28h,
sL,sH,sE,m1,
a1L,a1H,a1ESend data stored in general-purpose memory.
sL:Data size, lower byte
sH:Data size, upper byte
sE:Data size, extension byte
m1:Memory select
a1L:Memory address, lower byte
a1H:Memory address, upper byte
a1E:Memory address, extension bytep61
Display status send 1Fh,28h,65h,40h,
a,b,cSend display status information.
a:Information name
a=01h:Boot version information
a=02h:Firmware version information
a=10h:2-byte character code information
a=11h:Language type information
a=20h:Memory checksum information
a=30h:Product information
a=40h:Display x dot information
a=41h:Display y dot information
b:Start address
c:Data lengthp62
RS-232 serial settings 1Fh,28h,69h,10h,
a,bChange the RS-232 serial interface communication  
parameters.
a:Baud rate setting
a=00h:19200 bps
a=01h:4800 bps
a=02h:9600 bps
a=03h:19200 bps
a=04h:38400 bps
a=05h:57600 bps
a=06h:115200 bps
07h ≤ a ≤ 0Bh: Setting prohibited
b:Parity setting
b=00h:No parity
b=01h:Even parity
b=02h:Odd parityp62
Memory re-write mode 1Ch,7Ch,4Dh,
D0h,4Dh,4Fh,44h,
45h,49h,4EhShift to “Memory re-write mode” from “Normal mode”. p62
- 24 -

GU-3900B series “General Function” Software Specification
4.7.4Command Set Details
4.7.4.1US X n(Brightness level setting)
Code:1Fh  58h  n
n:Brightness level setting
Definable area:00h ≤ n ≤ 04h, 10h ≤ n ≤ 18h
Default:n = 04h or Memory SW setting.
Function:Set display brightness level.
n: Level
nBrightness level nBrightness level
00h0%12h25%
01h25%13h37.5%
02h50%14h50%
03h75%15h62.5%
04h100%16h75%
10h0%17h87.5%
11h12.5%18h100%
4.7.4.2ESC @(Initialize Display)
Code:1Bh  40h
Settings return to default values.
DIP Switch is not re-loaded.
Contents of receive buffer r emain in memory.
4.7.4.3US $ x y(Cursor Set)
Code:1Fh  24h  xL  xH  yL  yH
xL:Cursor position x, lower byte (1 dot / unit)
xH:Cursor position x, upper byte (1 dot / unit)
yL:Cursor position y, lower byte (8 dots / unit)
yH:Cursor position y, upper byte (8 dots / unit)
Definable area:0000h ≤ (xL + xH×100h) ≤ Max_Xdot
0000h ≤ (yL + yH×100h) ≤ Max_Ybyte
Function:Cursor moves to the specified (X, Y) position on Display Memory.
If the specified X, Y position (X and/or Y) is outside the definable area, the command is ignored and  
the cursor remains in the same position.
This command has effect for the currently-selected window.
4.7.4.4US C n(Cursor display ON/OFF)
Code:1Fh  43h  n
n:Cursor display setting
Definable area:00h ≤ n ≤ 01h
n = 00h: Cursor display OFF
n = 01h: Cursor display ON
Default:n = 00h (Cursor OFF)
Function:Cursor display setting.
When cursor display is ON, cursor position appears as reverse blinking, 1×8 dots.
When cursor is in hidden area, it does not appear, even when cursor display is set ON.
This command has effect for the currently-selected window.
- 25 -

GU-3900B series “General Function” Software Specification
4.7.4.5US ( w 10h a(Write screen mode select)
Code:1Fh  28h  77h  10h  a
a:  Write screen mode
a = 00h: Display screen mode
a = 01h: All screen mode
Definable area:00h ≤ a ≤ 01h
Default:a = 00h or Memory SW setting.
Function:Select the write screen mode.  This setting is only applicable for Base-Window.
Display screen mode:  Display action is valid within area of either Display area or Hidden area,  
depending on cursor position.
All screen mode: Display action is valid over the entire display memory.
4.7.4.6ESC R n(International font set)
Code:1Bh  52h  n
Definable area:00h ≤ n ≤ 0Dh
Default:n = 00h or Memory SW setting.
Function:Select international font set.
Characters already displayed are not affected.
- 26 -nFont set
00hAmerica
01hFrance
02hGermany
03hEngland
04hDenmark 1
05hSweden
06hItaly
07hSpain1
08hJapan
09hNorway
0AhDenmark2
0BhSpain2
0ChLatin America
0DhKoreaDisplay memory
8 dots1 dot
Cursor position

GU-3900B series “General Function” Software Specification
4.7.4.7ESC t n(Character table type)
Code:1Bh  74h  n
Definable area:n = 00h, 01h, 02h, 03h, 04h, 05h, 10h, 11h, 12h, 13h, FFh
Default:n = 0 or Memory SW setting.
Function:Select Character table type.
Characters already displayed are not affected.
FFh (User table): The user-defined font table (refer to FROM user font definition command).
nFont code type
00hPC437(USA – Euro std)
01hKatakana – Japanese
02hPC850 (Multilingual)
03hPC860 (Portuguese)
04hPC863 (Canadian-French)
05hPC865 (Nordic)
10hWPC1252
11hPC866 (Cyrillic #2)
12hPC852 (Latin 2)
13hPC858
FFhUser table
4.7.4.8US MD1(Over-write mode)
Code:1Fh  01h
Function:Display mode set to Over-write mode.
This command has effect for the currently-selected window.
4.7.4.9US MD2(Vertical scroll mode)
Code:1Fh  02h
Function:Display mode set to Vertical scroll mode.
This command has effect for the currently-selected window.
4.7.4.10US MD3(Horizontal scroll mode)
Code:1Fh  03h
Function:Display mode set to Horizontal scroll mode.
This command has effect for the currently-selected window.
4.7.4.11US MD5(Horizontal scroll mode, scroll ON)
Code:1Fh  05h
Function:Display mode set to Horizontal scroll mode, scroll ON state.
After this command, operation is same as MD3 mode.
This command has effect for the currently-selected window.
4.7.4.12US s n(Horizontal scroll speed)
Code:1Fh  73h  n
Definable area:00 ≤ n ≤ 1Fh
Default:n = 00h or Memory SW setting.
Function:Set speed for Horizontal scroll mode.
Scroll speed is set by n.
Subsequent commands are not processed until scroll is completed.
Scroll base time period “T” = module timing unit, but may be longer due to screen mode or character  
size, etc.  Refer to 3.1 Timing Unit.
nSpeed
00hInstantaneous01hT ms / 2 dots02h – 1Fh(n−1)×T ms / dot
Note:  Scroll speed is approximate.  Depending on the scrolling area, scroll may reduce in speed or  
flicker.  See also 4.7.4.39 Horizontal scroll display quality select.
- 27 -

GU-3900B series “General Function” Software Specification
4.7.4.13US ( g 01h m(Font size select)
Code:1Fh  28h  67h  01h  m
Definable area:m = 01h, 02h, 03h, 04h
Default:m = 01h or Memory SW setting.
Function:Sets the font size for 1-byte  
characters.
4.7.4.14US ( g 02h m(2-byte character)
Code:1Fh  28h  67h  02h  m
Definable area:m = 00h, 01h
Default:m = 00h or Memory SW setting.
Function:Sets 2-byte character ON/OFF.
4.7.4.15US ( g 03h m,  US ( g 0Fh m (2-byte character type)
Code:1Fh  28h  67h  03h  m
1Fh  28h  67h  0Fh  m
Definable area:m = 00h, 01h, 02h, 03h
Default:m = 00h or Memory SW  
setting.
Function:Sets 2-byte character type.
To display a 16×16 dot, 2-byte character:
Font size select: Code:1Fh 28h 67h 01h 02h
2-byte character ON: Code:1Fh 28h 67h 02h 01h
2-byte character type: Code:1Fh 28h 67h 03h 00h  Japanese
         1Fh 28h 67h 03h 01h  Korean
         1Fh 28h 67h 03h 02h  Simplified Chinese
　　　         1Fh 28h 67h 03h 03h  Traditional Chinese
2-byte character code input: Code: 88h 9Fh (“” 亜Example Japanese character)
- 28 -m Function
01h6×8 dot character
02h8×16 dot character
03h12×24 dot character
04h16×32 dot character
mFunction
00h2-byte character mode OFF
01h2-byte character mode ON
mFunctionCode type
00hJapaneseJIS X0208(Shift-JIS)
01hKoreanKSC5601-87
02hSimplified Chinese GB2312-80
03hTraditional Chinese Big-5

GU-3900B series “General Function” Software Specification
4.7.4.16US ( g 04h m(Font Width)
Code:1Fh  28h  67h  04h  m
m:Font width setting
Definable area:m = 00h, 02h, 03h, 04h
Default:m = 00h
Function:Sets the character width.
For fixed-width font, all characters are displayed as font size.
For proportional font, characters are displayed as:
display width = right blank + character width + left blank
6×8 dot character
mCharacter widthLeft blank 
dotsRight blank 
dotsSpace (20h) 
character width
00hFixed-width 006
02hProportional 1 012
03hProportional 2 112
04hProportional 3 222
8×16 dot character
mCharacter widthLeft blank 
dotsRight blank 
dotsSpace (20h) 
character width
00hFixed-width 008
02hProportional 1 014
03hProportional 2 114
04hProportional 3 224
12×24 dot character
mCharacter widthLeft blank 
dotsRight blank 
dotsSpace (20h) 
character width
00hFixed-width 0012
02hProportional 1 026
03hProportional 2 226
04hProportional 3 446
16×32 dot character
mCharacter widthLeft blank 
dotsRight blank 
dotsSpace (20h) 
character width
00hFixed-width 0016
02hProportional 1 028
03hProportional 2 228
04hProportional 3 448
Example:  Proportional 2, 6×8 dot character 'I'
Left blank Character width Right blank
- 29 -

GU-3900B series “General Function” Software Specification
4.7.4.17US ( g 05h n(FROM Extended Font)
Code:1Fh  28h  67h  05h  n
n:FROM Extended Font select
Definable area:00h ≤ n ≤ FFh
Default:n = 00h
Function:n=00h:  Normal font.
n=01h–FFh:  FROM Extended Font (if FROM Extended Font is defined).
4.7.4.18US ( g 40h x y(Font Magnification)
Code:1Fh  28h  67h  40h  x  y
x:　X magnification factor
y:Y magnification factor
Definable area:01h ≤ x ≤ 04h
01h ≤ y ≤ 04h (Ydots ≥ 40h)
01h ≤ y ≤ 02h (Ydots = 20h)
01h ≤ y ≤ 01h (Ydots = 10h)
Default:x = 01h or Memory SW setting.
y = 01h or Memory SW setting.
Function:Set character magnification 'x' times to the right and 'y' times downward.
4.7.4.19US ( g 41h b(Bold character)
Code:1Fh  28h  67h  41h  b
b:Bold
Definable area:00h ≤ b ≤ 01h
    b = 00h: Bold OFF  /  b = 01h: Bold ON
Default:b = 00h or Memory SW setting.
Function:Boldface character ON/OFF  (Boldface may reduce legibility)
4.7.4.20US ( a 01h t(Wait)
Code:1Fh  28h  61h  01h  t
t:Wait time
Definable area:00h ≤ t ≤ FFh
Function:Waits for the specified time (command and data processing is stopped).
Wait time = t × approximately 0.5s
Command / data processing does not resume until wait time is completed.
It is possible to interrupt this command if the command is defined and run in a Macro.
4.7.4.21US ( a 02h t(Short Wait)
Code:1Fh  28h  61h  02h  t
t:Wait time
Definable area:00h ≤ t ≤ FFh
Function:  Waits for the specified time (command and data processing is stopped).
Wait time = t × module timing unit (refer to 3.1 Timing Unit)
Command / data processing does not resume until wait time is completed.
It is possible to interrupt this command if the command is defined and run in a Macro.
- 30 -

GU-3900B series “General Function” Software Specification
4.7.4.22US ( a 10h wL wH cL cH s (Scroll display action)
Code:1Fh  28h  61h  10h  wL  wH  cL  cH  s
wL:Display screen shift byte count, lower byte
wH:Display screen shift byte count, upper byte
cL:Number of cycles, lower byte
cH:Number of cycles, upper byte
s:Scroll speed
Definable area:0000h ≤ (wL + wH×100h) ≤ Max_DispMemAddr
0001h ≤ (cL + cH×100h) ≤ FFFFh
00h ≤ s ≤ FFh
Function:Shift the display screen.
Horizontal scrolling is possible by specifying as the shift byte count a multiple of Ybytes.  Display  
switching is possible by specifying shift byte count as (Display screen “x” dot × Ybytes).  Scroll speed  
is specified by 's'.
Scroll speed: s × module timing unit / shift (refer to 3.1 Timing Unit)
Command / data processing does not resume until wait time is completed.
It is possible to interrupt this command if the command is defined and run in a Macro.
For example: 1 dot scroll to the left: wL=08h, wH=00h, 256×64 dot module.
4.7.4.23US ( a 11h p t1 t2 c (Blink)
Code:1Fh  28h  61h  11h  p  t1  t2  c
p:Blink pattern
t1:Normal display time
t2:Blank or reverse display time
c:Number of cycles
Definable area:00h ≤ p ≤ 02h
p=00h:  Normal display.
p=01h:  Blink display (alternately Normal and Blank display).
p=02h:  Blink display (alternately Normal and Reverse display).
01h ≤ t1 ≤ FFh
01h ≤ t2 ≤ FFh
00h ≤ c ≤ FFh
Function:Blink display action Blink pattern specified by “p”.
Time is specified by “t1” and “t2”
A: t1 × module timing unit Normal display
B: t2 × module timing unit Blank or Reverse display (refer to 3.1 Timing Unit) 
Repeated 'c' times.
This command does not affect Display Memory.
c=00h:  Blink continues during subsequent command and data processing, until c=01h–FFh is set, or 
Initialize command.
c=01h–FFh:  Blink display is repeated 1–255 times while command and data processing is stopped.  
After display blinking is completed, Normal display returns and command and data processing  
resumes.
Command / data processing does not resume until operation is completed.
This command cannot be interrupted when running in a Macro.
- 31 -
0000h0007h0008h000Fh07F8h07FFh0FF8h0FFFh
0FF0h0FF7h
Display area 256 dots Hidden area 256 dots

GU-3900B series “General Function” Software Specification
4.7.4.24US ( a 12h v s p (Curtain display action)
Code:1Fh  28h  61h  12h  v  s  p
v:Direction of Curtain action
s:Curtain action speed
p:Curtain action pattern
Definable area:00h ≤ v ≤ 03h
v=00h: To the Right from the Left edge
v=01h: To the Left from the Right edge.
v=02h: To the Left and Right separately from the Center.
v=03h: To the Center from Left edge and Right edge.
00h ≤ s ≤ FFh
00h ≤ p ≤ FFh
Function:Curtain display action on display screen
Curtain action pattern 'p' is displayed from the direction specified by 'v'.
Curtain action speed is:
Curtain action speed = 256 / 8 × s × module timing unit (refer to 3.1 Timing Unit)
This command only affects the display area.  The non-display area memory is not affected.
Example is shown below.
Command / data processing does not resume until operation is completed.
If it is necessary to be able to cancel the display action during processing, this is possible if the  
command is defined and run in a Macro.
Example:
4.7.4.25US ( a 13h v s pL pH (Spring display action)
Code:1Fh  28h  61h  13h  v  s  pL  pH
v:Direction of spring action
s:Spring action speed
pL:Display Memory pattern address, lower byte
pH:Display Memory pattern address, upper byte
Definable area:00h ≤ v ≤ 03h
v=00h: To the Right from the Left edge.
v=01h: To the Left from the Right edge.
v=02h: To the Left and Right separately from the Center.
v=03h: To the Center from Left edge and Right edge.
00h ≤ s ≤ FFh
0000h ≤ (pL + pH×100h) ≤ Max_DispMemAddr
Function:Spring display action on display screen.
Pattern 'p' specified by Display Memory pattern address is displayed from the direction specified by  
'v'.
Spring action speed is as follows;
Spring action speed = 256 / 8 × s × module timing unit (refer to 3.1 Timing Unit)
This command effects only the display area, not hidden area.
Command / data processing does not resume until operation is completed.
If it is necessary to be able to cancel the display action during processing, this is possible if the  
command is defined and run in a Macro.
Example is shown below.
- 32 -０１２３４５６７
Display areaP PAction Start
Display areaPAction End

GU-3900B series “General Function” Software Specification
4.7.4.26US ( a 14h s pL pH (Random display action)
Code:1Fh  28h  61h  14h  s  pL  pH
s:Random display action speed
pL:Display Memory pattern address, lower byte
pH:Display Memory pattern address, upper byte
Definable area:00h ≤ s ≤ FFh
0000h ≤ (pL + pH×100h) ≤ Max_DispMemAddr
Function:Random display action on display screen.
Pattern “p” specified by Display Memory pattern address is displayed randomly.
Random display action is completed in 8 steps, at approximately (s × 4 × module timing unit) / step.  
(Refer to 3.1 Timing Unit)
This command effects only the display area, not hidden area.
Command / data processing does not resume until operation is completed.
If it is necessary to be able to cancel the display action during processing, this is possible if the  
command is defined and run in a Macro.
Example is shown below.
Action start 
Action end
- 33 -０１２３４５６７
Display area０１２３４５６７
Hidden area
０１２３４５６７
Display area０１２３４５６７
Hidden areaAction start
Action end
Display area Hidden area０１２３４５６７ ０１２３４５６７０１２３４５６７ ０１２３４５６７
Display area Hidden area

GU-3900B series “General Function” Software Specification
4.7.4.27US ( a 40h p(Display power ON/OFF/auto-OFF)
Code:1Fh  28h  61h  40h  p
p:Set display power ON/OFF/auto-OFF
Definable area:p=00h: Power OFF (Display OFF, Power save mode)
p=01h: Power ON (Display ON)
p=10h: Power auto-OFF (Display ON → Display OFF, Power save mode)
Default:p = 01h
Function:Control display power ON / OFF / auto-OFF.
Display power ON/OFF setting applies until the next Display power or Initialize command, or power-
off.
For display power auto-OFF, display power is ON, and is then turned OFF after Display power auto-
OFF time.  Regardless of the elapsed time, at the point of receiving any data, this mode is cancelled  
and display power is turned ON.
4.7.4.28US ( a 40h 11h t (Display power auto-OFF time)
Code:1Fh  28h  61h  40h  11h  t
t:auto-OFF time
Definable area:01h ≤ t ≤ FFh
Default:t = 1Eh (approximately 30 minutes)
Function:Set display power auto-OFF time.
auto-OFF time = t × 1 minute (±10%)
4.7.4.29US ( d 10h pen xL xH yL yH (Dot drawing)
Code:1Fh  28h  64h  10h  pen  xL  xH  yL  yH
pen:Dot display ON or OFF
xL:Dot position x, lower byte
xH:Dot position x, upper byte
yL:Dot position y, lower byte
yH:Dot position y, upper byte
Definable area:00h ≤ pen ≤ 01h
pen = 00h: Dot Display OFF, pen = 01h: Dot Display ON
0000h ≤ (xL + xH×100h) ≤ Max_Xdot
0000h ≤ (yL + yH×100h) ≤ Max_Ydot
Function:Display the dot at the position specified, or delete the dot already displayed.
This command has effect for the currently-selected window.
If Dot display ON/OFF, or Dot position is outside the definable area, the command is cancelled at  
that point and the following data is treated as standard data.
4.7.4.30US ( d 11h mode pen x1L x1H y1L y1H x2L x2H y2L y2H (Line/Box pattern drawing)
Code:1Fh  28h  64h  11h  mode  pen  x1L  x1H  y1L  y1H  x2L  x2H  y2L  y2H
mode:Line / Box / Box FILL select (refer to illustration)
pen:Line/Box Display ON or OFF
x1L:Line/Box pattern drawing start position x1, lower byte
x1H:Line/Box pattern drawing start position x1, upper byte
y1L:Line/Box pattern drawing start position y1, lower byte
y1H:Line/Box pattern drawing start position y1, upper byte
x2L:Line/Box pattern drawing end position x2, lower byte
x2H:Line/Box pattern drawing end position x2, upper byte
y2L:Line/Box pattern drawing end position y2, lower byte
y2H:Line/Box pattern drawing end position y2, upper byte
Definable area:00h ≤ mode ≤ 02h
mode = 00h:  Line
mode = 01h:  Box
mode = 02h:  Box FILL
00h ≤ pen ≤ 01h
pen = 00h:  Line/Box  Display OFF,  pen = 01h:  Line/Box  Display ON
0000h ≤ (x1L + x1H×100h) ≤ Max_Xdot
0000h ≤ (y1L + y1H×100h) ≤ Max_Ydot
0000h ≤ (x2L + x2H×100h) ≤ Max_Xdot
0000h ≤ (y2L + y2H×100h) ≤ Max_Ydot
- 34 -

GU-3900B series “General Function” Software Specification
Function:Display a Line, Box, or Box FILL on the drawing area specified by (x1,y1)–(x2,y2) or  
delete the dot pattern already displayed.
This command has effect for the currently-selected window.
If Display ON/OFF or Dot pattern drawing position is outside the definable area, the command is  
cancelled at that point and the following data is treated as standard data.
If a diagonal line is specified, parts of the line may be 2 or more dots in width.
Drawing mode
- 35 -Line Drawing
(X1,Y1)
(X2,Y2)
Box Drawing
(X1,Y1)
(X2,Y2)Box FILL Drawing
(X1,Y1)
(X2,Y2)

GU-3900B series “General Function” Software Specification
4.7.4.31US ( f 20h xPL xPH yPL yPH m aL aH aE ySL ySH xOL xOH yOL yOH xL xH yL yH g)    (Dot  
unit downloaded bit image display)
Code:1Fh  28h  64h  20h  xPL  xPH  yPL  yPH  m  aL  aH  aE  ySL  ySH  xOL  xOH  yOL  yOH  
xL  xH  yL  yH  g
xPL:Display position x, lower byte (by 1 dot)
xPH:Display position x, upper byte (by 1 dot)
yPL:Display position y, lower byte (by 1 dot)
yPH:Display position y, upper byte (by 1 dot)
m:Image data display memory select
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
ySL:Bit image defined, Y size, lower byte (by 8 dots)
ySH:Bit image defined, Y size, upper byte (by 8 dots)
xOL:Image data offset x, lower byte (by 1 dot)
xOH:Image data offset x, upper byte (by 1 dot)
yOL:Image data offset y, lower byte (by 1 dot)
yOH:Image data offset y, upper byte (by 1 dot)
xL:Bit image display, X size, lower byte (by 1 dot)
xH:Bit image display, X size, upper byte (by 1 dot)
yL:Bit image display, Y size, lower byte (by 1 dot)
yH:Bit image display, Y size, upper byte (by 1 dot)
g:Image information = 01h (fixed)
Definable area:0000h ≤ (xPL + xPH×100h) ≤ Max_Xdot
0000h ≤ (yPL + yPH×100h) ≤ Max_Ydot
00h ≤ m ≤ 02h
m = 00h:RAM bit image
m = 01h:FROM bit image
m = 02h:Display Memory bit image
RAM bit image:
000000h ≤ (aL + aH×100h + aE×10000h) ≤ 000FFFh
FROM bit image:
aE = 00h
000000h ≤ (aL + aH×100h + aE x 10000h) ≤ 007FFFh
aE=01h – 04h (Extension area, 4 blocks)
010000h ≤ (aL + aH×100h + aE x 10000h) ≤ 04FFFFh
Display Memory bit image:
000000h ≤ (aL + aH×100h + aE×10000h) ≤ Max_DispMemAddr
0000h ≤ (ySL + ySH×100h) ≤ FFFFh
0000h ≤ (xOL + xOH×100h) ≤ FFFFh
0000h ≤ (yOL + yOH×100h) ≤ FFFFh
0001h ≤ (xL + xH×100h) ≤ Xdots
0001h ≤ (yL + yH×100h) ≤ Ydots
g=01h
Function:Display the bit image defined in RAM or FROM at the specified (x,y) position.
Display position, display size, and image data offset are specified in units of 1 dot.
If bit image exceeds the bounds of the current window, only the portion within the currently-selected  
window is displayed.
If Display position or image size, etc are outside the definable area, the command is cancelled at the  
point where the error is detected, and the remaining data is treated as standard data.
- 36 -

GU-3900B series “General Function” Software Specification
Example:
Display position xP=2, xP=3
Defined image data m=01h, a=001000h
Defined image, Y size yS=0010h
Offset xO=1, yO=3
Display size x=9, y=12
FROM Bit Image memoryx=9
xO=1
001000h-001010h-001020h-001030h-001040h-001050h-001060h-001070h-001080h-001090h-0010A0h-0010B0h-
b7yS=0010hb6
b5
y=12yO=3b4a
b3
b2
b1
b0
b7
b6
b5
b4
b3
b2
b1
b0
b7
b6
b2
b1
b0
- 37 -

GU-3900B series “General Function” Software Specification
Display Memory
x=9
xP
01234567891011
0
1
2
y=12yP3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
- 38 -

GU-3900B series “General Function” Software Specification
4.7.4.32US ( d 21h xPL xPH yPL yPH xL xH yL yH g d(1)...d(k) (Dot unit real-time bit image  
display)
Code: 1Fh  28h  64h  21h  xPL  xPH  yPL  yPH  xL  xH  yL  yH  g  d(1)...d(k)
xPL:Display position x, lower byte (by 1 dot)
xPH:Display position x, upper byte (by 1 dot)
yPL:Display position y, lower byte (by 1 dot)
yPH:Display position y, upper byte (by 1 dot)
xL:Bit image display X size, lower byte (by 1 dot)
xH:Bit image display X size, upper byte (by 1 dot)
yL:Bit image display Y size, lower byte (by 1 dot)
yH:Bit image display Y size, upper byte (by 1 dot)
g:Display information = 1 (fixed)
d(1)–d(k):Bit image data (see below)
Definable area:0000h ≤ (xPL + xPH×100h) ≤ Max_Xdot
0000h ≤ (yPL + yPH×100h) ≤ Max_Ydot
0001h ≤ (xL + xH×100h) ≤ Xdots
0001h ≤ (yL + yH×100h) ≤ Ydots
g = 01h
00h ≤ d ≤ FFh
Function:Display the bit image data at the specified (x,y) position in real-time.
Display position and display size are specified in units of 1 dot.
If bit image exceeds the bounds of the current window, only the portion within the currently-selected  
window is displayed.
If Display position or display size are outside the definable area, the command is cancelled at the  
point where the error is detected, and the remaining data is treated as standard data.
Example:  xP=2, yP=3,  Display size x=8, y=14
Image data
b7d1d3d5d7d9d11d13d15
b6
b5
b4
b3
b2
b1
b0
b7d2d4d6d8d10d12d14d16
b6
b5
b4
b3
b2
b1
b0
- 39 -

GU-3900B series “General Function” Software Specification
Display Memory
x=8
xP
01234567891011
0
1
2
y=14yP3d1d3d5d7d9d11d13d15
4
5
6
7
8
9
10
11d2d4d6d8d10d12d14d16
12
13
14
15
16
17
18
- 40 -

GU-3900B series “General Function” Software Specification
4.7.4.33US ( d 30h xPL xPH yPL yPH m bLen d(1)...d(bLen) (Dot unit character display)
Code:1Fh  28h  64h  30h  xPL  xPH  yPL  yPH  m  bLen  d(1)...d(bLen)
xPL:Display position x, lower byte (by 1 dot)
xPH:Display position x, upper byte (by 1 dot)
yPL:Display position y, lower byte (by 1 dot)
yPH:Display position y, upper byte (by 1 dot)
m:Response select
bLen:Character data length
d(1)–d(bLen):Character data / reverse select
Definable area:0000h ≤ (xPL + xPH×100h) ≤ Max_Xdot, FFFFh
0000h ≤ (yPL + yPH×100h) ≤ Max_Ydot
00h ≤ m ≤ 01h
00h ≤ bLen ≤ FFh
00h ≤ d ≤ FFh
d=10h:  Reverse OFF
d=11h:  Reverse ON
Function:Display the specified text characters at the specified (x,y) position.
Display position is specified in units of 1 dot.
For display position xP=FFFFh, write position continues from previous writes done using this  
command.
The current settings for character size and table type, etc are used.
Character magnification and bold settings are not used.
If character display exceeds the bounds of the current window, only the portion within the currently-
selected window is displayed.
If Display position or Response select is outside the definable area, the command is cancelled at the  
point where the error is detected, and the remaining data is treated as standard data.
Example:  Display position  xP=2, yP=3, 6×8 dot character “AB”
Display Memory
xP
012345678910111213
0
1
2
yP3
4
5
6
7
8
9
10
11
Response select m=01h:  The display position of the next character is returned as response data.
If the display position would be 20 – 30 beyond the area of the currently-selected window, 0xFFFFh  
is returned.
Transmitted data HexData length
(1) Header 28h1 byte
(2) Identifier 1 64h1 byte
(3) Identifier 2 30h1 byte
(4) Display position X, 
lower byte00h–FFh1 byte
(5) Display position X, 
upper byte00h–FFh1 byte
- 41 -

GU-3900B series “General Function” Software Specification
4.7.4.34US ( f 11h xL xH yL yH g d(1)...d(k) (Real-time bit image display)
Code:1Fh  28h  66h  11h  xL  xH  yL  yH  g  d(1)...d(k)
xL:Bit image X size, lower byte (by 1 dot)
xH:Bit image X size, upper byte (by 1 dot)
yL:Bit image Y size, lower byte (by 8 dots)
yH:Bit image Y size, upper byte (by 8 dots)
g:Image information = 1 (fixed)
d(1)–d(k):Bit Image data (see below)
Definable area:0001h ≤ (xL + xH×100h) ≤ Xdots
0001h ≤ (yL + yH×100h) ≤ Ybytes
g = 01h
k = x × y × g
00h ≤ d ≤ FFh
Function:Display the bit image data at the cursor position in real-time.
Cursor position does not change.
If bit image exceeds the bounds of the current window, only the portion within the currently-selected  
window is displayed.
If Display position or display size etc, are outside the definable area, the command is cancelled at  
the point where the error is detected, and the remaining data is treated as standard data.
- 42 -Display Memory
Cursor position
yx
dyd(y+1)d(y+2)
d1d2d(y*2)

GU-3900B series “General Function” Software Specification
4.7.4.35US (f 01h aL aH aE sL sH sE d(1)...d(s) (RAM bit image definition)
Code:1Fh  28h  66h  01h  aL  aH  aE  sL  sH  sE  d(1)...d(s)
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
sL:Bit image data length, lower byte
sH:Bit image data length, upper byte
sE:Bit image data length, extension byte
d(1)–d(s):Image data (see below)
Definable area:000000h ≤ (aL + aH×100h+ aE×10000h) ≤ 000FFFh
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 001000h
00h ≤ d ≤ FFh
Function: Define user bit image to the RAM.
RAM bit image capacity is 4096 bytes.
Bit image data at arbitrary addresses can be defined or changed by appropriately setting Bit image  
data definition address and Bit image data length.
Bit images defined in RAM can be displayed using 4.7.4.37 Downloaded bit image display command.
If Bit image data definition address or Bit image data length is outside the definable area, the  
command is cancelled at that point, and the remaining data is treated as standard data.
Example:  RAM Bit image definition memory
Define 8 bytes data “0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h,11h” from definition address “00000Ah”
- 43 -
0000h0001h0003h03FCh03FDh03FFh03FEh
0002hAddress 'a'  (=00000Ah) Data length 's' (= 8)
d(1)
=0Ah
d(2)
=0Bhd(3)
=0Ch
d(4)
=0Dh
d(5)
=0Eh
d(6)
=0Fhd(7)
=10h
d(s)
=11h(Code) 1Fh 28h 66h 01h 0Ah 00h 00h 08h 00h 00h 0Ah 0Bh 0Ch 0Dh 0Eh 0Fh 10h 11h
Memory Address

GU-3900B series “General Function” Software Specification
4.7.4.36US ( e 10h aL aH aE sL sH sE d(1)...d(s) (FROM bit image definition)
Code:1Fh  28h  65h  10h  aL  aH  aE  sL  sH  sE  d(1)...d(s)
aL:Bit image data definition address, lower byte (bit 0 ignored)
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
sL:Bit image data length, lower byte (bit 0 ignored)
sH:Bit image data length, upper byte
sE:Bit image data length, extension byte
d(1)–d(s):Bit Image data (see below)
Definable area:aE = 00h – 04h
aE = 00h:
000000h ≤ ((aL & FEH) + aH×100h + aE×10000h) ≤ 007FFEh
000002h ≤ ((sL & FEH) + sH×100h + sE×10000h) ≤ 008000h
aE = 01h – 04h (Extension area, 4 blocks):
010000h ≤ ((aL & FEH) + aH×100h + aE×10000h) ≤ 04FFFEh
000002h ≤ ((sL & FEH) + sH×100h + sE×10000h) ≤ 010000h
00h ≤ d ≤ FFh
Function:Define user bit image to the FROM.
FROM bit image capacity is 32,768 bytes + Extension area 262,144 bytes.
Data is defined or changed from the specified Bit image data definition address for the number of  
bytes specified by Bit image data length.
Bit images defined in FROM can be displayed using 4.7.4.37 Downloaded bit image display  
command.
The least significant bit for both Bit image data definition address and Bit image data length is  
ignored – these are processed as even values.
If Bit image data definition address or Bit image data length is outside the definable area, the  
command is cancelled at that point, and the remaining data is treated as standard data.
This command is only valid in User setup mode.
BUSY signal is output by the display module during processing of this command.  The host should  
not transmit any data during this time.
aE = 00h:
Total definable area is 000000h to 007FFFh (32,768 bytes).  Bit image definition is performed in units  
of 2 bytes.
aE = 01h – 04h:
Total definable area is 010000h to 04FFFFh (262,144 bytes).  Bit image definition is performed in  
units of 65536 bytes (64KB).  For example, if 10KB of bit image data is defined, the remaining 54KB  
data is set to FFh.
Bit image data definition address cannot be specified in such a way that the definition data would  
overflow into the area of the next extension byte (for example, 01xxxxh – 02xxxxh).  The command is  
cancelled if this situation is detected, and the remaining data is treated as standard data.
Defined contents are not guaranteed if an error occurs.
- 44 -

GU-3900B series “General Function” Software Specification
Example 1:  FROM Bit image definition memory  aE=00h area
Define 8 bytes data” 0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h,11h” from definition address “00000Ah”
Example 2:  FROM Bit image definition memory  aE=01h area
Define 8 bytes data “0Ah,0Bh,0Ch,0Dh,0Eh,0Fh,10h,11h” from definition address “01000Ah”
Note:  Areas aE=02h – 04h are also processed as above.
- 45 -
010000h010001h010003h01FFFCh01FFDh01FFFFh01FFFEh
010002hAddress 'a'  (=01000Ah) Data length 's' (= 8)(Code) 1Fh 28h 65h 10h 0Ah 00h 01h 08h 00h 00h 0Ah 0Bh 0Ch 0Dh 0Eh 0Fh 10h 11h
Memory Address
d(3)
=0Ch
d(4)
=0Dh
d(5)
=0Eh
d(6)
=0Fhd(1)
=0Ah
d(2)
=0Bhd(7)
=10h
d(s)
=11hFFh  FFh  FFh
FFh  FFh  FFh
FFh  FFh
FFh  FFhFFh
 FFh
FFh  FFh
FFh  FFhFFh  FFh
FFh  FFh
FFh  FFh
FFh  FFhData replaced by FFh 
outside definition area.(Code) 1Fh 28h 65h 10h 0Ah 00h 00h  08h 00h 00h  0Ah 0Bh 0Ch 0Dh 0Eh 0Fh 10h 11h
0000h0001h 0003h7FFCh7FFDh 7FFFh 7FFEh
0002hAddress 'a'  (=00000Ah) Data length 's' (= 8)Memory Address
d(1)
=0Ah
d(2)
=0Bhd(3)
=0Ch
d(4)
=0Dh
d(5)
=0Eh
d(6)
=0Fhd(7)
=10h
d(s)
=11h

GU-3900B series “General Function” Software Specification
4.7.4.37US ( f 10h m aL aH aE ySL ySH xL xH yL yH g) (Downloaded bit image display)
Code:1Fh  28h  66h  10h  m  aL  aH  aE  ySL  ySH  xL  xH  yL  yH g
m:Select bit image data memory
aL :Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
ySL:Bit image defined Y size, lower byte (by 8 dots)
ySH:Bit image defined Y size, upper byte (by 8 dots)
xL:Bit image display X size, lower byte (by 1 dot)
xH:Bit image display X size, upper byte (by 1 dot)
yL:Bit image display Y size, lower byte (by 8 dots)
yH:Bit image display Y size, upper byte (by 8 dots)
g:Image information = 1 (fixed)
Definable area:00h ≤ m ≤ 02h
m = 00h:RAM bit image
m = 01h:FROM bit image
m = 02h:Display Memory bit image
RAM bit image:
000000h ≤ (aL + aH×100h + aE×10000h) ≤ 000FFFh
FROM bit image:
aE = 00h
000000h ≤ (aL + aH×100h + aE ×10000h) ≤ 007FFFh
aE=01h – 04h (Extension area, 4 blocks)
010000h ≤ (aL + aH×100h + aE×10000h) ≤ 04FFFFh
Display Memory bit image:
000000h ≤ (aL + aH×100h + aE×10000h) ≤ Max_DispMemAddr
0000h ≤ (ySL + ySH×100h) ≤ FFFFh
0001h ≤ (xL + xH×100h) ≤ Xdots
0001h ≤ (yL + yH×100h) ≤ Ybytes
g = 01h
Function:Display, at the cursor position, the bit image defined in RAM, FROM, or in Display  
Memory.
Cursor position does not change.
Select RAM, FROM or Display Memory bit image by Select Bit image data memory 'm'.
Set Bit image defined Y size to the same Y size of the bit image defined in memory.
A portion of the Defined bit image can be displayed by setting Bit image display Y size less than  
Defined bit image Y size, or by changing Bit image display X size and/or Bit image data definition  
address.
If the bit image extends beyond the currently-selected window, only the portion within the current  
window is displayed.
When the bit image is being written to the Display Memory, if the bit image memory area is  
exceeded, undefined data is displayed.
Note for aE = 01h – 04h:
Bit image data can be read from 010000h to 04FFFFh continuously (bit image display can cross a  
block boundary).
- 46 -

GU-3900B series “General Function” Software Specification
- 47 -Bit image memory (RAM, FROM, or Display Memory)
Display address 'a'
yx
dyd(yS+1)d(yS+2)
d1d2d(yS+y)yS
Display Memory
Cursor position
yx
dyd(yS+1)d(yS+2)
d1d2d(yS+y)Bit image data write

GU-3900B series “General Function” Software Specification
4.7.4.38US ( f 90h m aL aH aE ySL ySH xL xH yL yH g s) (Downloaded bit image scroll display)
Code:1Fh  28h  66h  90h  m  aL  aH  aE  ySL  ySH  xL  xH  yL  yH  g  s
m:Select bit image data memory
aL:Bit image data definition address, lower byte
aH:Bit image data definition address, upper byte
aE:Bit image data definition address, extension byte
ySL:Bit image defined Y size, lower byte (by 8 dots)
ySH:Bit image defined Y size, upper byte (by 8 dots)
xL:Bit image scroll display shift X size, lower byte (by 1 dot)
xH:Bit image scroll display shift X size, upper byte (by 1 dot)
yL:Bit image scroll display Y size, lower byte (by 8 dots)
yH:Bit image scroll display Y size, upper byte (by 8 dots)
g:Image information = 1 (fixed)
s:Scroll speed select
Definable area:00h ≤ m ≤ 01h
m = 00h:  RAM bit image
m = 01h:  FROM bit image
RAM bit image:
000000h ≤ (aL + aH×100h + aE×10000h) ≤ 000FFFh
FROM bit image:
aE = 00h
000000h ≤ (aL + aH×100h + aE ×10000h) ≤ 007FFFh
aE = 01h – 04h (Extension area, 4 blocks)
010000h ≤ (aL + aH×100h + aE×10000h) ≤ 04FFFFh
0000h ≤ (ySL + ySH×100h) ≤ FFFFh
0001h ≤ (xL + xH×100h) ≤ FFFFh
0001h ≤ (yL + yH×100h) ≤ Ybytes
g = 01h
s = 00h – 1Fh
Function: Scroll display, from the right end of current window, at cursor height, the bit image  
defined in RAM or FROM.
Cursor position does not change.
Select RAM or FROM bit image by Select Bit image data memory 'm'.
Set Bit image defined Y size to the same Y size of the bit image defined in memory.
A portion of the Defined bit image can be displayed by setting Bit image scroll display Y size less  
than Defined bit image Y size, or by changing Bit image data definition address.
Note for aE = 01h – 04h:
Bit image data can be read from 010000h to 04FFFFh continuously (bit image display can cross a  
block boundary).
If the bit image memory area 010000 – 04FFFF is exceeded, undefined data is displayed.
Note:  Scroll speed is approximate.  Depending on the scrolling area, scroll may reduce in speed or  
flicker.  See also 4.7.4.39 Horizontal scroll display quality select and 3.1 Timing Unit.
- 48 -sScroll speed00h4 dots / module timing unit01h2 dots / module timing unit02h – 1Fh　1 dot / (s-1)×module timing unit

GU-3900B series “General Function” Software Specification
- 49 -y
yBit image memory (RAM or FROM)
x
dyd(yS+1)d(yS+2)
d1d2d(yS+y)yS
Write bit image data from the right end of 
current window at cursor height.
(Scroll display)
Display MemoryCursor position
Number of scroll shift x
dyd(yS+1)d(yS+2)
d1d2d(yS+y)dy d1d2
Scrolling from right endDisplay address 'a'

GU-3900B series “General Function” Software Specification
4.7.4.39US m n(Horizontal scroll display quality select)
Code:1Fh  6Dh  n
n:Horizontal scroll display quality
Definable area:00h ≤ n ≤ 01h
n = 00h:  Scroll speed-priority
n = 01h:  Visual quality-priority
Default:n = 00h or Memory SW setting.
Function:Select horizontal scroll display quality – Scroll speed-priority or Visual quality-priority.
If Scroll speed-priority is selected, scroll speed will be faster, but partial display flickering may  
increase.
If Visual quality-priority is selected, partial display flickering will decrease, but scroll speed may  
become slower.
Applicable for Character display and Horizontal Tab command in Horizontal scroll mode, and  
Downloaded bit image scroll display.
4.7.4.40US r n(Reverse display)
Code:1Fh  72h  n
n:Reverse display ON/OFF
Definable area:00h ≤ n ≤ 01h
n = 00h:  Reverse OFF
n = 01h:  Reverse ON
Default:n = 00h or Memory SW setting.
Function:Reverse display ON/OFF for character and image display.
Changing this setting only affects subsequent data.  Content already displayed is not affected.
4.7.4.41US w n(Write mixture display mode)
Code:1Fh  77h  n
n:Display write mode
Definable area:00h ≤ n ≤ 03h
n = 00h:  Normal display write (not mixture display)
n = 01h:  OR display write
n = 02h:  AND display write
n = 03h:  EX-OR display write
Default:n = 00h or Memory SW setting.
Function:Specifies write mixture mode.
Newly-written characters and images are combined with current display contents in Display Memory.
4.7.4.42US ( w 01h a(Window select)
Code:1Fh  28h  77h  01h  a
a:  Window number
a = 00h:Base-Window 
a = 01h – 04h:User-Window
Definable area:00h ≤ a ≤ 04h
Function:Select current window.
Command is ignored if Window number is for a User-Window that is not defined.
- 50 -

GU-3900B series “General Function” Software Specification
4.7.4.43US ( w 02h a b[xPL xPH yPL yPH  xSL  xSH ySL ySH] (User  Window  define  /  
cancel)
Code:1Fh  28h  77h  02h  a  b  [xPL  xPH  yPL  yPH  xSL  xSH  ySL  ySH]
a:  Definable window No.   No. 1 – 4
b:  Define or Cancel b = 00h:  Cancel,  b = 01h:  Define
xPL:Left position of window x, lower byte (by 1 dot)
xPH:Left position of window x, upper byte (by 1 dot)
yPL:Top position of window y, lower byte (by 8 dot)
yPH:Top position of window y, upper byte (by 8 dot)
xSL:X size of window, lower byte (by 1 dot)
xSH:X size of window, upper byte (by 1 dot)
ySL:Y size of window, lower byte (by 8 dot)
ySH:Y size of window, upper byte (by 8 dot)
Definable area:01h ≤ a ≤ 04h
00h ≤ b ≤ 01h
0000h ≤ (xPL + xPH×100h) ≤ Max_Xdot
0000h ≤ (yPL + yPH×100h) ≤ Max_Ybyte
0001h ≤ (xSL + xSH×100h) ≤ (Xdots − (xPL + xPH×100h))
0001h ≤ (ySL + ySH×100h) ≤ (Ybytes − (yPL + yPH×100h))
Function:Define or cancel User-Window
Display contents are not changed by this command.
User-Window define (b=01h):
Specify User-Window number, window position, and window size.  Window position and Window size  
are specified in units of one block (1×8 dot).
Up to 4 User-Windows can be defined.
The cursor position for the window is initialized to top left (X=0, Y=0).
User-Window cancel (b=00h):
For User-Window cancel, window range parameters [xPL – ySH] are not used.
If the currently-selected window is cancelled, the Base-Window becomes the currently-selected  
window.
If any of 'a', 'b', 'xP', 'yP', 'xS', or 'yS' are outside the definable area, the command is cancelled at that  
point and the following data is treated as standard data.
- 51 -(xP ,yP)xS
yS
Display area　　　　　　　　　　　　 Hidden area

GU-3900B series “General Function” Software Specification
4.7.4.44ESC % n(Download character ON/OFF)
Code:1Bh  25h  n
Function:Enable or disable display of download characters (6×8, 8×16, 12×24, and 16×32 dot).
n = 01h: Enable  (If download character is not defined, built-in character is displayed)
n = 00h: Disable
Characters already displayed are not affected.
4.7.4.45ESC & a c1 c2 [x1 d1...d(y×x1)]...[xk d1...d(y×xk)] (Download character definition)
Code:1Bh  26h  a  c1  c2  [x1  d1...d(y×x1)]...[xk d1...d(y×xk)]
a:Select character type
c1:Start character code
c2:End character code
x:Number of dots for X-direction
d:Definition data (refer to 4.9 Download character format )
Definable area:01h ≤ a ≤ 04h
a = 01h:6×8 dot character
00h ≤ × ≤ 06h
a = 02h:8×16 dot character
00h ≤  x ≤ 08h
a = 03h:12×24 dot character
00h ≤  x ≤ 0Ch
a = 04h:16×32 dot character
00h ≤  x ≤ 10h
20h ≤ c1 ≤ c2 ≤ FFh
00h ≤ d ≤ FFh
k = c2 − c1 + 1
Function:Define download characters (1-byte characters) into RAM.
For each font size, a maximum of 16 download characters can be defined.
After the maximum number of download characters are defined, in order to define other character  
codes, space must first be obtained using the Download 
character delete command.
Downloaded characters are valid until redefined, an initialize (ESC@) sequence is executed, or the  
power is turned off.
To display download characters the commands Download character definition and Download  
character ON/OFF (set to ON) are required.
If x is smaller than the character width, the remaining space on the right is filled with blank (non-
display) dots.
If a currently-displayed download character is re-defined, there is no affect on the currently-displayed  
character.  It is effective only for newly input characters.
Download characters can be saved into FROM using the Save download character command.
4.7.4.46ESC ? a c(Download character delete)
Code:1Bh  3Fh  a  c
a:Select character type
c:Delete Character code
Definable area:01h ≤  a ≤ 04h
a = 01h:6×8 dot character
a = 02h:8×16 dot character
a = 03h:12×24 dot character
a = 04h:16×32 dot character
20h ≤ c ≤ FFh
Function:Delete defined download character (1-byte character).
Built-in character is displayed after download character is deleted.
Characters already displayed are not affected.
Command is ignored if download character is not defined for the given character code.
- 52 -

GU-3900B series “General Function” Software Specification
4.7.4.47US ( g 10h c1 c2 d1...d32 (16×16 Download character definition)
Code:1Fh  28h  67h  10h  c1  c2  d1...d32
c1:Character code, upper byte
c2:Character code, lower byte
d:Definition data (refer to 4.9 Download character format )
Definable area:c1, c2:  Depends on language:
LanguageEncodingc1c2
Japanese JIS X0208 
(SHIFT-JIS)c1 = ECh40h ≤ c2 ≤ 4Fh
Korean KSC5601-87c1 = FEhA1h ≤ c2 ≤ B0h
Simplified Chinese GB2312-80c1 = FEhA1h ≤ c2 ≤ B0h
Traditional Chinese Big-5c1 = FEhA1h ≤ c2 ≤ B0h
00h ≤ d ≤ FFh
Function:Defines a 16×16 dot downloaded character (2-byte character) in character code  
specified by c1 and c2.  A maximum of 16 download characters can be defined.
Definition data “d” is processed as character pattern data in column format, and is stored  
sequentially from the left.
Download character is temporary stored in RAM, but can be stored in FROM using Download  
character save command.
4.7.4.48US ( g 11h c1 c2 (16×16 Downloaded character delete)
Code:1Fh  28h  67h  11h  c1  c2
c1:Character code, upper byte
c2:Character code, lower byte
Definable area:c1, c2:  Depends on language:
LanguageEncodingc1c2
Japanese JIS X0208 
(SHIFT-JIS)c1 = ECh40h ≤ c2 ≤ 4Fh
Korean KSC5601-87c1 = FEhA1h ≤ c2 ≤ B0h
Simplified Chinese GB2312-80c1 = FEhA1h ≤ c2 ≤ B0h
Traditional Chinese Big-5c1 = FEhA1h ≤ c2 ≤ B0h
Function:Delete defined 16×16 dot download character in code specified by c1 and c2.
4.7.4.49US ( g 14h c1 c2 d1...d128 (32×32 Download character definition)
Code:1Fh  28h  67h  14h  c1  c2  d1...d128
c1:Character code, upper byte
c2:Character code, lower byte
d:Definition data (refer to 4.9 Download character format )
Definable area:c1, c2:  Depends on language:
LanguageEncodingc1c2
Japanese JIS X0208 
(SHIFT-JIS)c1 = ECh40h ≤ c2 ≤ 4Fh
00h≤ d ≤ FFh
Function:Defines a 32×32 dot downloaded character (2-byte character) in character code  
specified by c1 and c2.  A maximum of 16 download characters can be defined.
Definition data “d” is processed as character pattern data in column format, and is stored  
sequentially from the left.
Download character is temporary stored in RAM, but can be stored in FROM using Download  
character save command.
This command is invalid if language selection is not set to Japanese.
- 53 -

GU-3900B series “General Function” Software Specification
4.7.4.50US ( g 15h c1 c2 (32×32 Downloaded character delete)
Code:1Fh  28h  67h  15h  c1  c2
c1:Character code, upper byte
c2:Character code, lower byte
Definable area:c1, c2:  Depends on language:
LanguageEncodingc1c2
Japanese JIS X0208 
(SHIFT-JIS)c1 = ECh40h ≤ c2 ≤ 4Fh,
Function:Delete defined 32×32 dot download character in code specified by c1 and c2.
This command is invalid if language selection is not set to Japanese.
4.7.4.51US ( e 11h a(Download character save)
Code:1Fh  28h  65h  11h  a
a:Font size
Definable area:01h ≤ a ≤ 06h
a=01h: 6×8 dot
a=02h: 8×16 dot
a=03h: 16×16 dot
a=04h: 16×32 dot
a=05h: 32×32 dot
a=06h: 12×24 dot
Function:Save the download characters defined on RAM to FROM (RAM →FROM).
The saved content is re-enabled using the Download character restore command.
This command is only valid in User setup mode.
BUSY signal is output by the display module during processing of this command.  The host should  
not transmit any data during this time.
4.7.4.52US ( e 21h a(Download character restore)
Code:1Fh  28h  65h  21h  a
a:Font size
Definable area:01h ≤ a ≤ 06h
a=01h: 6×8 dot
a=02h: 8×16 dot
a=03h: 16×16 dot
a=04h: 16×32 dot
a=05h: 32×32 dot
a=06h: 12×24 dot
Function:Transfer the download characters saved in FROM to RAM (FROM→RAM).
Command is ignored if specified font size download characters are not registered in FROM.
Command is valid in both User setup mode and Normal mode.
- 54 -

GU-3900B series “General Function” Software Specification
4.7.4.53US ( e 13h m P(80h-1) P(80h-2)...P(FFh-n) (FROM User font definition)
Code:1Fh  28h  65h  13h  m  P(80h-1)  P(80h-2)...P(FFh-n)
m:User table
p:Definition data (refer to Download character format)
Definable area:m = 01h, 02h, 03h, 04h
m = 01h:  6×8 dot
m = 02h:  8×16 dot
m = 03h:  12×24 dot
m = 04h:  16×32 dot
00h ≤ P ≤ FFh
m=01h: P(80h-1).....P(80h-6).......P(FFh-6)    6 Bytes / font × 128 characters (768 bytes)
m=02h: P(80h-1).....P(80h-16).......P(FFh-16)  16 Bytes / font × 128 characters (2,048 bytes)
m=03h: P(80h-1).....P(80h-36).......P(FFh-36)  36 Bytes / font × 128 characters (4,068 bytes)
m=04h: P(80h-1).....P(80h-64).......P(FFh-64)  64 Bytes / font × 128 characters (8,192 bytes)
Function:Define the user font for each size of 1-byte code to the user table.
This command defines all 128 characters at once; it is not possible to only define a part of the  
character code space.
User font tables for each font size are set to blank (00h) when shipped.
This command is only valid in User setup mode.
4.7.4.54US ( e 15h a b p(1)…p(65536) (FROM extension font definition)
Code:1Fh  28h  65h  15h  a  b  p(1)...p(65536)
a:Bank
b:Define / Delete
p:Definition data (if Define)
Definable area: a = 01h
b = 00h, 01h
00h ≤ p ≤ FFh
Function:Define or delete FROM extension font.
b=00h:  FROM extension font is deleted.  Definition data parameter is not used.
b=01h:  FROM extension font is defined.  Consult manufacturer for definition data format.  FROM  
extension font is in deleted state when shipped.
This command is only valid in User setup mode.
4.7.4.55US ( e 01h d1 d2 (User setup mode start)
Code:1Fh  28h  65h  01h  49h  4Eh
Definable area:d1 = 49h (Character 'I')
d2 = 4Eh (Character 'N')
Function:Start User setup mode.
The following response data is sent from the RS-232 interface:
This command is only valid in Normal mode.  Display screen is blanked.
4.7.4.56US ( e 02h d1 d2 d3 (User setup mode end)
Code:1Fh  28h  65h  02h  4Fh  55h  54h
Definable area:d1 = 4Fh (Character 'O')
d2 = 55h (Character 'U')
d3 = 54h (Character 'T')
Function:End User setup mode, and software reset of display as follows:
(1) Wait for any in-progress operations (memory control, information transmission, etc) to complete.
(2) Output display BUSY signal.
(3) Software reset.
This command is only valid in User setup mode.
This command clears the receive buffer, and all settings (Download character, Macro settings, etc)  
are reset to power-on state.
- 55 -Transmitted data HexData length
(1) Header 28h1 byte
(2) Identifier 1 65h1 byte
(3) Identifier 2 01h1 byte
(4) NUL 00h1 byte

GU-3900B series “General Function” Software Specification
4.7.4.57US ( p 01h n a(I/O Port Input / Output setting)
Code:1Fh  28h  70h  01h  n  a
n:I/O port number
a:Set Input / Output (bit-wise)
Definable area:00h ≤ n ≤ 01h
　n = 00h: Port 0
　n = 01h: Port 1
00h ≤ a ≤ FFh
Bit value = 0:  Input
Bit value = 1:  Output
Function:  Set input or output for general-purpose I/O ports.
Port input / output is set by value of 'a'.  Bit assignment is as follows:
Caution:  I/O port is intended for simple peripheral switches and for controlling lights, etc,  
and should not be used for applications where high reliability is required.
4.7.4.58US ( p 10h n a(I/O Port Output)
Code:1Fh  28h  70h  10h  n  a
n:I/O port number
a:Output data value
Definable area:00h ≤ n ≤ 01h
n = 00h:  Port 0
　n = 01h:  Port 1
00h ≤ a ≤ FFh
Function: Output data to general-purpose I/O port.
Output data is set by value of 'a'.  Bit assignment is as follows:
4.7.4.59US ( p 20h n(I/O Port Input)
Code:1Fh  28h  70h  20h  n
n:I/O port number
Definable area:00h ≤ n ≤ 01h
n = 00h: Port 0
n = 01h: Port 1
Function:The state of a general-purpose I/O port at the time this command is processed is  
transmitted.
The following data is transmitted from the RS-232 interface:
Transmitted data HexData length(1) Header 28h1 byte(2) Identifier (1) 70h1 byte(3) Identifier (2) 20h1 byte(4) Data 00h–FFh 1 byte
Response time varies depending on the state of the receive buffer.
- 56 -Port bit No.Bit7Bit6Bit5Bit4Bit3Bit2Bit1Bit0
Data bitD7D6D5D4D3D2D1D0
Port bit No.Bit7Bit6Bit5Bit4Bit3Bit2Bit1Bit0
Data bitD7D6D5D4D3D2D1D0

GU-3900B series “General Function” Software Specification
4.7.4.60US : pL pH [d1...dk] (RAM Macro define / delete)
Code:1Fh  3Ah  pL  pH  [d1...dk]
pL:RAM Macro data length, lower byte
pH:RAM Macro data length, upper byte
d:RAM Macro data
Definable area:0000h ≤ (pL + pH×100h) ≤ 4000h
Function:Define or delete RAM Macro or RAM Program Macro.
(pL + pH×100h) > 0000h: Supplied data “d” is stored as Macro.
(pL + pH×100h) = 0000h: Macro is deleted.
If Macro data length is outside the definable area, the command is cancelled, and the following data  
is treated as standard data.
Do not define any of the following commands in a Macro:
Initialize, Macro execution, RAM Macro define / delete, User setup mode start, [US ( e] group  
commands (FROM bit image definition, Download character save, etc), Macro execution settings,  
Memory re-write mode.
Program Macro details:  Refer to specification DS-1600-0006-XX Program Macro.
4.7.4.61US ( e 12h a pL pH t1 t2 [ d(1)...d(p) ] (FROM Macro define / delete)
Code:1Fh  28h  65h  12h  a  pL  pH  t1  t2  [d1...d(p)]
a:FROM Macro registration number
pL: FROM Macro data length, lower byte
pH: FROM Macro data length, upper byte
t1:Display time interval (t1 × module timing unit)
t2:Idle time for Macro repetition (t2 × module timing unit) (refer to 3.1 Timing Unit)
d:FROM Macro data
Definable area:01h ≤ a ≤ 04h:  FROM Macro number 1 – 4
0000h ≤ (pL + pH×100h) ≤ 1000h (if using 4 Macros), 4000h (if using 1 Macro)
00h ≤ t1 ≤ FFh
00h ≤ t2 ≤ FFh
00h ≤ d ≤ FFh
Function:Define or delete FROM Macro or FROM Program Macro.
FROM Macro storage capacity is a total of 16KB, 4KB / Macro when using 4 Macros.
For Macros exceeding 4KB, multiple Macro definition areas are used, which may result in some  
Macro number areas being undefined.
(pL + pH×256) > 0:  Supplied data “d” is stored as Macro.
(pL + pH×256) = 0:  Macro is deleted.
If Macro data length is outside the definable area, the command is cancelled, and the following data  
is treated as standard data.
Display time interval (t1) and Idle time (t2) settings are used when FROM Macro execution at power-
on is used.
Display time interval refers to the interval time between displaying characters, and does not affect  
the processing speed of command code.
Idle time refers to the time period from processing the last Macro data until the Macro is re-executed.
This command is only valid in User setup mode.
Do not define any of the following commands in a Macro:
Initialize, Macro execution, RAM Macro define / delete, User setup mode start, [US ( e] group  
commands (FROM bit image definition, Download character 
save, etc), Macro execution settings, Memory re-write mode.
BUSY signal is output by the display module during processing of this command.  The host should  
not transmit any data during this time.
Program Macro details:  Refer to specification DS-1600-0006-XX Program Macro.
- 57 -

GU-3900B series “General Function” Software Specification
Example:
FROM Macro 1 area Undefined
FROM Macro 2 area Undefined
FROM Macro 3 area Undefined
FROM Macro 4 area Undefined
↓  Define 4KB Macros in Macro 1 – 4
FROM Macro 1 area FROM Macro 1  4KB
FROM Macro 2 area FROM Macro 2  4KB
FROM Macro 3 area FROM Macro 3  4KB
FROM Macro 4 area FROM Macro 4  4KB
↓  Define 8KB Macro in Macro 2
FROM Macro 1 area FROM Macro 1  4KB
FROM Macro 2 area FROM Macro 2  8KB
FROM Macro 3 area
FROM Macro 4 area FROM Macro 4  4KB
↓  Define 8KB Macro in Macro 3
FROM Macro 1 area FROM Macro 1  4KB
FROM Macro 2 area Undefined
FROM Macro 3 area FROM Macro 3  8KB
FROM Macro 4 area
↓  Define 12KB Macro in Macro 1
FROM Macro 1 area FROM Macro 1  12KB
FROM Macro 2 area
FROM Macro 3 area
FROM Macro 4 area Undefined
4.7.4.62US ^ n t1 t2(Macro execution)
Code:1Fh  5Eh  a  t1  t2
a:Macro processing definition number
t1:Display time interval (t1 × module timing unit)
t2:Idle time for Macro repetition (t2 × module timing unit) (refer to 3.1 Timing Unit)
Definable area:00h ≤ a ≤ 04h, 80h ≤ a ≤ 84h
a = 00h:RAM Macro 0
01h ≤ a ≤ 04h:FROM Macro 1 – 4
a = 80h:RAM Program Macro 0
81h ≤ a ≤ 84h:FROM Program Macro 1 – 4
00h ≤ t1 ≤ FFh
00h ≤ t2 ≤ FFh
Function:Continuously execute contents of defined Macro 'a'.
Display time interval refers to the interval time between displaying characters, and does not affect  
the processing speed of command code.
Idle time refers to the time period from processing the last Macro data until the Macro is re-executed.
If Macro 'a' is not defined, or is outside the definable area, the entire command (up to t2) is ignored.
Macro execution is stopped when a command is input.  The current window (Write screen mode area  
if Base-Window) is cleared and cursor moves to home position.  Display settings remain in the  
current state when the Macro ended.
- 58 -

GU-3900B series “General Function” Software Specification
4.7.4.63US ( i 20h a b c(Macro end condition)
Code:1Fh  28h  69h  20h  a  b  c
a:Macro end code Enable/Disable
b:Macro end code
c:Macro end Clear Screen setting
Definable area:a = 00h, 01h
a = 00h:Macro end code Disabled
a = 01h:Macro end code Enabled
00h ≤ b ≤ FFh
c = 00h, 01h
c = 00h:Clear Screen at Macro end
c = 01h:Do not clear screen at Macro end
Default:a = 00h or Memory SW setting.
b = 00h or Memory SW setting.
c = 00h or Memory SW setting.
Function:Macro end condition set.
a = 00h: Macro will unconditionally end if data is received.
a = 01h: Macro will end if data byte 'b' is received.  All other values are ignored.
c = 00h: Clear screen on Macro end.
c = 01h: Do not clear screen on Macro end.
The received byte code that ends the Macro is processed as the first byte of the next command.
This setting is not applicable for Program Macro.
4.7.4.64US ( e 03h a b(Memory SW setting)
Code:1Fh  28h  65h  03h  a  b
1Fh  28h  65h  03h  a  b  c[1]  d[1]  [  ...  c[b]  d[b]  ]
a:Memory SW Number
b:Setting data
Definable area:Set Memory SW:
00h ≤ a ≤ 3Fh
00h ≤ b ≤ FFh
Multiple Memory SW setting:
a = FFh
01h ≤ b ≤ FFh
00h ≤ c ≤ 3Fh
00h ≤ d ≤ FFh
Function: Set Memory SW.
A single Memory switch can be set (a=00h–3Fh) or multiple Memory switches can be set (a=FFh).
Single setting (a=00h–3Fh): a = Memory SW number, b = Setting value.
Multiple setting (a=FFh): b = Number of settings, c = Memory SW number, d = Setting value.
This command is only valid in User setup mode.
BUSY signal is output by the display module during processing of this command.  The host should  
not transmit any data during this time.
Memory SW details:  Refer to section 6.2 Memory SW (MSW).
- 59 -

GU-3900B series “General Function” Software Specification
4.7.4.65US ( e 04h a(Memory SW data send)
Code:1Fh  28h  65h  04h  a
1Fh  28h  65h  04h  a  b  c[1]  [  ...  c[b]  ]
a:Memory SW Number
Definable area:Single read:
00h ≤ a ≤ 3Fh
Multiple read:
a = FFh
01h ≤ b ≤ FFh
00h ≤ c ≤ 3Fh
Function:Send the contents of Memory SW data.
A single Memory switch can be read (a=00h–3Fh) or multiple Memory switches can be read (a=FFh).
Single read (a=00h–3Fh): a = Memory SW number.
Multiple read (a=FFh): b = Number of reads, c = Memory SW number.
The following data is transmitted from the RS-232 interface:
Transmitted data HexData length
(1) Header 28h1 byte
(2) Identifier 1 65h1 byte
(3) Identifier 2 04h1 byte
(4) Data 00h–FFh1 byte / b byte(s)
This command is valid in both User setup mode and Normal mode.
Memory SW details:  Refer to section 6.2 Memory SW (MSW).
4.7.4.66US ( e 18h sL sH sE m1 a1L a1H a1E d[1]...d[s] (General-purpose memory store)
Code:1Fh  28h  65h  18h  sL  sH  sE  m1  a1L  a1H  a1E  d[1]  ...  d[s]
sL:Data size, lower byte
sH:Data size, upper byte
sE:Data size, extension byte
m1:Memory select
a1L:Memory address, lower byte
a1H:Memory address, upper byte
a1E:Memory address, extension byte
d: Data to store
Definable area:m1 = 30h  (General-purpose RAM):
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 000400h
000000h ≤ (a1L + a1H×100h + a1E×10000h) ≤ 0003FFh
m1 = 31h  (General-purpose FROM):
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 001000h
000000h ≤ (a1L + a1H×100h + a1E×10000h) ≤ 00FFFFh
Note:  General-purpose FROM is in units of 001000h, with a total of 16 areas.
Function:Store the supplied data into general-purpose memory.
Stored data can be read using General-purpose memory send command or by Program Macro.
Storage that would exceed the address range cannot be set.
For General-purpose RAM, data is stored only into the specified address range.
For General-purpose FROM, data is stored into the specified address range, and all other memory  
locations in the same FROM area are set to FFh.  Further, it is not possible to specify data storage  
that would exceed a general-purpose FROM area.
This command is valid in both User setup mode and Normal mode.
- 60 -

GU-3900B series “General Function” Software Specification
4.7.4.67US ( e 19h sL sH sE m1 a1L a1H a1E m2 a2L a2H a2E (General-purpose  memory  
transfer)
Code:1Fh  28h  65h  19h  sL  sH  sE  m1  a1L  a1H  a1E  m2  a2L  a2H  a2E
sL:Transfer size, lower byte
sH:Transfer size, upper byte
sE:Transfer size, extension byte
m1:Destination memory select
a1L:Destination address, lower byte
a1H:Destination address, upper byte
a1E:Destination address, extension byte
m2:Source memory select
a2L:Source address, lower byte
a2H:Source address, upper byte
a2E:Source address, extension byte
Definable area:m1, m2 = 30h  (General-purpose RAM):
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 000400h
000000h ≤ (a1L + a1H×100h + a1E×10000h) ≤ 0003FFh
000000h ≤ (a2L + a2H×100h + a2E×10000h) ≤ 0003FFh
m1, m2 = 31h  (General-purpose FROM):
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 001000h
000000h ≤ (a1L + a1H×100h + a1E×10000h) ≤ 00FFFFh
000000h ≤ (a2L + a2H×100h + a2E×10000h) ≤ 00FFFFh
Note:  General-purpose FROM is in units of 001000h, with a total of 16 areas.
Function:Transfer data between general-purpose memory areas.
Storage that would exceed the address range cannot be set.
For General-purpose RAM, data is transferred only into the specified address range.
For General-purpose FROM, data is transferred into the specified address range, and all other  
memory locations in the same FROM area are set to FFh.  Further, it is not possible to specify data  
transfer that would exceed a general-purpose FROM area.
Operation is not guaranteed if source and destination areas overlap.
This command is valid in both User setup mode and Normal mode.
4.7.4.68US ( e 28h sL sH sE m1 a1L a1H a1E (General-purpose memory send)
Code:1Fh  28h  65h  28h  sL  sH  sE  m1  a1L  a1H  a1E
sL:Data size, lower byte
sH:Data size, upper byte
sE:Data size, extension byte
m1:Memory select
a1L:Memory address, lower byte
a1H:Memory address, upper byte
a1E:Memory address, extension byte
Definable area:m1 = 30h  (General-purpose RAM):
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 000400h
000000h ≤ (a1L + a1H×100h + a1E×10000h) ≤ 0003FFh
m1 = 31h  (General-purpose FROM):
000001h ≤ (sL + sH×100h + sE×10000h) ≤ 001000h
000000h ≤ (a1L + a1H×100h + a1E×10000h) ≤ 00FFFFh
Note:  General-purpose FROM is in units of 001000h, with a total of 16 areas.
Function:Send data stored in general-purpose memory.
Data read that would exceed the address range cannot be set.
This command is valid in both User setup mode and Normal mode.
The following data is transmitted from the RS-232 interface:
Transmitted data HexData length
(1) Header 28h1 byte
(2) Identifier 1 65h1 byte
(3) Identifier 2 28h1 byte
(4) Data 00h–FFhs byte(s)
- 61 -

GU-3900B series “General Function” Software Specification
4.7.4.69US ( e 40h a [b c ] (Display status send)
Code:1Fh  28h  65h  40h  a  [ b  c ]
Definable area:a = 01h:Boot version information (b, c not used)
a = 02h:Firmware version information (b, c not used)
a = 10h:2-byte character code information (b, c not used)
a = 11h:Language type information (b, c not used)
a = 20h:Memory checksum information
00h ≤ b ≤ FFh:  Start address  (Effective address = b×10000h)
00h ≤ c ≤ FFh:  Data length  (Effective data length = c×10000h)
a = 30h:Product type information (b, c not used)
a = 40h:Display x dot information (b, c not used)
a = 41h : Display y dot information (b, c not used)
Function:Send display status information.
The following data is transmitted from the RS-232 interface:
This command is valid in both User setup mode and Normal mode.
4.7.4.70US ( i 10h a b(RS-232 serial settings)
Code:1Fh  28h  69h  10h  a  b
a:Baud rate setting
b:Parity setting
Definable area:00h ≤ a ≤ 0Bh
a=00h: 19200 bps
a=01h: 4800 bps
a=02h: 9600 bps
a=03h: 19200 bps
a=04h: 38400 bps
a=05h: 57600 bps
a=06h: 115200 bps
07h ≤ a ≤ 0Bh: Setting prohibited
00h ≤ b ≤ 02h
b=00h: No parity
b=01h: Even parity
b=02h: Odd parity
Function:Change the RS-232 serial interface communication parameters.
Operation is [DTR=MARK][Communication settings change][DTR=SPACE], so do not send the next  
data until DTR=SPACE.
If unsent data is in the transmit buffer (due to DSR=MARK), this data may not be transmitted  
correctly, so ensure the transmit buffer is clear before issuing this command.
For baud rate setting a = 07h – 0Bh, display operation is not guaranteed.  Do not use this setting.
4.7.4.71FS | M m d1...d6 (Memory re-write mode)
Code:1Ch  7Ch  4Dh  m  d1 ... d6
Definable area:m = D0h
d1...d6 = “MODEIN”
Function:Shift to “Memory re-write mode” from “Normal mode”.
Memory re-write mode is used for changing the firmware and fonts, etc in FROM that cannot be  
changed in User setup mode.
Changing this FROM requires special commands and tools.
Do not use this command.
- 62 -Transmitted dataHexData length
(1) Header28h1 byte
(2) Identifier 165h1 byte
(3) Identifier 240h1 byte
(4) Data00h–FFha = 01h:  4 bytes
a = 02h:  4 bytes
a = 10h:  15 bytes
a = 11h:  15 bytes
a = 20h:  4 bytes
a = 30h:  15 bytes
a = 40h:  3 bytes
a = 41h:  3 bytes

GU-3900B series “General Function” Software Specification
4.8Bit image data format
The Bit image consists of data for image size (x × y) as follows:
4.9Download character format
Download character format is shown below.
6×8
D7d1d2d6
D68×16 16×16
D5d1d3d15d1d3d31
D4d2d4d16d2d4d32
D312×24 24×24
D2d1d4d34d1d4d70
D1d2d5d35d2d5d71
D0d3d6d36d3d6d72
16×32 32×32
d1d5d61d1d5d125
d2d6d62d2d6d126
d3d7d63d3d7d127
d4d8d64d4d8d128
- 63 -DataPattern position
d (1) P1
d (2) P2
d (x × y) P(x × y)P1
P2
P(x×y)P(x×y)-1
PyD7
D6
D5
D4
D3
D2
D1
D0

GU-3900B series “General Function” Software Specification
5Graphic DMA mode  (Applicable for Parallel interface only)
5.1Displayable image types
5.1.1Graphic display
Depends on model – refer to 3 VFD Module model-specific information .
5.2Display Memory
Size: Refer to 3.2 Display Memory configuration .
The portion of memory which is displayed is selected using the “Display start address” command.
Display Memory is a roll configuration.  In areas of the display screen that would exceed the Display  
Memory, the contents from 0000h are displayed.
Example for 256×64 dot module:
5.3Protocol
High-speed graphic display is possible by using the parallel interface for data input.
The Graphic DMA mode protocol is described below.
Display waits until a valid “Header (STX)” + “Header 2” combination is received.  The module only  
processes packets with an address that matches the display's address set by DIP-SW + MSW.  
Using this mode, a maximum of 255 displays, addressed by DIP-SW and MSW settings, can be  
controlled individually.
Packets addressed to FFh are processed by all connected displays.
Header 1Header 2AddressCommand/Data
STX (02h)44h00h – FFh00h – FFh
1 byte1 byte1 byte n byte(s)
- 64 -x
0　　1　　　　　 255　256　　　　　　 510  511
256 dots
512 dots64 dotsD7
D6
D5
D4
D3
D2
D1
D0y   0
1
7    . . .0000h0001h0008h0009h07F8h07F9h0800h0801h0FF0h0FF1h0FF8h0FF9h
0007h000Fh07FFh0807h0FF7h0FFFh

GU-3900B series “General Function” Software Specification
5.4Commands 
Command Name Hex Code Operation Page
Bit image write 02h,44h,DAD,46h,
aL,aH,sL,sH,
d(1)...d(s) Write bit image data to the specified address.
DAD:Display address
aL:Bit image write address, lower byte
aH:Bit image write address, upper byte
sL:Bit image write size, lower byte
sH:Bit image write size, upper byte
d(1)...d(s):Bit image datap65
BOX Area Bit Image Write 02h,44h,DAD,42h,
aL,aH,
sXL,sXH,sYL,sYH,
d(1)...d(s)Write bit image data to the specified area.
DAD:Display address
aL:Bit image write start address, lower byte
aH:Bit image write start address, upper byte
sXL:Bit image write size X, lower byte
sXH:Bit image write size X, upper byte
sYL:Bit image write size Y , lower byte
sYH:Bit image write size Y , upper byte
d(1)...d(s):Bit image datap66
Display start address 02h,44h,DAD,53h,
aL,aHSet the Display start address.
DAD:Display address
aL:Display start address, lower byte
aH:Display start address, upper bytep67
Display synchronous 02h,44h,DAD,57h,
01hSynchronizes the next command with internal display  
refresh cycle.p67
Brightness level 02h,44h,DAD,58h,
nSet brightness level.
DAD: Display address
n: Brightness level setting
n=00h:0%n=01h:25%n=02h:50%
n=03h:75%n=04h:100%
n=10h:0%n=11h:12.5%n=12h:25%
n=13h:37.5%n=14h:50%n=15h:62.5%
n=16h:75%n=17h:87.5%n=18h:100%p67
5.4.1Command Details
5.4.1.1STX 44h DAD 46h aL aH sL sH d(1)...d(s) (Bit image write)
Code:02h  44h  DAD  46h  aL  aH  sL  sH  d(1)...d(s)
DAD:Display address
aL:Bit image write address, lower byte
aH:Bit image write address, upper byte
sL:Bit image write size, lower byte
sH:Bit image write size, upper byte
d(1)–d(s):Bit image data
Definable area:00h ≤ DAD ≤ FFh
0000h ≤ (aL + aH×100h) ≤ Max_DispMemAddr
0001h ≤ (sL + sH×100h) ≤ DispMemSize
(aL + aH×100h) + (sL + sH×100h) ≤ DispMemSize
00h ≤ d ≤ FFh
Function:Write bit image data to the specified address.
If the Write address or Write size are outside the definable area, the command (STX to sH) is  
cancelled, and the display waits for the next header (STX).
During Bit image write, data from the host is transferred to the Display Memory using DMA.  This  
may result in a flickering display if a large volume of data is written at high speed.  If display flickering  
occurs, ensure that data writing is in accordance with the timing requirements described in the  
hardware specification at “Parallel interface timing 2”.
- 65 -

GU-3900B series “General Function” Software Specification
Example for 256×64 dot module:
5.4.1.2STX 44h DAD 42h aL aH sXL sXH sYL sYH d(1)...d(s) (BOX Area Bit image write)
Code:02h  44h  DAD  42h  aL  aH  sXL  sXH  sYL  sYH  d(1)...d(s)
DAD:Display address
aL:Bit image write start address, lower byte
aH:Bit image write start address, upper byte
sXL:Bit image write size X, lower byte
sXH:Bit image write size X, upper byte
sYL:Bit image write size Y, lower byte
sYH:Bit image write size Y, upper byte
d(1)–d(s):Bit image data
Definable area:00h ≤ DAD ≤ FFh
0000h ≤ (aL + aH×100h) ≤ Max_DispMemAddr
0001h ≤ (sXL + sXH×100h) ≤ Xdots
0001h ≤ (sYL + sYH×100h) ≤ Ybytes
Note:  X size and Y size must both be within the Display Memory area.
00h ≤ d ≤ FFh
Function:Write bit image data to the specified area.
If the Write address or Write size are outside the definable area, the command (STX to sH) is  
cancelled, and the display waits for the next header (STX).
- 66 -Display MemoryWrite address a
dsd1
. . .0FFFh
0007h 0000h
(aL,aH)sX
sY
Display Area　　　　　　　　　　　　　　　　 Hidden Area

GU-3900B series “General Function” Software Specification
5.4.1.3STX 44h DAD 53h aL aH (Display start address)
Code:02h  44h  DAD  53h  aL  aH
DAD:Display address
aL:Display start address, lower byte
aH:Display start address, upper byte
Definable area:00h ≤ DAD ≤ FFh
0000h ≤ (aL + aH×100h) ≤ Max_DispMemAddr
Function:Set the Display start address (top left position of display screen).
Command is ignored if Display start address is outside the definable area.
Example for 256×64 dot module:
5.4.1.4STX 44h DAD 57h 01h (Display synchronous)
Code:02h  44h  DAD  57h  01h
DAD:Display address
Definable area:00h ≤ DAD ≤ FFh
Function:Synchronizes the next command with internal display refresh cycle.
Smooth scroll display is possible by using this command in combination with “Display start address”  
command.
5.4.1.5STX 44h DAD 58h n (Brightness level)
Code:02h  44h  DAD  58h  n
DAD:Display address
n:Brightness level setting
Definable area:00h ≤ DAD ≤ FFh
00h ≤ n ≤ 04h, 10h ≤ n ≤ 18h
Default:n = 04h or Memory SW setting.
Function:Set brightness level, as shown below.
nBrightness level nBrightness level
00h0%12h25%
01h25%13h37.5%
02h50%14h50%
03h75%15h62.5%
04h100%16h75%
10h0%17h87.5%
11h12.5%18h100%
- 67 -
0000h0007h0008h000Fh07F8h07FFh0FF8h0FFFh
0FF0h0FF7h
256 dots
512 dots0800h0807h64 dotsDisplay start address a

GU-3900B series “General Function” Software Specification
6Setup
6.1DIP-Switch (SW1)
6.1.1Display address (for Packet mode and Graphic DMA mode)
Display address is set by a combination of DIP-SW and Memory SW.
bit 7bit 6bit 5bit 4bit 3bit 2bit 1bit 0
MSW50
bit 7MSW50
bit 6MSW50
bit 5MSW50
bit 4DIP-SW
SW4
ON=1
OFF=0DIP-SW
SW3
ON=1
OFF=0DIP-SW
SW2
ON=1
OFF=0DIP-SW
SW1
ON=1
OFF=0
If the above address is FFh, the setting is ignored and 00h is assumed.
6.1.2RS-232 communication settings
Communication settings are set by a combination of DIP-SW and Memory SW.
SW5 Setting
Baud Rate ParityDataStop bits
OFF38400 bps No parity 8 bits1 bit
ONMSW48 setting
00h: 19200 bps
01h: 4800 bps
02h: 9600 bps
03h: 19200 bps
04h: 38400 bps
05h: 57600 bps
06h: 115200 bps
07h: Prohibited*
08h: Prohibited*
09h: Prohibited*
0Ah: Prohibited*
0Bh: Prohibited*
0Ch–FFh: 19200 bps
* Operation is not 
guaranteed, so do not use  
this setting.MSW49 setting
00h: No parity
01h: Even parity
02h: Odd Parity
03h–FFh: No parity8 bits1 bit
6.1.3Command Mode
- 68 -SW No.Function Default
1
Display address selectOff
2 Off
3 Off
4 Off
5RS-232 communication  
settingsOff
6Command mode select Off
7Operating Mode select Off
8Protocol select Off
SW6 Mode
OFFNormal command mode Character, Graphic display mode
ONGraphic DMA mode High speed graphic display mode (parallel only)

GU-3900B series “General Function” Software Specification
6.1.4Operating Mode
SW7 Mode
OFFNormal operation mode Normal display operating modeONMemory re-write mode Memory re-write mode for firmware, fonts, etc.
6.1.5Protocol mode
SW8 Mode
OFFDirect modeModule accepts all of data regardless of address setting.
ONPacket modeOnly  the  display  with  address  that  matches  packet  address  processes the data.If packet address is FFh, all displays process the data.
6.2Memory SW
Note:  Module operates with default value if Memory SW value is outside the valid range.
* 1:  If setting is 01h, download characters for 12×24 dot and 16×32 dot are also restored.
* 2:  If setting is 01h, download characters for 32×32 dot are also restored.
- 69 -Switch 
No.Function Valid rangeDefault
0International font set 00h–0Dh00h
1Character table type 00h–05h,10h–13h,FFh 00h
2Horizontal scroll speed 00h–1Fh00h
3Reverse display 00h,01h00h
4Write mixture display mode 00h–03h00h
5Brightness level setting 00h–04h,10h–18h 04h
6Reserved --
7Write screen mode 00h,01h00h
8Font size 01h,02h,03h,04h01h
92-byte character 00h,01h00h
10Font magnification X 01h–04h01h
11Font magnification Y 01h–04h01h
12Bold character 00h,01h00h
132-byte character type 00h–03h00h
14Horizontal scroll display quality select 00h,01h00h
15Reserved --
16Download character restore at power-on
(FROM→RAM) 6×8 dot (00h = Don't restore)00h,01h00h
17Download character restore at power-on
(FROM→RAM) 8×16 dot (00h = Don't restore) *100h,01h00h
18Download character restore at power-on
(FROM→RAM) 16×16 dot (00h = Don't restore) *200h,01h00h
19FROM Macro execution at power-on 
(00h = Not execute)00h–04h,81h–84h 00h
20–47Reserved --
48RS-232 Baud rate setting 00h–0Bh00h
49RS-232 Parity setting 00h–02h00h
50Display address setting (lower 4 bits not used) 0xh–Fxh00h
51Packet mode response setting (00h = No response) 00h,01h00h
52Macro end code Enable/Disable 00h,01h00h
53Macro end code 00h–FFh00h
54Macro end Clear Screen setting 00h,01h00h
55–63Reserved --

GU-3900B series “General Function” Software Specification
Notice for the Cautious Handling of VFD Modules
Handling and Usage Precautions:
Please  carefully follow the  appropriate  product  application  notes  and  operation  standards  for  proper  usage,  safe  
handling, and maximum performance.
[VFD tubes are made of glass]
•The edges of the VFD glass envelope are not smooth, so it is necessary to handle carefully to avoid injuries to  
hands.
•Use caution to avoid breaking the VFD glass envelope, to prevent injury from sharp glass particles.
•The tip of the exhaust pipe is fragile so avoid shock from impact.
•It is recommended to allow sufficient open space surrounding the exhaust pipe to avoid possible damage.
•Please design the PCB for the VFD module within 0.3 mm warping tolerance to avoid any forces that may  
damage the display due to PCB distortion causing a breakdown of the electrical circuit leading to VFD failure.
[High voltage]
•Avoid touching conductive electrical parts, because the VFD module uses high voltage exceeding 30 – 100  
volts.
•Even when electric power is turned off, it may take more than one minute for the electrical current to discharge.
[Cable connection]
•Do not unplug the power and/or data cables of VFD modules during operation, because unrecoverable damage  
may result.
•Sending input signals to the VFD module when not powered can cause I/O port damage.
•It is recommended to use a 30cm or shorter signal cable to prevent functional failures.
[Electrostatic charge]
•VFD modules need electrostatic-free packaging and protection from electrostatic charges during handling and  
usage.
[Structure]
•During operation, VFD and VFD modules generate heat.  Please consider sufficient heat radiation dissipation  
using heat sink solutions.
•Preferably, use UL-grade materials or components in conjunction with VFD modules.
•Warp and twist movement causes stress and may break VFDs and VFD modules.  Please adhere to allowances  
within 0.3mm at the point of attachment.
[Power]
•Apply regulated power to the VFD module within specified voltages to protect from failures.
•VFD modules may draw in-rush current exceeding twice the typical current at power-on, so a power supply with  
sufficient capacity and quick starting of the power regulator is recommended.
•VFD module needs a specified voltage at the point of connection.  Please use an adequate power cable to  
avoid a decrease in voltage.  As a safety measure, a fuse or other over-current protection is recommended.
 [Operating consideration]
•Illuminating phosphor will decrease in brightness during extended operation.  If a fixed pattern illuminates for an  
extended  period  (several  hours),  the  phosphor  efficiency  will  decrease  compared  to  the  non-operating  
phosphor,  causing  non-uniform  brightness.   Please consider  programming  the display patterns to use all  
phosphor segments evenly.  Scrolling may be a consideration for a period of time to refresh the phosphor  
condition and improve even illumination of the pixels.
•A signal cable 30cm or less is recommended to avoid possible disturbances to the signal.
[Storage and operating environment]
•Please use VFD modules under the recommended specified environmental conditions.  Salty, sulfuric and dusty  
environments may damage the VFD module even during storage.
[Disposal]
•VFD uses lead-containing materials (RoHS directive exempts these lead compounds in the glass for electronic  
devices).  When discarding VFDs or VFD modules, please adhere to applicable laws and regulations.
[Other cautions]
•Although the VFD module is designed to be protected from electrical noise, please plan your circuitry to exclude  
as much noise as possible.
•Do not reconstruct or repair the VFD module without our authorization.  We cannot assure the quality or  
reliability of unauthorized reconstructed VFD modules.
Notice:
•We do not authorize the use of any patents that may be inherent in these specifications.
•Neither whole nor partial copying of these specifications is permitted without our approval.  If necessary, please  
ask for assistance from our sales consultant.
•This product is not designed for military, aerospace, medical or other life-critical applications.  If you choose to  
use this product for these applications, please ask us for prior consultation or we cannot accept responsibility for  
problems that may occur.
- 70 -

GU-3900B series “General Function” Software Specification
Revision history
Specification number Date Revision
DS-1600-0008-00Oct. 27, 2010Initial release
- 71 -