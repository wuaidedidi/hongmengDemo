// 简化版状态管理器 - ArkTS兼容版本

// 定义全局状态接口
interface GlobalAppState {
  isLoggedIn: boolean;
  username: string;
  userId: number;
  token: string;
  currentTheme: string;
}

// 状态变化监听器类型
type StateChangeListener = (state: GlobalAppState) => void;

// 用户信息接口
interface UserInfo {
  username: string;
  userId: number;
  token: string;
}

/**
 * 简化版全局状态管理器
 */
class GlobalStateManager {
  private state: GlobalAppState;
  private listeners: StateChangeListener[] = [];

  constructor() {
    this.state = {
      isLoggedIn: false,
      username: '',
      userId: 0,
      token: '',
      currentTheme: 'default'
    };
  }

  /**
   * 获取当前状态
   */
  getState(): GlobalAppState {
    return {
      isLoggedIn: this.state.isLoggedIn,
      username: this.state.username,
      userId: this.state.userId,
      token: this.state.token,
      currentTheme: this.state.currentTheme
    };
  }

  /**
   * 添加状态变化监听器
   */
  addListener(listener: StateChangeListener): void {
    this.listeners.push(listener);
  }

  /**
   * 移除状态变化监听器
   */
  removeListener(listener: StateChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      listener(this.getState());
    });
  }

  /**
   * 用户登录
   */
  login(username: string, userId: number, token: string): void {
    this.state.isLoggedIn = true;
    this.state.username = username;
    this.state.userId = userId;
    this.state.token = token;
    this.notifyListeners();
  }

  /**
   * 用户登出
   */
  logout(): void {
    this.state.isLoggedIn = false;
    this.state.username = '';
    this.state.userId = 0;
    this.state.token = '';
    this.notifyListeners();
  }

  /**
   * 设置主题
   */
  setTheme(theme: string): void {
    this.state.currentTheme = theme;
    this.notifyListeners();
  }

  /**
   * 获取用户信息
   */
  getUserInfo(): UserInfo {
    return {
      username: this.state.username,
      userId: this.state.userId,
      token: this.state.token
    };
  }

  /**
   * 检查登录状态
   */
  isLoggedIn(): boolean {
    return this.state.isLoggedIn;
  }
}

// 全局状态管理器实例
export const globalState = new GlobalStateManager(); 