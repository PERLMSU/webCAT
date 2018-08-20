import "reflect-metadata";
import Axios, { AxiosInstance } from 'axios';

import { SignupDTO, LoginDTO, TokenDTO } from "../domain/dto"
import { Either } from 'tsmonad';
import { Error } from './types';
import { Auth } from './resources/auth';

/**
 * Create a configured Axios instance for use
 * @param {string} token Authentication token
 * @param {string} baseURL URL of the API endpoint
 * @returns {AxiosInstance}
 */
export function create(token: string, baseURL: string = "http://localhost:4000/"): AxiosInstance {
    return Axios.create({
        baseURL,
        headers: {
            Authorization: `Bearer ${token}`,
        },
        timeout: 5000,
    });
}

/**
 * Sign up a user
 * @param signUp Sign up details to send
 * @param baseURL URL of the API endpoint
 */
export async function signUp(signUp: SignupDTO, baseURL: string = "http://localhost:4000/"): Promise<Either<TokenDTO, Error>> {
    const client = Axios.create({
        baseURL,
        timeout: 5000,
    });

    return await Auth.signUp(client, signUp);
}

/**
 * Log in a user
 * @param login Log in details to send
 * @param baseURL URL of the API endpoint
 */
export async function authLogin(login: LoginDTO, baseURL: string = "http://localhost:4000/"): Promise<Either<TokenDTO, Error>> {
    const client = Axios.create({
        baseURL,
        timeout: 5000,
    });

    return await Auth.login(client, login);
}
