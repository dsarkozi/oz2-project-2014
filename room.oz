functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
export
   drawMap:DrawMap
   drawImg:DrawImg
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
   getComponent:GetComponent
   loadingDone:LoadingDone
define
   LoadingDone
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
	       end
	       {DrawImg X Y Row.X}
	       if X \= {Width Row} then thread {DrawRow Row X+1 Y} end end
	    else skip end
	 end
      in
	 thread {DrawRow Map.Y 1 Y} end
	 if Y \= {Width Map} then thread {DrawRows Map Y+1} end end
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
   
   fun {GetComponent X Y}
      Map.Y.X
   end
in
   {DrawMap Map}
   {Canvas set(width:WidthMap height:HeightMap)}
   {Window show}
   LoadingDone = unit
end
