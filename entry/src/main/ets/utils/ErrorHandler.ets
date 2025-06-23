// 错误处理工具 - ArkTS兼容版本

import { CommonError, ErrorInfo } from '../types/CommonTypes';

// 定义支持的错误类型
type SupportedError = Error | CommonError | string;

/**
 * 安全执行异步操作
 */
export async function safeExecute<T>(
  operation: () => Promise<T>,
  onError: (error: ErrorInfo) => void
): Promise<T | undefined> {
  try {
    return await operation();
  } catch (err) {
    const errorInfo = createErrorInfo(err as SupportedError);
    onError(errorInfo);
    return undefined;
  }
}

/**
 * 安全执行同步操作
 */
export function safeExecuteSync<T>(
  operation: () => T,
  onError: (error: ErrorInfo) => void
): T | undefined {
  try {
    return operation();
  } catch (err) {
    const errorInfo = createErrorInfo(err as SupportedError);
    onError(errorInfo);
    return undefined;
  }
}

/**
 * 创建错误信息
 */
export function createErrorInfo(error: SupportedError): ErrorInfo {
  if (typeof error === 'string') {
    return {
      message: error,
      code: 0,
      details: error
    };
  }
  
  if (error instanceof Error) {
    return {
      message: error.message,
      code: 0,
      details: error.stack || error.message
    };
  }
  
  // CommonError类型
  return {
    message: error.message || '未知错误',
    code: typeof error.code === 'number' ? error.code : 0,
    details: error.detail || error.message || '未知错误'
  };
}

/**
 * 格式化错误消息
 */
export function formatErrorMessage(error: ErrorInfo): string {
  if (error.code && error.code !== 0) {
    return `[${error.code}] ${error.message}`;
  }
  return error.message;
}

/**
 * 判断是否为网络错误
 */
export function isNetworkError(error: ErrorInfo): boolean {
  const message = error.message.toLowerCase();
  return message.includes('network') || 
         message.includes('网络') ||
         message.includes('timeout') ||
         message.includes('超时') ||
         message.includes('connect') ||
         message.includes('连接');
}

/**
 * 判断是否为认证错误
 */
export function isAuthError(error: ErrorInfo): boolean {
  return error.code === 401 || 
         error.code === 403 ||
         error.message.includes('unauthorized') ||
         error.message.includes('认证') ||
         error.message.includes('登录');
}

/**
 * 获取用户友好的错误消息
 */
export function getUserFriendlyMessage(error: ErrorInfo): string {
  if (isNetworkError(error)) {
    return '网络连接异常，请检查网络设置';
  }
  
  if (isAuthError(error)) {
    return '登录已过期，请重新登录';
  }
  
  if (error.code === 404) {
    return '请求的资源不存在';
  }
  
  if (error.code === 500) {
    return '服务器内部错误，请稍后重试';
  }
  
  return error.message || '操作失败，请稍后重试';
}

/**
 * 简单的重试机制
 */
export async function retryOperation<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  let lastError: ErrorInfo | undefined;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (err) {
      lastError = createErrorInfo(err as SupportedError);
      
      if (attempt === maxRetries) {
        break;
      }
      
      // 等待后重试
      await new Promise<void>(resolve => setTimeout(resolve, delay * (attempt + 1)));
    }
  }
  
  throw new Error(lastError?.message || '操作失败');
} 