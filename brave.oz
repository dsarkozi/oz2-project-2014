functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   Room at 'room.ozf'
   OS
define
   Window = Room.window
   CD = {OS.getCWD}
   BraveIMG = {QTk.newImage photo(file:CD#'/images/brave.gif')}
   MAXSTEP = 2
   Commands
   CommandsPort = {NewPort Commands}
   {Window bind(event:"<Up>" action:CommandsPort#r(0 ~1))}
   {Window bind(event:"<Left>" action:CommandsPort#r(~1 0))}
   {Window bind(event:"<Down>" action:CommandsPort#r(0 1))}
   {Window bind(event:"<Right>" action:CommandsPort#r(1 0))}
   {Window bind(event:"<Return>" action:CommandsPort#nextTurn)}

   proc {Init}
      {Room.drawImg Room.doorX Room.doorY BraveIMG}
   end
in
   {Init}
end