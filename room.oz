functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   Lib at 'lib.ozf'
export
   room:Room
   window:Window
   doorX:DoorX
   doorY:DoorY
   floor:FLOOR
   wall:WALL
   bullets:BULLETS
   food:FOOD
   meds:MEDS
   door:DOOR
   brave:BRAVE
   zombie:ZOMBIE
define
   Room
   Canvas
   Map = map(r(1 1 1 1 1 1 5 1 1 1 1 1 1 1 1 1 1 1 1 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 1)
	     r(1 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 0 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	     r(1 0 3 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1)
	     r(1 0 4 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1)
	     r(1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 4 0 1)
	     r(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1))
   WidthCell = 40
   HeightCell = 40
   RowAm
   ColAm
   WidthMap = thread WidthCell*ColAm end
   HeightMap = thread HeightCell*RowAm end
   
   CD = {OS.getCWD}
   BraveIMG = {QTk.newImage photo(file:CD#'/images/brave.gif')}
   ZombieIMG = {QTk.newImage photo(file:CD#'/images/zombie.gif')}
   FoodIMG = {QTk.newImage photo(file:CD#'/images/food.gif')}
   BulletsIMG = {QTk.newImage photo(file:CD#'/images/bullets.gif')}
   MedsIMG = {QTk.newImage photo(file:CD#'/images/medicine.gif')}
   FloorIMG = {QTk.newImage photo(file:CD#'/images/floor.gif')}
   WallIMG = {QTk.newImage photo(file:CD#'/images/wall.gif')}
   DoorIMG = {QTk.newImage photo(file:CD#'/images/door.gif')}
   
   Desc = td(title:"ZombieLand" canvas(glue:nswe bg:white handle:Canvas))
   Window = {QTk.build Desc}

   DoorX
   DoorY

   ZOMBIE_MAXSTEP = 3

   fun {RoomInit Map}
      fun {FRoom Msg Map}
	 case Msg
	 of move(Comp OldX OldY Steps NewX NewY)#Resp then
	    if {CheckCoordinates NewX NewY} then
	       if {CheckAction movement(comp:Comp steps:Steps compXY:{GetComponent Map NewX NewY})}
	       then
		  {DrawImg OldX OldY {GetComponent Map OldX OldY}}
		  {DrawImg NewX NewY Comp}
		  Resp = ok
		  Map %TODO
	       else
		  Resp = failure
		  Map
	       end
	    else
	       Resp = failure
	       Map
	    end
	 [] interact(Comp X Y Steps)#Resp then
	    if {CheckAction interaction(comp:Comp steps:Steps)}
	    then
	       Resp = ok
	       {UpdateMap Map X Y FLOOR}
	    else
	       Resp = failure
	       Map
	    end
	 else Map
	 end
      end
   in
      {DrawMap Map}
      {DrawImg DoorX DoorY BRAVE}
      {Lib.newPortObject FRoom Map}
   end
   
   %% Map static constants %%
   FLOOR = 0
   WALL = 1
   BULLETS = 2
   FOOD = 3
   MEDS = 4
   DOOR = 5
   BRAVE = 6
   ZOMBIE = 7

   proc {DrawMap Map}
      proc {DrawRows Map Y}
	 proc {DrawRow Row X Y}
	    case Row
	    of r(...) then
	       if Row.X == DOOR then
		  DoorX = X
		  DoorY = Y
	       %elseif Row.X == BULLETS orelse Row.X == FOOD orelse Row.X == MEDS
	       %then {Send CollectPort X#Y#Row.X}
	       end
	       {DrawImg X Y Row.X}
	       if X \= {Width Row} then
		  {DrawRow Row X+1 Y} end
	    else skip end
	 end
      in
	 {DrawRow Map.Y 1 Y}
	 if Y \= {Width Map} then {DrawRows Map Y+1} end
      end
   in
      case Map
      of map(r(...) ...) then
	 RowAm = {Width Map}
	 ColAm = {Width Map.1}
	 {DrawRows Map 1}
	 %{Send CollectPort nil}
      else skip
      end
   end
   proc {DrawImg X Y Component}
      Image in
      if Component == FLOOR then Image = FloorIMG
      elseif Component == WALL then Image = WallIMG
      elseif Component == BULLETS then Image = BulletsIMG
      elseif Component == FOOD then Image = FoodIMG
      elseif Component == MEDS then Image = MedsIMG
      elseif Component == DOOR then Image = DoorIMG
      elseif Component == BRAVE then Image = BraveIMG
      elseif Component == ZOMBIE then Image = ZombieIMG
      else skip
      end
	 {Canvas create(image (X-1)*WidthCell (Y-1)*HeightCell
			image:Image anchor:nw)}
   end

   fun {CheckAction Action}
      case Action
      of movement(comp:Comp steps:Steps compXY:CompXY) then
	 if Comp == BRAVE then
	    Steps \= BRAVE_MAXSTEP andthen CompXY \= WALL
	    andthen CompXY \= ZOMBIE
	 elseif Comp == ZOMBIE then
	    Steps \= ZOMBIE_MAXSTEP andthen CompXY \= WALL andthen CompXY \= DOOR
	    andthen CompXY \= BRAVE andthen CompXY \= ZOMBIE
	 else false
	 end
      [] interaction(comp:Comp steps:Steps) then
	 if Comp == BRAVE then Steps \= BRAVE_MAXSTEP
	 elseif Comp == ZOMBIE then Steps \= ZOMBIE_MAXSTEP
	 else false
	 end
      else false
      end
   end

   fun {CheckCoordinates X Y}
      X > 0 andthen Y > 0 andthen X =< ColAm andthen Y =< RowAm
   end
   
   fun {GetComponent Map X Y}
      Map.Y.X
   end

   fun {UpdateMap Map X Y Comp}
      {AdjoinAt Map Y {AdjoinAt Map.Y X Comp}}
   end

   %% ----- Brave Definitions ----- %%
   Brave
   BRAVE_MAXSTEP = 2
   
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
	    {Port.sendRecv Room move(BRAVE State.x State.y State.steps NextX NextY) Resp}
	    if Resp == ok then
	       {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	    else State
	    end
	 [] collect then
	    {Port.sendRecv Room.room interact(BRAVE State.x State.y State.steps) Resp}
	    if Resp == ok then
	       {AdjoinList State [steps#State.steps+1 collected#State.collected+1]}
	    else State
	    end
	 else State
	 end
      end
   in
      {Lib.newPortObject FBrave
       state(x:DoorX y:DoorY steps:0 collected:0 bullets:0)}
   end

in
   Room = {RoomInit Map}
   {Canvas set(width:WidthMap height:HeightMap)}
   {Window show}
   Brave = {BraveInit}
end
