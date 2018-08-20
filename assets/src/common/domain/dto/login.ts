import {IsEmail, IsString, MinLength} from "class-validator";

export class LoginDTO {

    @IsEmail()
    public readonly email: string;

    @MinLength(10)
    @IsString()
    public readonly password: string;

    constructor(email: string, password: string) {
        this.email = email;
        this.password = password;
    }
}
