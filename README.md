# README

## Architecture

- **Frontend**: React.js
- **Backend**: Node.js API
- **Database**: PostgreSQL for data persistence

## Project Structure

```
├── backend/                 # Node.js API
│   ├── src/
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   └── server.js       # Express server
│   ├── Dockerfile
│   └── package.json
├── frontend/               # React application
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── services/       # API services
│   │   └── tests/          # Component tests
│   ├── Dockerfile
│   └── package.json
```

## Getting Started

### Prerequisites

- Node.js 20
- Docker
- PostgreSQL (for local development)
- npm

### Local Development

#### Start PostgreSQL Container (Docker)

```
docker run -itd --rm --name devops-postgres \
  -e POSTGRES_DB=devops_user \
  -e POSTGRES_USER=devops_password \
  -e POSTGRES_PASSWORD=devops1234 \
  -p 5432:5432 postgres:15-alpine
```

##### PostgreSQL Details

```
POSTGRES_DB=devops
POSTGRES_USER=devops
POSTGRES_PASSWORD=devops1234
POSTGRES_HOSTNAME=localhost
```

> **⚠️ Command: To Remove PostgreSQL Container**: Delete it before docker compose up --build -d :
>
> ```bash
> docker stop devops-postgres
> ```

1. **Start Backend**:

```bash
cd backend
npm install
npm run migrate           # Run database migrations
npm run dev              # Start with auto-migration
```

2. **Start Frontend**:

```bash
cd frontend
npm install
npm start
```

Docker/Local Development

> **⚠️ Windows Users Only**: Run this command first to fix line endings:
>
> ```bash
> dos2unix backend/entrypoint.sh
> ```

> **⚠️ Remove PostgreSQL Container**: if already exists :
>
> ```bash
> docker stop devops-postgres
> ```

```bash
docker compose up 
```

## Environment Variables

### Backend

```
PORT=3001
NODE_ENV=development
DATABASE_URL=postgresql://devops_user:devops_password@localhost:5432/devops
```

### Frontend

```
REACT_APP_API_URL=http://localhost:3001/api
```

# Volumes

# Use volume
```
docker run -itd --name --rm devops-postgres \
  -e POSTGRES_DB=devops \
  -e POSTGRES_USER=devops_user \
  -e POSTGRES_PASSWORD=devops1234 \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine
```


# Use local directory as bind volumes
```
mkdir -p ~/postgres-data

```

```
docker run -itd --rm --name devops-postgres \
  -e POSTGRES_DB=devops \
  -e POSTGRES_USER=devops_user \
  -e POSTGRES_PASSWORD=devops1234 \
  -p 5432:5432 \
  -v ~/postgres-data:/var/lib/postgresql/data \
  postgres:15-alpine
```



### EXIT STATUS

# Example 1: Success
ls /home
echo $?     # Prints: 0 (success)

# Example 2: Failure
ls /fake/dir
echo $?     # Prints: 2 (error - no such file)

# Example 3: Node.js crash
node broken.js
echo $?     # Prints: 1 (error - node exited with error)

## Docker Network Demonstration

This section demonstrates how Docker networking works by showing database connection failure and success.

### Step 1: Build the Backend Docker Image

```bash
docker build -t backend-app:latest ./backend
```

### Step 2: Run WITHOUT Network (Show Connection Failure)

Run the container with environment variables but no custom network. The container will try to connect to `localhost:5432` which will fail:

```bash
docker run --name backend-test \
  -p 5001:5001 \
  -e DATABASE_URL="postgresql://devops_user:devops_password@localhost:5432/devops" \
  backend-app:latest
```

**Expected Result:** You'll see errors like:
- ❌ Connection refused or database connection errors
- The entrypoint script will fail during migrations because it can't reach the database

To stop and remove this container:

```bash
docker stop backend-test && docker rm backend-test
```

### Step 3: Create a Custom Docker Network

```bash
docker network create three-tier-network
```

### Step 4: Run PostgreSQL Database on the Network

```bash
docker run -d \
  --name postgres-db \
  --network three-tier-network \
  -e POSTGRES_USER=devops_user \
  -e POSTGRES_PASSWORD=devops_password \
  -e POSTGRES_DB=devops \
  -p 5432:5432 \
  postgres:15-alpine
```

### Step 5: Run Backend WITH Network (Show Successful Connection)

Now run the backend container on the same network, using the PostgreSQL container name as the hostname:

```bash
docker run --name backend-app \
  --network three-tier-network \
  -p 5001:5001 \
  -e DATABASE_URL="postgresql://devops_user:devops_password@postgres-db:5432/devops" \
  backend-app:latest
```

