# Project Management System

This application serves to minic the functionality of developer-focused tools like Linear and Jira for general proejct management.

## Status

**Status:** In development

### Current Progress

- User account creation
- Session-based user authentication
- PostgreSQL database
- Flyway setup for database migrations
- Containerization of database, Flyway migrations, and Express.js server

### Current Technical Stack

- PostgreSQL + Flyway for migrations
- Express.js + TypeScript for server/API
- Docker for containerizing database, server, and Flyway

## Architecture

### Server Architecture

The Express.js server follows the Repository-Service-Controller-Route architecture, where:

- Repositories directly query the database
- Services contain business logic
- Controllers contain logic to handle HTTP requests
- Routes define API routes, middleware, and associated controllers
