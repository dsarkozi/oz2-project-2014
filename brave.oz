functor
import
   Room at 'room.ozf'
   Lib at 'lib.ozf'
   Port
define
   Brave
   NewPortObject = Lib.newPortObject
   Window = Room.window
   {Window bind(event:"<Up>" action:Brave#r(0 ~1))}
   {Window bind(event:"<Left>" action:Brave#r(~1 0))}
   {Window bind(event:"<Down>" action:Brave#r(0 1))}
   {Window bind(event:"<Right>" action:Brave#r(1 0))}
   {Window bind(event:"<space>" action:Brave#collect)}
   {Window bind(event:"<Return>" action:Brave#endTurn)}

   fun {BraveInit}
      fun {FBrave Msg State} %% state(x: y: steps: collected: bullets: )
	 Resp in
	 case Msg
	    %% Move request %%
	 of r(DX DY) then NextX NextY in
	    NextX = State.x + DX
	    NextY = State.y + DY
	    {Port.sendRecv Room.room move(Room.brave State.x State.y State.steps NextX NextY) Resp}
	    if Resp == ok then
	       {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	    else State
	    end
	 [] collect then
	    {Port.sendRecv Room.room interact(Room.brave State.x State.y State.steps) Resp}
	    if Resp == ok then
	       {AdjoinList State [steps#State.steps+1 collected#State.collected+1]}
	    else State
	    end
	 else State
	 end
      end
   in
      {Wait Room.loadingDone}
      {NewPortObject FBrave
       state(x:Room.doorX y:Room.doorY steps:0 collected:0 bullets:0)}
   end
in
   Brave = {BraveInit}
end