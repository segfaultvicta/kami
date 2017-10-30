// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length)
    }
  }
  return "";
}

import Elm from "./kami.js"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

//const elmDiv = document.getElementById('elm-main')
//    , elmApp = Elm.Kami.embed(elmDiv)

let kamiDiv = document.getElementById('kami-main')
if (kamiDiv !== undefined && kamiDiv !== null) {
  var app = Elm.Kami.embed(kamiDiv, {uid: getCookie("user-id"), loc: getCookie("location-id"), key: getCookie("elm-key"), width: window.innerWidth})
}

// elmApp.ports.loc.send(window.location.search);
