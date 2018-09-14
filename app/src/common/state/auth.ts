import * as Cookies from "universal-cookie";
import { TokenDTO } from '../client/resources/auth';

export default class API {
    private static cookies = new Cookies();


    public static getAuthToken(): string {
        return API.cookies.get('auth');
    }

    public static isAuthenticated(): boolean {
        return this.getAuthToken() !== undefined;
    }

    public static login(token: TokenDTO): void {
        API.cookies.set('auth', token.token, { path: '/' });
        window.location.replace('./');
    }

    public static logout(): void {
        if (this.isAuthenticated()) {
            API.cookies.remove('auth');
        }

        window.location.replace('./login');
    }
}