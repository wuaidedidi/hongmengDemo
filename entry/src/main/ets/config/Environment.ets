import getContext from '@ohos.app.ability.common';

export interface EnvironmentConfig {
  name: string;
  baseUrl: string;
  description: string;
}

// 本地环境配置
const LOCAL_ENV: EnvironmentConfig = {
  name: 'local',
  baseUrl: 'http://localhost:8080/api',
  description: '本地开发环境'
};

// 服务器环境配置
const SERVER_ENV: EnvironmentConfig = {
  name: 'server',
  baseUrl: 'http://8.148.20.194:8080/api',
  description: '服务器环境'
};

// 获取环境配置
export function getEnvironmentConfig(envName: string): EnvironmentConfig | null {
  if (envName === 'local') {
    return LOCAL_ENV;
  } else if (envName === 'server') {
    return SERVER_ENV;
  }
  return null;
}

// 检查环境是否存在
export function hasEnvironment(envName: string): boolean {
  return envName === 'local' || envName === 'server';
}

// 获取所有环境
export function getAllEnvironments(): EnvironmentConfig[] {
  return [LOCAL_ENV, SERVER_ENV];
}

// 默认环境（可以根据需要切换）
export const DEFAULT_ENVIRONMENT = 'local';

// 获取当前环境配置
export async function getCurrentEnvironment(): Promise<EnvironmentConfig> {
  try {
    // 暂时直接返回默认环境，避免复杂的context获取
    const defaultEnv = getEnvironmentConfig(DEFAULT_ENVIRONMENT);
    return defaultEnv!;
  } catch (error) {
    console.error('Failed to get current environment:', error);
    const defaultEnv = getEnvironmentConfig(DEFAULT_ENVIRONMENT);
    return defaultEnv!;
  }
}

// 获取基础URL（同步版本，用于初始化）
export function getBaseUrl(): string {
  // 由于这是同步函数，暂时返回默认环境的URL
  // 在实际使用中，应该在应用启动时异步加载环境配置
  const defaultEnv = getEnvironmentConfig(DEFAULT_ENVIRONMENT);
  return defaultEnv ? defaultEnv.baseUrl : 'http://8.148.20.194:8080/api';
}

// 获取基础URL（异步版本）
export async function getBaseUrlAsync(): Promise<string> {
  const env = await getCurrentEnvironment();
  return env.baseUrl;
}

// 切换环境的函数（供设置页面使用）
export function switchEnvironment(envName: string): boolean {
  if (hasEnvironment(envName)) {
    // 这里可以保存到用户偏好设置中
    return true;
  }
  return false;
}