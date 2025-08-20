Interceptor.attach(ObjC.classes.Decryption['<FUNCTION-NAME>'].implementation,
{
  onEnter: function (args) {
  	var arg = ObjC.Object(args[2]).toString();
	   send('First argument is: ' + arg);
  },
  onLeave: function (retval) {
  		var ret = ObjC.Object(retval).toString()
  	 	send('return value is: ' + ret);
  }
});