# 0. (0,0),               (0,3),               (0,6)
# 1.        (1,1),        (1,3),        (1,5)
# 2.               (2,2), (2,3), (2,4)
# 3. (3,0), (3,1), (3,2),        (3,4), (3,5), (3,6)
# 4.               (4,2), (4,3), (4,4)
# 5.        (5,1),        (5,3),        (5,5)
# 6. (6,0),               (6,3),               (6,6)

from utils import StaticTuple
from utils import StaticIntTuple

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

    # returns true if player picks a valid position, false if not
    fn is_valid_position(self, row: Int, col: Int) -> Bool:
        if row < 0 or row >= 7 or col < 0 or col >= 7:
            return False
        return self.board[row][col] == 1
        
    fn is_in_mill(self, row: Int, col: Int, player: Int) -> Bool:
        # Check horizontal mill
        if col == 0 or col == 3 or col == 6:
            if self.board[row][0] == player and self.board[row][3] == player and self.board[row][6] == player:
                return True
        
        # Check vertical mill
        if row == 0 or row == 3 or row == 6:
            if self.board[0][col] == player and self.board[3][col] == player and self.board[6][col] == player:
                return True
        
        # Check middle horizontal lines
        if row == 1 or row == 5:
            if self.board[row][1] == player and self.board[row][3] == player and self.board[row][5] == player:
                return True
        
        # Check middle vertical lines
        if col == 1 or col == 5:
            if self.board[1][col] == player and self.board[3][col] == player and self.board[5][col] == player:
                return True
        
        # Check diagonal lines in the middle square
        if (row == 2 or row == 3 or row == 4) and (col == 2 or col == 3 or col == 4):
            if self.board[2][2] == player and self.board[3][3] == player and self.board[4][4] == player:
                return True
            if self.board[2][4] == player and self.board[3][3] == player and self.board[4][2] == player:
                return True
        
        return False

    # 0 is unusable
    # 1 is unowned
    # 2 is player 1
    # 3 is player 2
    fn place_piece(inout self, row: Int, col: Int, player: Int, opponent: Int) -> Bool:
        if self.is_valid_position(row, col) and self.board[row][col] != player and self.board[row][col] != opponent:
            self.board[row][col] = player
            if self.is_in_mill(row, col, player):  # Check if the current player formed a mill
                print("Player", player, "got a mill")
                _ = self.remove_opponent_piece(player)
            return True
        return False

    fn remove_opponent_piece(inout self, player: Int) -> Bool:
        var opponent = 3 if player == 2 else 2  # Assuming player 2 and 3
        
        print("Player ", player, ", choose an opponent's piece to remove.")
        print("Enter the row and column (0-6) separated by a space:")
        
        while True:
            var input_str = input()
            var input_parts = input_str.split()
            
            if len(input_parts) != 2:
                print("Invalid input. Please enter two numbers separated by a space.")
                continue
            
            var row: Int
            var col: Int
            try:
                row = atol(input_parts[0])
                col = atol(input_parts[1])
            except:
                print("Invalid input. Please enter valid numbers.")
                continue
            
            if row < 0 or row > 6 or col < 0 or col > 6:
                print("Invalid position. Row and column must be between 0 and 6.")
                continue
            
            if self.board[row][col] != opponent:
                print("Invalid position. There is no opponent piece at this location.")
                continue
            
            if self.is_in_mill(row, col, opponent):
                print("This piece is part of a mill and cannot be removed. Choose another piece.")
                continue
            
            self.board[row][col] = 1  # Set back to empty valid position
            print("Removed opponent's piece at row ", row, ", col ", col)
            return True

    fn print_board(self):
        for row in range(7):
            for col in range(7):
                if self.board[row][col] == 1:
                    print("O ", end="")
                elif self.board[row][col] == 2:
                    print("⑁⚇", end="")
                elif self.board[row][col] == 3:
                    print("⑁⚉", end="")
                else:
                    print(". ", end="")
            print()