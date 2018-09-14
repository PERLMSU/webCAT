import * as React from "react";
import { CookiesProvider, Cookies } from "react-cookie";
import { BrowserRouter } from "react-router-dom";
import { Route, Switch } from 'react-router-dom'
import { hot } from 'react-hot-loader'
import ProtectedRoute from './common/components/ProtectedRoute';
import Semesters from './semesters/Semesters';
import NotFound from './common/components/NotFound';
import Login from './login/login';


class App extends React.Component {
    render() {
        return (
            <CookiesProvider>
                <BrowserRouter>
                    <Switch>
                        <ProtectedRoute path="/" component={Semesters} exact />
                        <Route path="/login" component={Login} exact />

                        <Route component={NotFound} />
                    </Switch>
                </BrowserRouter>
            </CookiesProvider>
        );
    }
}

export default hot(module)(App);