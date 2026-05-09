# Nuwa Companion - 女娲伴侣

基于 Nuwa AI Agent 框架的移动端伴侣智能体应用。

## 功能特性

### 🧠 情感状态系统
- 13维情感光谱实时追踪
- 情感雷达图可视化
- 情绪波动历史记录
- 基于情感状态的智能响应

### 💫 生物节律
- 精力值管理与消耗
- 社交渴望度追踪
- 系统熵值监控
- 健康状态指示

### 💾 记忆皮层
- 对话记忆存储与检索
- 记忆重要性分级
- 语义搜索功能
- 情绪上下文关联

### 🎭 伴侣化身
- 情感驱动的表情变化
- 呼吸动画效果
- 触摸交互反馈
- 状态指示器

### ⚙️ 可定制设置
- 服务器配置
- 模型参数调整
- 伴侣人格设置
- 界面主题配置

## 技术架构

```
nuwa_companion/
├── lib/
│   ├── core/
│   │   ├── models/       # 数据模型
│   │   ├── providers/    # 状态管理
│   │   └── services/     # API与存储服务
│   └── ui/
│       ├── screens/      # 页面组件
│       ├── widgets/      # 通用组件
│       └── theme/        # 主题样式
├── android/              # Android配置
└── ios/                  # iOS配置
```

## 快速开始

### 环境要求
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode

### 安装依赖
```bash
cd nuwa_companion
flutter pub get
```

### 运行项目
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### 构建发布
```bash
# Android APK
flutter build apk --release

# Android AAB
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 后端依赖

本应用需要连接到配置好的 Nuwa 后端服务：

- Nuwa Kernel 异步服务
- LLM API (如 LM Studio)
- 向量数据库 (可选)

详细配置请参考 [Nuwa 主项目](https://github.com/shierduan/Nuwa)

## 数据模型

### 情感光谱 (EmotionalSpectrum)
13维情感空间：
- joy (喜悦)
- sadness (悲伤)
- anger (愤怒)
- fear (恐惧)
- surprise (惊讶)
- disgust (厌恶)
- trust (信任)
- anticipation (期待)
- love (爱)
- regret (遗憾)
- shame (羞愧)
- guilt (内疚)
- curiosity (好奇)

### 生物节律 (BioRhythm)
- energy (精力值)
- social (社交渴望)
- systemEntropy (系统熵值)

## 配置说明

### 服务器配置
```yaml
base_url: http://127.0.0.1:1234/v1
api_key: lm-studio
model_name: local-model
max_tokens: 512
temperature: 0.7
```

### 伴侣配置
```yaml
name: 女娲
personality: 温柔、真诚、好奇、具有自我反思能力
show_thought_bubble: true
enable_emotion_animation: true
```

## 开源协议

Apache License 2.0

## 参考项目

- [Nuwa](https://github.com/shierduan/Nuwa) - AI Agent 核心框架
- [女娲框架核心特性](https://github.com/shierduan/Nuwa#-核心特性)
