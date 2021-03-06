'DEFCON 2012 Badge Example
'Simple program shows how to use the DEFCON 2012 Badge to drive a VGA display,
'and interface with a mouse and a keyboard

CON

  'Propeller clock mode declarations
  _xinfreq = 5_000_000          'Timing crystal frequency, in Hz
  _clkmode = xtal1 + pll16x     'Use crystal type 1, with the 16x PLL to wind the clock up to 80 MHz

  'Propeller pin constant definitions.  Works with any Defcon 20 board.
  VGA_BASE_PIN  = 16
  
  MOUSE_DATA_PIN     = 24
  MOUSE_CLOCK_PIN    = 25
  KEYBOARD_DATA_PIN  = 26 
  KEYBOARD_CLOCK_PIN = 27

  'screen character size definitions
  COLS = vga#COLS               'value is actually defined in the 
  ROWS = vga#ROWS               'VGA_Text_Defcon object's constant section

  'bitwise map for the mouse buttons
  MOUSE_LEFT    = 1<<0
  MOUSE_RIGHT   = 1<<1
  MOUSE_CENTER  = 1<<2
  MOUSE_L_SIDE  = 1<<3
  MOUSE_R_SIDE  = 1<<4

  'constant definitions for VGA screen manipulation functionality
  VGA_CLS       = $00           'clear screen
  VGA_HOME      = $01           'home
  VGA_BACKSPACE = $08           'backspace
  VGA_TAB       = $09           'tab (8 spaces per)
  VGA_SET_X     = $0A           'set X position (X follows)
  VGA_SET_Y     = $0B           'set Y position (Y follows)
  VGA_SET_COLOR = $0C           'set color (color follows)
  VGA_CR        = $0D           'carriage return

OBJ

  'object declarations
  VGA     : "VGA_Text_Defcon.spin"
  Mouse   : "Mouse.spin"
  Keyboard: "Keyboard.spin"

VAR

  long xPos           'raw X value for the mouse
  long yPos           'raw Y value for the mouse
  long zPos           'raw Z value for the mouse wheel
  byte mouse_buttons  'bitwise variable, holds which mouse buttons are pressed
  
  long cursorX        'scale and limited mouse cursor position
  long cursorY

  long keyVal         'variable to hold the last keyboard keypress value
  
PUB Go | i, oldChar, oldX, oldY  

  'Start drivers for the various software peripherals in this application.

  VGA.Start(VGA_BASE_PIN)

  Mouse.Start(MOUSE_DATA_PIN, MOUSE_CLOCK_PIN)
  Mouse.Bound_limits(0, 0, 0, cols - 1, rows - 2, 0)    'set cursor limits
  Mouse.Bound_scales(15, -15, 0)                        'scale the raw values to make mouse actions smoother
  
  Keyboard.Start(KEYBOARD_DATA_PIN, KEYBOARD_CLOCK_PIN)                                      


  'Print the static text to the screen
  VGA.Str(string("Mouse, Keyboard, and VGA",13))
  VGA.Str(string("========================",13,13))

  VGA.Str(string("Mouse Raw X       = ",13))
  VGA.Str(string("Mouse Raw Y       = ",13))
  VGA.Str(string("Mouse Raw Z Wheel = ", 13))
  VGA.Str(string("Mouse Buttons     = ", 13))
  VGA.Str(string("Keyboard          = 0x000",13))

  VGA.Out(VGA_SET_X)
  VGA.Out(2)
  VGA.Out(VGA_SET_Y)
  VGA.Out(14)
  VGA.Str(string("Parallax Inc. + LostboY.net"))

  'initialize the oldChar and cursor values
  cursorX := cursorY := 0
  oldChar := VGA.GetChar(cursorX, cursorY)

  'main loop
  repeat
    VGA.Out(VGA_SET_COLOR)      'reset the drawing color
    VGA.Out(0)

    'get and print the mouse raw X position                                        
    xPos := Mouse.Abs_x
    VGA.Out(VGA_SET_X)
    VGA.Out(20)
    VGA.Out(VGA_SET_Y)
    VGA.Out(3)
    VGA.Dec(xPos)
    VGA.Str(string("    "))     'spaces are to clear any trailing characters for cleaner output
              
    'get and print the mouse raw Y position                                        
    yPos := Mouse.Abs_y
    VGA.Out(VGA_SET_X)
    VGA.Out(20)
    VGA.Out(VGA_SET_Y)
    VGA.Out(4)             
    VGA.Dec(yPos)
    VGA.Str(string("    "))

    'get and print the mouse raw Z position (the mouse wheel)                                        
    zPos := Mouse.Abs_z
    VGA.Out(VGA_SET_X)
    VGA.Out(20)
    VGA.Out(VGA_SET_Y)
    VGA.Out(5)             
    VGA.Dec(zPos)
    VGA.Str(string("    "))

    'get and print the state of the mouse buttons
    mouse_buttons := Mouse.Buttons
    VGA.Out(VGA_SET_X)
    VGA.Out(20)
    VGA.Out(VGA_SET_Y)
    VGA.Out(6)             
    VGA.Bin(mouse_buttons, 5)   'print as a binary number since each button is mapped to a bit

    'get and print the last keyboard key pressed                                        
    keyVal := Keyboard.Key
    VGA.Out(VGA_SET_X)
    VGA.Out(20)
    VGA.Out(VGA_SET_Y)
    VGA.Out(7)    
    if keyVal <> 0
      VGA.Str(string("0x"))  
      VGA.Hex(keyVal,3)
      VGA.Out(" ")
      VGA.Out(keyval & $FF)

    'save the mouse's current x and y postition within the bounds defined at the start of the program
    cursorX := Mouse.Bound_x
    cursorY := Mouse.Bound_y

    'update only when the mouse position or button state has changed
    if oldX <> cursorX or oldY <> cursorY or mouse_buttons <> 0
      VGA.Replace(oldX, oldY, oldChar)                  'replace the last old characer at the appropriate position
      oldChar := VGA.GetChar(cursorX, cursorY)          'save the current character as the old character to be replaced later
      oldX := cursorX                                   'make the current cursor position the old position
      oldY := cursorY

      'set the position for the new cursor
      VGA.Out(VGA_SET_X)                                
      VGA.Out(cursorX)
      VGA.Out(VGA_SET_Y)
      VGA.Out(cursorY)

      'change the color of the mouse cursor when a mouse button is pressed
      if mouse_buttons & MOUSE_LEFT
        VGA.Out(VGA_SET_COLOR)
        VGA.Out(2)              '<--- These colors are defined in the VGA_Text_Defcon.spin object, at the bottom.
      elseif mouse_buttons & MOUSE_RIGHT
        VGA.Out(VGA_SET_COLOR)
        VGA.Out(5)
      elseif mouse_buttons & MOUSE_CENTER
        VGA.Out(VGA_SET_COLOR)
        VGA.Out(6)

      'print the "dot" cursor character
      VGA.Out($0F)



DAT  
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}    