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
   {Window bind(event:"<space>" action:CommandsPort#getStuff)}
   {Window bind(event:"<Return>" action:CommandsPort#endTurn)}

   proc {Init}
      {Room.drawImg Room.doorX Room.doorY Room.brave}
   end

   proc {Input OldX OldY Commands}
      NewX NewY NextCommand
      fun {InputCommand Commands Steps X Y LastX LastY}
	 NextX NextY Component in
	 case Commands
	    %% Movement requested %%
	 of r(DX DY)|T then
	    NextX = X + DX
	    NextY = Y + DY
	    if Steps == MAXSTEP
	       orelse {Room.getComponent NextX NextY} == Room.wall
	    then
	       {InputCommand T Steps X Y LastX LastY}
	    else
	       Component = {Room.getComponent X Y}
	       {Room.drawImg X Y Component}
	       {Room.drawImg NextX NextY Room.brave}
	       {InputCommand T Steps+1 NextX NextY LastX LastY}
	    end
	    %% Get stuff on floor %%
	 %[] getStuff|T then
	    %% End the turn %%
	 %[] endTurn|T then
	 %else
	 end
      end
   in
      NextCommand = {InputCommand Commands 0 OldX OldY NewX NewY}
      {Input NewX NewY NextCommand}
   end
in
   {Init}
   {Input Room.doorX Room.doorY Commands}
end