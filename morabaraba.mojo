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
        print("player ", current_player - 1, "'s turn")

        if not game.has_valid_moves(current_player):
            print("player ", current_player - 1, " has no valid moves and loses the game")
            print("thank-you for playing, hamba kahle")
            break

        if game.count_player_cows(current_player) > 3:
            if game.move_cow(current_player):
                game.print_board()
        else:
            print("player ", current_player - 1, " has only 3 cows left and they can now fly")
            if game.fly_cow(current_player):
                game.print_board()
        
        if check_win_condition(game):
            break

        # check for draw condition
        if game.count_player_cows(2) <= 3 and game.count_player_cows(3) <= 3:
            game.three_cow_phase = True
        
        if game.three_cow_phase:
            game.moves_since_last_shot += 1
            if game.moves_since_last_shot >= 10:
                print("draw, neither player has shot a cow in 10 moves")
                print("thank-you for playing, hamba kahle")
                break
        
        current_player = 3 if current_player == 2 else 2

fn check_win_condition(inout game: MorabarabaBoard) -> Bool:
    if game.count_player_cows(2) < 3:
        print("player 2 wins. player 2 has fewer than 3 cows. ukuhalalisela!")
        print("thank-you for playing, hamba kahle")
        return True
    elif game.count_player_cows(3) < 3:
        print("player 1 wins. player 3 has fewer than 3 cows. ukuhalalisela!")
        print("thank-you for playing, hamba kahle")
        return True
    elif not game.has_valid_moves(2):
        print("player 2 wins. player 2 has no valid moves. ukuhalalisela!")
        print("thank-you for playing, hamba kahle")
        return True
    elif not game.has_valid_moves(3):
        print("player 1 wins. player 3 has no valid moves. ukuhalalisela!")
        print("thank-you for playing, hamba kahle")
        return True
    elif game.three_cow_phase and game.moves_since_last_shot >= 10:
        print("draw, neither player has shot a cow in 10 moves")
        print("thank-you for playing, hamba kahle")
        return True
    return False

fn main() raises:
    print_intro()
    var game = MorabarabaBoard()
    game.decide_player_one()
    game.print_board()
    play_game(game)