// Este archivo existía para un proxy CORS (cuando se consultaba una API remota).
// La app ahora calcula la fase lunar localmente (offline), así que el proxy ya
// no es necesario. Se mantiene como stub para evitar confusiones y para que
// `flutter analyze` no falle por imports/depencias inexistentes.

void main(List<String> args) {
  // ignore: avoid_print
  print(
    'cors_proxy.dart ya no es necesario: la fase lunar se calcula localmente.',
  );
}
