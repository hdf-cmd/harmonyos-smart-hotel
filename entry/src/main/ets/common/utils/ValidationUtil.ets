// 输入校验工具：纯函数，天生可单测
//
// 【为什么单独抽出来】校验规则不碰 UI、不碰状态——输入进、结果出，
// 所以它能在单测里直接喂参数断言结果，不用启动预览器、不用点界面。
// 如果把规则写在 View 的 onClick 里，就只能靠人眼点着验，回归一次累一次。
export class ValidationResult {
  isValid: boolean
  message?: string

  constructor(isValid: boolean, message?: string) {
    this.isValid = isValid
    this.message = message
  }
}

export class ValidationUtil {
  /**
   * 用户名：3-16 个字符，仅字母/数字/下划线
   */
  static validateUsername(username: string): ValidationResult {
    if (!username || username.trim() === '') {
      return new ValidationResult(false, '用户名不能为空')
    }
    if (username.length < 3) {
      return new ValidationResult(false, '用户名至少3个字符')
    }
    if (username.length > 16) {
      return new ValidationResult(false, '用户名不能超过16个字符')
    }
    const usernameRegex = /^[a-zA-Z0-9_]+$/
    if (!usernameRegex.test(username)) {
      return new ValidationResult(false, '用户名只能包含字母、数字和下划线')
    }
    return new ValidationResult(true)
  }

  /**
   * 密码：6-16 个字符
   */
  static validatePassword(password: string): ValidationResult {
    if (!password || password.trim() === '') {
      return new ValidationResult(false, '密码不能为空')
    }
    if (password.length < 6) {
      return new ValidationResult(false, '密码至少6个字符')
    }
    if (password.length > 16) {
      return new ValidationResult(false, '密码不能超过16个字符')
    }
    return new ValidationResult(true)
  }

  /**
   * 确认密码：非空，且与原密码一致
   */
  static validateConfirmPassword(password: string,
                                 confirmPassword: string): ValidationResult {
    if (!confirmPassword || confirmPassword.trim() === '') {
      return new ValidationResult(false, '确认密码不能为空')
    }
    if (password !== confirmPassword) {
      return new ValidationResult(false, '两次输入的密码不一致')
    }
    return new ValidationResult(true)
  }
}
