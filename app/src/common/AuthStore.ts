import { computed, observable, action } from "mobx"
import { Error } from './client/types';
import { authLogin, create } from './client';
import { User } from './domain';
import { Users } from './client/resources/users';

export class AuthStore {
    @observable
    public authToken: string = "";

    @observable
    public isAuthenticating: boolean = false;

    @observable
    public error: Error = undefined;

    @observable
    public user: User = undefined;

    @action
    public async login(email: string, password: string): Promise<void> {
        this.authToken = "";
        this.error = undefined;
        this.isAuthenticating = true;

        const result = await authLogin({ email, password });
        this.isAuthenticating = false;
        
        await result.caseOf({
            left: async (token) => {
                this.authToken = token.token;
                const meResponse = await Users.me(create(this.authToken));
                meResponse.
            },
            right: async (error) => {
                this.error = error;
            }
        });
    }

    @action
    public logout(): void {
        this.authToken = "";
    }

    @computed
    public isAuthenticated(): boolean {
        return this.authToken !== "";
    }
}