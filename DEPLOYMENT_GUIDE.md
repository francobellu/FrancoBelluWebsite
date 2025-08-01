# Franco Bellu Website - Deployment Guide

## Overview

This guide covers deployment options and strategies for the Franco Bellu personal website built with Swift Vapor 4.76.0 and Leaf templating.

## Current App Structure

### ✅ Deployment-Ready Configuration
- **Framework**: Swift Vapor 4.76.0 with Leaf 4.2.4
- **Swift Version**: 5.9+
- **Platform**: macOS 12+
- **Containerization**: Docker-ready with multi-stage Dockerfile
- **Static Assets**: Organized in `/Public` directory
- **Templates**: Structured in `/Resources/Views`
- **Architecture**: Clean, containerized server-side rendering

### Key Files
- `Dockerfile` - Multi-stage container build configuration
- `Package.swift` - Swift Package Manager dependencies
- `Sources/App/configure.swift` - Application configuration
- `Public/` - Static assets (CSS, JS, images)
- `Resources/Views/` - Leaf templates

## Deployment Platform Comparison (2025)

### 🏆 Recommended: Railway

**Advantages:**
- ⭐ Excellent Swift/Vapor support with dedicated templates
- 💰 $5 free monthly credit (essentially free for personal sites)
- ⚡ Fast deployment process with GitHub integration
- 🔧 Automatic scaling and resource management
- 📦 Uses existing Dockerfile automatically
- 💳 Pay-per-use pricing model (pay for what you use)

**Best For:** Personal websites, prototypes, cost-conscious developers

### 🥈 Alternative: Render

**Advantages:**
- 🆓 Free tier available (with limitations)
- 🏗️ Modern infrastructure with Docker support
- 🔄 Pull request previews
- 🛡️ Built-in CDN and SSL certificates
- 👥 Production-ready features

**Limitations:**
- 📅 Free PostgreSQL databases deleted after 90 days
- ⏸️ Free services sleep after 15 minutes inactivity
- 💸 Can become expensive at scale ($25/mo for 2GB/1CPU)

**Best For:** Teams needing production features, predictable pricing

### ⚠️ Not Recommended: Heroku

**Why Not:**
- 💸 Expensive ($50+/month minimum)
- 🚫 No free tier (discontinued November 2022)
- ⚠️ Frequent outages (15+ hours in June 2025)
- 📈 Costs spiral quickly for production workloads

**Only Consider If:** Enterprise requirements, existing Heroku expertise

## Docker Requirements by Platform

### Do I Need Docker Installed Locally?

**Short Answer: NO** ❌

All modern PaaS platforms handle Docker builds on their servers:

| Platform | Local Docker Required | Build Location |
|----------|----------------------|----------------|
| Railway | ❌ No | Remote servers |
| Render | ❌ No | Remote servers |
| Heroku | ❌ No | Remote servers |
| Fly.io | ❌ No | Remote servers |
| DigitalOcean | ❌ No | Remote servers |

### When You WOULD Need Local Docker

#### 1. **Local Development & Testing**
```bash
# Test container locally before deployment
docker build -t franco-website .
docker run -p 8080:8080 franco-website
# Visit http://localhost:8080
```

**Benefits:**
- Catch build errors before production
- Test containerized environment locally
- Verify file paths and dependencies
- Debug without remote build delays

#### 2. **Debugging Docker Issues**
```bash
# Step-by-step build debugging
docker build --no-cache -t franco-website .

# Interactive container inspection
docker run -it franco-website /bin/bash

# Check logs and environment
docker logs <container-id>
docker run franco-website env
```

#### 3. **Multi-Service Development**
```yaml
# docker-compose.yml for local database
version: '3.8'
services:
  web:
    build: .
    ports: ["8080:8080"]
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: franco_website
```

#### 4. **Performance Optimization**
```bash
# Analyze image size and layers
docker history franco-website
docker images | grep franco-website

# Test different base images
docker build -t franco-website-optimized .
```

#### 5. **Custom CI/CD Pipelines**
```bash
# Multi-architecture builds
docker buildx build --platform linux/amd64,linux/arm64 -t franco-website .

# Custom registry deployment
docker build -t myregistry.com/franco-website .
docker push myregistry.com/franco-website
```

#### 6. **Advanced Debugging**
```bash
# Resource monitoring
docker stats franco-website

# Memory limit testing
docker run -m 512m franco-website

# Network troubleshooting
docker run --network none franco-website
```

### Current Recommendation

For the Franco Bellu website, **skip local Docker installation** because:

✅ Simple web application architecture
✅ Well-structured existing Dockerfile
✅ Railway handles remote building efficiently
✅ Fast deployment feedback loop
✅ No complex multi-service requirements

**Consider Docker later if:**
- Build failures occur on deployment platform
- Adding database or background services
- Performance debugging becomes necessary
- Contributing to open-source Swift server projects
- Need faster local development feedback

## Railway Deployment Strategy

### Why Railway is the Best Choice

1. **Swift-Specific**: Dedicated Vapor templates and deployment guides
2. **Cost-Effective**: $5/month free credit covers personal site hosting
3. **Zero-Config**: Automatic Docker build from existing Dockerfile
4. **GitHub Integration**: Automatic deployments on push
5. **Scaling**: Automatic resource scaling based on traffic
6. **Developer Experience**: Simple, intuitive dashboard and CLI

### Deployment Process Overview

1. **Connect GitHub Repository**: Link Franco Bellu Website repo
2. **Automatic Detection**: Railway detects Dockerfile automatically
3. **Environment Configuration**: Set production environment variables
4. **Domain Setup**: Configure custom domain (optional)
5. **Automated Deployments**: Push to main branch triggers deployment

### Expected Costs

- **Development/Low Traffic**: Free (within $5 monthly credit)
- **Production Traffic**: Pay-per-use for compute and bandwidth
- **Scaling**: Automatic based on demand

## Next Steps

1. ✅ Create Railway account
2. ✅ Connect GitHub repository
3. ✅ Configure environment variables
4. ✅ Deploy and test
5. ✅ Set up custom domain (optional)
6. ✅ Configure automated deployments

## Alternative Deployment Options

### If Railway Doesn't Meet Needs

**Choose Render if:**
- Need built-in background workers
- Require predictable monthly pricing
- Want enterprise-grade features

**Choose Fly.io if:**
- Performance is critical
- Global edge deployment needed
- Comfortable with more complex configuration

**Choose DigitalOcean App Platform if:**
- Cost optimization is primary concern
- Already using DigitalOcean ecosystem
- Need integration with existing DO services

## Troubleshooting Common Issues

### Build Failures
1. Check Swift version compatibility (currently 5.8 in Dockerfile)
2. Verify all dependencies are properly declared in Package.swift
3. Ensure Resources/ and Public/ directories are copied correctly

### Runtime Issues
1. Verify PORT environment variable configuration
2. Check file path configurations for templates and static assets
3. Ensure proper working directory settings

### Performance Issues
1. Monitor memory usage and adjust container limits
2. Optimize static asset delivery
3. Consider CDN for improved global performance

## Security Considerations

### Environment Variables
- Never commit secrets to repository
- Use platform environment variable management
- Rotate API keys and sensitive data regularly

### Container Security
- Regularly update Swift base images
- Use non-root user in container (already configured)
- Limit container resource usage

### Network Security
- Use HTTPS in production (automatic with Railway)
- Implement rate limiting if needed
- Monitor for suspicious traffic patterns

---

**Last Updated**: January 2025
**Next Review**: Deploy to Railway and update with real-world experience