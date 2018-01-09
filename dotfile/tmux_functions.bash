## tmux functions to
## 1. refresh DISPLAY environment value on current pane
## 2. to excuted command to all the pane
## 
## to update DISPLAY on all the windows/pane: 
## 1. make sure every pane are at terminal, not at vim or something else
## 2. run "execute_in_all_tmux_panes refresh_tmux"
## 
## the refreence are lost...

if [ -n "$TMUX" ]; then                                                                               
	function refresh_tmux {                                                                                
		#export $(tmux show-environment | grep "^SSH_AUTH_SOCK")                                       
		export $(tmux show-environment | grep "^DISPLAY")                                             
		echo New DISPLAY =  $DISPLAY  
	}                                                                                                 

	function execute_in_all_tmux_panes {

	  # Notate which window/pane we were originally at
	  ORIG_WINDOW_INDEX=`tmux display-message -p '#I'`
	  ORIG_PANE_INDEX=`tmux display-message -p '#P'`

	  # Assign the argument to something readable
	  command=$1

	  # Count how many windows we have
	  windows=$((`tmux list-windows | wc -l` - 1))

	  # Loop through the windows
	  for (( window=0; window <= $windows; window++ )); do
	    tmux select-window -t $window #select the window

	    # Count how many panes there are in the window
	    panes=$((`tmux list-panes| wc -l` - 1))
	    # debugging
	    #echo "window:$window pane:$pane";
	    #sleep 1

	    # Loop through the panes that are in the window
	    for (( pane=0; pane <= $panes; pane++ )); do
	      # Skip the window that the command was ran in, run it in that window last
	      # since we don't want to suspend the script that we are currently running
	      # and also we want to end back where we started..
	      if [ $ORIG_WINDOW_INDEX -eq $window -a $ORIG_PANE_INDEX -eq $pane ]; then
		  continue
	      fi
	      tmux select-pane -t $pane #select the pane
	      # Send the escape key, in the case we are in a vim like program. This is
	      # repeated because the send-key command is not waiting for vim to complete
	      # its action... also sending a sleep 1 command seems to fuck up the loop.
	      for i in {1..25}; do tmux send-keys C-[; done
	      # temp suspend any gui thats running
	      tmux send-keys C-z
	      # if no gui was running, remove the escape sequence we just sent ^Z
	      tmux send-keys C-H
	      # run the command & switch back to the gui if there was any
	      tmux send-keys "$command && fg 2>/dev/null" C-m
	    done
	  done

	  tmux select-window -t $ORIG_WINDOW_INDEX #select the original window
	  tmux select-pane -t $ORIG_PANE_INDEX #select the original pane
	  # Send the escape key, in the case we are in a vim like program. This is
	  # repeated because the send-key command is not waiting for vim to complete
	  # its action... also sending a sleep 1 command seems to fuck up the loop.
	  for i in {1..25}; do tmux send-keys C-[; done
	  # temp suspend any gui thats running
	  # run the command & switch back to the gui if there was any
	  tmux send-keys C-c "$command && fg 2>/dev/null" C-m
	  tmux send-keys "clear" C-m

	}
else                                                                                                  
	function refresh_tmux {
		echo "Not in TMUX, empty function here!"
	}                                                                              
	function execute_in_all_tmux_panes {
		echo "Not in TMUX, empty function here!"
	}
fi