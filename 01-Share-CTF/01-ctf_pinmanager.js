// Hook into the PINManager class and the generateNewPIN method
var PINManager = ObjC.classes.PINManager;

Interceptor.attach(PINManager['- <name-of-method>'].implementation, {
    onLeave: function(retval) {
        var generatedPIN = new ObjC.Object(retval);
        console.log("[*] PIN Generated: " + generatedPIN);
    }
});
     