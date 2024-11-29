# 0. (0,0),               (0,3),               (0,6)
# 1.        (1,1),        (1,3),        (1,5)
# 2.               (2,2), (2,3), (2,4)
# 3. (3,0), (3,1), (3,2),        (3,4), (3,5), (3,6)
# 4.               (4,2), (4,3), (4,4)
# 5.        (5,1),        (5,3),        (5,5)
# 6. (6,0),               (6,3),               (6,6)

from utils import StaticTuple
from utils import StaticIntTuple
from utils.numerics import inf
from utils.numerics import neg_inf
from python import Python
from sys import exit
from rules import print_rules
from random import random_float64
from collections import List

@value
struct Move(CollectionElement):
    var from_row: Int
    var from_col: Int
    var to_row: Int
    var to_col: Int

    fn __init__(inout self, from_row: Int, from_col: Int, to_row: Int, to_col: Int):
        self.from_row = from_row
        self.from_col = from_col
        self.to_row = to_row
        self.to_col = to_col

    fn __copyinit__(inout self, existing: Self):
        self.from_row = existing.from_row
        self.from_col = existing.from_col
        self.to_row = existing.to_row
        self.to_col = existing.to_col

    fn __moveinit__(inout self, owned existing: Self):
        self.from_row = existing.from_row
        self.from_col = existing.from_col
        self.to_row = existing.to_row
        self.to_col = existing.to_col

