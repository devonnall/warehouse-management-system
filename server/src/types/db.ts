export interface DatabaseFunctionResult extends Record<string, unknown> {
    success: boolean,
    error_code: string,
    error_message: string
}
