functor
import
   Room at 'room.ozf'
define
   MAXSTEP = 3
   proc {Init}
      {Wait Room.loadingDone}
      %% Draw all the zombies here %%
   end

   fun {Destroy X Y}
      Component in
      Component = {Room.getComponent X Y}
      Component
   end
in
   {Init}
end