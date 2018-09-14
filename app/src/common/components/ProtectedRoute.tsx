import * as React from "react";
import { Redirect, Route } from "react-router-dom";
import { withCookies, Cookies } from "react-cookie";


const ProtectedRoute = ({ component: Component, ...rest }) => (
    <Route
        {...rest}
        render={(props) =>
            true ? (
                <Component {...props} />
            ) : (
                    <Redirect
                        to={{
                            pathname: "/login",
                            state: { from: props.location },
                        }}
                    />
                )
        }
    />
);

export default ProtectedRoute;
