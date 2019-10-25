Promise.all([
    import("./js/simplemde.js"),
    import("./js/selectize.js"),
    import("./js/bootstrap.js"),
]).then(() => import("./src/Main.elm")).then(({Elm}) => {
    var storageKey = "webcat_session_store";
    var flags = localStorage.getItem(storageKey);
    var app = Elm.Main.init({
        flags: flags,
        node: document.querySelector('main')
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

});



