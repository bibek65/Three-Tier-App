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
  -e POSTGRES_DB=devops \
  -e POSTGRES_USER=devops_user \
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

# Create backend image with entrypoint

```
CMD ["./entrypoint.sh"]
```

```
docker build -t backend-app-wm:latest ./backend  

```

# Create backend image without entrypoint

```
CMD ["node", "src/server.js"]
```

```
docker build -t backend-app:latest ./backend  

```

# Create container with backend app

```
docker run -it --name backend-app --rm \
  -p 5001:5001 \
  backend-app:latest

```

### Try to open it from host in port 5001 it will not open in HOST

as we have expose the port in 5001 in host but the server will run on PORT 3001 as env is not provided in environment variable

```
docker run -it --name backend-app --rm \
  -p 5001:5001 \
  -e PORT=5001 \
  backend-app:latest

```

Now access from outside on ip:port

Let the PORT=5002 npm run dev keep on running

see what is the behaviour

Let's create a network

docker network create net1

docker network ls

### Database

```
docker run -itd --rm --name devops-postgres \
  --network net1 \
  -e POSTGRES_DB=devops \
  -e POSTGRES_USER=devops_user \
  -e POSTGRES_PASSWORD=devops1234 \
  -p 5432:5432 postgres:15-alpine
```

### Backend

```
docker run -it --name backend-app --rm \
  --network net1 \
  -p 5001:5001 \
  -e PORT=5001 \
  -e DATABASE_URL=postgresql://devops_user:devops1234@devops-postgres:5432/devops \
  backend-app-wm:latest

```

Access now
http://172.16.115.129:5001/api/users

Now make a POST request using ThunderClient

with body
{
  "name": "Bibek Labh",
  "email": "bkarna@gmail.com"
}

Now stop database and backend and restart again the data is gone

# Volumes

# Use volume

```
docker run -itd --rm --name devops-postgres \
  --network net1 \
  -e POSTGRES_DB=devops \
  -e POSTGRES_USER=devops_user \
  -e POSTGRES_PASSWORD=devops1234 \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine
```

docker run -it --name backend-app --rm 
  --network net1 
  -p 5001:5001 
  -e PORT=5001 
  -e DATABASE_URL="postgresql://devops_user:devops1234@devops-postgres:5432/devops" 
  backend-app-wm:latest

# Use local directory as bind volumes

Build frontend

docker build -t frontend-app .

```
# Run frontend container with bind volume for live development
docker run -itd --rm --name frontend-app \
  --network net1 \
  -p 8080:80 \
  -v ~/Three-Tier-App/frontend:/app \
  frontend-app:latest
```

# Build frontend locally first

cd frontend
npm run build
cd ..

docker run -it --rm --name frontend-app 
  --network net1 
  -p 8080:80 
  -v "$PWD/frontend/build":/usr/share/nginx/html 
  frontend-app:latest

Browser → http://localhost:8080/api/users
    ↓
nginx (frontend container)
    ↓
proxy_pass http://backend-app:5001
    ↓
Backend container (internal Docker network)
    ↓
Database container

# TMPFS VOlUME

# Create secrets file (DO NOT commit to git!)

```
cat > backend-secrets.env << 'EOF'
DATABASE_URL=postgresql://devops_user:devops_password@postgres-db:5432/devops
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key
EOF

# Secure the file
chmod 600 backend-secrets.env
```

