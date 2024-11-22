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

fn play_game(inout game: MorabarabaBoard) raises:
    game.placement_phase()
    
    var current_player = 2  # Start with player 2
    while True:
        print("player ", current_player, "'s turn")
        if game.count_player_cows(current_player) > 3:
            if game.move_cow(current_player):
                game.print_board()
                current_player = 3 if current_player == 2 else 2
        else:
            print("player ", current_player, " has only 3 cows left and they can now fly")
            if game.fly_cow(current_player):
                game.print_board()
                current_player = 3 if current_player == 2 else 2
        
        if check_win_condition(game):
            break

fn check_win_condition(inout game: MorabarabaBoard) -> Bool:
    if game.count_player_cows(2) < 3:
        print("Player 3 wins, ukuhalalisela!")
        print("hamba kahle")
        return True
    elif game.count_player_cows(3) < 3:
        print("Player 2 wins, ukuhalalisela!")
        print("hamba kahle")
        return True
    return False

fn main() raises:
    print_intro()
    var game = MorabarabaBoard()
    
    play_game(game)