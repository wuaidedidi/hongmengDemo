import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { ConfigService } from './ConfigService';

// const BASE_URL = 'http://10.0.2.2:8080/api'; // 移除硬编码
const PREFERENCES_NAME = 'dailyapp_preferences';
const TOKEN_KEY = 'auth_token';
const USERNAME_KEY = 'username';

// 定义接口类型
interface AuthResponse {
  token: string;
  username: string;
}

interface FocusSessionRequest {
  durationMinutes: number;
  startTime: string;
  endTime: string;
  taskDescription: string;
}

interface FocusSession {
  id: number;
  userId: number;
  duration: number;
  startTime: string;
  endTime: string;
  type: string;
}

interface ErrorResponse {
  message?: string;
  error?: string;
}

interface CheckIn {
  id: number;
  userId: number;
  checkInTime: string;
  streakCount: number;
}

export interface StatisticsResponse {
  totalFocusTime: number;
  totalFocusCount: number;
  continuousDays: number;
  totalDays: number;
  todayFocusTime: number;
  weeklyFocusTime: number;
  monthlyFocusTime: number;
  currentStreak: number;
}

// 添加Todo相关接口
export interface TodoItemRequest {
  title: string;
  description?: string;
  type: string;
  duration: number;
  isImportant?: boolean;
  isUrgent?: boolean;
}

export interface TodoItem {
  id: number;
  title: string;
  description?: string;
  type: string;
  duration: number;
  completed: boolean;
  isImportant: boolean;
  isUrgent: boolean;
  createdAt: string;
  updatedAt?: string;
  userId: number;
  focusTime?: number;
  completedTime?: string;
}

export interface TodoCollection {
  id: number;
  title: string;
  description?: string;
  createdAt: string;
  updatedAt?: string;
  userId: number;
}

export interface TodoCollectionItem {
  id: number;
  title: string;
  description?: string;
  isCompleted: boolean;
  orderIndex: number;
  collectionId: number;
  createTime: string;
  durationMinutes?: number;
}

export interface TodoCollectionRequest {
  title: string;
  description?: string;
}

export interface TodoCollectionItemRequest {
  title: string;
  description?: string;
  durationMinutes?: number;
  orderIndex?: number;
}

export class ApiService {
  private static instance: ApiService;
  private token: string = '';
  private preferences: preferences.Preferences | null = null;
  private initPromise: Promise<void> | null = null;
  private configService: ConfigService = ConfigService.getInstance();
  private baseUrl: string = '';

  private constructor() {
    this.initPromise = this.initPreferences();
  }

  private async initPreferences() {
    try {
      // 初始化配置服务
      await this.configService.initialize();
      this.baseUrl = this.configService.getApiBaseUrl();
      console.info('API Base URL:', this.baseUrl);

      const context = getContext(this);
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
      // 从本地存储加载token
      this.token = await this.preferences.get(TOKEN_KEY, '') as string;
      console.info('Token loaded from preferences:', this.token ? 'Token exists' : 'No token');
    } catch (error) {
      console.error('初始化本地存储失败:', error);
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