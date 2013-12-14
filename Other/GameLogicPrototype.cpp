// TestVhdl.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

const unsigned char space_white_can_play = 0x41;
const unsigned char space_black_can_play = 0x51;
const unsigned char space_white = 0x02;
const unsigned char space_black = 0x03;
const unsigned char space_board = 0x01;

unsigned char GameBoard[64];

unsigned char s0;                                       // s0
unsigned char current_player;                           // s6
unsigned char current_position;                         // s7
unsigned char isPlayable;                               // s8
unsigned char board_pos;                                // s9
unsigned char current_player_color;                     // sA
unsigned char opposite_player_color;                    // sB
unsigned char current_player_can_play_color;            // sC
unsigned char temp_color;                               // sD
unsigned char current_test_position;                    // sE
unsigned char current_test_found_opposite_color;        // sF

void play();
void set_current_player_colors();
void init();
void set_next_plays();
void testLeft();
void testRight();
void testDown();
void testUp();
void testUpLeft();
void testUpRight();
void testDownLeft();
void testDownRight();
void playLeft();
void playRight();
void playDown();
void playUp();
void playUpLeft();
void playUpRight();
void playDownLeft();
void playDownRight();

int _tmain(int argc, _TCHAR* argv[])
{
	init();
	
	current_position = 29;
	play();

	return 0;
}

void play()
{
	board_pos = current_position;
	set_current_player_colors();

	temp_color = GameBoard[board_pos];
	if (temp_color != current_player_can_play_color) return;

	GameBoard[board_pos] = current_player_color;

	playLeft();
	playRight();
	playDown();
	playUp();
	playUpLeft();
	playUpRight();
	playDownLeft();
	playDownRight();

	current_player = current_player ^ 0xFF;	// switch players with an XOR.

	set_next_plays();
}

void set_current_player_colors()
{
	if (current_player == 0)
	{
		current_player_color = space_white;
		opposite_player_color = space_black;
		current_player_can_play_color = space_white_can_play;
	}
	else
	{
		current_player_color = space_black;
		opposite_player_color = space_white;
		current_player_can_play_color = space_black_can_play;
	}
}

void init()
{
	board_pos = 0;
	do {
		GameBoard[board_pos] = space_board;
		board_pos++;
	} while (board_pos < 64);

	GameBoard[0x1B] = space_white;
	GameBoard[0x24] = space_white;
	GameBoard[0x1C] = space_black;
	GameBoard[0x23] = space_black;

	current_player = 0x00;

	set_next_plays();
}


void set_next_plays()
{
	set_current_player_colors();
	has_a_play = 0x00;

	board_pos = 0xFF;
	while (board_pos != 63)
	{
		board_pos++;

		temp_color = GameBoard[board_pos] & 0x0F;  // Get the current color (as unplayable)
		GameBoard[board_pos] = temp_color;         // Set the space as unplayable
		if (temp_color != space_board) continue;   // If the space isn't a board space, keep it as unplayable.

		isPlayable = 0x00;

        testLeft();
		testRight();
	    testDown();
		testUp();
		testUpLeft();
		testUpRight();
		testDownLeft();
		testDownRight();

		if (isPlayable == 0x00) continue;
		has_a_play = 0xFF;
		GameBoard[board_pos] = current_player_can_play_color;
	}
}

void testLeft()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position - 1;

		s0 = current_test_position & 0x07;
		if (s0 == 0x07) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if(temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testRight()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position + 1;
		
		s0 = current_test_position & 0x07;
		if (s0 == 0x00) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testUp()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position - 8;

		s0 = current_test_position & 0x38;
		if (s0 == 0x38) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testDown()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position + 8;

		s0 = current_test_position & 0x38;
		if (s0 == 0x00) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testUpLeft()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position - 9;

		s0 = current_test_position & 0x07;
		if (s0 == 0x07) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x38) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testUpRight()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position - 7;

		s0 = current_test_position & 0x07;
		if (s0 == 0x00) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x38) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testDownLeft()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position + 7;

		s0 = current_test_position & 0x07;
		if (s0 == 0x07) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x00) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void testDownRight()
{
	current_test_found_opposite_color = 0x00;
	current_test_position = board_pos;

	while (true)
	{
		current_test_position = current_test_position + 9;

		s0 = current_test_position & 0x07;
		if (s0 == 0x00) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x00) return;

		temp_color = GameBoard[current_test_position] & 0x0F;
		if (temp_color == opposite_player_color)
		{
			current_test_found_opposite_color = 0xFF;
			continue;
		}
		else if (temp_color == current_player_color && current_test_found_opposite_color)
		{
			isPlayable = 0xFF;
		}
		return;
	}
}

void playLeft()
{
	isPlayable = 0x00;
	testLeft();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position - 1;

		s0 = current_test_position & 0x07;
		if (s0 == 0x07) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playRight()
{
	isPlayable = 0x00;
	testRight();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position + 1;

		s0 = current_test_position & 0x07;
		if (s0 == 0x00) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playUp()
{
	isPlayable = 0x00;
	testUp();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position - 8;

		s0 = current_test_position & 0x38;
		if (s0 == 0x38) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playDown()
{
	isPlayable = 0x00;
	testDown();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position + 8;

		s0 = current_test_position & 0x38;
		if (s0 == 0x00) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playUpLeft()
{
	isPlayable = 0x00;
	testUpLeft();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position - 9;

		s0 = current_test_position & 0x07;
		if (s0 == 0x07) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x38) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playUpRight()
{
	isPlayable = 0x00;
	testUpRight();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position - 7;

		s0 = current_test_position & 0x07;
		if (s0 == 0x00) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x38) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playDownLeft()
{
	isPlayable = 0x00;
	testDownLeft();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position + 7;

		s0 = current_test_position & 0x07;
		if (s0 == 0x07) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x00) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}

void playDownRight()
{
	isPlayable = 0x00;
	testDownRight();
	if (isPlayable == 0x00) return;

	current_test_position = board_pos;
	while (true)
	{
		current_test_position = current_test_position + 9;

		s0 = current_test_position & 0x07;
		if (s0 == 0x00) return;
		s0 = current_test_position & 0x38;
		if (s0 == 0x00) return;

		s0 = GameBoard[current_test_position];
		if (s0 != opposite_player_color) return;
		GameBoard[current_test_position] = current_player_color;
	}
}