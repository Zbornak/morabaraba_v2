# 0. (0,0),               (0,3),               (0,6)
# 1.        (1,1),        (1,3),        (1,5)
# 2.               (2,2), (2,3), (2,4)
# 3. (3,0), (3,1), (3,2),        (3,4), (3,5), (3,6)
# 4.               (4,2), (4,3), (4,4)
# 5.        (5,1),        (5,3),        (5,5)
# 6. (6,0),               (6,3),               (6,6)

from utils import StaticTuple
from utils import StaticIntTuple
from python import Python
from sys import exit
from rules import print_rules

struct MorabarabaBoard:
    var board: StaticTuple[StaticTuple[Int, 7], 7]

    fn __init__(inout self):
        self.board = StaticTuple[StaticTuple[Int, 7], 7](
            StaticTuple[Int, 7](1, 0, 0, 1, 0, 0, 1),
            StaticTuple[Int, 7](0, 1, 0, 1, 0, 1, 0),
            StaticTuple[Int, 7](0, 0, 1, 1, 1, 0, 0),
            StaticTuple[Int, 7](1, 1, 1, 0, 1, 1, 1),
            StaticTuple[Int, 7](0, 0, 1, 1, 1, 0, 0),
            StaticTuple[Int, 7](0, 1, 0, 1, 0, 1, 0),
            StaticTuple[Int, 7](1, 0, 0, 1, 0, 0, 1)
        )

    # get user input (mojo input not currently working 211104)
    fn get_input(self) raises -> String:
        while True:
            var input_str = str(Python.evaluate("input()"))
            input_str = input_str.lower()
            
            if input_str == "exit":
                print("Exiting the game. Thanks for playing!")
                exit(0)
            elif input_str == "rules":
                print_rules()
                print("Please enter your move:")
            else:
                return input_str

    # returns true if player picks a valid position, false if not
    fn is_valid_position(self, row: Int, col: Int) -> Bool:
        if row < 0 or row >= 7 or col < 0 or col >= 7:
            return False
        return self.board[row][col] == 1
        
    fn is_in_mill(self, row: Int, col: Int, player: Int) -> Bool:
        # check horizontal mill
        if col == 0 or col == 3 or col == 6:
            if self.board[row][0] == player and self.board[row][3] == player and self.board[row][6] == player:
                return True
        
        # check vertical mill
        if row == 0 or row == 3 or row == 6:
            if self.board[0][col] == player and self.board[3][col] == player and self.board[6][col] == player:
                return True
        
        # check middle horizontal lines
        if row == 1 or row == 5:
            if self.board[row][1] == player and self.board[row][3] == player and self.board[row][5] == player:
                return True
        
        # check middle vertical lines
        if col == 1 or col == 5:
            if self.board[1][col] == player and self.board[3][col] == player and self.board[5][col] == player:
                return True
        
        # check diagonal lines in the middle square
        if (row == 2 or row == 3 or row == 4) and (col == 2 or col == 3 or col == 4):
            if self.board[2][2] == player and self.board[3][3] == player and self.board[4][4] == player:
                return True
            if self.board[2][4] == player and self.board[3][3] == player and self.board[4][2] == player:
                return True
        
        return False

    # 0 is invalid
    # 1 is unowned
    # 2 is player 1
    # 3 is player 2
    fn place_cow(inout self, row: Int, col: Int, player: Int, opponent: Int) -> Bool:
        if self.is_valid_position(row, col) and self.board[row][col] != player and self.board[row][col] != opponent:
            self.board[row][col] = player
            if self.is_in_mill(row, col, player):  # check if the current player formed a mill
                print("player", player, "got a mill")
                try:
                    _ = self.shoot_opponent_cow(player)
                except:
                    print("unable to shoot opponent cow")
            return True
        return False

    fn move_cow(inout self, from_row: Int, from_col: Int, to_row: Int, to_col: Int, player: Int, opponent: Int) raises -> Bool:
        # check if the 'from' position contains the player's piece
        if self.board[from_row][from_col] != player:
            print("Invalid move: No piece at the starting position")
            return False
        
        # check if the 'to' position is empty
        if self.board[to_row][to_col] != 1:  # assuming 1 represents an empty position
            print("Invalid move: Destination is not empty")
            return False
        
        # check if the move is to an adjacent position
        if not self.is_adjacent(from_row, from_col, to_row, to_col):
            print("Invalid move: Can only move to adjacent positions")
            return False
        
        # perform the move
        self.board[to_row][to_col] = player
        self.board[from_row][from_col] = 1  # set the 'from' position to empty
        
        # check if the move formed a mill
        if self.is_in_mill(to_row, to_col, player): # check if the current player formed a mill
            print("player", player, "got a mill")
            try:
                _ = self.shoot_opponent_cow(player)
            except:
                print("unable to shoot opponent cow")
        
        return True

    fn is_adjacent(self, row1: Int, col1: Int, row2: Int, col2: Int) -> Bool:
        # check if two positions are adjacent on the board
        if row1 == row2:
            return abs(col1 - col2) == 3 or (abs(col1 - col2) == 1 and (row1 % 3 != 1 or col1 % 3 == 1))
        elif col1 == col2:
            return abs(row1 - row2) == 3 or (abs(row1 - row2) == 1 and (col1 % 3 != 1 or row1 % 3 == 1))
        return False

    fn shoot_opponent_cow(inout self, player: Int) raises -> Bool:
        var opponent = 3 if player == 2 else 2  # assuming player 2 and 3
        
        print("player ", player, ", choose an opponent's cow to shoot.")
        print("enter the row and column (0-6) separated by a space:")
        
        while True:
            var input_str = self.get_input()
            var input_parts = input_str.split()
            
            if len(input_parts) != 2:
                print("invalid input. please enter two numbers separated by a space.")
                continue
            
            var row: Int
            var col: Int
            try:
                row = atol(input_parts[0])
                col = atol(input_parts[1])
            except:
                print("invalid input. please enter valid numbers.")
                continue
            
            if row < 0 or row > 6 or col < 0 or col > 6:
                print("invalid position. row and column must be between 0 and 6.")
                continue
            
            if self.board[row][col] != opponent:
                print("invalid position. there is no opponent cow at this location.")
                continue
            
            if self.is_in_mill(row, col, opponent):
                print("this cow is part of a mill and cannot be shot. choose another piece.")
                continue
            
            self.board[row][col] = 1
            print("shot opponent's cow at row ", row, ", col ", col)
            return True

    fn print_board(self):
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == 1:
                    print(" O  ", end="")
                elif self.board[row][col] == 2:
                    print(" ⑁⚇ ", end="")
                elif self.board[row][col] == 3:
                    print(" ⑁⚉ ", end="")
                else:
                    print(" .  ", end="")
            print()
            print()