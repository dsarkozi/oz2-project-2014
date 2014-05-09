/*-------------------------------------------------------------------------
 *
 * This is a template for the Project of INGI1131: Zombieland 
 * The objective is to provide you with a starting point for application
 * programming in Mozart-Oz, and with a standard way of recibing arguments for
 * the program.
 *
 * Compile in Mozart 2.0
 *     ozc -c templateZombie.oz  **This will generate templateZombie.ozf
 *     ozengine templateZombie.ozf
 * Examples of execution
 *    ozengine templateZombie.ozf --help
 *    ozengine templateZombie.ozf --map mymap
 *    ozengine templateZombie.ozf -m mymap -s 4 -i 4
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Property
   System
   Lib at 'lib.ozf'
 export
    map:Map
    zombie:Zombie
    item:Item
    bullet:Bullet
 define
   Map
   Zombie
   Item
   Bullet
   %% Default values
   MAP = 'map_test.ozp'
   NUMZOMBIES = 5
   ITEMS2PICK    = 5
   INITIALBULLETS    = 3

   %% For feedback
   Say    = System.showInfo

   %% Posible arguments
   Args = {Application.getArgs
              record(
                     map(single char:&m type:atom default:MAP)
                     zombie(single char:&s type:int default:NUMZOMBIES)
                     item(single char:&b type:int default:ITEMS2PICK)
                     bullet(single char:&n type:int default:INITIALBULLETS) 
                     help(single char:[&? &h] default:false)
                    )}

in
   
   %% Help message
   if Args.help then
      {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
      {Say "Options:"}
      {Say "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
      {Say "  -s, --zombie INT\tNumber of zombies"}
      {Say "  -b, --item INT\tTotal number of items to pick"}
      {Say "  -n, --bullet INT\tInitial number of bullets"}
      {Say "  -h, -?, --help\tThis help"}
      {Say "Example : Following lines are equivalent"}
      {Say "   ozengine templateZombie.ozf -s 4"}
      {Say "   ozengine templateZombie.ozf --z 4"}
      {Say "   ozengine templateZombie.ozf --zombie 4"}
      {Application.exit 0}
   end

   {System.show 'These are the arguments to run the application'}
   {Say "Map:\t"#Args.map}
   {Say "Zombie:\t"#Args.zombie}
   {Say "Item:\t"#Args.item}
   {Say "Bullet:\t"#Args.bullet}

   Map = {Lib.loadPickle Args.map}
   Zombie = Args.zombie
   Item = Args.item
   Bullet = Args.bullet
end