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
    var ai_player = 3  # AI will play as player 3 (you can change this if needed)

    while True:
        print("player ", current_player - 1, "'s turn")

        if not game.has_valid_moves(current_player):
            print("player ", current_player - 1, " has no valid moves and loses the game")
            print("thank-you")
            break

        if current_player == ai_player:
            # AI's turn
            if game.count_player_cows(current_player) > 3:
                if game.ai_move(current_player):
                    game.print_board()
            else:
                print("AI player has only 3 cows left and they can now fly")
                if game.ai_fly(current_player):
                    game.print_board()
        else:
            # Human player's turn
            if game.count_player_cows(current_player) > 3:
                if game.move_cow(current_player):
                    game.print_board()
            else:
                print("player ", current_player - 1, " has only 3 cows left and they can now fly")
                if game.fly_cow(current_player):
                    game.print_board()

        if game.check_win_condition():
            break

        # check for draw condition
        if game.count_player_cows(2) <= 3 and game.count_player_cows(3) <= 3:
            game.three_cow_phase = True

        if game.three_cow_phase:
            game.moves_since_last_shot += 1
            if game.moves_since_last_shot >= 10:
                print("draw")
                print("thank-you for")
                break

        current_player = 3 if current_player == 2 else 2

fn main() raises:
    print_intro()
    var game = MorabarabaBoard()
    game.print_board()
    play_game(game)