struct MorabarabaBoard:
    var board: StaticTuple[StaticTuple[Int, 7], 7]
    var moves_since_last_shot: Int
    var three_cow_phase: Bool
    var total_cows_placed: StaticTuple[Int, 2]  # index 0 for player 2, index 1 for player 3

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
        self.moves_since_last_shot = 0
        self.three_cow_phase = False
        self.total_cows_placed = StaticTuple[Int, 2](0, 0)

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

    fn check_win_condition(self) -> Bool:
        if self.count_player_cows(2) < 3:
            print("player 2 wins. player 2 has fewer than 3 cows. ukuhalalisela!")
            print("thank-you for playing, hamba kahle")
            return True
        elif self.count_player_cows(3) < 3:
            print("player 1 wins. player 3 has fewer than 3 cows. ukuhalalisela!")
            print("thank-you for playing, hamba kahle")
            return True
        elif not self.has_valid_moves(2):
            print("player 2 wins. player 2 has no valid moves. ukuhalalisela!")
            print("thank-you for playing, hamba kahle")
            return True
        elif not self.has_valid_moves(3):
            print("player 1 wins. player 3 has no valid moves. ukuhalalisela!")
            print("thank-you for playing, hamba kahle")
            return True
        elif self.three_cow_phase and self.moves_since_last_shot >= 10:
            print("draw, neither player has shot a cow in 10 moves")
            print("thank-you for playing, hamba kahle")
            return True
        return False

    # returns true if player picks a valid position, false if not
    fn is_valid_position(self, row: Int, col: Int) -> Bool:
        if row < 0 or row >= 7 or col < 0 or col >= 7:
            return False
        return self.board[row][col] == 1
        
    fn is_in_mill(self, row: Int, col: Int, player: Int) -> Bool:
        # top-left diagonal
        if (row == 0 and col == 0) or (row == 1 and col == 1) or (row == 2 and col == 2):
            if self.board[0][0] == player and self.board[1][1] == player and self.board[2][2] == player:
                return True
        # top-middle down
        if (row == 0 and col == 3) or (row == 1 and col == 3) or (row == 2 and col == 3):
            if self.board[0][3] == player and self.board[1][3] == player and self.board[2][3] == player:
                return True
        # top-right diagonal
        if (row == 0 and col == 6) or (row == 1 and col == 5) or (row == 2 and col == 4):
            if self.board[0][6] == player and self.board[1][5] == player and self.board[2][4] == player:
                return True
        # middle-right left
        if (row == 3 and col == 6) or (row == 3 and col == 5) or (row == 3 and col == 4):
            if self.board[3][6] == player and self.board[3][5] == player and self.board[3][4] == player:
                return True
        # bottom-right diagonal
        if (row == 6 and col == 6) or (row == 5 and col == 5) or (row == 4 and col == 4):
            if self.board[6][6] == player and self.board[5][5] == player and self.board[4][4] == player:
                return True
        # bottom-middle up
        if (row == 6 and col == 3) or (row == 5 and col == 3) or (row == 4 and col == 3):
            if self.board[6][3] == player and self.board[5][3] == player and self.board[4][3] == player:
                return True
        # bottom-left diagonal 
        if (row == 6 and col == 0) or (row == 5 and col == 1) or (row == 4 and col == 2):
            if self.board[6][0] == player and self.board[5][1] == player and self.board[4][2] == player:
                return True
        # middle-left right
        if (row == 3 and col == 0) or (row == 3 and col == 1) or (row == 3 and col == 2):
            if self.board[3][0] == player and self.board[3][1] == player and self.board[3][2] == player:
                return True
        # 0 row right
        if (row == 0 and col == 0) or (row == 0 and col == 3) or (row == 0 and col == 6):
            if self.board[0][0] == player and self.board[0][3] == player and self.board[0][6] == player:
                return True
        # 1 row right
        if (row == 1 and col == 1) or (row == 1 and col == 3) or (row == 1 and col == 5):
            if self.board[1][1] == player and self.board[1][3] == player and self.board[1][5] == player:
                return True
        # 2 row right
        if (row == 2 and col == 2) or (row == 2 and col == 3) or (row == 2 and col == 4):
            if self.board[2][2] == player and self.board[2][3] == player and self.board[2][4] == player:
                return True
        # 4 row right
        if (row == 4 and col == 2) or (row == 4 and col == 3) or (row == 4 and col == 4):
            if self.board[4][2] == player and self.board[4][3] == player and self.board[4][4] == player:
                return True
        # 5 row right
        if (row == 5 and col == 1) or (row == 5 and col == 3) or (row == 5 and col == 5):
            if self.board[5][1] == player and self.board[5][3] == player and self.board[5][5] == player:
                return True
        # 6 row right
        if (row == 6 and col == 0) or (row == 6 and col == 3) or (row == 6 and col == 6):
            if self.board[6][0] == player and self.board[6][3] == player and self.board[6][6] == player:
                return True
        # 0 column down
        if (row == 0 and col == 0) or (row == 3 and col == 0) or (row == 6 and col == 0):
            if self.board[0][0] == player and self.board[3][0] == player and self.board[6][0] == player:
                return True
        # 1 column down
        if (row == 1 and col == 1) or (row == 3 and col == 1) or (row == 5 and col == 1):
            if self.board[1][1] == player and self.board[3][1] == player and self.board[5][1] == player:
                return True
        # 2 column down
        if (row == 2 and col == 2) or (row == 3 and col == 2) or (row == 4 and col == 2):
            if self.board[2][2] == player and self.board[3][2] == player and self.board[4][2] == player:
                return True
        # 4 column down
        if (row == 2 and col == 4) or (row == 3 and col == 4) or (row == 4 and col == 4):
            if self.board[2][4] == player and self.board[3][4] == player and self.board[4][4] == player:
                return True
        # 5 column down
        if (row == 1 and col == 5) or (row == 3 and col == 5) or (row == 5 and col == 5):
            if self.board[1][5] == player and self.board[3][5] == player and self.board[5][5] == player:
                return True
        # 6 column down
        if (row == 0 and col == 6) or (row == 3 and col == 6) or (row == 6 and col == 6):
            if self.board[0][6] == player and self.board[3][6] == player and self.board[6][6] == player:
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
        
        print("player ", player - 1, ", choose where to place your cow")
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
                self.total_cows_placed[player - 2] += 1  # increment total cows placed
                print("placed cow for player", player - 1, "at row", row, "col", col)
                if self.is_in_mill(row, col, player):
                    print("player", player - 1, "got a mill")
                    try:
                        _ = self.shoot_opponent_cow(player)
                    except:
                        print("unable to shoot opponent cow")
                return True
            else:
                print("invalid position. please choose an empty, valid position")

    fn move_cow(inout self, player: Int) raises -> Bool:
        #var opponent = 3 if player == 2 else 2  # assuming player 2 and 3

        print("player ", player - 1, ", choose a cow to move")
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
                print("Player", player - 1, "formed a mill")
                try:
                    _ = self.shoot_opponent_cow(player)
                except:
                    print("Unable to remove opponent cow")

            return True

    fn is_valid_adjacent_position(self, row: Int, col: Int) -> Bool:
        return (row == 0 and (col == 0 or col == 3 or col == 6)) or
            (row == 1 and (col == 1 or col == 3 or col == 5)) or
            (row == 2 and (col == 2 or col == 3 or col == 4)) or
            (row == 3 and (col == 0 or col == 1 or col == 2 or col == 4 or col == 5 or col == 6)) or
            (row == 4 and (col == 2 or col == 3 or col == 4)) or
            (row == 5 and (col == 1 or col == 3 or col == 5)) or
            (row == 6 and (col == 0 or col == 3 or col == 6))

    fn is_valid_adjacent_corner_move(self, row: Int, col: Int) -> Bool:
        return (row == 1 and (col == 1 or col == 5)) or
            (row == 5 and (col == 1 or col == 5))

    fn is_valid_adjacent_inner_move(self, row: Int, col: Int) -> Bool:
        return (row == 2 and (col == 2 or col == 4)) or
            (row == 4 and (col == 2 or col == 4))

    fn is_adjacent(self, row1: Int, col1: Int, row2: Int, col2: Int) -> Bool:
        # check if the positions are the same
        if row1 == row2 and col1 == col2:
            return False

        # check if both positions are valid
        if not self.is_valid_adjacent_position(row1, col1) or not self.is_valid_adjacent_position(row2, col2):
            return False

        # check for moves along the same line
        if row1 == row2:
            return abs(col1 - col2) == 1 or abs(col1 - col2) == 3
        if col1 == col2:
            return abs(row1 - row2) == 1 or abs(row1 - row2) == 3

        # check for diagonal moves between rings
        if abs(row1 - row2) == 1 and abs(col1 - col2) == 1:
            # check if one position is on the outer ring and the other is on the middle ring
            if (row1 == 0 or row1 == 6 or col1 == 0 or col1 == 6) and (row2 == 1 or row2 == 5 or col2 == 1 or col2 == 5):
                return True
            if (row2 == 0 or row2 == 6 or col2 == 0 or col2 == 6) and (row1 == 1 or row1 == 5 or col1 == 1 or col1 == 5):
                return True
            # check for moves between middle and inner rings
            return (self.is_valid_adjacent_corner_move(row1, col1) and self.is_valid_adjacent_inner_move(row2, col2)) or
                (self.is_valid_adjacent_corner_move(row2, col2) and self.is_valid_adjacent_inner_move(row1, col1))

        return False

    fn fly_cow(inout self, player: Int) raises -> Bool:
        #var opponent = 3 if player == 2 else 2  # Assuming player 2 and 3

        print("player ", player - 1, ", choose a cow to fly")
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
                print("player", player - 1, "formed a mill")
                try:
                    _ = self.shoot_opponent_cow(player)
                except:
                    print("unable to remove opponent cow")

            return True

    fn shoot_opponent_cow(inout self, player: Int) raises -> Bool:
        var opponent = 3 if player == 2 else 2  # assuming player 2 and 3
        
        print("player ", player - 1, ", choose an opponent's cow to shoot")
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
            print("Shot opponent's cow at row ", row, ", col ", col)
            self.moves_since_last_shot = 0  # reset the counter
            return True

    fn print_board(self):
        print()
        print("        0   1   2   3   4   5   6")  # x-axis labels
        print("   -------------------------------")
        print()
        for row in range(7):
            print(row, "|", end="    ")  # y-axis label
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
        var ai_player = 3       # AI is player 3

        while self.count_placed_cows(2) < 12 or self.count_placed_cows(3) < 12:
            if self.count_placed_cows(current_player) >= 12:
                current_player = ai_player if current_player == 2 else 2
                continue

            print("Player ", current_player - 1, " (", self.count_placed_cows(current_player), "/12 cows placed)")
            
            var placement_successful = False
            if current_player == ai_player:
                placement_successful = self.ai_place_cow(current_player)
            else:
                placement_successful = self.place_cow(current_player)
            
            if placement_successful:
                self.print_board()
                current_player = ai_player if current_player == 2 else 2
            
        print("Placement phase complete. Moving to the movement phase")

    fn place_ai_cow(inout self, row: Int, col: Int, player: Int) -> Bool:
        if self.is_valid_position(row, col) and self.board[row][col] == 1:  # Assuming 1 represents an empty spot
            self.board[row][col] = player
            self.total_cows_placed[player - 2] += 1  # increment total cows placed
            return True
        return False

    fn remove_cow(inout self, row: Int, col: Int):
        if self.is_valid_position(row, col):
            self.board[row][col] = 1  # Set back to empty

    fn ai_place_cow(inout self, player: Int) -> Bool:
        print("AI attempting to place cow. Current count:", self.count_placed_cows(player))

        if self.count_placed_cows(player) >= 12:
            print("AI has already placed all 12 of its cows")
            return False

        var placements = self.get_possible_placements(player)
        print("Number of possible placements:", len(placements))

        if len(placements) == 0:
            print("No valid placements available for AI")
            return False

        var best_score = -inf[DType.float64]()
        var best_move: Move = Move(-1, -1, -1, -1)

        for i in range(len(placements)):
            var move = placements[i]
            self.board[move.to_row][move.to_col] = player
            var score = self.minimax(2, -inf[DType.float64](), inf[DType.float64](), False, player, True)
            self.board[move.to_row][move.to_col] = 1  # Set back to empty

            print("Evaluated move:", move.to_row, move.to_col, "with score:", score)

            if score > best_score:
                best_score = score
                best_move = move

            if best_move.to_row != -1:
                self.board[best_move.to_row][best_move.to_col] = player
                self.total_cows_placed[player - 2] += 1
                print("AI placed a cow at row", best_move.to_row, "col", best_move.to_col)
            if self.is_in_mill(best_move.to_row, best_move.to_col, player):
                print("AI got a mill")
                _ = self.ai_shoot_opponent_cow(player)
            return True
        else:
            print("AI failed to find a valid move")
            return False
        
    fn get_possible_placements(self, player: Int) -> List[Move]:
        var placements = List[Move]()
        for row in range(7):
            for col in range(7):
                if self.is_valid_position(row, col) and self.board[row][col] == 1:  # Assuming 1 represents an empty spot
                    placements.append(Move(-1, -1, row, col))  # Use -1, -1 for 'from' position as it's not applicable for placement
        return placements

    fn ai_shoot_opponent_cow(inout self, player: Int) -> Bool:
        var opponent = 3 if player == 2 else 2
        var best_score = -inf[DType.float64]()
        var best_move: Move = Move(-1, -1, -1, -1)

        for row in range(7):
            for col in range(7):
                if self.board[row][col] == opponent and not self.is_in_mill(row, col, opponent):
                    self.board[row][col] = 1  # Temporarily remove opponent's cow
                    var score = self.minimax(2, -inf[DType.float64](), inf[DType.float64](), False, player, True)  # Depth of 2
                    self.board[row][col] = opponent  # Put the cow back

                    if score > best_score:
                        best_score = score
                        best_move = Move(-1, -1, row, col)

        if best_move.to_row != -1:
            self.board[best_move.to_row][best_move.to_col] = 1  # Remove the opponent's cow
            print("AI removed opponent's cow at row", best_move.to_row, "col", best_move.to_col)
            return True

        return False

    fn count_player_cows(self, player: Int) -> Int:
        var count = 0
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == player:
                    count += 1
        return count

    fn count_placed_cows(self, player: Int) -> Int:
        return self.total_cows_placed[player - 2]

    fn has_valid_moves(self, player: Int) -> Bool:
        # check if the player has any cows left
        var piece_count = self.count_player_cows(player)
        if piece_count == 0:
            return False
        
        # if the player has 3 or fewer cows, they can fly to any empty spot
        if piece_count <= 3:
            for row in range(8):
                for col in range(8):
                    if self.is_valid_position(row, col) and self.board[row][col] == 1:  # empty spot
                        return True
        
        # otherwise check for adjacent empty spots
        for row in range(8):
            for col in range(8):
                if self.board[row][col] == player:
                    # check adjacent positions using is_adjacent method
                    for adj_row in range(8):
                        for adj_col in range(8):
                            if self.is_adjacent(row, col, adj_row, adj_col) and self.board[adj_row][adj_col] == 1:
                                return True
        
        return False

    fn evaluate_board(self, player: Int) -> Int:
        var opponent = 3 if player == 2 else 2
        var score = 0

        # Count pieces
        var player_pieces = self.count_player_cows(player)
        var opponent_pieces = self.count_player_cows(opponent)
        score += (player_pieces - opponent_pieces) * 10

        # Count mills
        var player_mills = self.count_mills(player)
        var opponent_mills = self.count_mills(opponent)
        score += (player_mills - opponent_mills) * 50

        # Check potential mills and strategic positions
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == player:
                    score += self.evaluate_position(row, col, player)
                elif self.board[row][col] == opponent:
                    score -= self.evaluate_position(row, col, opponent)

        # Bonus for controlling center positions
        if self.board[3][3] == player:
            score += 5

        return score

    fn evaluate_position(self, row: Int, col: Int, player: Int) -> Int:
        var value = 0

        # Check for potential mills
        if self.is_part_of_potential_mill(row, col, player):
            value += 3

        # Value corner positions
        if (row == 0 or row == 6) and (col == 0 or col == 6):
            value += 2
        # Value edge middle positions
        if (row == 0 or row == 6 or col == 0 or col == 6) and (row == 3 or col == 3):
            value += 1

        return value

    fn is_part_of_potential_mill(self, row: Int, col: Int, player: Int) -> Bool:
        # Check horizontal
        if col == 0 and self.board[row][3] == player and self.board[row][6] == 1:
            return True
        if col == 3 and ((self.board[row][0] == player and self.board[row][6] == 1) or 
                        (self.board[row][6] == player and self.board[row][0] == 1)):
            return True
        if col == 6 and self.board[row][0] == player and self.board[row][3] == 1:
            return True

        # Check vertical
        if row == 0 and self.board[3][col] == player and self.board[6][col] == 1:
            return True
        if row == 3 and ((self.board[0][col] == player and self.board[6][col] == 1) or 
                        (self.board[6][col] == player and self.board[0][col] == 1)):
            return True
        if row == 6 and self.board[0][col] == player and self.board[3][col] == 1:
            return True

        # Check diagonals (for positions that are part of diagonals)
        if (row == col or row + col == 6) and row % 3 == 0:
            var other1 = (row + 3) % 9
            var other2 = (row + 6) % 9
            if self.board[other1 // 3][other1 % 3] == player and self.board[other2 // 3][other2 % 3] == 1:
                return True
            if self.board[other2 // 3][other2 % 3] == player and self.board[other1 // 3][other1 % 3] == 1:
                return True

        return False

    fn count_mills(self, player: Int) -> Int:
        var mills = 0
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == player and self.is_in_mill(row, col, player):
                    mills += 1
        return mills // 3  # Divide by 3 as each mill is counted 3 times

    fn is_valid_move(self, from_row: Int, from_col: Int, to_row: Int, to_col: Int, player: Int) -> Bool:
        # Check if the destination is empty
        if self.board[to_row][to_col] != 1:  # Assuming 1 represents an empty spot
            return False
        
        # Check if the starting position contains the player's piece
        if self.board[from_row][from_col] != player:
            return False
        
        # If the player has more than 3 pieces, check for adjacency
        if self.count_player_cows(player) > 3:
            return self.is_adjacent(from_row, from_col, to_row, to_col)
        
        # If the player has 3 or fewer pieces, they can "fly" to any empty spot
        return self.is_valid_position(to_row, to_col)

    fn get_possible_moves(self, player: Int) -> List[Move]:
        var moves = List[Move]()
        for from_row in range(7):
            for from_col in range(7):
                if self.board[from_row][from_col] == player:
                    for to_row in range(7):
                        for to_col in range(7):
                            if self.is_valid_move(from_row, from_col, to_row, to_col, player):
                                moves.append(Move(from_row, from_col, to_row, to_col))
        return moves

    fn minimax(inout self, depth: Int, alpha: Float64, beta: Float64, maximizing_player: Bool, player: Int, is_placing_phase: Bool) -> Float64:
        if depth == 0 or self.check_win_condition():
            return self.evaluate_board(player)

        var opponent = 3 if player == 2 else 2

        if is_placing_phase:
            moves = self.get_possible_placements(player if maximizing_player else opponent)
        else:
            moves = self.get_possible_moves(player if maximizing_player else opponent)
        if maximizing_player:
            var max_eval = -inf[DType.float64]()
            for i in range(len(moves)):
                var move = moves[i]
                if is_placing_phase:
                    _ = self.place_ai_cow(move.to_row, move.to_col, player)
                else:
                    self.make_move(move, player)

                var eval = self.minimax(depth - 1, alpha, beta, False, player, is_placing_phase)

                if is_placing_phase:
                    self.remove_cow(move.to_row, move.to_col)
                else:
                    self.undo_move(move, player)

                max_eval = max(max_eval, eval)
                var alpha = max(alpha, eval)
                if beta <= alpha:
                    break
            return max_eval
        else:
            var min_eval = inf[DType.float64]()
            for i in range(len(moves)):
                var move = moves[i]
                if is_placing_phase:
                    _ = self.place_ai_cow(move.to_row, move.to_col, opponent)
                else:
                    self.make_move(move, opponent)

                var eval = self.minimax(depth - 1, alpha, beta, True, player, is_placing_phase)

                if is_placing_phase:
                    self.remove_cow(move.to_row, move.to_col)
                else:
                    self.undo_move(move, player)

                min_eval = min(min_eval, eval)
                var beta = min(beta, eval)
                if beta <= alpha:
                    break
            return min_eval

    fn make_move(inout self, move: Move, player: Int):
        self.board[move.to_row][move.to_col] = player
        self.board[move.from_row][move.from_col] = 1

    fn undo_move(inout self, move: Move, player: Int):
        self.board[move.from_row][move.from_col] = player
        self.board[move.to_row][move.to_col] = 1

    fn ai_move(inout self, player: Int) -> Bool:
        var infinity = inf[DType.float64]()
        var negative_infinity = neg_inf[DType.float64]()
        var best_score = negative_infinity
        var best_move: Move = Move(-1, -1, -1, -1)  # Initialize with invalid move

        var moves = self.get_possible_moves(player)
        for i in range(len(moves)):
            var move = moves[i]
            self.make_move(move, player)
            var score = self.minimax(3, negative_infinity, infinity, False, player, False)  # Depth of 3
            self.undo_move(move, player)

            if score > best_score:
                best_score = score
                best_move = move

        if best_move.from_row != -1:  # Check if a valid move was found
            self.make_move(best_move, player)
            print("AI moved from (", best_move.from_row, ",", best_move.from_col, 
                ") to (", best_move.to_row, ",", best_move.to_col, ")")
            return True

        return False

    fn get_possible_fly_moves(self, player: Int) -> List[Move]:
        var moves = List[Move]()
        for from_row in range(7):
            for from_col in range(7):
                if self.board[from_row][from_col] == player:
                    for to_row in range(7):
                        for to_col in range(7):
                            if self.is_valid_position(to_row, to_col) and self.board[to_row][to_col] == 1:  # 1 represents an empty spot
                                moves.append(Move(from_row, from_col, to_row, to_col))
        return moves

    fn ai_fly(inout self, player: Int) -> Bool:
        var infinity = inf[DType.float64]()
        var negative_infinity = neg_inf[DType.float64]()
        var best_score = negative_infinity
        var best_move: Move = Move(-1, -1, -1, -1)  # Initialize with invalid move

        var moves = self.get_possible_fly_moves(player)
        for i in range(len(moves)):
            var move = moves[i]
            self.make_move(move, player)
            var score = self.minimax(3, negative_infinity, infinity, False, player, False)  # Depth of 3
            self.undo_move(move, player)

            if score > best_score:
                best_score = score
                best_move = move

        if best_move.from_row != -1:  # Check if a valid move was found
            self.make_move(best_move, player)
            print("AI flew from (", best_move.from_row, ",", best_move.from_col, 
                ") to (", best_move.to_row, ",", best_move.to_col, ")")
            return True

        return False