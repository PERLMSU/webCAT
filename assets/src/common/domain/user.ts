import { DateTime } from "luxon";

export interface User {
    id: number;
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
    active: boolean;
    role: string;
    insertedAt: DateTime;
    updatedAt: DateTime;
}