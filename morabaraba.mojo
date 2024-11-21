# 0. (0,0),               (0,3),               (0,6)
# 1.        (1,1),        (1,3),        (1,5)
# 2.               (2,2), (2,3), (2,4)
# 3. (3,0), (3,1), (3,2),        (3,4), (3,5), (3,6)
# 4.               (4,2), (4,3), (4,4)
# 5.        (5,1),        (5,3),        (5,5)
# 6. (6,0),               (6,3),               (6,6)

from board import MorabarabaBoard
from intro import print_intro

# 0 is invalid
# 1 is unowned
# 2 is player 1
# 3 is player 2

fn main() raises:
    print_intro()
    var game = MorabarabaBoard()
    
    print("Initial board:")
    game.print_board()
    
    print("\nPlacing cow for player 2:")
    _ = game.place_cow(2)
    game.print_board()

    print("\nPlacing cow for player 3:")
    _ = game.place_cow(3)
    game.print_board()
    
    print("\nMoving cow for player 2:")
    _ = game.move_cow(2)
    game.print_board()