Reversi
=======

Project Goal
------------
The objective of this project is to develop a VHDL implementation of Reversi/Othello using the Digilent Nexys 2 board, a VGA display, and an external human interface device such as a mouse or keyboard. It is expected that the PicoBlaze processor core will be used for the implementation of the game rule logic.

Basic Requirements
------------------
* Render board on VGA display
* Allow selection of next move position using external input device (mouse or keyboard)
* Detect and ignore illegal move attempts
* Detect piece captures
* Detect win conditions