FROM node:18-alpine as builder
WORKDIR /app
COPY ./ ./
RUN npm install

FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/ ./ 
EXPOSE 3000
CMD ["npm", "start"]
