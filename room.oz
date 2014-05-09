functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   Lib at 'lib.ozf'
export
   room:Room
   window:Window
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
   EmptyCells = {Lib.newPortObject
		 fun {$ Msg State}
		    fun {DropUnit L I}
		       case L
		       of H|T then
			  if I == 1 then T
			  else H|{DropUnit T I-1}
			  end
		       else L
		       end
		    end
		 in
		    case Msg
		    of add(X Y) then NewLength in
		       NewLength = State.length + 1
		       {AdjoinList State [length#NewLength list#((X#Y)|State.list)]}
		    [] request#Resp then
		       if State.length == 0 then Resp = empty
		       else I in
			  I = ({OS.rand} mod State.length) + 1
			  Resp = {Nth State.list I}
			  {AdjoinList State [length#State.length-1 list#{DropUnit State.list I}]}
		       end
		    [] empty then emptied
		    else State
		    end
		 end empty(length:0 list:nil)}
   
   CD = {OS.getCWD}
   BraveIMG = {QTk.newImage photo(file:CD#'/images/brave.gif')}
   ZombieIMG = {QTk.newImage photo(file:CD#'/images/zombie.gif')}
   FoodIMG = {QTk.newImage photo(file:CD#'/images/food.gif')}
   BulletsIMG = {QTk.newImage photo(file:CD#'/images/bullets.gif')}
   MedsIMG = {QTk.newImage photo(file:CD#'/images/medicine.gif')}
   FloorIMG = {QTk.newImage photo(file:CD#'/images/floor.gif')}
   WallIMG = {QTk.newImage photo(file:CD#'/images/wall.gif')}
   DoorIMG = {QTk.newImage photo(file:CD#'/images/door.gif')}
   
   Desc = td(title:"ZombieLand"
	     lr(glue:nwe
		label(glue:nw text:"Collectables:") label(glue:nw text:"2/3")
		label(glue:ne text:"Bullets:") label(glue:ne text:3))
	     canvas(glue:nswe bg:white handle:Canvas))
   Window = {QTk.build Desc}

   Door

   fun {RoomInit Map}
      fun {FRoom Msg Map}
	 case Msg
	 of move(Comp OldX OldY Steps NewX NewY)#Resp then
	    if {CheckCoordinates NewX NewY} then
	       Resp = {CheckAction movement(comp:Comp steps:Steps compXY:{GetUnderlay Map NewX NewY})}
	       if Resp == ok orelse Resp == laststep orelse Resp == destroyable then
		  {DrawImg OldX OldY {GetComponent Map OldX OldY}}
		  {DrawImg NewX NewY Comp}
		  {UpdateMoveMap Map OldX OldY NewX NewY}
	       else Map
	       end
	    else
	       Resp = failure
	       Map
	    end
	 [] interact(Comp X Y Steps)#Resp then
	    Resp = {CheckAction interaction(comp:Comp steps:Steps compXY:{GetComponent Map X Y})}
	    if Resp == ok orelse Resp == laststep then
	       {UpdateMap Map X Y FLOOR#Comp}
	    else Map
	    end
	 [] zombiesTurn then
	    for I in 1..{Width Zombies} do
	       {Send Zombies.I zombie}
	    end
	    {AdjoinAt Map zombiesDone 0}
	 [] zombieDone then ZDone in
	    ZDone = Map.zombiesDone+1
	    %% All the zombies are done %%
	    if ZDone == {Width Zombies} then
	       {Send Brave brave}
	       {Record.subtract Map zombiesDone}
	    else
	       {AdjoinAt Map zombiesDone ZDone}
	    end
	 else Map
	 end
      end
   in
      {DrawMap Map}
      {BraveInit}
      {ZombiesInit 2} %% 173 max %%
      {Lib.newPortObject FRoom {InitMap Map}}
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
	       if Row.X == FLOOR then {Send EmptyCells add(X Y)} end
	       if Row.X == DOOR then
		  Door = door(x:X y:Y)
		  {DrawImg X Y BRAVE}
	       else
		  {DrawImg X Y Row.X}
	       end
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
	    if Steps == BRAVE_MAXSTEP then maxstep
	    else
	       if CompXY \= WALL andthen CompXY \= ZOMBIE andthen CompXY \= BRAVE
	       then
		  if Steps+1 == BRAVE_MAXSTEP then laststep
		  else ok
		  end
	       else inaccessible
	       end
	    end
	 elseif Comp == ZOMBIE then Destroyable in
	    Destroyable = (CompXY == FOOD orelse CompXY == BULLETS orelse CompXY == MEDS)
	    if Steps == ZOMBIE_MAXSTEP then maxstep
	    else
	       if CompXY \= WALL andthen CompXY \= DOOR
		  andthen CompXY \= BRAVE andthen CompXY \= ZOMBIE
	       then
		  if Destroyable then destroyable
		  else ok
		  end
	       else inaccessible
	       end
	    end
	 else failure
	 end
      [] interaction(comp:Comp steps:Steps compXY:CompXY) then Collectible in
	 Collectible = (CompXY == FOOD orelse CompXY == BULLETS orelse CompXY == MEDS)
	 if Comp == BRAVE then
	    if Steps == BRAVE_MAXSTEP then maxstep
	    else
	       if Collectible then
		  if Steps+1 == BRAVE_MAXSTEP then laststep
		  else ok
		  end
	       else uncollectible
	       end
	    end
	 elseif Comp == ZOMBIE then
	    if Steps == ZOMBIE_MAXSTEP then maxstep
	    else
	       if Collectible then
		  if {OS.rand} mod 5 == 0 then ok
		  else dumb
		  end
	       else uncollectible
	       end
	    end
	 else failure
	 end
      else failure
      end
   end

   fun {CheckCoordinates X Y}
      X > 0 andthen Y > 0 andthen X =< ColAm andthen Y =< RowAm
   end

   fun {GetUnderlay Map X Y}
      case Map.Y.X
      of _#Live then Live
      else {GetComponent Map X Y}
      end
   end
   
   fun {GetComponent Map X Y}
      case Map.Y.X
      of Dead#_ then Dead
      else Map.Y.X
      end
   end

   fun {UpdateMap Map X Y Comp}
      {AdjoinAt Map Y {AdjoinAt Map.Y X Comp}}
   end

   fun {UpdateMoveMap Map OldX OldY NewX NewY}
      case Map.OldY.OldX
      of Dead#Live then
	 {UpdateMap {UpdateMap Map NewX NewY {GetComponent Map NewX NewY}#Live} OldX OldY Dead}
      else Map
      end
   end

   fun {InitMap Map}
      ResMap
      fun {UsableSpace}
	 Resp in
	 {Port.sendRecv EmptyCells request Resp}
	 Resp
      end
      fun {InitZombieMap Map N}
	 case {UsableSpace}
	 of X#Y then
	    {DrawImg X Y ZOMBIE}
	    {Send Zombies.N init(X Y)}
	    if N == 1 then {UpdateMap Map X Y {GetComponent Map X Y}#ZOMBIE}
	    else {InitZombieMap {UpdateMap Map X Y {GetComponent Map X Y}#ZOMBIE} N-1}
	    end
	 else raise 'No more usable space' end
	 end
      end
   in
      ResMap = {UpdateMap {InitZombieMap Map {Width Zombies}} Door.x Door.y DOOR#BRAVE}
      {Send EmptyCells empty}
      ResMap
   end

   %% ----- Brave Definitions ----- %%
   Brave
   BRAVE_MAXSTEP = 2
   
   {Window bind(event:"<Up>" action:Brave#r(0 ~1))}
   {Window bind(event:"<Left>" action:Brave#r(~1 0))}
   {Window bind(event:"<Down>" action:Brave#r(0 1))}
   {Window bind(event:"<Right>" action:Brave#r(1 0))}
   {Window bind(event:"<space>" action:Brave#collect)}

   proc {BraveInit}
      fun {FBrave Msg State} %% state(x: y: steps: collected: bullets: )
	 Resp in
	 case Msg
	    %% Move request %%
	 of r(DX DY) then NextX NextY in
	    NextX = State.x + DX
	    NextY = State.y + DY
	    {Port.sendRecv Room move(BRAVE State.x State.y State.steps NextX NextY) Resp}
	    if Resp == ok orelse Resp == laststep then
	       if Resp == laststep then {Send Room zombiesTurn} end
	       {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	    else State
	    end
	 [] collect then
	    {Port.sendRecv Room interact(BRAVE State.x State.y State.steps) Resp}
	    if Resp == ok orelse Resp == laststep then
	       if Resp == laststep then {Send Room zombiesTurn} end
	       {AdjoinList State [steps#State.steps+1 collected#State.collected+1]}
	    else State
	    end
	 [] brave then
	    {AdjoinList State [steps#0]}
	 else State
	 end
      end
   in
      Brave = {Lib.newPortObject FBrave
       state(x:Door.x y:Door.y steps:0 collected:0 bullets:3)}
   end

   %% ----- Zombie Definitions ----- %%
   Zombies
   ZOMBIE_MAXSTEP = 3
   NORTH = 0
   SOUTH = 1
   WEST = 2
   EAST = 3

   fun {ZRand}
      {OS.rand} mod 4
   end
   
   fun {ZCompass D}
      if D == NORTH then r(0 ~1)
      elseif D == SOUTH then r(0 1)
      elseif D == WEST then r(~1 0)
      elseif D == EAST then r(1 0)
      else r(0 0)
      end
   end
   
   proc {ZombiesInit N}
      fun {FZombie Msg State} %% state('#': x: y: steps: facing: lastAction: )
	 {Delay 100} %% Smooth move delay
	 Resp ZNumber in
	 ZNumber = State.'#'
	 case Msg
	 of init(X Y) then {AdjoinList State [x#X y#Y]}
	 [] zombie then
	    case State.lastAction
	    of move then {Send Zombies.ZNumber {ZCompass State.facing}}
	    [] destroy then {Send Zombies.ZNumber destroy}
	    end
	    {AdjoinAt State steps 0}
	 [] r(DX DY) then NextX NextY in
	    NextX = State.x + DX
	    NextY = State.y + DY
	    {Port.sendRecv Room move(ZOMBIE State.x State.y State.steps NextX NextY) Resp}
	    if Resp == maxstep then
	       {Send Room zombieDone}
	       {AdjoinAt State lastAction move}
	    elseif Resp == inaccessible then ZR in
	       ZR = {ZRand}
	       {Send Zombies.ZNumber {ZCompass ZR}}
	       {AdjoinAt State facing ZR}
	    else
	       if Resp == ok then
		  {Send Zombies.ZNumber {ZCompass State.facing}}
		  {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	       elseif Resp == destroyable then
		  {Send Zombies.ZNumber destroy}
		  {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	       else
		  State
	       end
	    end
	 [] destroy then
	    {Port.sendRecv Room interact(ZOMBIE State.x State.y State.steps) Resp}
	    case Resp
	    of ok then
	       {Send Zombies.ZNumber {ZCompass State.facing}}
	       {AdjoinList State [steps#State.steps+1]}
	    [] maxstep then
	       {Send Room zombieDone}
	       {AdjoinAt State lastAction destroy}
	    [] dumb then
	       {Send Zombies.ZNumber {ZCompass State.facing}}
	       State
	    [] uncollectible then
	       {Send Zombies.ZNumber {ZCompass State.facing}}
	       State
	    else State
	    end
	 else State
	 end
      end
      fun {ZGenerator FZ N}
	 if N == 0 then nil
	 else
	    {Lib.newPortObject FZ state('#':N steps:0 facing:{ZRand} lastAction:move)}|{ZGenerator FZ N-1}
	 end
      end
   in
      Zombies = {List.toTuple zombies {ZGenerator FZombie N}}
   end
in
   Room = {RoomInit Map}
   {Canvas set(width:WidthMap height:HeightMap)}
   {Window show}
end
