---
date: <% tp.date.now("YYYY-MM-DD") %>
stack: mern-nextjs
estado: pendiente
prioridad: media
tipo: fullstack
tags: [proyecto, mern, nextjs, mongodb, finanzas]
type: project
---

# <% tp.file.title %> — Proyecto

## Descripción
App fullstack con Next.js (App Router) + MongoDB + Tailwind.

## Stack
- **Frontend:** Next.js 15 (App Router), TypeScript strict, TailwindCSS, Tremor, Recharts
- **Backend:** Next.js API Routes, Mongoose, Zod
- **DB:** MongoDB 7 (Docker)
- **Auth:** Sin auth (MVP) / NextAuth (futuro)

## Estado
- [ ] Scaffold y estructura base
- [ ] Modelos Mongoose
- [ ] API routes
- [ ] Frontend — Dashboard
- [ ] Frontend — CRUD
- [ ] Gráficos y reportes
- [ ] Semilla de datos

## Criterios de Éxito
- [ ] Dashboard funcional con estadísticas
- [ ] CRUD completo
- [ ] API routes con manejo de errores
- [ ] UI responsive y accesible

## Enlaces
- `~/workspace/projects/mern-nextjs/<% tp.file.title.toLowerCase().replace(/\s+/g, '-') %>`
