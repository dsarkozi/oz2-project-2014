functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   OS
define
   Canvas
   WidthCell = 40
   HeightCell = 40
   RowAm = 20
   ColAm = 20
   WidthMap = WidthCell*ColAm
   HeightMap = HeightCell*RowAm
   
   CD = {OS.getCWD}
   BraveIMG = {QTk.newImage photo(file:CD#'/brave.gif')}
   ZombieIMG = {QTk.newImage photo(file:CD#'/zombie.gif')}
   FoodIMG = {QTk.newImage photo(file:CD#'/food.gif')}
   BulletsIMG = {QTk.newImage photo(file:CD#'/bullets.gif')}
   MedsIMG = {QTk.newImage photo(file:CD#'/medicine.gif')}
   FloorIMG = {QTk.newImage photo(file:CD#'/floor.gif')}
   WallIMG = {QTk.newImage photo(file:CD#'/wall.gif')}
   DoorIMG = {QTk.newImage photo(file:CD#'/door.gif')}
   
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
	       if I \= {Width Row} then {DrawRow Row I+1 J} end
	    else skip
	    end
	 end
      in
	 {DrawRow Map.J 1 J}
	 if J \= {Width Map} then {DrawRows Map J+1} end
      end
      proc {DrawImg X Y Image}
	 {Canvas create(image (X-1)*WidthCell (Y-1)*HeightCell image:Image anchor:nw)}
      end
   in
      case Map
      of map(...) then {DrawRows Map 1}
      else skip
      end
   end
in
   {DrawMap map(r(1 1 5 1 1) r(1 2 3 4 1) r(1 0 0 0 1) r(1 1 1 1 1))}
   {Window show}
end
