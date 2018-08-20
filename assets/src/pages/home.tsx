import * as React from "react";
import { NavBar } from '../common/components/NavBar';
import { Section, Container, Field, Label, Input, Control } from 'bloomer';

export default class Home extends React.Component {
    public render() {
        return (
            <>
                <NavBar />
                <Section>
                    <Container>
                        <h1>Please Log In</h1>
                        <form>
                            <Field>
                                <Label>Email</Label>
                                <Control>
                                    <Input type="text" placeholder='email' />
                                </Control>
                            </Field>
                        </form>
                    </Container>
                </Section>
            </>
        );
    }
}
