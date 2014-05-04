functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
export
   drawMap:DrawMap
   drawImg:DrawImg
   window:Window
define
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

   proc {DrawMap Map}
      FLOOR = 0
      WALL = 1
      BULLETS = 2
      FOOD = 3
      MEDS = 4
      DOOR = 5
      proc {DrawRows Map J}
	 proc {DrawRow Row I J}
	    case Row
	    of r(...) then
	       if Row.I == FLOOR then {DrawImg I J FloorIMG}
	       elseif Row.I == WALL then {DrawImg I J WallIMG}
	       elseif Row.I == BULLETS then {DrawImg I J BulletsIMG}
	       elseif Row.I == FOOD then {DrawImg I J FoodIMG}
	       elseif Row.I == MEDS then {DrawImg I J MedsIMG}
	       elseif Row.I == DOOR then {DrawImg I J DoorIMG}
	       else skip
	       end
	       if I \= {Width Row} then thread {DrawRow Row I+1 J} end end
	    else skip
	    end
	 end
      in
	 thread {DrawRow Map.J 1 J} end
	 if J \= {Width Map} then thread {DrawRows Map J+1} end end
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
   proc {DrawImg X Y Image}
	 {Canvas create(image (X-1)*WidthCell (Y-1)*HeightCell image:Image anchor:nw)}
      end
in
   {DrawMap Map}
   {Canvas set(width:WidthMap height:HeightMap)}
   {Window show}
end
