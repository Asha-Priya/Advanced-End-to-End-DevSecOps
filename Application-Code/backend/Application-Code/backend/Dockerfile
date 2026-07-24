# ---------- Build Stage ----------
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# ---------- Production Stage ----------
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app .

EXPOSE 3500

CMD ["npm", "start"]