# Dify Helm Chart for Azure Kubernetes Service (AKS)

[English](README.md#english) | [中文](README.md#chinese)

---

## <a name="chinese"></a>中文版本

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
  # 主机配置
  # 支持两种配置方式：
  # 1. IP 地址：适用于内网访问，如 "10.104.179.207"
  # 2. 域名：适用于公网访问，如 "dify.your-domain.com"
  # 注意：使用域名时需要确保 DNS 解析正确，并配置相应的 TLS 证书
  host: "10.104.179.207"  # 使用前端LoadBalancer IP作为主机名
  
  # 端口配置
  # 通常不需要设置，使用默认端口
  # 如需自定义端口，请确保与 LoadBalancer 配置一致
  port: ""  # 不需要设置端口
  
  # TLS 配置
  # - false: 适用于内网访问或 HTTP 访问
  # - true: 适用于公网访问，需要配置 TLS 证书
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

**强烈推荐使用外部安全存储服务**：

- **数据库**：使用 Azure Database for PostgreSQL 或 Azure Database for MySQL
  - 提供自动备份和恢复
  - 内置安全性和合规性
  - 自动扩展和高可用性
  - 托管维护和更新

- **对象存储**：使用 Azure Blob Storage 或 Azure Files
  - 提供数据冗余和灾难恢复
  - 内置加密和访问控制
  - 自动扩展存储容量
  - 成本效益更高

- **缓存**：使用 Azure Cache for Redis
  - 提供高性能缓存服务
  - 内置安全性和监控
  - 自动扩展和故障转移

使用外部存储的优势：
1. **数据安全**：专业的数据保护和备份策略
2. **高可用性**：99.9%+ 的服务可用性保证
3. **自动扩展**：根据需求自动调整资源
4. **成本优化**：按使用量付费，避免资源浪费
5. **运维简化**：减少运维负担，专注于应用开发

配置示例：
```yaml
# 禁用内置数据库，使用外部 PostgreSQL
postgresql:
  enabled: false

# 禁用内置 Redis，使用外部 Redis
redis:
  enabled: false

# 禁用内置 MinIO，使用外部存储
minio:
  enabled: false

# 配置外部存储连接信息
global:
  extraBackendEnvs:
  - name: DB_HOST
    value: "your-postgresql-server.postgres.database.azure.com"
  - name: DB_PORT
    value: "5432"
  - name: DB_DATABASE
    value: "dify"
  - name: DB_USERNAME
    value: "dify_user"
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: DB_PASSWORD
  - name: REDIS_HOST
    value: "your-redis-server.redis.cache.windows.net"
  - name: REDIS_PORT
    value: "6380"
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: REDIS_PASSWORD
  - name: S3_ENDPOINT
    value: "https://your-storage-account.blob.core.windows.net"
  - name: S3_BUCKET_NAME
    value: "dify-storage"
  - name: S3_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: S3_ACCESS_KEY
  - name: S3_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: S3_SECRET_KEY
```

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

---

## <a name="english"></a>English Version

This is a Helm Chart for deploying [Dify](https://github.com/langgenius/dify) on Azure Kubernetes Service (AKS). Dify is an open-source LLM application development platform, and this Helm Chart aims to simplify its deployment and management in Kubernetes environments.

## Features

- 🚀 One-click deployment of complete Dify platform to AKS
- 🔒 Built-in security configuration and secret management
- 🔄 CI/CD automation deployment support
- 📦 Includes all necessary dependencies (Redis, PostgreSQL, MinIO, etc.)
- 🔍 Multiple vector database options (Weaviate, Qdrant)

## System Architecture

This Helm Chart deploys the Dify platform with the following core components:

- **Frontend**: Dify's web interface
- **API Server**: Backend API service
- **Worker**: Asynchronous task processing service
- **PostgreSQL**: Main database (v12.1.6)
- **Redis**: Cache and message queue (v18.1.2)
- **MinIO**: Object storage service (v12.8.7)
- **Vector Database**: Vector database (supports Weaviate v16.3.0 or Qdrant v0.7.0)

## Quick Start

### Prerequisites

- Azure Kubernetes Service (AKS) cluster
- Azure DevOps account (for CI/CD)
- Helm 3.x
- kubectl configuration

### Installation Steps

1. Create a custom values file:

```yaml
global:
  # Host configuration
  # Supports two configuration methods:
  # 1. IP address: For internal network access, e.g., "10.104.179.207"
  # 2. Domain name: For public network access, e.g., "dify.your-domain.com"
  # Note: When using domain names, ensure DNS resolution is correct and configure TLS certificates
  host: "10.104.179.207"  # Use frontend LoadBalancer IP as hostname
  
  # Port configuration
  # Usually no need to set, use default port
  # If custom port is needed, ensure it matches LoadBalancer configuration
  port: ""  # No need to set port
  
  # TLS configuration
  # - false: For internal network access or HTTP access
  # - true: For public network access, requires TLS certificate configuration
  enableTLS: false  # Internal network access doesn't need TLS
  
  image:
    tag: "1.4.1"  # Currently supported Dify version
  
  edition: "SELF_HOSTED"
  storageType: "s3"  # Use S3 storage

  # Additional environment variables configuration
  extraBackendEnvs:
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: SECRET_KEY
  - name: VECTOR_STORE
    value: "weaviate"  # or "qdrant"

# Component configuration
postgresql:
  enabled: true
  # PostgreSQL configuration...

redis:
  enabled: true
  # Redis configuration...

minio:
  enabled: true
  # MinIO configuration...

weaviate:
  enabled: true
  # Weaviate configuration...

qdrant:
  enabled: false
  # Qdrant configuration...
```

2. Push Helm Chart to Azure DevOps repository and execute Pipeline:

```bash
# Push Helm Chart to Azure DevOps repository
git add .
git commit -m "feat: update Dify Helm Chart configuration"
git push origin main

# Pipeline will automatically execute the following steps:
# 1. Create Kubernetes namespace
# 2. Generate and create necessary secrets
# 3. Update Helm dependencies
# 4. Deploy Dify application
# 5. Verify deployment status
# 6. Wait for services to be ready
```

After Pipeline execution completes, you will see output similar to:
```
================================================
Dify deployment completed!
Frontend access address: http://10.104.179.207
================================================
```

## Version Information

- Chart version: 0.1.0
- Dify application version: 1.4.1
- Dependency versions:
  - Redis: 18.1.2
  - PostgreSQL: 12.1.6
  - MinIO: 12.8.7
  - Weaviate: 16.3.0
  - Qdrant: 0.7.0

## CI/CD Configuration

This project includes Azure DevOps Pipeline configuration (`azure-pipeline-helm.yaml`) that supports automated deployment. Main features include:

- Automatic namespace creation
- Secret generation and management
- Helm dependency updates
- Application deployment
- Deployment status verification
- Service health checks

### Pipeline Variable Configuration

Configure the following variables in Azure DevOps:

```yaml
azureSubscriptionEndpoint: 'your-azure-subscription'
azureResourceGroup: 'your-resource-group'
kubernetesCluster: 'your-aks-cluster'
namespace: 'dify'
helmReleaseName: 'dify'
```

## Production Environment Configuration Recommendations

### 1. Security Configuration

- Use Kubernetes Secrets to manage sensitive information
- Configure appropriate resource limits and requests
- Enable network policies
- Regularly update keys and certificates

### 2. Storage Configuration

**Strongly recommend using external secure storage services**:

- **Database**: Use Azure Database for PostgreSQL or Azure Database for MySQL
  - Provides automatic backup and recovery
  - Built-in security and compliance
  - Auto-scaling and high availability
  - Managed maintenance and updates

- **Object Storage**: Use Azure Blob Storage or Azure Files
  - Provides data redundancy and disaster recovery
  - Built-in encryption and access control
  - Auto-scaling storage capacity
  - Better cost efficiency

- **Cache**: Use Azure Cache for Redis
  - Provides high-performance caching service
  - Built-in security and monitoring
  - Auto-scaling and failover

Benefits of using external storage:
1. **Data Security**: Professional data protection and backup strategies
2. **High Availability**: 99.9%+ service availability guarantee
3. **Auto-scaling**: Automatically adjust resources based on demand
4. **Cost Optimization**: Pay-as-you-use, avoid resource waste
5. **Simplified Operations**: Reduce operational burden, focus on application development

Configuration example:
```yaml
# Disable built-in database, use external PostgreSQL
postgresql:
  enabled: false

# Disable built-in Redis, use external Redis
redis:
  enabled: false

# Disable built-in MinIO, use external storage
minio:
  enabled: false

# Configure external storage connection information
global:
  extraBackendEnvs:
  - name: DB_HOST
    value: "your-postgresql-server.postgres.database.azure.com"
  - name: DB_PORT
    value: "5432"
  - name: DB_DATABASE
    value: "dify"
  - name: DB_USERNAME
    value: "dify_user"
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: DB_PASSWORD
  - name: REDIS_HOST
    value: "your-redis-server.redis.cache.windows.net"
  - name: REDIS_PORT
    value: "6380"
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: REDIS_PASSWORD
  - name: S3_ENDPOINT
    value: "https://your-storage-account.blob.core.windows.net"
  - name: S3_BUCKET_NAME
    value: "dify-storage"
  - name: S3_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: S3_ACCESS_KEY
  - name: S3_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: dify-secrets
        key: S3_SECRET_KEY
```

### 3. High Availability Configuration

- Configure multiple replicas
- Use Pod anti-affinity
- Configure appropriate resource limits
- Use persistent storage

### 4. Monitoring and Logging

- Configure appropriate log levels
- Set up resource usage alerts
- Monitor service health status
- Regularly check system logs

## Maintenance and Upgrade

### Version Upgrade

1. Update image version in `values.yaml`
2. Execute Helm upgrade
3. Run database migration

```bash
helm upgrade dify dify-helm/dify -f values.yaml
kubectl exec -it $(kubectl get pod -l app.kubernetes.io/component=api -o jsonpath='{.items[0].metadata.name}') \
  -n dify -- flask db upgrade
```

### Backup and Recovery

- Regularly backup PostgreSQL database
- Backup MinIO storage data
- Save Helm values configuration

## Troubleshooting

Common issues and solutions:

1. Pod startup failure
   - Check resource limits
   - Verify environment variable configuration
   - View Pod logs

2. Database connection issues
   - Verify database credentials
   - Check network policies
   - Confirm database service status

3. Storage access issues
   - Check storage class configuration
   - Verify access credentials
   - Confirm storage service status

## Contributing

Welcome to submit Pull Requests or create Issues. Before submitting code, please ensure:

1. Follow Helm Chart best practices
2. Update version numbers
3. Add necessary documentation
4. Pass all tests

## License

This project is licensed under Apache License 2.0. See [LICENSE](LICENSE) file for details.

## Related Links

- [Dify Official Documentation](https://docs.dify.ai)
- [Helm Documentation](https://helm.sh/docs)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/azure/aks)
- [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops)
