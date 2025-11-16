# ditttto™ DaaS MVP - Digital Identity Revolution

**Your World Perxonefied™** - Autonomous digital humans powered by UE5, NVIDIA NIM, and LangGraph AI.

## 🚀 Quick Start

### Prerequisites
- Node.js 22+
- pnpm
- Terraform (for deployment)
- GCP project
- Supabase project

### Installation
```bash
pnpm install
pnpm db:push
pnpm dev
```

Visit: http://localhost:3000

## 🎯 Features

### Animated Intro Sequence
- 4 rotating intro screens with gradient colors
- Marquee background with scrolling keywords
- Cold start masking (intro plays while app loads)
- Smooth hero reveal animation

### Chat Interface
- Real-time message history
- User/assistant differentiation
- Auto-scrolling messages
- Loading states
- Ready for LangGraph agent integration

### Technology Stack
- **Frontend**: React 19 + Tailwind 4 + TypeScript
- **Backend**: Express 4 + tRPC 11
- **Database**: Supabase (PostgreSQL)
- **Storage**: GCP Cloud Storage
- **Auth**: Google OAuth + Supabase
- **Streaming**: UE5 Pixel Streaming (4K@120)
- **AI**: NVIDIA NIM + LangGraph

## 📦 Project Structure

```
ditttto_daas_mvp/
├── client/
│   ├── src/
│   │   ├── components/
│   │   │   ├── AnimatedIntro.tsx      # Intro sequence
│   │   │   ├── ChatInterface.tsx      # Chat UI
│   │   │   └── ui/marquee.tsx         # Scrolling text
│   │   ├── pages/
│   │   │   └── Home.tsx               # Main page
│   │   └── App.tsx                    # Routes
│   └── index.html
├── server/
│   ├── routers.ts                     # tRPC procedures
│   ├── db.ts                          # Database helpers
│   └── _core/                         # Framework plumbing
├── drizzle/
│   └── schema.ts                      # Database schema
├── terraform/
│   └── supabase-gcp-deploy.tf        # Infrastructure as code
├── scripts/
│   └── deploy.sh                      # Deployment automation
└── config/
    └── ue5-4k120-streaming.ini        # UE5 config
```

## 🔧 Configuration

### Environment Variables
```env
SUPABASE_URL=https://hzbztruzroyqlvfhayrd.supabase.co
SUPABASE_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
GCP_PROJECT_ID=ditttto-daas-mvp
ADMIN_EMAIL=dev@thiccrobot.com
```

### Database Schema
- `users` - User accounts with roles
- `chat_history` - Agent conversation logs
- `files` - User file storage metadata
- `agent_sessions` - LangGraph session state

## 🚀 Deployment

### Using Terraform
```bash
# Initialize
./scripts/deploy.sh init

# Plan
./scripts/deploy.sh plan

# Deploy
./scripts/deploy.sh apply

# Check status
./scripts/deploy.sh status

# Destroy
./scripts/deploy.sh destroy
```

### What Gets Deployed
- ✅ Supabase PostgreSQL database
- ✅ GCP Cloud Storage bucket
- ✅ Google OAuth authentication
- ✅ Cloud Run containerized app
- ✅ Database schema with RLS policies
- ✅ Admin user (dev@thiccrobot.com)

### Manual Deployment
```bash
# Build
pnpm build

# Deploy to Cloud Run
gcloud run deploy ditttto-daas-mvp \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

## 🔐 Security

### Row-Level Security (RLS)
All tables have RLS policies enabled:
- Users can only view/edit their own data
- Chat history is user-scoped
- Files are user-owned

### Authentication
- Google OAuth via GCP Identity Platform
- Admin: dev@thiccrobot.com
- JWT tokens via Supabase

## 📊 Monitoring

### Cloud Run Logs
```bash
gcloud run logs read ditttto-daas-mvp --region us-central1
```

### Supabase Dashboard
- https://hzbztruzroyqlvfhayrd.supabase.co

### GCP Console
- https://console.cloud.google.com

## 🤖 LangGraph Agent Integration

Chat interface is ready for agent integration:

```typescript
// server/routers.ts
chat: protectedProcedure
  .input(z.object({ message: z.string() }))
  .mutation(async ({ ctx, input }) => {
    // TODO: Call LangGraph agent
    const response = await invokeLLM({
      messages: [{ role: 'user', content: input.message }]
    });
    return response;
  }),
```

## 🎬 UE5 Pixel Streaming

### 4K@120 Configuration
- Resolution: 3840x2160
- FPS: 120
- Codec: H.265 NVENC
- Bitrate: 25 Mbps
- Latency: <100ms

See `config/ue5-4k120-streaming.ini` for details.

## 📝 Development Workflow

1. **Update schema** → `pnpm db:push`
2. **Add procedures** → `server/routers.ts`
3. **Build UI** → `client/src/pages/`
4. **Test locally** → `pnpm dev`
5. **Deploy** → `./scripts/deploy.sh apply`

## 🐛 Troubleshooting

### App won't start
```bash
pnpm install
pnpm db:push
pnpm dev
```

### Database connection failed
- Check Supabase URL and API key
- Verify network access to Supabase

### Deployment fails
```bash
# Check Terraform state
./scripts/deploy.sh status

# Rollback
terraform destroy -auto-approve
./scripts/deploy.sh apply
```

## 📞 Support

- **GitHub**: https://github.com/thiccrobot/ditttto-daas-mvp
- **Admin Email**: dev@thiccrobot.com
- **Supabase**: https://hzbztruzroyqlvfhayrd.supabase.co

## 📄 License

thicc robot LLC © 2025

---

**ditttto™** - Your World Perxonefied™
