import { AxiosInstance } from "axios";
import { Either } from "tsmonad/lib/src";

import { Error } from "../types";
import { Classroom, Notification, RotationGroup, User } from "../../domain"
import { ListQueryOptions } from '../types';

export interface UserUpdate {
    firstName: string;
    lastName: string;
    middleName?: string;
    email: string;
    username: string;
    nickname?: string;
    bio?: string;
    phone?: string;
    city?: string;
    state?: string;
    country?: string;
    birthday?: Date;
}

/**
 * Represents all of the possible actions for user authentication
 */
export class Users {

    /**
     * Get all of the users
     * @param client HTTP client to use
     * @param options Options to pass
     */
    public static async list(client: AxiosInstance, options: ListQueryOptions = {}): Promise<Either<Array<User>, Error>> {
        try {
            const response = await client.get<Array<User>>("/users/", {
                params: options
            });
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }

    /**
     * Get a user by their id
     * @param client HTTP client to use
     * @param id ID of the user to get
     */
    public static async get(client: AxiosInstance, id: number): Promise<Either<User, Error>> {
        try {
            const response = await client.get<User>(`/users/${id}`);
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }
    /**
     * Update a user by their id
     * @param client HTTP client to use
     * @param id ID of the user
     * @param update Updated user
     */
    public static async update(client: AxiosInstance, id: number, update: UserUpdate): Promise<Either<User, Error>> {
        try {
            const response = await client.put<User>(`/users/${id}`, update);
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }

    /**
     * Get the notifications for a user
     * @param client HTTP client to use
     * @param id ID of the user
     * @param options Options to pass
     */
    public static async notifications(client: AxiosInstance, id: number, options: ListQueryOptions = {}): Promise<Either<Array<Notification>, Error>> {
        try {
            const response = await client.get<Array<Notification>>(`/users/${id}/notifications`, {
                params: options
            });
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }

    /**
     * Get the classrooms for a particular user
     * @param client HTTP client to use
     * @param id ID of the user
     * @param options Options to pass
     */
    public static async classrooms(client: AxiosInstance, id: number, options: ListQueryOptions = {}): Promise<Either<Array<Classroom>, Error>> {
        try {
            const response = await client.get<Array<Classroom>>(`/users/${id}/classrooms`, {
                params: options
            });
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }

    /**
     * Get the rotation groups for a particular user
     * @param client HTTP client to use
     * @param id ID of the user
     * @param options Options to pass
     */
    public static async rotationGroups(client: AxiosInstance, id: number, options: ListQueryOptions = {}): Promise<Either<Array<RotationGroup>, Error>> {
        try {
            const response = await client.get<Array<RotationGroup>>(`/users/${id}/rotation_groups`, {
                params: options
            });
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }

    public static async me(client: AxiosInstance): Promise<Either<User, Error>> {
        try {
            const response = await client.get<User>(`/users/me`);
            return Either.left(response.data);
        } catch (error) {
            return error.response != undefined ? Either.right({ message: error.response.data }) : Either.right({ message: error });
        }
    }
}
