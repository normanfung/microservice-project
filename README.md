# microservice-project


# 🐳 Build and Push Microservices to Amazon ECR

This GitHub Actions workflow automates the process of building Docker images for microservices, scanning them for vulnerabilities, and pushing them to Amazon Elastic Container Registry (ECR). It supports partial builds (based on code changes) or full builds (rebuild all services).

## 🚀 Workflow Features

- Detects changed services using [`dorny/paths-filter`](https://github.com/dorny/paths-filter)
- Supports manual trigger via `workflow_dispatch`
- Supports full or partial builds using an input flag
- Builds and tags Docker images with Git commit SHA
- Scans images using Trivy for critical and high vulnerabilities
- Pushes images to Amazon ECR with:
  - SHA-based tag (short SHA)
  - Environment-based tag (e.g., `dev`, `stage`, `main`)

---

## 🧾 Inputs (via `workflow_dispatch`)

| Name           | Description                      | Required | Default | Options             |
|----------------|----------------------------------|----------|---------|---------------------|
| `environment`  | Target deployment environment    | ✅ Yes   | `dev`   | `dev`, `stage`, `main` |
| `full_build`   | Build all services               | ❌ No    | `false` | `true`, `false`     |

---

## ⚙️ Workflow Logic

### 1. `detect-changes-in-service` Job
- Checks out the repo.
- Uses `dorny/paths-filter` to detect which services have changed (unless `full_build` is `true`).
- Outputs a JSON array of changed services.

> Example output:
> ```json
> ["cartservice", "paymentservice"]
> ```

### 2. `build-scan-and-push` Job
- Runs only if services changed.
- Loops through each changed service using a matrix strategy.
- For each service:
  - Builds the Docker image.
  - Tags it with short Git SHA (first 7 characters).
  - Scans it using Trivy.
  - Pushes to ECR with:
    - `short_sha` tag: `ecr_repo:abcdef1`
    - `environment` tag: `ecr_repo:dev` (or `stage`, `main`)

---

## 📁 Project Structure Expectations

The workflow expects each microservice to be in this structure:

src/
├── cartservice/
│ └── src/ # Special case for Docker build context
├── adservice/
│ └── Dockerfile
...

yaml
Copy
Edit

Special handling is included for `cartservice` to build from `src/cartservice/src/`.

---

## 🔐 Secrets & Variables

| Key                   | Type    | Description                       |
|------------------------|---------|-----------------------------------|
| `AWS_ACCESS_KEY_ID`   | Secret  | AWS IAM access key                |
| `AWS_SECRET_ACCESS_KEY` | Secret | AWS IAM secret                    |
| `AWS_REGION`          | Variable | AWS region (e.g., `us-west-2`)    |
| `ECR_REGISTRY`        | Variable | ECR registry URI (no trailing `/`) |

---

## 📦 Example Usage

To manually run the workflow:
1. Go to the **Actions** tab.
2. Select **"Build and Push Microservices to ECR"**.
3. Click **"Run workflow"**.
4. Choose:
   - Environment: `dev`, `stage`, or `main`
   - Full build: `true` to build all, `false` to build only changed services.

---

## 🛡 Security

Images are scanned before being pushed to ECR using [Trivy](https://github.com/aquasecurity/trivy-action). Only images with known `CRITICAL` or `HIGH` severity vulnerabilities will be reported.

---

## 📬 Outputs

Images will be available in your ECR under:

> Example output:
> ```json
> <AWS_ACC_ID>.dkr.ecr.us-east-1.amazonaws.com/adservice:latest
> <AWS_ACC_ID>.dkr.ecr.us-east-1.amazonaws.com/cartservice:latest
> ```

---

## 🧼 Tips & Troubleshooting

- Ensure your AWS credentials have permission for ECR (push, login).
- Use the `Debug matrix input` step to verify changed services.
- To force rebuilds, use `full_build: true`.

---

Happy shipping 🚢