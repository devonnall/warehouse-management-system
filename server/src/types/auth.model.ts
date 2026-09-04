export interface AuthCredentials {
  email: string;
  password: string;
}

export type SignupInput = AuthCredentials;
export type LoginInput = AuthCredentials;
