import { DateTime } from "luxon";

export interface RotationGroup {
    id: number;
    description?: string;
    number: number;
    insertedAt: DateTime;
    updatedAt: DateTime;
}