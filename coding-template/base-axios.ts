import axios from 'axios';
import type { AxiosInstance } from 'axios';

const baseURL = '/api';

// extend this class to add more api
/**
 * ! auto use `try... catch...` statement, if you don't use customer exception, feel free not use `try... catch...` statement outside
 * if you want to edit default exception handler, check `exceptionHandler` method
 */
export class BaseAxios {
  protected axios: AxiosInstance;

  constructor(private url: string) {
    this.axios = axios.create({
      baseURL: `${baseURL}/${this.url}`,
      headers: {
        aui: 'aui',
        token: 'token',
      },
    });
  }

  protected tryCatch(tryCallback: Function, catchCallback: Function | null = null) {
    try {
      return tryCallback();
    } catch (error) {
      if (catchCallback) {
        return catchCallback();
      }
      this.exceptionHandler(error as Error);
    }
  }

  protected exceptionHandler(error: Error) {
    console.error(error);
  }
}
