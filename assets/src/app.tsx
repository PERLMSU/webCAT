import * as React from "react";
import { BrowserRouter } from "react-router-dom";
import { Route, Switch } from 'react-router-dom'
import { hot } from 'react-hot-loader'
import { Home, Login, SignUp, NotFound } from "./pages"
import ProtectedRoute from './common/components/ProtectedRoute';


class App extends React.Component {
    render() {
        return (
            <BrowserRouter>
                <Switch>
                    <ProtectedRoute path="/" component={Home} exact />
                    <Route path="/login" component={Login} exact />
                    <Route path="/signup" component={SignUp} exact />

                    <Route component={NotFound} />
                </Switch>
            </BrowserRouter>
        );
    }
}

export default hot(module)(App);
//export default App;