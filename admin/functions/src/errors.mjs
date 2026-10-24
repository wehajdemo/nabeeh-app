/** An error the caller may see. `code` is a Firebase callable error code. */
export class ServiceError extends Error {
  constructor(code, message) {
    super(message);
    this.name = 'ServiceError';
    this.code = code;
  }
}
