import * as React from "react";
import { Redirect, Route, RouteProps } from "react-router-dom";
import { inject, observer } from "mobx-react";
import { AuthStore } from '../AuthStore';
@inject('authStore')
@observer
export default class PrivateRoute extends React.Component<{ authStore?: AuthStore } & RouteProps> {
    render() {
        const { authStore, ...restProps } = this.props;
        if (authStore!.user) return <Route {...restProps} />;
        return <Redirect to="/login" />;
    }
}