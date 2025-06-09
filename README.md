# Dify Helm Chart for Azure Kubernetes Service (AKS)

这是一个用于在 Azure Kubernetes Service (AKS) 上部署 [Dify](https://github.com/langgenius/dify) 的 Helm Chart。Dify 是一个开源的 LLM 应用开发平台，本 Helm Chart 旨在简化其在 Kubernetes 环境中的部署和管理。

## 项目特点

- 🚀 一键部署完整的 Dify 平台到 AKS
- 🔒 内置安全配置和密钥管理
- 🔄 支持 CI/CD 自动化部署
- 📦 包含所有必要的依赖组件（Redis、PostgreSQL、MinIO 等）
- 🔍 支持多种向量数据库选项（Weaviate、Qdrant、Milvus）
- 🌐 灵活的存储配置（支持 S3、Google Cloud Storage 等）

## 系统架构

本 Helm Chart 部署的 Dify 平台包含以下核心组件：

- **Frontend**: Dify 的 Web 界面
- **API Server**: 后端 API 服务
- **Worker**: 异步任务处理服务
- **PostgreSQL**: 主数据库
- **Redis**: 缓存和消息队列
- **MinIO**: 对象存储服务
- **Vector Database**: 向量数据库（支持 Weaviate/Qdrant/Milvus）

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
  host: "your-dify-domain.com"
  enableTLS: true  # 生产环境建议启用 TLS

  image:
    tag: "0.6.3"  # 使用最新的稳定版本

  extraBackendEnvs:
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: SECRET_KEY
  - name: VECTOR_STORE
    value: "weaviate"  # 或 "qdrant" 或 "milvus"

ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod

# 存储配置
minio:
  embedded: false  # 生产环境建议使用外部存储
```

2. 使用 Helm 安装：

```bash
# 添加 Helm 仓库
helm repo add dify-helm https://your-helm-repo-url

# 安装/更新
helm upgrade dify dify-helm/dify \
  -f values.yaml \
  --install \
  --namespace dify \
  --create-namespace
```

3. 执行数据库迁移：

```bash
kubectl exec -it $(kubectl get pod -l app.kubernetes.io/component=api -o jsonpath='{.items[0].metadata.name}') \
  -n dify -- flask db upgrade
```

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

- 使用 Azure Key Vault 管理敏感信息
- 启用 TLS 加密
- 配置网络策略
- 使用 Azure AD 集成进行身份验证

### 2. 存储配置

推荐使用 Azure 托管服务：

- Azure Database for PostgreSQL
- Azure Cache for Redis
- Azure Blob Storage 或 Azure Files

### 3. 高可用配置

- 配置 Pod 反亲和性
- 使用 Azure 托管磁盘
- 配置适当的资源限制
- 设置自动扩缩容

### 4. 监控和日志

- 集成 Azure Monitor
- 配置 Prometheus 和 Grafana
- 设置日志收集和分析

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
