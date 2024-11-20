from board import MorabarabaBoard

fn main():
    var board = MorabarabaBoard()
    board.print_board()

    _ = board.place_piece(0, 0, 2, 3)
    _ = board.place_piece(0, 3, 2, 3)
    _ = board.place_piece(0, 6, 2, 3)
    
    _ = board.place_piece(3, 0, 3, 2)
    _ = board.place_piece(6, 0, 3, 2)

    board.print_board()