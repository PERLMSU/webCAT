import { IsEmail, IsString, MinLength, IsOptional, MaxLength } from "class-validator";

export class SignupDTO {
    @IsString()
    public readonly firstName: string;

    @IsString()
    public readonly lastName: string

    @IsEmail()
    public readonly email: string;

    @IsString()
    @MinLength(1)
    @MaxLength(24)
    public readonly username: string;

    @IsString()
    @MinLength(10)
    public readonly password: string;

    constructor(firstName: string, lastName: string, username: string, email: string, password: string) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.username = username;
        this.email = email;
        this.password = password;
    }
}
