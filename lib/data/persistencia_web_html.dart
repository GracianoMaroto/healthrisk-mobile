import 'dart:html' as html;

const _chave = 'healthrisk_estado_v1';

String? lerEstadoWeb() => html.window.localStorage[_chave];

void gravarEstadoWeb(String json) {
  html.window.localStorage[_chave] = json;
}

void apagarEstadoWeb() {
  html.window.localStorage.remove(_chave);
}
