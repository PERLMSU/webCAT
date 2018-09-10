import * as React from "react";
import * as Yup from 'yup';
import { InjectedFormikProps, withFormik } from 'formik';
import { Section, Container, Field, Label, Input, Control, Button, Help, Title, Box, Hero, HeroBody, Column, Subtitle } from 'bloomer';
import { authLogin } from '../common/client';
import { LoginDTO } from '../common/domain/dto';
import API from '../common/state/auth';


// Adapted from https://gist.github.com/oukayuka/1ef7278c466fe926496ac2181a029f97
interface FormValues {
    email: string;
    password: string;
}

interface FormProps {
    email?: string;
    password?: string;
}

const InnerForm: React.SFC<InjectedFormikProps<FormProps, FormValues>> = (
    props,
) => (
        <form onSubmit={props.handleSubmit}>
            <Field>
                <Label>Email</Label>
                <Control>
                    <Input id="email" type="text" placeholder='email' onChange={props.handleChange} value={props.values.email} />
                    {props.touched.email && props.errors.email && <Help isColor="danger">{props.errors.email}</Help>}
                </Control>
            </Field>
            <Field>
                <Label>Password</Label>
                <Control>
                    <Input id="password" type="password" placeholder='password' onChange={props.handleChange} value={props.values.password} />
                    {props.touched.password && props.errors.password && <Help isColor="danger">{props.errors.password}</Help>}
                </Control>
            </Field>
            <Field>
                <Control>
                    <Button type="submit" isColor='primary' disabled={props.isSubmitting}>Submit</Button>
                    {props.error && <Help isColor="danger">{props.error}</Help>}
                </Control>
            </Field>
        </form>
    );

const LoginForm = withFormik<FormProps, FormValues>({
    mapPropsToValues: () => ({ email: '', password: '' }),
    validationSchema: Yup.object().shape({
        email: Yup.string()
            .email("Please enter a valid email")
            .required('Please enter your email'),
        password: Yup.string()
            .required("Please enter your password")
    },
    ),
    handleSubmit: async (values: FormValues, { setSubmitting, setError }) => {
        const result = await authLogin(new LoginDTO(values.email, values.password))
        result.caseOf({
            left: token => {
                setSubmitting(false);
                API.login(token);
            },
            right: error => {
                setError(error);
                setSubmitting(false);
            }
        })
    },
})(InnerForm);

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
