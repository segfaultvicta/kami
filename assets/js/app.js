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

function getSocketUrl() {
  var host = window.location.host
  var protocol = window.location.protocol == "https:" ? "wss://" : "ws://";
  return protocol + host + "/socket/websocket"
}

function inactivate(app) {
  app.ports.activity.send(false);
}

function activate(app) {
  app.ports.activity.send(true);
}

function idle(app) {
    var t;
    window.onload = resetTimer;
    window.onfocus = resetTimer;
    window.onmousedown = resetTimer; // catches touchscreen presses
    window.onclick = resetTimer;     // catches touchpad clicks
    window.onscroll = resetTimer;    // catches scrolling with arrow keys
    window.onkeypress = resetTimer;

    function inactivateIdle() {
        inactivate(app);
    }

    function resetTimer() {
        activate(app);
        clearTimeout(t);
        t = setTimeout(inactivateIdle, 10000);  // time is in milliseconds
    }
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
  var app = Elm.Kami.embed(kamiDiv, {uid: getCookie("user-id"),
    loc: getCookie("location-id"), key: getCookie("elm-key"),
    width: window.innerWidth, socketUrl: getSocketUrl()});

  app.ports.title.subscribe(function(title) {
    document.title = title;
  });

  app.ports.donk.subscribe(function() {
    console.log("donk!");
    var audio = new Audio("https://s3.us-east-2.amazonaws.com/gannokoe/uploads/assets/donk2.ogg");
    audio.play();
  });

  idle(app);
}
