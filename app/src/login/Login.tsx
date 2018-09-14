import * as React from "react";
import {Title, Box, Hero, HeroBody, Column, Subtitle, Container } from 'bloomer';
import {LoginForm} from './components/LoginForm';

export default class Login extends React.Component {
    public render() {
        return (
            <Hero isColor="primary" isFullHeight>
                <HeroBody>
                    <Container hasTextAlign="centered">
                        <Column isSize="1/2" isOffset="1/4">
                            <Box>
                                <figure className="avatar">
                                    <img src={require("../../static/images/physics.png")}></img>
                                </figure>
                                <Title hasTextColor="dark">WebCAT</Title>
                                <Subtitle hasTextColor="dark">Please Log In</Subtitle>
                                <LoginForm />
                            </Box>
                        </Column>
                    </Container>
                </HeroBody>
            </Hero>
        );
    }
}
