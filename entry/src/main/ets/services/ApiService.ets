/**
 * 🌐 API服务类 (ApiService)
 * 
 * 这是应用与后端服务通信的核心类，负责处理所有的HTTP请求
 * 采用单例模式，确保全局只有一个API服务实例
 * 
 * 🔥 核心功能：
 * - 用户认证管理（登录、注册、Token管理）
 * - 待办事项CRUD操作
 * - 专注会话管理
 * - 统计数据获取
 * - 自动错误处理和重试机制
 * 
 * 🏗️ 架构特点：
 * - 单例模式：全局统一的API服务实例
 * - JWT认证：自动处理Token认证
 * - 配置灵活：支持多环境配置
 * - 数据持久化：本地存储用户信息
 */

import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { ConfigService } from './ConfigService';

// 🔧 配置常量
// const BASE_URL = 'http://10.0.2.2:8080/api'; // 移除硬编码，改为动态配置
const PREFERENCES_NAME = 'dailyapp_preferences'; // 本地存储配置名称
const TOKEN_KEY = 'auth_token';                  // Token存储键
const USERNAME_KEY = 'username';                 // 用户名存储键

// 🔗 API接口类型定义
// 这些接口定义了与后端交互的数据结构

/**
 * 👤 用户认证响应接口
 */
interface AuthResponse {
  token: string;    // JWT认证令牌
  username: string; // 用户名
}

/**
 * ⏰ 专注会话请求接口
 */
interface FocusSessionRequest {
  durationMinutes: number;  // 专注时长（分钟）
  startTime: string;        // 开始时间
  endTime: string;          // 结束时间
  taskDescription: string;  // 任务描述
}

/**
 * 📊 专注会话数据接口
 */
interface FocusSession {
  id: number;        // 会话ID
  userId: number;    // 用户ID
  duration: number;  // 持续时长
  startTime: string; // 开始时间
  endTime: string;   // 结束时间
  type: string;      // 会话类型
}

/**
 * ❌ 错误响应接口
 */
interface ErrorResponse {
  message?: string; // 错误消息
  error?: string;   // 错误详情
}

/**
 * ✅ 签到数据接口
 */
interface CheckIn {
  id: number;           // 签到ID
  userId: number;       // 用户ID
  checkInTime: string;  // 签到时间
  streakCount: number;  // 连续签到天数
}

/**
 * 📈 统计数据响应接口
 */
export interface StatisticsResponse {
  totalFocusTime: number;   // 总专注时长
  totalFocusCount: number;  // 总专注次数
  continuousDays: number;   // 连续天数
  totalDays: number;        // 总天数
  todayFocusTime: number;   // 今日专注时长
  weeklyFocusTime: number;  // 本周专注时长
  monthlyFocusTime: number; // 本月专注时长
  currentStreak: number;    // 当前连击数
}

// 📝 待办事项相关接口定义

/**
 * 待办事项创建/更新请求接口
 */
export interface TodoItemRequest {
  title: string;          // 待办标题（必填）
  description?: string;   // 待办描述（可选）
  type: string;          // 待办分类
  duration: number;      // 预计时长（分钟）
  isImportant?: boolean; // 是否重要
  isUrgent?: boolean;    // 是否紧急
}

/**
 * 待办事项完整数据接口
 */
export interface TodoItem {
  id: number;              // 待办ID
  title: string;           // 待办标题
  description?: string;    // 待办描述
  type: string;           // 待办分类
  duration: number;       // 预计时长
  completed: boolean;     // 完成状态
  isImportant: boolean;   // 重要性标记
  isUrgent: boolean;      // 紧急性标记
  createdAt: string;      // 创建时间
  updatedAt?: string;     // 更新时间
  userId: number;         // 所属用户ID
  focusTime?: number;     // 实际专注时长
  completedTime?: string; // 完成时间
}

/**
 * 📋 待办合集接口
 */
export interface TodoCollection {
  id: number;           // 合集ID
  title: string;        // 合集标题
  description?: string; // 合集描述
  createdAt: string;    // 创建时间
  updatedAt?: string;   // 更新时间
  userId: number;       // 所属用户ID
}

