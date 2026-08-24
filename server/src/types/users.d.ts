export interface Account {
    id: string,
    email: string,
    passwordHash: string,
    firstName: string,
    lastName: string,
    role: string
}

export interface User {
    id: string,
    email: string,
    firstName: string,
    lastName: string,
    role: string
}

export interface CreateUser {
    email: string,
    passwordHash: string,
    firstName: string,
    lastName: string
}
