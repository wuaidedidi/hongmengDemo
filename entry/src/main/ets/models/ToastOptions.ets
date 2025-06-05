export class ToastOptions {
  message: string;
  duration?: number;
 
  constructor(message: string, duration?: number) {
    this.message = message;
    this.duration = duration;
  }
} 