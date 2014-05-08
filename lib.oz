functor
import
   Pickle
   Open
export
   newPortObject:NewPortObject
   loadPickle:LoadPickle
define
   fun {NewPortObject F Init}
      S P
      proc {Loop S State}
	 case S of M|S2 then
	    {Loop S2 {F M State}}
	 end
      end
   in
      {NewPort S P}
      thread {Loop S Init} end
      P
   end

   fun {LoadPickle URL}
      F={New Open.file init(url:URL flags:[read])}
   in
      try
	 VBS
      in
	 {F read(size:all list:VBS)}
	 {Pickle.unpack VBS}
      finally
	 {F close}
      end
   end
end
