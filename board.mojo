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
        
    fn check_mill(self, player: Int) -> Bool:
        # check horizontal lines
        for i in range(3):
            var row = i * 3
            if self.board[row][0] == player and self.board[row][3] == player and self.board[row][6] == player:
                return True

        # check vertical lines
        for i in range(3):
            var col = i * 3
            if self.board[0][col] == player and self.board[3][col] == player and self.board[6][col] == player:
                return True

        # check middle horizontal lines
        if self.board[1][1] == player and self.board[1][3] == player and self.board[1][5] == player:
            return True
        if self.board[5][1] == player and self.board[5][3] == player and self.board[5][5] == player:
            return True

        # check middle vertical lines
        if self.board[1][1] == player and self.board[3][1] == player and self.board[5][1] == player:
            return True
        if self.board[1][5] == player and self.board[3][5] == player and self.board[5][5] == player:
            return True

        # check diagonal lines in the middle square
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
        if self.is_valid_position(row, col) and not self.board[row][col] == opponent:
            self.board[row][col] = player
            if self.check_mill(player):
                print("player", player, "got a mill")
            return True
        return False

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