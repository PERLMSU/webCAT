import * as React from "react";
import * as ReactDOM from "react-dom";
import App from "./app";

// webpack automatically concatenates all files in your
// watched paths. Those paths can be configured as
// endpoints in "webpack.config.js".
//
// Import dependencies
//
import "../scss/app.scss";

ReactDOM.render(
    <App/>,
    document.getElementById("react-app"),
);