```
# Run with tmpfs for secrets
docker run -d \
  --name backend-app-tmpfs \
  --network net1 \
  -p 5001:5001 \
  --tmpfs /run/secrets:size=1024m \
  -v $(pwd)/backend-secrets.env:/run/secrets/env:ro \
  backend-app:latest


# Write multiple files to reach 4GB
docker exec backend-app sh -c 'dd if=/dev/zero of=/run/secrets/test1 bs=1M count=1024'  # 1GB
docker exec backend-app sh -c 'dd if=/dev/zero of=/run/secrets/test2 bs=1M count=1024'  # 1GB
docker exec backend-app sh -c 'dd if=/dev/zero of=/run/secrets/test3 bs=1M count=1024'  # 1GB
docker exec backend-app sh -c 'dd if=/dev/zero of=/run/secrets/test4 bs=1M count=1024'  # 1GB

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

1. Bridge Network (Default) 🌉
   What it is: Creates a private internal network on your host. Containers can talk to each other, and Docker does NAT to access the internet.
   When to use: Default for most applications, microservices on single host

Host Machine (192.168.1.100)
    │
    ├─ docker0 bridge (172.17.0.1)
    │   │
    │   ├─ container1 (172.17.0.2)
    │   ├─ container2 (172.17.0.3)
    │   └─ container3 (172.17.0.4)
    │
    └─ Internet ←→ NAT ←→ containers

2. Host Network 🏠
   What it is: Container shares the host's network stack directly. No network isolation!
   When to use: Maximum performance, monitoring tools, network utilities

Host Machine (192.168.1.100)
    │
    └─ Container (uses host's 192.168.1.100 directly)
       No NAT, no bridge, no isolation!

Overlay Network ☁️
What it is: Multi-host networking for Docker Swarm. Containers on different machines can communicate!
When to use: Docker Swarm, distributed applications, microservices across hosts

Host 1 (192.168.1.10)          Host 2 (192.168.1.20)
    │                              │
    ├─ container1 ←─────┬─────→ ├─ container3
    │  (10.0.0.2)       │         │  (10.0.0.4)
    │                   │         │
    ├─ container2       │         ├─ container4
       (10.0.0.3)       │            (10.0.0.5)
                        │
                VXLAN Tunnel (overlay)
         (Encrypted cross-host communication)

None Network 🚫
What it is: No network at all! Complete isolation.
When to use: Maximum security, batch processing, testing

Container
    │
    └─ No network interface
       Can't access anything!

Your Host Machine (192.168.1.100)
    │
    ├─ eth0 (192.168.1.100) ← Host's real IP
    │
    └─ docker0 bridge (172.17.0.1) ← Virtual bridge
        │
        ├─ nginx container (172.17.0.2) ← Private IP
        │   Port 80 inside container
        │   │
        │   └─ NAT/Port Forward ─→ Host's port 8080
        │
        └─ Internet ←─ NAT ─→ Container

Access: curl http://192.168.1.100:8080  (goes through NAT to container's port 80)

Your Host Machine (192.168.1.100)
    │
    └─ eth0 (192.168.1.100) ← Container uses THIS directly!
        │
        └─ nginx container (uses host's 192.168.1.100)
            Port 80 ← Binds directly to host's port 80
            │
            └─ No NAT, No bridge, No translation!

Access: curl http://192.168.1.100:80  (direct access, no NAT!)

# Run nginx on bridge with port mapping

docker run -d --name nginx-bridge -p 9090:80 nginx

# Check container's IP

docker inspect nginx-bridge

# Output: 172.17.0.2  ← Private IP

# Check from host

curl http://localhost:9090  ✅ Works (port 9090 mapped to container's 80)
curl http://localhost:80    ❌ Fails (nothing on host's port 80)

# Check listening ports on host

netstat -tuln | grep 8080

# tcp  0.0.0.0:8080  ← Docker proxy listening

# What's happening:

# Request → Host:8080 → Docker proxy → NAT → Container:80

create custom-nginx.conf listens on a different port like 8081:

```
  server {
      listen 8081;
      server_name localhost;
      location / {
          root /usr/share/nginx/html;
          index index.html;
      }
  }

```

# Run nginx on host network (NO -p flag!)

  docker run -it \
    --name nginx-host \
    --network host \
    -v $(pwd)/custom-nginx.conf:/etc/nginx/conf.d/default.conf \
    nginx

# Check container's IP

docker inspect nginx-host

# Output: (empty) ← No separate IP!

# Container uses host's network stack directly

docker exec -it nginx-host /bin/sh

apt-get update
apt-get install -y iproute2

# Shows: 192.168.1.100 (same as host!)

# Check from host

curl http://localhost:8081    ✅ Works directly!
curl http://localhost:8080  ❌ Nothing (we didn't use -p, and it's ignored anyway)

# Check listening ports on host

netstat -tuln | grep 80

# tcp  0.0.0.0:80  ← nginx listening directly on host's port!

# What's happening:

# Request → Host:80 → nginx (no translation!)
