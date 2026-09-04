export interface Success<T> {
  ok: true;
  value: T;
}

export interface Failure<E> {
  ok: false;
  error: E;
}

export interface StandardError {
  code: string;
  message: string;
}

export interface ProblemDetails {
  type: string;
  title: string;
  status: number;
  detail: string;
  instance?: string;
  invalidParams?: Array<{ name: string; reason: string }>;
}

export type Result<T, E = StandardError> = Success<T> | Failure<E>;

export const ok = <T>(value: T): Success<T> => ({ ok: true, value });
export const err = <E>(error: E): Failure<E> => ({ ok: false, error });

const BASE_URL = process.env.BASE_URL;

export const Problem = {
  internalError(
    detail = 'An unexpected error occurred on the server'
  ): ProblemDetails {
    return {
      type: `${BASE_URL}/internal-server-error`,
      title: 'Internal Sever Error',
      status: 500,
      detail,
    };
  },

  notFound(resource: string, id?: string): ProblemDetails {
    return {
      type: `${BASE_URL}/not-found`,
      title: 'Resource Not Found',
      status: 404,
      detail: id
        ? `${resource} with ID ${id} not found`
        : `${resource} was not found`,
    };
  },

  unauthorized(
    detail = 'Authentication is required to access this resource'
  ): ProblemDetails {
    return {
      type: `${BASE_URL}/unauthorized`,
      title: 'Unauthorized',
      status: 401,
      detail,
    };
  },

  forbidden(
    detail = 'You do not have permission to perform this action'
  ): ProblemDetails {
    return {
      type: `${BASE_URL}/forbidden`,
      title: 'Forbidden',
      status: 403,
      detail,
    };
  },

  badRequest(
    detail = 'Required fields missing from request body'
  ): ProblemDetails {
    return {
      type: `${BASE_URL}/bad-request`,
      title: 'Bad Request',
      status: 400,
      detail,
    };
  },

  emailTaken(detail = 'Account with email already exists'): ProblemDetails {
    return {
      type: `${BASE_URL}/invalid-credentials`,
      title: 'Invalid Credentials',
      status: 409,
      detail,
    };
  },

  invalidCredentials(
    detail = 'Email and/or password are invalid'
  ): ProblemDetails {
    return {
      type: `${BASE_URL}/invalid-credentials`,
      title: 'Invalid Credentials',
      status: 401,
      detail,
    };
  },

  wrongSigninType(
    detail = 'Account associated with email uses OAuth signin'
  ): ProblemDetails {
    return {
      type: `${BASE_URL}/wrong-signin-type`,
      title: 'Wrong Signin Type',
      status: 401,
      detail,
    };
  },

  unknownError(detail = 'An unknown error occurred'): ProblemDetails {
    return {
      type: `${BASE_URL}/unknown-error`,
      title: 'Unknown Error',
      status: 400,
      detail,
    };
  },
};

export const errors = {
  'internal-server-error': {
    type: 'http://localhost:3000/errors/internal-server-error',
    status: 500,
    title: 'Internal server error',
    detail: 'A sever error occurred while creating the user',
  },
  'email-in-use': {
    type: 'http://localhost:3000/errors/email-in-use',
    status: 409,
    title: 'Email already in use',
    detail: 'Account with given email already exists',
  },
  'invalid-credentials': {
    type: 'http://localhost:3000/errors/invalid-credentials',
    status: 401,
    title: 'Invalid credentials',
    detail: 'Provided email and/or password are invalid',
  },
  'missing-credentials': {
    type: 'http://localhost:3000/errors/missing-credentials',
    status: 400,
    title: 'Missing or malformed credentials',
    detail: 'Email and/or password are missing or malformed',
  },
};
