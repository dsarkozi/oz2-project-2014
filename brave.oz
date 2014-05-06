functor
import
   Room at 'room.ozf'
define
   Window = Room.window
   MAXSTEP = 2
   Commands
   CommandsPort = {NewPort Commands}
   {Window bind(event:"<Up>" action:CommandsPort#r(0 ~1))}
   {Window bind(event:"<Left>" action:CommandsPort#r(~1 0))}
   {Window bind(event:"<Down>" action:CommandsPort#r(0 1))}
   {Window bind(event:"<Right>" action:CommandsPort#r(1 0))}
   {Window bind(event:"<space>" action:CommandsPort#collect)}
   {Window bind(event:"<Return>" action:CommandsPort#endTurn)}

   proc {Init}
      {Wait Room.loadingDone}
      {Room.drawImg Room.doorX Room.doorY Room.brave}
      {Input Room.doorX Room.doorY Commands 0}
   end

   fun {Collect X Y}
      Component in
      Component = {Room.getComponent X Y}
      Component
   end

   proc {Input OldX OldY Commands Collected}
      NewX NewY NextCommand
      fun {InputCommand Commands Steps Collected X Y LastX LastY}
	 NextX NextY Component in
	 case Commands
	    %% Movement requested %%
	 of r(DX DY)|T then
	    NextX = X + DX
	    NextY = Y + DY
	    if Steps == MAXSTEP
	       orelse {Room.getComponent NextX NextY} == Room.wall
	    then
	       {InputCommand T Steps Collected X Y LastX LastY}
	    else
	       Component = {Room.getComponent X Y}
	       {Room.drawImg X Y Component}
	       {Room.drawImg NextX NextY Room.brave}
	       {InputCommand T Steps+1 Collected NextX NextY LastX LastY}
	    end
	    %% Get stuff on floor %%
	 [] collect|T then
	    if Steps == MAXSTEP then
	       {InputCommand T Steps Collected X Y LastX LastY}
	    else
	       Stuff in
	       Stuff = {Collect X Y}
	       {InputCommand T Steps+1 Collected+1 X Y LastX LastY}
	    end
	    %% End the turn %%
	 [] endTurn|T then
	    LastX = X
	    LastY = Y
	    T
	 %else
	 end
      end
   in
      NextCommand = {InputCommand Commands 0 Collected OldX OldY NewX NewY}
      {Input NewX NewY NextCommand Collected}
   end
in
   {Init}
end