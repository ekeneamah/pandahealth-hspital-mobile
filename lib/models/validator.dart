validValue(var placeholder, var value, {String selector = ""}) {
  try{
    if (placeholder.runtimeType == value.runtimeType) {
      return value;
    } else {
      print(
          "Expected a ${placeholder.runtimeType} but got a ${value.runtimeType} in $value");

      return placeholder;
    }
  }
  catch(er){
    print(er);
    return placeholder;
  }

}