import { Elm } from "../src/Main.elm";
import "../css/tailwind.css";

var storageKey = "webcat_session_store";
var flags = localStorage.getItem(storageKey);
var app = Elm.Main.init({
    flags: flags
});
app.ports.storeCache.subscribe((val) => {
    if (val === null) {
        localStorage.removeItem(storageKey);
    } else {
        localStorage.setItem(storageKey, JSON.stringify(val));
    }
    // Send a notification of storage success back to Elm
    setTimeout(() => {
        app.ports.onStoreChange.send(JSON.stringify(val));
    }, 0);
});
// Whenever localStorage changes in another tab, report it if necessary.
window.addEventListener("storage", (event) => {
    if (event.storageArea === localStorage && event.key === storageKey) {
        app.ports.onStoreChange.send(event.newValue);
    }
}, false);

