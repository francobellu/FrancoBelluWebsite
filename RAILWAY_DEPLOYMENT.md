# Railway Deployment Instructions

## Quick Start Guide

### 1. Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with your GitHub account
3. Verify your email address

### 2. Deploy from GitHub

#### Option A: Railway Dashboard (Recommended)
1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose **"FrancoBelluWebsite"** repository
4. Railway will automatically detect the Dockerfile
5. Click **"Deploy Now"**

#### Option B: Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

### 3. Configure Environment Variables

In Railway dashboard, go to **Variables** tab and add:

```
ENVIRONMENT=production
VAPOR_ENV=production
PORT=8080
```

### 4. Custom Domain (Optional)

1. Go to **Settings** → **Domains**
2. Click **"Custom Domain"**
3. Enter your domain (e.g., `francobellu.com`)
4. Configure DNS records as shown

## Expected Build Process

Railway will:
1. 🔍 Detect your Dockerfile automatically
2. 🏗️ Build Swift container using multi-stage build
3. 📦 Create optimized production image
4. 🚀 Deploy to Railway's infrastructure
5. 🌐 Provide public URL

## Build Time

- **Initial Build**: ~3-5 minutes (Swift compilation)
- **Subsequent Builds**: ~2-3 minutes (Docker layer caching)

## Automatic Deployments

Once configured, Railway will automatically deploy when you:
- Push to `main` branch
- Merge pull requests to `main`

## Monitoring & Logs

### View Logs
1. Go to Railway dashboard
2. Click on your service
3. Go to **"Deployments"** tab
4. Click **"View Logs"** on latest deployment

### Monitor Usage
- **CPU/Memory**: Available in dashboard
- **Bandwidth**: Tracked for billing
- **Build Minutes**: Monitored for limits

## Cost Estimation

### Free Tier ($5 monthly credit)
- **Low Traffic Site**: Completely free
- **Resource Usage**: ~$0.50-2.00/month
- **Build Time**: Minimal impact

### Scaling Costs
- **CPU**: $0.000463 per vCPU-hour
- **Memory**: $0.000231 per GB-hour  
- **Network**: $0.10 per GB outbound

## Troubleshooting

### Build Failures

#### Swift Version Issues
If build fails with Swift version errors:
```dockerfile
# Update Dockerfile to use newer Swift version
FROM swift:5.9-slim as build
# ... rest of Dockerfile
FROM swift:5.9-slim-runtime
```

#### Dependency Resolution
```bash
# In Railway logs, look for:
error: failed to resolve dependencies
```
**Solution**: Ensure Package.swift dependencies are correctly specified

#### Memory Limits
```bash
# If build runs out of memory:
error: Killed (signal 9)
```
**Solution**: Contact Railway support to increase build memory

### Runtime Issues

#### Port Configuration
Ensure your app binds to `0.0.0.0:8080`:
```swift
// In configure.swift - already correct
app.http.server.configuration.port = 8080
app.http.server.configuration.hostname = "0.0.0.0"
```

#### File Path Issues
If templates not found:
```swift
// Verify in configure.swift
app.directory.viewsDirectory = app.directory.workingDirectory + "Resources/Views/"
app.directory.publicDirectory = app.directory.workingDirectory + "Public/"
```

#### Static Assets Not Loading
Check Dockerfile copies:
```dockerfile
COPY --from=build --chown=vapor:vapor /build/Public /app/Public
COPY --from=build --chown=vapor:vapor /build/Resources /app/Resources
```

### Performance Issues

#### Slow Response Times
1. Check Railway metrics in dashboard
2. Consider upgrading to more CPU/memory
3. Monitor database queries if added later

#### Cold Starts
- Railway keeps services warm on paid plans
- Free tier may have cold starts after inactivity

## Advanced Configuration

### Multiple Environments

#### Staging Environment
1. Create separate Railway service
2. Connect to `develop` branch
3. Use staging environment variables

#### Production Environment  
1. Use `main` branch
2. Set production environment variables
3. Configure custom domain

### Database Integration (Future)

When you need a database:
```bash
# In Railway dashboard
1. Click "New" → "Database" → "PostgreSQL"
2. Railway will provide connection string
3. Add to environment variables
```

### Secrets Management

For sensitive data:
1. **Never commit secrets to Git**
2. **Use Railway environment variables**
3. **Rotate secrets regularly**

## Health Checks

Railway automatically monitors:
- HTTP response codes
- Service availability
- Resource usage

## Backup Strategy

### Code Backup
- ✅ Git repository (already covered)
- ✅ Automatic GitHub backups

### Data Backup (if database added)
- Railway provides automated database backups
- Manual backups via Railway CLI

## Support & Resources

### Getting Help
- **Railway Discord**: Most responsive
- **Railway Docs**: Comprehensive guides
- **GitHub Issues**: For bug reports

### Useful Links
- [Railway Docs](https://docs.railway.app)
- [Swift on Railway](https://railway.app/deploy/swift)
- [Vapor Deployment Guide](https://docs.vapor.codes/deploy/)

---

## Next Steps After Deployment

1. ✅ **Test the live site**
2. ✅ **Configure custom domain** (optional)
3. ✅ **Set up monitoring alerts**
4. ✅ **Document the live URL**
5. ✅ **Celebrate!** 🎉

Your Franco Bellu personal website will be live and accessible worldwide!