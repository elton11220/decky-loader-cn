# decky-loader-cn

A simple mirror repository with accelerated access for decky-loader installation

## Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                 End Users (Chinese mainland)                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    Request resources
                         │
        ┌────────────────┴────────────────┐
        ▼                                 ▼
   ┌─────────────┐            ┌──────────────────┐
   │ Cloudflare  │            │   Vercel API     │
   │    CDN      │◄──────────►│   (origin)       │
   └─────────────┘            └──────────────────┘
     (CDN Layer)                 (Service Layer)
                         │
          ┌──────────────┴──────────────┐
          ▼                             ▼
    ┌─────────────────┐          ┌──────────────┐
    │ decky-loader-cn │          │ Timing Sync  │
    │ repo            │◄─────────│  (GitHub CI) │
    └─────────────────┘          └──────────────┘
          │
          └──► Files synchronized from the official repository::
              - PluginLoader binary file
              - plugin_loader.service
```

## Usage