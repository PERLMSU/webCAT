import * as React from "react";
import * as Yup from 'yup';
import { InjectedFormikProps, withFormik } from 'formik';
import { Field, Label, Input, Control, Button, Help } from 'bloomer';
import { authLogin } from '../../common/client';


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
                </Control>
            </Field>
        </form>
    );

export const LoginForm = withFormik<FormProps, FormValues>({
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
        const result = await authLogin({email: values.email, password: values.password})
        result.caseOf({
            left: token => {
                setSubmitting(false);
            },
            right: error => {
                this.props.error = error;
                setSubmitting(false);
            }
        })
    },
})(InnerForm);