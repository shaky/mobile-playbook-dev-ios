function appInfo() {
  var output = {};
  output["Name"] = infoLookup("CFBundleName");
  output["Bundle ID"] = ObjC.classes.NSBundle.mainBundle().bundleIdentifier().toString();
  output["Version"] = infoLookup("CFBundleVersion");
  output["Bundle"] = ObjC.classes.NSBundle.mainBundle().bundlePath().toString();
  output["Data"] = ObjC.classes.NSProcessInfo.processInfo().environment().objectForKey_("HOME").toString(); output["Binary"] = ObjC.classes.NSBundle.mainBundle().executablePath().toString();
  return output;
}

function infoLookup(key) {
  if (ObjC.available && "NSBundle" in ObjC.classes) {
  var info = ObjC.classes.NSBundle.mainBundle().infoDictionary(); var value = info.objectForKey_(key);
  if (value === null) {
  return value;
  } else if (value.class().toString() === "__NSCFArray") {
  return arrayFromNSArray(value);
  } else if (value.class().toString() === "__NSCFDictionary") {
  return dictFromNSDictionary(value); } else {
  return value.toString(); }
  }
  return null; 
}