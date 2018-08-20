import * as React from "react";
import { Redirect, Route } from "react-router-dom";
import API from '../state/auth';


const ProtectedRoute = ({ component: Component, ...rest }) => (
    <Route
        {...rest}
        render={(props) =>
            API.isAuthenticated() ? (
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
