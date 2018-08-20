import { DateTime } from "luxon";

export interface Notification {
    id: number;
    content: string;
    seen: boolean;
    insertedAt: DateTime;
    updatedAt: DateTime;
}