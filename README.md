# Dify Helm Chart for Azure Kubernetes Service (AKS)

这是一个用于在 Azure Kubernetes Service (AKS) 上部署 [Dify](https://github.com/langgenius/dify) 的 Helm Chart。Dify 是一个开源的 LLM 应用开发平台，本 Helm Chart 旨在简化其在 Kubernetes 环境中的部署和管理。

## 项目特点

- 🚀 一键部署完整的 Dify 平台到 AKS
- 🔒 内置安全配置和密钥管理
- 🔄 支持 CI/CD 自动化部署
- 📦 包含所有必要的依赖组件（Redis、PostgreSQL、MinIO 等）
- 🔍 支持多种向量数据库选项（Weaviate、Qdrant）

## 系统架构

本 Helm Chart 部署的 Dify 平台包含以下核心组件：

- **Frontend**: Dify 的 Web 界面
- **API Server**: 后端 API 服务
- **Worker**: 异步任务处理服务
- **PostgreSQL**: 主数据库 (v12.1.6)
- **Redis**: 缓存和消息队列 (v18.1.2)
- **MinIO**: 对象存储服务 (v12.8.7)
- **Vector Database**: 向量数据库（支持 Weaviate v16.3.0 或 Qdrant v0.7.0）

## 快速开始

### 前置条件

- Azure Kubernetes Service (AKS) 集群
- Azure DevOps 账号（用于 CI/CD）
- Helm 3.x
- kubectl 配置

### 安装步骤

1. 创建自定义的 values 文件：

```yaml
global:
  # 使用 LoadBalancer IP 作为主机名（内网访问）
  host: "10.104.179.207"
  port: ""  # 不需要设置端口
  enableTLS: false  # 内网访问不需要 TLS
  
  image:
    tag: "1.4.1"  # 当前支持的 Dify 版本
  
  edition: "SELF_HOSTED"
  storageType: "s3"  # 使用 S3 存储

  # 额外的环境变量配置
  extraBackendEnvs:
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: SECRET_KEY
  - name: VECTOR_STORE
    value: "weaviate"  # 或 "qdrant"

# 组件配置
postgresql:
  enabled: true
  # PostgreSQL 配置...

redis:
  enabled: true
  # Redis 配置...

minio:
  enabled: true
  # MinIO 配置...

weaviate:
  enabled: true
  # Weaviate 配置...

qdrant:
  enabled: false
  # Qdrant 配置...
```

2. 推送 Helm Chart 到 Azure DevOps 仓库并执行 Pipeline：

```bash
# 将 Helm Chart 推送到 Azure DevOps 仓库
git add .
git commit -m "feat: update Dify Helm Chart configuration"
git push origin main

# Pipeline 将自动执行以下步骤：
# 1. 创建 Kubernetes 命名空间
# 2. 生成并创建必要的密钥
# 3. 更新 Helm 依赖
# 4. 部署 Dify 应用
# 5. 验证部署状态
# 6. 等待服务就绪
```

Pipeline 执行完成后，您将看到类似以下的输出：
```
================================================
Dify 部署完成！
前端访问地址: http://10.104.179.207
================================================
```

## 版本信息

- Chart 版本：0.1.0
- Dify 应用版本：1.4.1
- 依赖组件版本：
  - Redis: 18.1.2
  - PostgreSQL: 12.1.6
  - MinIO: 12.8.7
  - Weaviate: 16.3.0
  - Qdrant: 0.7.0

## CI/CD 配置

本项目包含 Azure DevOps Pipeline 配置（`azure-pipeline-helm.yaml`），支持自动化部署。主要功能包括：

- 自动创建命名空间
- 生成并管理密钥
- 更新 Helm 依赖
- 部署应用
- 验证部署状态
- 服务健康检查

### Pipeline 变量配置

在 Azure DevOps 中配置以下变量：

```yaml
azureSubscriptionEndpoint: 'your-azure-subscription'
azureResourceGroup: 'your-resource-group'
kubernetesCluster: 'your-aks-cluster'
namespace: 'dify'
helmReleaseName: 'dify'
```

## 生产环境配置建议

### 1. 安全配置

- 使用 Kubernetes Secrets 管理敏感信息
- 配置适当的资源限制和请求
- 启用网络策略
- 定期更新密钥和证书

### 2. 存储配置

- 使用外部存储服务（如 Azure Blob Storage）
- 配置适当的存储类
- 设置存储大小限制
- 定期备份数据

### 3. 高可用配置

- 配置多个副本
- 使用 Pod 反亲和性
- 配置适当的资源限制
- 使用持久化存储

### 4. 监控和日志

- 配置适当的日志级别
- 设置资源使用告警
- 监控服务健康状态
- 定期检查系统日志

## 维护和升级

### 版本升级

1. 更新 `values.yaml` 中的镜像版本
2. 执行 Helm 升级
3. 运行数据库迁移

```bash
helm upgrade dify dify-helm/dify -f values.yaml
kubectl exec -it $(kubectl get pod -l app.kubernetes.io/component=api -o jsonpath='{.items[0].metadata.name}') \
  -n dify -- flask db upgrade
```

### 备份和恢复

- 定期备份 PostgreSQL 数据库
- 备份 MinIO 存储数据
- 保存 Helm values 配置

## 故障排除

常见问题及解决方案：

1. Pod 启动失败
   - 检查资源限制
   - 验证环境变量配置
   - 查看 Pod 日志

2. 数据库连接问题
   - 验证数据库凭证
   - 检查网络策略
   - 确认数据库服务状态

3. 存储访问问题
   - 检查存储类配置
   - 验证访问凭证
   - 确认存储服务状态

## 贡献指南

欢迎提交 Pull Request 或创建 Issue。在提交代码前，请确保：

1. 遵循 Helm Chart 最佳实践
2. 更新版本号
3. 添加必要的文档
4. 通过所有测试

## 许可证

本项目采用 Apache License 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

## 相关链接

- [Dify 官方文档](https://docs.dify.ai)
- [Helm 文档](https://helm.sh/docs)
- [Azure Kubernetes Service 文档](https://docs.microsoft.com/azure/aks)
- [Azure DevOps 文档](https://docs.microsoft.com/azure/devops)
