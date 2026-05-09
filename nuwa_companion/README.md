# Nuwa Companion - 女娲伴侣

基于 Nuwa AI Agent 框架的移动端伴侣智能体应用。**完全本地化运行**。

## 核心特性

### 🧠 本地向量计算引擎
- **SimHash + 语义哈希**: 64维文本向量化
- **余弦相似度**: 向量相似度计算
- **欧几里得距离**: 语义空间距离度量
- **插值与演化**: 向量状态的平滑过渡

### 🎭 黎曼语义场
- **势能计算**: 基于人格核心的语义距离
- **梯度下降**: 状态演化方向引导
- **流形投影**: 保证语义一致性
- **稳定性分析**: OOC检测与修正

### ⚙️ 自适应 PID 控制器
- **PPO强化学习**: 参数自适应调整
- **生物节律模拟**: 精力衰减、社交饥渴
- **情绪/熵值双控制器**: 多目标协同控制
- **经验回放**: 性能历史追踪

### 💾 本地记忆引擎
- **语义检索**: 基于向量的记忆匹配
- **重要性加权**: 重要记忆优先保留
- **时效性衰减**: 新记忆权重更高
- **记忆整合**: 相似记忆自动合并

### 💫 情感状态系统
- **13维情感光谱**: joy, sadness, anger, fear, surprise, disgust, trust, anticipation, love, regret, shame, guilt, curiosity
- **情感关联传播**: 情绪间的相互影响
- **自然衰减**: 情感状态的回归平衡
- **应激响应**: 外部输入的情绪反馈

## 技术架构

```
nuwa_companion/
├── lib/
│   ├── core/
│   │   ├── engine/           # 本地计算引擎
│   │   │   ├── vector_engine.dart      # 向量计算
│   │   │   ├── semantic_field.dart     # 语义场论
│   │   │   ├── pid_controller.dart    # PID控制器
│   │   │   ├── memory_engine.dart     # 记忆引擎
│   │   │   ├── emotion_engine.dart     # 情感引擎
│   │   │   └── computation_engine.dart # 统一计算入口
│   │   ├── models/          # 数据模型
│   │   ├── providers/       # 状态管理
│   │   └── services/        # API与存储
│   └── ui/
│       ├── screens/         # 页面
│       ├── widgets/         # 组件
│       └── theme/          # 主题
```

## 本地计算 vs 依赖外部

| 功能模块 | 本地计算 | 说明 |
|---------|---------|------|
| 向量生成 | ✅ | SimHash + 语义哈希 |
| 相似度计算 | ✅ | 余弦相似度/欧氏距离 |
| 语义场演化 | ✅ | 黎曼梯度下降 |
| 情感状态更新 | ✅ | 规则引擎 + 自然衰减 |
| 生物节律控制 | ✅ | 自适应PID |
| 记忆存储检索 | ✅ | 本地向量数据库 |
| LLM对话生成 | 🔌 | OpenAI兼容API (可选) |

## 快速开始

### 环境要求
- Flutter SDK 3.0+
- Dart SDK 3.0+

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

## 工作模式

### 本地模式 (默认)
所有计算在本地完成，包括：
- 情感状态实时更新
- 记忆语义检索
- 生物节律演化
- 对话基于规则响应

### 联网模式 (可选)
配置LLM服务器后启用：
- 向量生成使用本地计算
- 语义分析使用本地计算
- 对话生成调用远程LLM
- 记忆检索使用本地向量索引

## 配置说明

```yaml
# 本地计算配置
local_computation:
  vector_dimension: 64
  memory_max_size: 1000
  emotion_decay_rate: 0.01
  bio_rhythm_enabled: true

# LLM配置 (可选)
llm:
  base_url: http://127.0.0.1:1234/v1
  api_key: lm-studio
  model_name: local-model
```

## 数据模型

### 情感光谱 (13维)
```
joy(喜悦) - sadness(悲伤)
anger(愤怒) - fear(恐惧)
surprise(惊讶) - disgust(厌恶)
trust(信任) - anticipation(期待)
love(爱) - regret(遗憾)
shame(羞愧) - guilt(内疚)
curiosity(好奇)
```

### 生物节律
- **energy**: 精力值 (0.0-1.0)
- **social**: 社交渴望 (0.0-1.0)
- **systemEntropy**: 系统熵值 (0.0-1.0)

## 开源协议

Apache License 2.0

## 参考项目

- [Nuwa](https://github.com/shierduan/Nuwa) - AI Agent 核心框架
