import { AxiosInstance } from "axios";
import { Either } from "tsmonad";

import { Error } from "../types";

export interface LoginDTO {
    email: string,
    password: string,
}
export interface TokenDTO {
    token: string,
}

export class Auth {
    /**
     * Login a user
     * @param {AxiosInstance} client
     * @param {LoginDTO} body
     * @returns {Promise<Either<TokenDTO, Error>>}
     */
    public static async login(client: AxiosInstance, body: LoginDTO): Promise<Either<TokenDTO, Error>> {
        try {
            const response = await client.post<TokenDTO>("/auth/login", body);
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }
}