/**
 * 📑 待办合集子项接口
 */
export interface TodoCollectionItem {
  id: number;               // 子项ID
  title: string;            // 子项标题
  description?: string;     // 子项描述
  isCompleted: boolean;     // 完成状态
  orderIndex: number;       // 排序索引
  collectionId: number;     // 所属合集ID
  createTime: string;       // 创建时间
  durationMinutes?: number; // 预计时长
}

/**
 * 待办合集创建请求接口
 */
export interface TodoCollectionRequest {
  title: string;        // 合集标题
  description?: string; // 合集描述
}

/**
 * 待办合集子项创建请求接口
 */
export interface TodoCollectionItemRequest {
  title: string;            // 子项标题
  description?: string;     // 子项描述
  durationMinutes?: number; // 预计时长
  orderIndex?: number;      // 排序索引
}

/**
 * 🌐 API服务类 - 核心网络通信服务
 * 
 * 采用单例模式设计，确保全应用只有一个API服务实例
 * 负责处理所有与后端的HTTP通信
 */
export class ApiService {
  /** 单例实例 */
  private static instance: ApiService;
  
  /** JWT认证令牌 */
  private token: string = '';
  
  /** 本地存储服务 */
  private preferences: preferences.Preferences | null = null;
  
  /** 初始化Promise，确保服务完全初始化后再使用 */
  private initPromise: Promise<void> | null = null;
  
  /** 配置服务实例 */
  private configService: ConfigService = ConfigService.getInstance();
  
  /** API基础URL */
  private baseUrl: string = '';

  /**
   * 私有构造函数 - 实现单例模式
   * 在构造时启动异步初始化过程
   */
  private constructor() {
    this.initPromise = this.initPreferences();
  }

  private async initPreferences() {
    try {
      // 初始化配置服务
      await this.configService.initialize();
      this.baseUrl = this.configService.getApiBaseUrl();
      console.info('✅ API Base URL:', this.baseUrl);

      const context = getContext(this);
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      // 从本地存储加载token
      this.token = await this.preferences.get(TOKEN_KEY, '') as string;
      console.info('Token loaded from preferences:', this.token ? 'Token exists' : 'No token');
    } catch (error) {
      console.error('❌ 初始化失败:', error);
      // 设置默认API地址作为fallback
      this.baseUrl = 'http://8.148.20.194:8080/api';
      console.warn('⚠️ 使用默认API地址作为fallback:', this.baseUrl);
    }
  }

