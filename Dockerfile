# 1. Сборка статических файлов Quartz
FROM node:22-slim AS builder

WORKDIR /app

# Копируем только зависимости
COPY package.json package-lock.json ./
RUN npm ci

# Копируем исходный код и собираем Quartz
COPY . .
RUN npx quartz build

# 2. Финальный образ с nginx
FROM nginx:alpine

# Удаляем дефолтный html контент nginx
RUN rm -rf /usr/share/nginx/html/*

# Копируем собранную статику
COPY --from=builder /app/public /usr/share/nginx/html

# Добавляем кастомный nginx конфиг (по рекомендации из Quartz)
COPY nginx.conf /etc/nginx/nginx.conf

# Пробрасываем порт
EXPOSE 80

# Запускаем nginx в фореграунд
CMD ["nginx", "-g", "daemon off;"]
