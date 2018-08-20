import { AxiosInstance } from "axios";
import { validate } from "class-validator";
import { Either } from "tsmonad/lib/src";

import { Error } from "../types";
import { LoginDTO, SignupDTO, TokenDTO } from "../../domain/dto"

/**
 * Represents all of the possible actions for user authentication
 */
export class Auth {

    /**
     * Sign up a user
     * @param {AxiosInstance} client
     * @param {SignupDTO} body
     * @returns {Promise<TokenDTO>}
     */
    public static async signUp(client: AxiosInstance, body: SignupDTO): Promise<Either<TokenDTO, Error>> {
        try {
            await validate(body);
            const response = await client.post<TokenDTO>("/auth/signup", body);
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }

    /**
     * Login a user
     * @param {AxiosInstance} client
     * @param {LoginDTO} body
     * @returns {Promise<Either<TokenDTO, Error>>}
     */
    public static async login(client: AxiosInstance, body: LoginDTO): Promise<Either<TokenDTO, Error>> {
        try {
            await validate(body);
            const response = await client.post<TokenDTO>("/auth/signup", body);
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }
}