  static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }

  private async ensureInitialized() {
    if (this.initPromise) {
      await this.initPromise;
      this.initPromise = null;
    }
  }

  private ensureBaseUrl() {
    if (!this.baseUrl) {
      this.baseUrl = 'http://8.148.20.194:8080/api';
      console.warn('⚠️ BaseUrl为空，使用默认值:', this.baseUrl);
    }
  }

  async setToken(token: string) {
    await this.ensureInitialized();
    this.token = token;
    if (this.preferences) {
      try {
        await this.preferences.put(TOKEN_KEY, token);
        await this.preferences.flush();
        console.info('Token saved to preferences');
      } catch (error) {
        console.error('保存token失败:', error);
      }
    }
  }

  async setUsername(username: string) {
    await this.ensureInitialized();
    if (this.preferences) {
      try {
        await this.preferences.put(USERNAME_KEY, username);
        await this.preferences.flush();
      } catch (error) {
        console.error('保存用户名失败:', error);
      }
    }
  }

  async getUsername(): Promise<string> {
    await this.ensureInitialized();
    if (this.preferences) {
      try {
        return await this.preferences.get(USERNAME_KEY, '') as string;
      } catch (error) {
        console.error('获取用户名失败:', error);
      }
    }
    return '';
  }

  async getToken(): Promise<string> {
    await this.ensureInitialized();
    if (this.preferences) {
      try {
        return await this.preferences.get(TOKEN_KEY, '') as string;
      } catch (error) {
        console.error('获取token失败:', error);
      }
    }
    return '';
  }

  async clearAuth() {
    await this.ensureInitialized();
    this.token = '';
    if (this.preferences) {
      try {
        await this.preferences.delete(TOKEN_KEY);
        await this.preferences.delete(USERNAME_KEY);
        await this.preferences.flush();
        console.info('Auth cleared from preferences');
      } catch (error) {
        console.error('清除认证信息失败:', error);
      }
    }
  }

  private async getHeaders(): Promise<Record<string, string>> {
    const headers: Record<string, string> = {};
    headers['Content-Type'] = 'application/json';
    
    try {
      const token: string = await this.getToken();
      console.log('🔍 获取到的token:', token ? (token.substring(0, 20) + '...') : 'null');
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
        console.log('✅ 已添加Authorization头');
      } else {
        console.warn('⚠️ 没有找到token，可能未登录');
      }
    } catch (error) {
      console.error('❌ 获取token失败:', error);
    }
    
    return headers;
  }

  async login(username: string, password: string): Promise<AuthResponse> {
    try {
      await this.ensureInitialized();
      this.ensureBaseUrl();
      
      console.info(`尝试登录: username=${username}`);
      console.info(`请求URL: ${this.baseUrl}/auth/login`);
      const headers = await this.getHeaders();
      console.info(`请求头: ${JSON.stringify(headers)}`);
      console.info(`请求数据: ${JSON.stringify({ username, password })}`);

      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        `${this.baseUrl}/auth/login`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify({ username, password })
        }
      );
      console.info(`登录响应: code=${response.responseCode}, result=${response.result}`);
      console.info(`响应头: ${JSON.stringify(response.header)}`);

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as AuthResponse;
        return data;
      } else {
        console.error(`登录失败: code=${response.responseCode}, result=${response.result}`);
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`);
      }
    } catch (error) {
      console.error('登录请求失败:', error);
      console.error('错误类型:', typeof error);
      console.error('错误详情:', JSON.stringify(error));
      throw new Error((error as Error).message);
    }
  }

  async register(username: string, password: string): Promise<AuthResponse> {
    try {
      await this.ensureInitialized();
      this.ensureBaseUrl();
      
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/auth/register`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify({ username, password })
        }
      );
      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as AuthResponse;
        this.setToken(data.token);
        return data;
      } else {
        throw new Error('注册失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '注册失败：' + (error as Error).message });
      throw new Error('注册失败');
    }
  }

  async createFocusSession(sessionData: FocusSessionRequest): Promise<FocusSession> {
    try {
      await this.ensureInitialized();
      this.ensureBaseUrl();
      
      console.info('发送专注会话请求:', JSON.stringify(sessionData));
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      console.info('请求头:', JSON.stringify(headers));
      
      let response = await httpRequest.request(
        `${this.baseUrl}/sessions`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify(sessionData)
        }
      );
      
      console.info(`响应状态码: ${response.responseCode}`);
      console.info(`响应内容: ${response.result}`);
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as FocusSession;
      } else {
        let errorMessage = '创建专注时段失败';
        try {
          const errorResponse: ErrorResponse = JSON.parse(response.result as string);
          if (errorResponse.message) {
            errorMessage = errorResponse.message;
          } else if (errorResponse.error) {
            errorMessage = errorResponse.error;
          }
        } catch (parseError) {
          errorMessage = `HTTP ${response.responseCode}: ${response.result}`;
        }
        throw new Error(errorMessage);
      }
    } catch (error) {
      console.error('创建专注会话失败:', error);
      const errorMessage = (error as Error).message || '网络请求失败';
      promptAction.showToast({ message: '创建专注时段失败：' + errorMessage });
      throw new Error(errorMessage);
    }
  }

  async getDailySessions(date: string): Promise<FocusSession[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/sessions/daily?date=${date}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as FocusSession[];
      } else {
        throw new Error('获取每日统计失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '获取每日统计失败：' + (error as Error).message });
      throw new Error('获取每日统计失败');
    }
  }

  async getWeeklySessions(weekStart: string): Promise<FocusSession[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/sessions/weekly?weekStart=${weekStart}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as FocusSession[];
      } else {
        throw new Error('获取周统计失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '获取周统计失败：' + (error as Error).message });
      throw new Error('获取周统计失败');
    }
  }

  async getMonthlySessions(monthStart: string): Promise<FocusSession[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/sessions/monthly?monthStart=${monthStart}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as FocusSession[];
      } else {
        throw new Error('获取月统计失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '获取月统计失败：' + (error as Error).message });
      throw new Error('获取月统计失败');
    }
  }

  async getStatistics(): Promise<StatisticsResponse> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/sessions/statistics`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as StatisticsResponse;
      } else {
        throw new Error('获取统计数据失败');
      }
    } catch (error) {
      console.error('获取统计数据失败:', error);
      throw new Error('获取统计数据失败：' + (error as Error).message);
    }
  }

  async checkIn(): Promise<CheckIn> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/check-in`,
        {
          method: http.RequestMethod.POST,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as CheckIn;
      } else {
        throw new Error('打卡失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '打卡失败：' + (error as Error).message });
      throw new Error('打卡失败');
    }
  }

  async getCurrentStreak(): Promise<number> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/check-in/streak`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as number;
      } else {
        throw new Error('获取连续打卡天数失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '获取连续打卡天数失败：' + (error as Error).message });
      return 0;
    }
  }

  async hasCheckedInToday(): Promise<boolean> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/check-in/today`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as boolean;
      } else {
        throw new Error('检查今日打卡状态失败');
      }
    } catch (error) {
      promptAction.showToast({ message: '检查今日打卡状态失败：' + (error as Error).message });
      return false;
    }
  }

  // Todo相关方法实现
  async createTodoItem(todoData: TodoItemRequest): Promise<TodoItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify(todoData)
        }
      );
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result as string) as TodoItem;
      } else {
        throw new Error('创建待办事项失败');
      }
    } catch (error) {
      console.error('创建待办事项失败:', error);
      throw new Error('创建待办事项失败：' + (error as Error).message);
    }
  }

  async getTodoItems(): Promise<TodoItem[]> {
    try {
      console.log('🔍 开始获取待办事项...');
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      console.log('🔍 请求头:', JSON.stringify(headers));
      console.log('🔍 请求URL:', `${this.baseUrl}/todos`);
      
      let response = await httpRequest.request(
        `${this.baseUrl}/todos`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      
      console.log('🔍 响应状态码:', response.responseCode);
      console.log('🔍 响应内容:', response.result);
      
      if (response.responseCode === 200) {
        const todos = JSON.parse(response.result as string) as TodoItem[];
        console.log('✅ 成功获取待办事项，数量:', todos.length);
        return todos;
      } else {
        console.error('❌ 获取待办事项失败，状态码:', response.responseCode);
        throw new Error('获取待办事项失败');
      }
    } catch (error) {
      console.error('❌ 获取待办事项异常:', error);
      throw new Error('获取待办事项失败：' + (error as Error).message);
    }
  }

  async toggleTodoItemStatus(todoId: number): Promise<TodoItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/${todoId}/toggle`,
        {
          method: http.RequestMethod.PUT,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem;
      } else {
        throw new Error('更新待办事项状态失败');
      }
    } catch (error) {
      console.error('更新待办事项状态失败:', error);
      throw new Error('更新待办事项状态失败：' + (error as Error).message);
    }
  }

  async deleteTodoItem(todoId: number): Promise<void> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/${todoId}`,
        {
          method: http.RequestMethod.DELETE,
          header: headers
        }
      );
      if (response.responseCode !== 200 && response.responseCode !== 204) {
        throw new Error('删除待办事项失败');
      }
    } catch (error) {
      console.error('删除待办事项失败:', error);
      throw new Error('删除待办事项失败：' + (error as Error).message);
    }
  }

  // 按状态获取待办事项
  async getTodoItemsByStatus(isCompleted: boolean): Promise<TodoItem[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/status/${isCompleted}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem[];
      } else {
        throw new Error('按状态获取待办事项失败');
      }
    } catch (error) {
      console.error('按状态获取待办事项失败:', error);
      throw new Error('按状态获取待办事项失败：' + (error as Error).message);
    }
  }

  // 按类型获取待办事项
  async getTodoItemsByType(type: string): Promise<TodoItem[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/type/${type}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem[];
      } else {
        throw new Error('按类型获取待办事项失败');
      }
    } catch (error) {
      console.error('按类型获取待办事项失败:', error);
      throw new Error('按类型获取待办事项失败：' + (error as Error).message);
    }
  }

  // 按日期范围获取待办事项
  async getTodoItemsInDateRange(startDate: string, endDate: string): Promise<TodoItem[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/date-range?startDate=${startDate}&endDate=${endDate}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem[];
      } else {
        throw new Error('按日期范围获取待办事项失败');
      }
    } catch (error) {
      console.error('按日期范围获取待办事项失败:', error);
      throw new Error('按日期范围获取待办事项失败：' + (error as Error).message);
    }
  }

  // 获取单个待办事项
  async getTodoItem(todoId: number): Promise<TodoItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/${todoId}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem;
      } else {
        throw new Error('获取待办事项失败');
      }
    } catch (error) {
      console.error('获取待办事项失败:', error);
      throw new Error('获取待办事项失败：' + (error as Error).message);
    }
  }

  // 更新待办事项
  async updateTodoItem(todoId: number, todoData: TodoItemRequest): Promise<TodoItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/${todoId}`,
        {
          method: http.RequestMethod.PUT,
          header: headers,
          extraData: JSON.stringify(todoData)
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem;
      } else {
        throw new Error('更新待办事项失败');
      }
    } catch (error) {
      console.error('更新待办事项失败:', error);
      throw new Error('更新待办事项失败：' + (error as Error).message);
    }
  }

  // 更新待办事项的专注时间
  async updateTodoItemFocusTime(todoId: number, focusTime: number): Promise<TodoItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todos/${todoId}/focus-time`,
        {
          method: http.RequestMethod.PUT,
          header: headers,
          extraData: JSON.stringify({ focusTime })
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoItem;
      } else {
        throw new Error('更新待办事项专注时间失败');
      }
    } catch (error) {
      console.error('更新待办事项专注时间失败:', error);
      throw new Error('更新待办事项专注时间失败：' + (error as Error).message);
    }
  }

  async createTodoCollection(collectionData: TodoCollectionRequest): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify(collectionData)
        }
      );
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        throw new Error('创建待办合集失败');
      }
    } catch (error) {
      console.error('创建待办合集失败:', error);
      throw new Error('创建待办合集失败：' + (error as Error).message);
    }
  }

  // 新增方法：直接接受字符串参数，避免结构化类型问题
  async createTodoCollectionDirect(title: string, description?: string): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      
      // 直接构造JSON字符串，避免对象字面量，使用title字段
      const requestBody = description 
        ? `{"title":"${title}","description":"${description}"}`
        : `{"title":"${title}"}`;
      
      console.info('发送待办合集请求:', requestBody);
      
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: requestBody
        }
      );
      
      console.info(`待办合集创建响应状态码: ${response.responseCode}`);
      console.info(`待办合集创建响应内容: ${response.result}`);
      
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        let errorMessage = '创建待办合集失败';
        try {
          const errorResponse: ErrorResponse = JSON.parse(response.result as string);
          if (errorResponse.message) {
            errorMessage = errorResponse.message;
          } else if (errorResponse.error) {
            errorMessage = errorResponse.error;
          }
        } catch (parseError) {
          errorMessage = `HTTP ${response.responseCode}: ${response.result}`;
        }
        throw new Error(errorMessage);
      }
    } catch (error) {
      console.error('创建待办合集失败:', error);
      throw new Error('创建待办合集失败：' + (error as Error).message);
    }
  }

  async getTodoCollections(): Promise<TodoCollection[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollection[];
      } else {
        throw new Error('获取待办合集失败');
      }
    } catch (error) {
      console.error('获取待办合集失败:', error);
      throw new Error('获取待办合集失败：' + (error as Error).message);
    }
  }

  async deleteTodoCollection(collectionId: number): Promise<void> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}`,
        {
          method: http.RequestMethod.DELETE,
          header: headers
        }
      );
      if (response.responseCode !== 200 && response.responseCode !== 204) {
        throw new Error('删除待办合集失败');
      }
    } catch (error) {
      console.error('删除待办合集失败:', error);
      throw new Error('删除待办合集失败：' + (error as Error).message);
    }
  }

  // 获取单个待办合集
  async getTodoCollection(collectionId: number): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        throw new Error('获取待办合集失败');
      }
    } catch (error) {
      console.error('获取待办合集失败:', error);
      throw new Error('获取待办合集失败：' + (error as Error).message);
    }
  }

  // 获取合集项目
  async getCollectionItems(collectionId: number): Promise<TodoCollectionItem[]> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/items`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollectionItem[];
      } else {
        throw new Error('获取合集项目失败');
      }
    } catch (error) {
      console.error('获取合集项目失败:', error);
      throw new Error('获取合集项目失败：' + (error as Error).message);
    }
  }

  // 更新待办合集
  async updateTodoCollection(collectionId: number, collectionData: TodoCollectionRequest): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}`,
        {
          method: http.RequestMethod.PUT,
          header: headers,
          extraData: JSON.stringify(collectionData)
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        throw new Error('更新待办合集失败');
      }
    } catch (error) {
      console.error('更新待办合集失败:', error);
      throw new Error('更新待办合集失败：' + (error as Error).message);
    }
  }

  // 添加项目到合集
  async addItemToCollection(collectionId: number, itemData: TodoCollectionItemRequest): Promise<TodoCollectionItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/items`,
        {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify(itemData)
        }
      );
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result as string) as TodoCollectionItem;
      } else {
        throw new Error('添加合集项目失败');
      }
    } catch (error) {
      console.error('添加合集项目失败:', error);
      throw new Error('添加合集项目失败：' + (error as Error).message);
    }
  }

  // 切换合集项目状态
  async toggleCollectionItemStatus(collectionId: number, itemId: number): Promise<TodoCollectionItem> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/items/${itemId}/toggle`,
        {
          method: http.RequestMethod.PUT,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollectionItem;
      } else {
        throw new Error('切换合集项目状态失败');
      }
    } catch (error) {
      console.error('切换合集项目状态失败:', error);
      throw new Error('切换合集项目状态失败：' + (error as Error).message);
    }
  }

  // 开始序列
  async startSequence(collectionId: number): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/sequence/start`,
        {
          method: http.RequestMethod.PUT,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        throw new Error('开始序列失败');
      }
    } catch (error) {
      console.error('开始序列失败:', error);
      throw new Error('开始序列失败：' + (error as Error).message);
    }
  }

  // 停止序列
  async stopSequence(collectionId: number): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/sequence/stop`,
        {
          method: http.RequestMethod.PUT,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        throw new Error('停止序列失败');
      }
    } catch (error) {
      console.error('停止序列失败:', error);
      throw new Error('停止序列失败：' + (error as Error).message);
    }
  }

  // 下一个任务序列
  async nextTaskInSequence(collectionId: number): Promise<TodoCollection> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/sequence/next`,
        {
          method: http.RequestMethod.PUT,
          header: headers
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as TodoCollection;
      } else {
        throw new Error('下一个任务失败');
      }
    } catch (error) {
      console.error('下一个任务失败:', error);
      throw new Error('下一个任务失败：' + (error as Error).message);
    }
  }

  // 删除合集项目
  async deleteCollectionItem(collectionId: number, itemId: number): Promise<void> {
    try {
      let httpRequest = http.createHttp();
      const headers = await this.getHeaders();
      let response = await httpRequest.request(
        `${this.baseUrl}/todo-collections/${collectionId}/items/${itemId}`,
        {
          method: http.RequestMethod.DELETE,
          header: headers
        }
      );
      if (response.responseCode !== 200 && response.responseCode !== 204) {
        throw new Error('删除合集项目失败');
      }
    } catch (error) {
      console.error('删除合集项目失败:', error);
      throw new Error('删除合集项目失败：' + (error as Error).message);
    }
  }
}