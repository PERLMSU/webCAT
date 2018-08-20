import { DateTime } from "luxon";
import { IsEmail, IsString, MinLength, IsOptional, MaxLength, IsMobilePhone, IsDateString, IsBoolean, IsIn } from "class-validator";
import { Subtract } from "utility-types";

import { User } from "../user";

export class UserUpdate {
    @IsString()
    @IsOptional()
    public readonly firstName?: string;

    @IsString()
    @IsOptional()
    public readonly lastName?: string

    @IsString()
    @IsOptional()
    public readonly middleName?: string;

    @IsEmail()
    @IsOptional()
    public readonly email?: string;

    @IsString()
    @MinLength(1)
    @MaxLength(24)
    @IsOptional()
    public readonly username?: string;

    @IsString()
    @IsOptional()
    public readonly nickname?: string;

    @IsString()
    @IsOptional()
    public readonly bio?: string;

    @IsMobilePhone("en-US")
    @IsOptional()
    public readonly phone?: string;

    @IsString()
    @IsOptional()
    public readonly city?: string;

    @IsString()
    @IsOptional()
    public readonly state?: string;

    @IsString()
    @IsOptional()
    public readonly country?: string;

    @IsDateString()
    @IsOptional()
    public readonly birthday?: string;

    @IsBoolean()
    @IsOptional()
    public readonly active?: boolean;

    @IsString()
    @IsIn(["instructor", "admin"])
    @IsOptional()
    public readonly role?: string;

    constructor(options: Subtract<User, { id: number, insertedAt: DateTime, updatedAt: DateTime }>) {
        this.firstName = options.firstName;
        this.lastName = options.lastName;
        this.middleName = options.middleName;
        this.email = options.email;
        this.username = options.username;
        this.nickname = options.nickname;
        this.bio = options.bio;
        this.phone = options.phone;
        this.city = options.city;
        this.state = options.state;
        this.country = options.country;
        this.birthday = options.birthday !== undefined ? DateTime.fromJSDate(options.birthday).toISODate() : undefined;
        this.active = options.active;
        this.role = options.role;
    }
}
