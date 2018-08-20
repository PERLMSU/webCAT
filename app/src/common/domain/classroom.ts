import { DateTime } from "luxon";

export interface Classroom {
    id: number;
    courseCode: string;
    section: string;
    description?: string;
    insertedAt: DateTime;
    updatedAt: DateTime;
}