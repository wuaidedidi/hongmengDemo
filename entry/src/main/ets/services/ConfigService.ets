import resourceManager from '@ohos.resourceManager';

export interface EnvironmentConfig {
  apiBaseUrl: string;
  debug: boolean;
  logLevel: string;
}

export interface EnvironmentMap {
  development: EnvironmentConfig;
  production: EnvironmentConfig;
}

export interface AppConfig {
  environments: EnvironmentMap;
  currentEnvironment: string;
}

export class ConfigService {
  private static instance: ConfigService;
  private config: AppConfig | null = null;
  private initPromise: Promise<void> | null = null;

  private constructor() {}

  static getInstance(): ConfigService {
    if (!ConfigService.instance) {
      ConfigService.instance = new ConfigService();
    }
    return ConfigService.instance;
  }

  async initialize(): Promise<void> {
    if (this.initPromise) {
      return this.initPromise;
    }

    this.initPromise = this.loadConfig();
    return this.initPromise;
  }

  private async loadConfig(): Promise<void> {
    try {
      const context = getContext(this);
      const resourceMgr = context.resourceManager;
      
      // 读取config.json文件
      const configBuffer = await resourceMgr.getRawFileContent('config.json');
      const configStr = String.fromCharCode(...new Uint8Array(configBuffer));
      this.config = JSON.parse(configStr) as AppConfig;
      
      console.info('配置文件加载成功:', JSON.stringify(this.config));
    } catch (error) {
      console.error('加载配置文件失败:', error);
      // 提供默认配置
      const defaultDevelopment: EnvironmentConfig = {
        apiBaseUrl: 'http://10.0.2.2:8080/api',
        debug: true,
        logLevel: 'debug'
      };
      
      const defaultProduction: EnvironmentConfig = {
        apiBaseUrl: 'http://8.148.20.194:8080/api',
        debug: false,
        logLevel: 'error'
      };
      
      const defaultEnvironments: EnvironmentMap = {
        development: defaultDevelopment,
        production: defaultProduction
      };
      
      this.config = {
        environments: defaultEnvironments,
        currentEnvironment: 'production'
      };
      console.info('使用默认配置:', JSON.stringify(this.config));
    }
  }

  getCurrentEnvironment(): string {
    if (!this.config) {
      throw new Error('配置服务未初始化');
    }
    return this.config.currentEnvironment;
  }

  getEnvironmentConfig(env?: string): EnvironmentConfig {
    if (!this.config) {
      throw new Error('配置服务未初始化');
    }
    
    const environment = env || this.config.currentEnvironment;
    let envConfig: EnvironmentConfig | null = null;
    
    // 避免索引访问，使用显式判断
    if (environment === 'development') {
      envConfig = this.config.environments.development;
    } else if (environment === 'production') {
      envConfig = this.config.environments.production;
    }
    
    if (!envConfig) {
      throw new Error(`未找到环境配置: ${environment}`);
    }
    
    return envConfig;
  }

  getApiBaseUrl(): string {
    const config = this.getEnvironmentConfig();
    return config.apiBaseUrl;
  }

  isDebugMode(): boolean {
    const config = this.getEnvironmentConfig();
    return config.debug;
  }

  getLogLevel(): string {
    const config = this.getEnvironmentConfig();
    return config.logLevel;
  }

  // 切换环境（用于测试）
  switchEnvironment(env: string): void {
    if (!this.config) {
      throw new Error('配置服务未初始化');
    }
    
    let isValidEnv = false;
    if (env === 'development' || env === 'production') {
      isValidEnv = true;
    }
    
    if (isValidEnv) {
      this.config.currentEnvironment = env;
      console.info(`已切换到环境: ${env}`);
    } else {
      throw new Error(`无效的环境: ${env}`);
    }
  }

  // 获取所有可用环境
  getAvailableEnvironments(): string[] {
    if (!this.config) {
      return [];
    }
    return ['development', 'production'];
  }
} 