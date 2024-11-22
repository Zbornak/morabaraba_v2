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
                print("exiting the game, hamba kahle")
                exit(0)
            elif input_str == "rules":
                print_rules()
                print("enter your move:")
            else:
                return input_str

    # returns true if player picks a valid position, false if not
    fn is_valid_position(self, row: Int, col: Int) -> Bool:
        if row < 0 or row >= 7 or col < 0 or col >= 7:
            return False
        return self.board[row][col] == 1
        
    fn is_in_mill(self, row: Int, col: Int, player: Int) -> Bool:
        # check horizontal mills
        if (col == 0 or col == 1 or col == 2) and self.board[row][0] == player and self.board[row][1] == player and self.board[row][2] == player:
            return True
        if (col == 3 or col == 4 or col == 5) and self.board[row][3] == player and self.board[row][4] == player and self.board[row][5] == player:
            return True
        if (col == 4 or col == 5 or col == 6) and self.board[row][4] == player and self.board[row][5] == player and self.board[row][6] == player:
            return True
        
        # check vertical mills:
        if (row == 0 or row == 1 or row == 2) and self.board[0][col] == player and self.board[1][col] == player and self.board[2][col] == player:
            return True
        if (row == 3 or row == 4 or row == 5) and self.board[3][col] == player and self.board[4][col] == player and self.board[5][col] == player:
            return True
        if (row == 4 or row == 5 or row == 6) and self.board[4][col] == player and self.board[5][col] == player and self.board[6][col] == player:
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
        if row == 3 and col == 3:
            if (self.board[2][2] == player and self.board[4][4] == player) or
            (self.board[2][4] == player and self.board[4][2] == player):
                return True
        
        # check outer diagonal mills
        if (row == 6 and col == 0) or (row == 5 and col == 1) or (row == 4 and col == 2):
            if self.board[6][0] == player and self.board[5][1] == player and self.board[4][2] == player:
                return True
        if (row == 0 and col == 6) or (row == 1 and col == 5) or (row == 2 and col == 4):
            if self.board[0][6] == player and self.board[1][5] == player and self.board[2][4] == player:
                return True
        if (row == 0 and col == 0) or (row == 1 and col == 1) or (row == 2 and col == 2):
            if self.board[0][0] == player and self.board[1][1] == player and self.board[2][2] == player:
                return True
        if (row == 6 and col == 6) or (row == 5 and col == 5) or (row == 4 and col == 4):
            if self.board[6][6] == player and self.board[5][5] == player and self.board[4][4] == player:
                return True

        return False

    # 0 is invalid
    # 1 is unowned
    # 2 is player 1
    # 3 is player 2
    fn place_cow(inout self, player: Int) raises -> Bool:
        if self.count_placed_cows(player) >= 12:
            print("you have already placed all 12 of your cows")
            return False

        var opponent = 3 if player == 2 else 2  # assuming player 2 and 3
        
        print("player ", player, ", choose where to place your cow")
        print("enter the row and column (0-6) separated by a space:")

        while True:
            var input_str = self.get_input()
            var input_parts = input_str.split()
            
            if len(input_parts) != 2:
                print("invalid input. please enter two numbers separated by a space")
                continue
            
            var row: Int
            var col: Int
            try:
                row = atol(input_parts[0])
                col = atol(input_parts[1])
            except:
                print("invalid input. please enter valid numbers")
                continue

            if self.is_valid_position(row, col) and self.board[row][col] != player and self.board[row][col] != opponent:
                self.board[row][col] = player
                print("placed cow for player", player, "at row", row, "col", col)
                if self.is_in_mill(row, col, player):
                    print("player", player, "got a mill")
                    try:
                        _ = self.shoot_opponent_cow(player)
                    except:
                        print("unable to shoot opponent cow")
                return True
            else:
                print("invalid position. please choose an empty, valid position")
        
        #return False

    fn move_cow(inout self, player: Int) raises -> Bool:
        #var opponent = 3 if player == 2 else 2  # assuming player 2 and 3

        print("player ", player, ", choose a cow to move")
        print("enter the current row and column (0-6) of your cow, then the destination row and column, all separated by spaces:")

        while True:
            var input_str = self.get_input()
            var input_parts = input_str.split()

            if len(input_parts) != 4:
                print("invalid input. Please enter four numbers separated by spaces")
                continue

            var from_row: Int
            var from_col: Int
            var to_row: Int
            var to_col: Int
            try:
                from_row = atol(input_parts[0])
                from_col = atol(input_parts[1])
                to_row = atol(input_parts[2])
                to_col = atol(input_parts[3])
            except:
                print("invalid input. please enter valid numbers")
                continue
            if self.board[from_row][from_col] != player:
                print("invalid move: no piece at the starting position")
                continue

            if self.board[to_row][to_col] != 1:  # assuming 1 represents an empty position
                print("invalid move: destination is not valid")
                continue

            if not self.is_adjacent(from_row, from_col, to_row, to_col):
                print("invalid move: can only move to adjacent positions")
                continue

            self.board[to_row][to_col] = player
            self.board[from_row][from_col] = 1  # set the 'from' position to empty

            if self.is_in_mill(to_row, to_col, player):
                print("Player", player, "formed a mill")
                try:
                    _ = self.shoot_opponent_cow(player)
                except:
                    print("Unable to remove opponent cow")

            return True

        #return False

    fn is_adjacent(self, row1: Int, col1: Int, row2: Int, col2: Int) -> Bool:
        # Check if the positions are the same
        if row1 == row2 and col1 == col2:
            return False

        # Check for corner to corner moves
        if (row1 == 0 or row1 == 6) and (col1 == 0 or col1 == 6):
            return abs(row1 - row2) == 1 and abs(col1 - col2) == 1

        # Check for moves along the same line
        if row1 == row2:
            return abs(col1 - col2) == 3 or (abs(col1 - col2) == 1 and (row1 % 3 == 0 or col1 % 3 == 1))
        if col1 == col2:
            return abs(row1 - row2) == 3 or (abs(row1 - row2) == 1 and (col1 % 3 == 0 or row1 % 3 == 1))
            
        # Check for diagonal moves in the middle square
        if (row1 == 3 and col1 == 3) or (row2 == 3 and col2 == 3):
            return abs(row1 - row2) == 1 and abs(col1 - col2) == 1

        return False

    fn fly_cow(inout self, player: Int) raises -> Bool:
        #var opponent = 3 if player == 2 else 2  # Assuming player 2 and 3

        print("player ", player, ", choose a cow to fly")
        print("enter the current row and column (0-6) of your cow, then the destination row and column, all separated by spaces:")

        while True:
            var input_str = self.get_input()
            var input_parts = input_str.split()

            if len(input_parts) != 4:
                print("invalid input. Please enter four numbers separated by spaces")
                continue

            var from_row: Int
            var from_col: Int
            var to_row: Int
            var to_col: Int
            try:
                from_row = atol(input_parts[0])
                from_col = atol(input_parts[1])
                to_row = atol(input_parts[2])
                to_col = atol(input_parts[3])
            except:
                print("invalid input. Please enter valid numbers")
                continue

            if not self.is_valid_position(from_row, from_col) or not self.is_valid_position(to_row, to_col):
                print("invalid position. please choose valid board positions")
                continue

            if self.board[from_row][from_col] != player:
                print("invalid move: no cow at the starting position")
                continue

            if self.board[to_row][to_col] != 1:  # Assuming 1 represents an empty position
                print("invalid move: destination is not empty")
                continue

            self.board[to_row][to_col] = player
            self.board[from_row][from_col] = 1  # Set the 'from' position to empty

            if self.is_in_mill(to_row, to_col, player):
                print("player", player, "formed a mill")
                try:
                    _ = self.shoot_opponent_cow(player)
                except:
                    print("unable to remove opponent cow")

            return True

    fn shoot_opponent_cow(inout self, player: Int) raises -> Bool:
        var opponent = 3 if player == 2 else 2  # assuming player 2 and 3
        
        print("player ", player, ", choose an opponent's cow to shoot")
        print("enter the row and column (0-6) separated by a space:")

        # check if all pieces are in a mill
        var all_in_mill = True
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == opponent and not self.is_in_mill(row, col, opponent):
                    all_in_mill = False
                    break
            if not all_in_mill:
                break
        
        while True:
            var input_str = self.get_input()
            var input_parts = input_str.split()
            
            if len(input_parts) != 2:
                print("invalid input. please enter two numbers separated by a space")
                continue
            
            var row: Int
            var col: Int
            try:
                row = atol(input_parts[0])
                col = atol(input_parts[1])
            except:
                print("invalid input. please enter valid numbers")
                continue
            
            if row < 0 or row > 6 or col < 0 or col > 6:
                print("invalid position. row and column must be between 0 and 6")
                continue
            
            if self.board[row][col] != opponent:
                print("invalid position. there is no opponent cow at this location")
                continue
            
            if not all_in_mill and self.is_in_mill(row, col, opponent):
                print("this cow is part of a mill and cannot be shot. choose another piece")
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

    fn placement_phase(inout self) raises:
        var current_player = 2  # start with player 2
        while self.count_placed_cows(2) < 12 or self.count_placed_cows(3) < 12:
            print("player ", current_player, " (", self.count_placed_cows(current_player), "/12 cows placed)")
            if self.place_cow(current_player):
                self.print_board()
                current_player = 3 if current_player == 2 else 2
        print("placement phase complete. moving to the movement phase")

    fn count_player_cows(self, player: Int) -> Int:
        var count = 0
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == player:
                    count += 1
        return count

    fn count_placed_cows(self, player: Int) -> Int:
        var count = 0
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == player:
                    count += 1
        return count

    fn has_valid_moves(self, player: Int) -> Bool:
        #var opponent = 3 if player == 2 else 2
        
        # Check if the player has any pieces left
        var piece_count = self.count_player_cows(player)
        if piece_count == 0:
            return False
        
        # If the player has 3 or fewer pieces, they can fly to any empty spot
        if piece_count <= 3:
            for row in range(7):
                for col in range(7):
                    if self.board[row][col] == 1:  # Empty spot
                        return True
        
        # Otherwise, check for adjacent empty spots
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == player:
                    # Check adjacent positions
                    for adj_row in range(max(0, row-1), min(7, row+2)):
                        for adj_col in range(max(0, col-1), min(7, col+2)):
                            if self.is_valid_position(adj_row, adj_col) and self.board[adj_row][adj_col] == 1:
                                return True
        
        return False