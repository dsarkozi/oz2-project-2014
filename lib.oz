functor
export
   newPortObject:NewPortObject
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
end
