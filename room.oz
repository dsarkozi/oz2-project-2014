functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
   Lib at 'lib.ozf'
   Input at 'input.ozf'
   Application
define
   Room
   Door
   Canvas
   Map = Input.map
   NZombies = Input.zombie
   NItems = Input.item
   NBullets = Input.bullet
   
   CollectTXT
   TurnTXT
   BulletsTXT
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
		    [] remove(X Y) then N S W E in
		       N = {List.subtract State.list X#(Y-1)}
		       S = {List.subtract N X#(Y+1)}
		       W = {List.subtract S (X-1)#Y}
		       E = {List.subtract W (X+1)#Y}
		       {AdjoinList State [length#State.length-1 list#E]}
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
		label(glue:nw text:"Collect:") label(glue:nw text:NItems handle:CollectTXT)
		label(glue:n text:"Brave's turn" handle:TurnTXT)
		label(glue:ne text:"Bullets:") label(glue:ne text:NBullets handle:BulletsTXT))
	     canvas(glue:nswe bg:white handle:Canvas))
   Window = {QTk.build Desc}

   fun {RoomInit Map}
      fun {FRoom Msg Map}
	 case Msg
	 of move(Comp OldX OldY Steps NewX NewY)#Resp then
	    if {CheckCoordinates NewX NewY} then CA in
	       CA = {CheckAction movement(comp:Comp steps:Steps compXY:{GetUnderlay Map NewX NewY})}
	       if CA == ok orelse CA == laststep orelse CA == destroyable then CN in
		  CN = {CheckNearby Comp Map NewX NewY}
		  if CN \= nil then
		     if Comp == BRAVE then Resp = CA
		     elseif Comp == ZOMBIE then Resp = unit
		     end
		     {Send Room zombieDone}
		     {Send Brave shoot(NewX NewY CN)}
		  else Resp = CA
		  end
		  {DrawImg OldX OldY {GetComponent Map OldX OldY}}
		  {DrawImg NewX NewY Comp}
		  {UpdateMoveMap Map OldX OldY NewX NewY}
	       else
		  Resp = CA
		  Map
	       end
	       %% Door special case %%
	    elseif Door.x == OldX andthen Door.y == OldY then DX DY NX NY in
	       DX = OldX - NewX
	       DY = OldY - NewY
	       NX = OldX + DX
	       NY = OldY + DY
	       if {GetUnderlay Map NX NY} == ZOMBIE then
		  {Send Room zombieDone}
		  {Send Brave shoot(NX NY [NX#NY])}
	       end
	       Resp = ok
	       Map
	    else Map
	    end
	 [] interact(Comp X Y Steps)#Resp then
	    Resp = {CheckAction interaction(comp:Comp steps:Steps compXY:{GetComponent Map X Y})}
	    if Resp == ok orelse Resp == laststep then
	       if Comp == BRAVE then C in
		  C = {StringToInt {CollectTXT get($)}}
		  if C > 0 then
		     {CollectTXT set(text:C-1)}
		  end
	       end
	       {UpdateMap Map X Y FLOOR#Comp}
	    else Map
	    end
	 [] zombiesTurn then Resp in
	    {TurnTXT set(text:"Zombies' turn")}
	    {Port.sendRecv Zombies getAmount Resp}
	    if Resp == 0 then
	       {Send Brave brave}
	       {TurnTXT set(text:"Brave's turn")}
	       Map
	    else
	       {Send Zombies sendAll(zombie)}
	       {AdjoinAt Map zombiesDone 0}
	    end
	 [] zombieDone then ZDone Resp in
	    if {HasFeature Map zombiesDone} then
	       ZDone = Map.zombiesDone+1
	    else
	       ZDone = 1
	    end
	    %% All the zombies are done %%
	    {Port.sendRecv Zombies getAmount Resp}
	    if ZDone >= Resp then
	       {Send Brave brave}
	       {TurnTXT set(text:"Brave's turn")}
	       {Record.subtract Map zombiesDone}
	    else
	       {AdjoinAt Map zombiesDone ZDone}
	    end
	 [] inaccessible(X Y)#Resp then
	    Resp = {ZRand Map X Y Faces}
	    Map
	 [] zombieKill#L then
	    {KillZombies Map L}
	 [] bullets(V) then
	    {BulletsTXT set(text:V)}
	    Map
	 [] endGame(B) then
	    if B then
	       {TurnTXT set(text:"Winner ! Close the window and celebrate your glory !")}
	    else
	       {TurnTXT set(text:"Loser ! Close the window and live the rest of your life in shame !")}
	    end
	    {Window wait}
	    {Application.exit 0}
	    Map
	 else Map
	 end
      end
   in
      {DrawMap Map}
      {BraveInit NBullets}
      {ZombiesInit NZombies}
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
	 {Send EmptyCells remove(Door.x Door.y)}
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

   fun {KillZombies Map L}
      case L
      of nil then Map
      [] X#Y|T then Comp in
	 Comp = {GetComponent Map X Y}
	 {Send Zombies killZombie(X Y)}
	 {DrawImg X Y Comp}
	 {KillZombies {UpdateMap Map X Y Comp} T}
      end
   end

   fun {CheckAction Action}
      case Action
      of movement(comp:Comp steps:Steps compXY:CompXY) then
	 if Comp == BRAVE then
	    if Steps == BRAVE_MAXSTEP then maxstep
	    else
	       if CompXY \= WALL andthen CompXY \= ZOMBIE andthen CompXY \= BRAVE andthen CompXY \= DOOR
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

   fun {CheckNearby Comp Map X Y}
      Check
      fun {CNHelper Check Map X Y I}
	 NextX NextY in
	 if I == 1 then
	    NextX = X-1
	    NextY = Y
	 elseif I == 2 then
	    NextX = X+1
	    NextY = Y
	 elseif I == 3 then
	    NextX = X
	    NextY = Y-1
	 elseif I == 4 then
	    NextX = X
	    NextY = Y+1
	 end
	 if I > 4 then nil
	 else
	    if {GetUnderlay Map NextX NextY} == Check
	    then
	       NextX#NextY|{CNHelper Check Map X Y I+1}
	    else
	       {CNHelper Check Map X Y I+1}
	    end
	 end
      end
   in
      if Comp == BRAVE then Check = ZOMBIE
      else Check = BRAVE
      end
      {CNHelper Check Map X Y 1}
   end

   fun {IsInaccessible Map X Y}
      {GetComponent Map X Y} == WALL orelse {GetComponent Map X Y} == DOOR
      orelse {GetUnderlay Map X Y} == BRAVE orelse {GetUnderlay Map X Y} == ZOMBIE
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
	    {Send Zombies send(N init(X Y))}
	    if N == 1 then {UpdateMap Map X Y {GetComponent Map X Y}#ZOMBIE}
	    else {InitZombieMap {UpdateMap Map X Y {GetComponent Map X Y}#ZOMBIE} N-1}
	    end
	 else raise 'No more usable space' end
	 end
      end
   in
      ResMap = {UpdateMap {InitZombieMap Map NZombies} Door.x Door.y DOOR#BRAVE}
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

   proc {BraveInit NBullets}
      fun {FBrave Msg State} %% state(x: y: steps: collected: bullets: )
	 Resp in
	 case Msg
	    %% Move request %%
	 of r(DX DY) then NextX NextY in
	    NextX = State.x + DX
	    NextY = State.y + DY
	    if NextX == Door.x andthen NextY == Door.y andthen State.collected >= NItems then
	       {Send Room endGame(true)}
	    end
	    {Port.sendRecv Room move(BRAVE State.x State.y State.steps NextX NextY) Resp}
	    if Resp == ok orelse Resp == laststep then
	       %% Door special case %%
	       if {CheckCoordinates NextX NextY} == false andthen Door.x == State.x andthen Door.y == State.y then
		  {Send Brave r(~DX ~DY)}
		  State
	       else
		  if Resp == laststep then
		     {Send Room zombiesTurn}
		  end
		  {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	       end
	    else State
	    end
	 [] collect then
	    {Port.sendRecv Room interact(BRAVE State.x State.y State.steps) Resp}
	    if Resp == ok orelse Resp == laststep then
	       if Resp == laststep then {Send Room zombiesTurn} end
	       {AdjoinList State [steps#State.steps+1 collected#State.collected+1]}
	    else State
	    end
	 [] shoot(X Y L) then
	    case L
	    of nil then State
	    else
	       {Send Room bullets(State.bullets-1)}
	       if State.bullets-1 < 0 then
		  {Send Room endGame(false)}
	       else
		  if State.x == X andthen State.y == Y then
		     {Send Room zombieKill#L}
		  else
		     {Send Room zombieKill#[X#Y]}
		  end
	       end
	       {AdjoinAt State bullets State.bullets-1}
	    end
	 [] brave then
	    {AdjoinList State [steps#0]}
	 else State
	 end
      end
   in
      Brave = {Lib.newPortObject FBrave
       state(x:Door.x y:Door.y steps:0 collected:0 bullets:NBullets)}
   end

   %% ----- Zombie Definitions ----- %%
   Zombies
   ZOMBIE_MAXSTEP = 3
   
   NORTH = 0
   SOUTH = 1
   WEST = 2
   EAST = 3
   Faces = [NORTH SOUTH WEST EAST]

   fun {ZRand Map X Y Faces}
      if Faces == nil then ~1
      else
	 Rand Compass Face in
	 Rand = {OS.rand} mod {Length Faces} + 1
	 Face = {Nth Faces Rand}
	 Compass = {ZCompass Face}
	 case Compass
	 of r(DX DY) then
	    if {IsInaccessible Map X+DX Y+DY} then
	       {ZRand Map X Y {List.subtract Faces Face}}
	    else Face
	    end
	 end
      end
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
	    of move then {Send Zombies send(ZNumber {ZCompass State.facing})}
	    [] destroy then {Send Zombies send(ZNumber destroy)}
	    end
	    {AdjoinAt State steps 0}
	 [] r(DX DY) then NextX NextY in
	    NextX = State.x + DX
	    NextY = State.y + DY
	    {Port.sendRecv Room move(ZOMBIE State.x State.y State.steps NextX NextY) Resp}
	    if Resp == maxstep then
	       {Send Room zombieDone}
	       {AdjoinAt State lastAction move}
	    elseif Resp == inaccessible then Resp in
	       {Port.sendRecv Room inaccessible(State.x State.y) Resp}
	       if Resp == ~1 then
		  {Send Zombies send(ZNumber {ZCompass State.facing})}
		  {AdjoinAt State steps State.steps+1}
	       else
		  {Send Zombies send(ZNumber {ZCompass Resp})}
		  {AdjoinAt State facing Resp}
	       end
	    else
	       if Resp == ok then
		  {Send Zombies send(ZNumber {ZCompass State.facing})}
		  {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	       elseif Resp == destroyable then
		  {Send Zombies send(ZNumber destroy)}
		  {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	       elseif Resp == unit then
		  {AdjoinList State [x#NextX y#NextY steps#State.steps+1]}
	       else
		  State
	       end
	    end
	 [] destroy then
	    {Port.sendRecv Room interact(ZOMBIE State.x State.y State.steps) Resp}
	    case Resp
	    of ok then
	       {Send Zombies send(ZNumber {ZCompass State.facing})}
	       {AdjoinList State [steps#State.steps+1]}
	    [] maxstep then
	       {Send Room zombieDone}
	       {AdjoinAt State lastAction destroy}
	    [] dumb then
	       {Send Zombies send(ZNumber {ZCompass State.facing})}
	       State
	    [] uncollectible then
	       {Send Zombies send(ZNumber {ZCompass State.facing})}
	       State
	    else State
	    end
	 [] getKilled(X Y)#Resp then
	    if State.x == X andthen State.y == Y then
	       Resp = ZNumber
	    else Resp = ~1
	    end
	    State
	 else State
	 end
      end
      fun {ZGenerator FZ N}
	 fun {ZGHelper FZ N I}
	    if I > N then nil
	    else
	       {Lib.newPortObject FZ state('#':I steps:0 facing:{OS.rand} mod 4 lastAction:move)}|{ZGHelper FZ N I+1}
	    end
	 end
      in
	 {ZGHelper FZ N 1}
      end
      fun {FZombies Msg State}
	 case Msg
	 of send(I M) then
	    if {HasFeature State I} then
	       {Send State.I M}
	    end
	    State
	 [] sendRecv(I M R) then
	    {Port.sendRecv State.I M R}
	    State
	 [] sendAll(M) then
	    {Record.forAllInd State
	     proc {$ I S}
		if I == width then skip
		else {Send S M}
		end
	     end }
	    State
	 [] killZombie(X Y) then SState in
	    {Record.forAllInd State
	     proc {$ I S}
		if I == width then skip
		else Resp in
		   {Port.sendRecv S getKilled(X Y) Resp}
		   if Resp > 0 then
		      SState = {Record.subtract State I}
		      if SState.width-1 == 0 then
			 {Send Room endGame(true)}
		      end
		   end
		end
	     end}
	    {AdjoinAt SState width SState.width-1}
	 [] getAmount#Resp then
	    Resp = State.width
	    State
	 else State
	 end
      end
   in
      Zombies = {Lib.newPortObject FZombies {AdjoinAt {List.toTuple zombies {ZGenerator FZombie N}} width N}}
   end
in
   Room = {RoomInit Map}
   {Canvas set(width:WidthMap height:HeightMap)}
   {Window show}
end
