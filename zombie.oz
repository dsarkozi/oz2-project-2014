functor
import
   Room at 'room.ozf'
   OS
define
   MAXSTEP = 3
   NORTH = 0
   SOUTH = 1
   WEST = 2
   EAST = 3
   Zombies
   proc {Init}
      {Wait Room.loadingDone}
      %% Draw all the zombies here %%
      Zombies = zombies(5#5)
      for I in 1..{Width Zombies}
      do case Zombies.I
	 of X#Y then
	    thread
	       ZPort ZStream in
	       ZPort = {NewPort ZStream}
	       {AI X Y I 0 {AdjoinAt Zombies I X#Y#ZPort#ZStream}}
	    end
	 else skip
	 end
      end
   end

   proc {AI X Y Z Steps Zombies}
      case Zombies.Z
      of _#_#ZPort#ZStream then
	 case ZStream
	    %% Movement %%
	 of r(DX DY)|T then
	    NextX = X + DX
	    NextY = Y + DY
	    %% if facing a wall %%
	    if {Room.getComponent NextX NextY} == Room.wall then Rand in
	       Rand = {OS.rand} mod 4
	       if Rand == NORTH then {Send ZombiePort r(0 1)}
	       elseif Rand == SOUTH then {Send ZombiePort r(0 ~1)}
	       elseif Rand == WEST then {Send ZombiePort r(~1 0)}
	       elseif Rand == EAST then {Send ZombiePort r(1 0)}
	       else skip
	       end
	       {AI NextX NextY Z Steps+1 T Zombies}
	       %% if destroyable %%
	    elseif {Room.getComponent NextX NextY} == Room.bullets
	       orelse {Room.getComponent NextX NextY} == Room.food
	       orelse {Room.getComponent NextX NextY} == Room.meds
	    then
	       {Send ZombiePort destroy}
	       {Send ZombiePort r(DX DY)}
	       {AI NextX NextY Z Steps+1 T {AdjoinAt Zombies Z NextX#NextY#ZPort#ZStream}}
	       %% Move in the same direction %%
	    else
	       {Send ZombiePort r(DX DY)}
	       {AI NextX NextY Z Steps+1 T {AdjoinAt Zombies Z NextX#NextY}}
	    end
	    %% Collectable
	 [] destroy|T then
	    if {OS.rand} mod 5 == 0 then % destroy
	    end
	    {AI X Y Z Steps+1 T {AdjoinAt Zombies Z X#Y#ZPort#ZStream}}
	 end
      end
   end
in
   {Init}
end