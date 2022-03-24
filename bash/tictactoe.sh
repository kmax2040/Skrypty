#!/usr/bin/bash

WINNER=none
declare TURN # X, O
declare BOARD

IS_INT_REGEX=^[-+]?[0-9]+$

H_LINE="---+---+---" # Horizontal line
V_LINES="   |   |" # Vertical lines

init_board () {
	TURN=O
	BOARD=($(seq 1 9))
}

load_save () {
	local FILE_NAME=$1
	local RAW_FILE_DATA=$(cat $FILE_NAME)

	TURN=$(cut -d$'\n' -f1 <<< $RAW_FILE_DATA)
	BOARD=($(cut -d$'\n' -f2 <<< $RAW_FILE_DATA))
}

print_board_row () {
	local CELL_VALUE
	local INDEX=$(($1*3))

	echo "$V_LINES"

	for i in {1..2}; do
		CELL_VALUE=${BOARD[$INDEX]}
		if [[ $CELL_VALUE == X ]]; then
			echo -en " \e[1;32m$CELL_VALUE\e[0m |"
		elif [[ $CELL_VALUE == O ]]; then
			echo -en " \e[1;36m$CELL_VALUE\e[0m |"
		else
			echo -en " \e[1;30m$CELL_VALUE\e[0m |"
		fi
		INDEX=$(($INDEX+1))
	done

	CELL_VALUE=${BOARD[$INDEX]}
	if [[ $CELL_VALUE == X ]]; then
		echo -e " \e[1;32m$CELL_VALUE\e[0m"
	elif [[ $CELL_VALUE == O ]]; then
		echo -e " \e[1;36m$CELL_VALUE\e[0m"
	else
		echo -e " \e[1;30m$CELL_VALUE\e[0m"
	fi

	echo "$V_LINES"
}

print_board () {
	print_board_row 0
	echo "$H_LINE"
	print_board_row 1
	echo "$H_LINE"
	print_board_row 2
}

toggle_turn () {
	if [[ $TURN = X ]]; then
		TURN=O
	else
		TURN=X
	fi
}

is_taken () { [[ ${BOARD[$1]} == X || ${BOARD[$1]} == O ]]; }

make_player_turn () {
	local IS_INPUT_VALID=false
	local INDEX
	local CHOICE
	local SAVE_FILE_NAME

	while [[ $IS_INPUT_VALID = false ]]; do
		echo -n "Enter cell number to make a move or 'Q' to quit: "
		read -r INDEX

		if [[ $INDEX = q || $INDEX = Q ]]; then
			echo -n "Do you want to save the game? [y/n]: "
			read -r CHOICE
			IS_INPUT_VALID=true
		elif ! [[ $INDEX =~ $IS_INT_REGEX ]]; then
			echo -e "\e[31mThe input has to be an integer\e[0m"
		elif [[ $INDEX -gt 9 || $INDEX -lt 1 ]]; then
			echo -e "\e[31mThe input has to be in range from 1 to 9\e[0m"
		elif is_taken $(($INDEX-1)); then
			echo -e "\e[31mCell at index $INDEX is already taken\e[0m"
		else
			IS_INPUT_VALID=true
		fi
	done

	if [[ $INDEX = q || $INDEX = Q ]]; then
		if [[ $CHOICE = y || $CHOICE = Y ]]; then
			echo -n "Enter save file name: "
			read -r SAVE_FILE_NAME

			echo $TURN > $SAVE_FILE_NAME # current turn
			echo "${BOARD[*]}" >> $SAVE_FILE_NAME # board state
		fi
		exit
	fi

	BOARD[$((INDEX-1))]=$TURN

	#check win condition
	if [[
		# rows
		${BOARD[0]} = ${BOARD[1]} && ${BOARD[1]} = ${BOARD[2]} ||
		${BOARD[3]} = ${BOARD[4]} && ${BOARD[4]} = ${BOARD[5]} ||
		${BOARD[6]} = ${BOARD[7]} && ${BOARD[7]} = ${BOARD[8]} ||
		# columns
		${BOARD[0]} = ${BOARD[3]} && ${BOARD[3]} = ${BOARD[6]} ||
		${BOARD[1]} = ${BOARD[4]} && ${BOARD[4]} = ${BOARD[7]} ||
		${BOARD[2]} = ${BOARD[5]} && ${BOARD[5]} = ${BOARD[8]} ||
		# diagonals
		${BOARD[0]} = ${BOARD[4]} && ${BOARD[4]} = ${BOARD[8]} ||
		${BOARD[2]} = ${BOARD[4]} && ${BOARD[4]} = ${BOARD[6]}
	]]; then
		WINNER=$TURN
	fi

	toggle_turn
}

main_menu () {
	local CHOICE
	local FILE_NAME

	clear
	echo "1. New game"
	echo "2. Load save"
	echo "3. Quit"
	echo -n "Enter option number: "
	read -r CHOICE

	if [[ $CHOICE -eq 1 ]]; then
		init_board
	elif [[ $CHOICE -eq 2 ]]; then
		echo -n "Enter save file name: "
		read -r FILE_NAME
		load_save $FILE_NAME
	else
		exit
	fi
}

main_loop () {
	for _ in {1..9}; do
		if [[ $WINNER != none ]]; then break; fi
		clear
		echo "Current Turn: $TURN"
		print_board
		make_player_turn
	done

	clear
	echo "Game over"
	print_board
	if [[ $WINNER != none ]]; then
		echo "$WINNER is the winner!"
	else
		echo "Draw!"
	fi
}

main_menu

main_loop
