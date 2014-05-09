oz2-project-2014
================

This project contains :
  * `lib.oz`: The functions library functor
  * `input.oz`: The input manager functor
  * `room.oz`: The main functor to execute
  
Please compile the files in this order, as `room.oz` depends on `input.oz` and `lib.oz`, while `input.oz` depends also on `lib.oz`.
Please also note that even though `input.oz` manages the program's input, the linking is done in `room.oz`, so execute `room.oz` as it is the main functor of the project.

Please note finally that the brave user is controlled with the Arrow keys, as the WASD keys aren't the same for everyone, and use Space to collect an item (the items are *NOT* collected automatically by moving on it).

Thank you.

David Sarkozi & Thibault Vandermosten
  
