export {};

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      APP_ENV: 'development' | 'production' | 'test';
      PORT: string;
      SESSION_SECRET: string;
      POSTGRES_USER: string;
      POSTGRES_PASSWORD: string;
      POSTGRES_DB: string;
      DATABASE_URL: string;
      BASE_URL: string;
    }
  }
}
