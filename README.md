<div align="center">
  <h1>Simple Drive</h1>
  <p><strong>Secure, flexible blob storage API with multiple backend options</strong></p>
  
  <p>
    <img src="https://img.shields.io/badge/rails-7.1.5-red" alt="Rails 7.1.5">
    <img src="https://img.shields.io/badge/ruby-2.7.5-red" alt="Ruby 2.7.5">
    <img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT">
  </p>
  
  <p>
    <a href="#features">Features</a> •
    <a href="#installation">Installation</a> •
    <a href="#configuration">Configuration</a> •
    <a href="#api-usage">API Usage</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#testing">Testing</a>
  </p>
</div>

---

## Overview

Simple Drive is a Ruby on Rails API service that provides secure, scalable binary data (blob) storage and retrieval capabilities. It's designed for flexibility with multiple storage backend options and robust JWT-based authentication, making it ideal for applications that need reliable and adaptable file storage.

## Features

<table>
  <tr>
    <td width="33%">
      <h3>🗄️ Blob Storage</h3>
      <ul>
        <li>Store blobs with POST <code>/v1/blobs</code></li>
        <li>Retrieve blobs with GET <code>/v1/blobs/:id</code></li>
        <li>Metadata tracking (id, size, creation date)</li>
      </ul>
    </td>
    <td width="33%">
      <h3>🔐 Authentication</h3>
      <ul>
        <li>JWT token-based authentication</li>
        <li>Secure token validation</li>
        <li>Configurable token expiration</li>
      </ul>
    </td>
    <td width="33%">
      <h3>🛠️ Error Handling</h3>
      <ul>
        <li>Standardized error codes</li>
        <li>Localized error messages</li>
        <li>Secure information handling</li>
      </ul>
    </td>
  </tr>
</table>

### Storage Backends

Simple Drive supports multiple storage options that can be configured via environment variables:

- **📁 Local File System**: Perfect for development and testing
- **💾 Database**: Store blobs directly in PostgreSQL for simplicity
- **☁️ Amazon S3**: Scale with cloud storage (implemented with raw HTTP, no SDK required)
- **📡 FTP Server**: Connect to legacy or remote storage systems
- **🧩 Extensible**: Architecture designed for adding new providers

## Prerequisites

- **Ruby**: 2.7.5 or higher
- **Rails**: 7.x
- **Database**: PostgreSQL
- **Optional**: FTP server (only for FTP storage backend)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/simple_drive.git
cd simple_drive
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Configure Environment Variables

Create a `.env` file in the project root (use `.env.example` as a template):

```bash
JWT_SECRET=your-secure-secret-key
STORAGE_BACKEND=file  # Options: file, database, s3, ftp
```

### 4. Set Up the Database

```bash
bin/rails db:setup  # Creates, migrates, and seeds the database
```

Alternatively, to reset an existing database:

```bash
bin/rails db:drop db:create db:migrate db:seed
```

### 5. Start the Server

```bash
bin/rails server
```

The API will be available at http://localhost:3000

## Configuration

### Environment Configuration

Simple Drive uses a `.env` file for all configuration settings. Below is a sample configuration with all available options:

```bash
# Simple Drive Environment Configuration

# JWT Authentication
JWT_SECRET=your-secure-secret-key

# Storage backend: 'file', 'database', 's3', or 'ftp'
STORAGE_BACKEND=s3

# Local File Storage Configuration (only needed if STORAGE_BACKEND=file)
STORAGE_PATH=/path/to/storage/directory

# S3 Storage Configuration (only needed if STORAGE_BACKEND=s3)
S3_BUCKET_NAME=your-bucket-name
AWS_REGION=your-aws-region
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key

# FTP Storage Configuration (only needed if STORAGE_BACKEND=ftp) 
FTP_HOST=your-ftp-host
FTP_USERNAME=your-username
FTP_PASSWORD=your-password
FTP_DIRECTORY=/remote/directory
FTP_PORT=21
FTP_PASSIVE=true

# MySQL Database Configuration
DB_USERNAME=your-db-username
DB_PASSWORD=your-db-password
DB_HOST=your-db-host
DB_PORT=3306
DB_NAME=your-db-name
```

### Storage Backends

<details open>
<summary><strong>📁 File System Storage</strong></summary>

To use local file system storage:

```bash
STORAGE_BACKEND=file
STORAGE_PATH=/path/to/storage/directory
```

This option stores files directly on your server's file system.
</details>

<details>
<summary><strong>💾 Database Storage</strong></summary>

To store blobs in your MySQL database:

```bash
STORAGE_BACKEND=database  # or db
```

With this option, blob content is stored directly in the database table `blob_binary_storages`.
</details>

<details>
<summary><strong>☁️ Amazon S3 Storage</strong></summary>

For Amazon S3 or compatible services:

```bash
STORAGE_BACKEND=s3
S3_BUCKET_NAME=simple-drive-uploads
AWS_REGION=eu-north-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

This is recommended for production deployments for better scalability.
</details>

<details>
<summary><strong>📡 FTP Storage</strong></summary>

For using an FTP server as storage backend:

```bash
STORAGE_BACKEND=ftp
FTP_HOST=your-ftp-host
FTP_USERNAME=your-username
FTP_PASSWORD=your-password
FTP_DIRECTORY=/ftpfiles
FTP_PORT=21
FTP_PASSIVE=true
```

This option is useful for integrating with existing FTP-based systems.
</details>

### Database Configuration

Simple Drive uses MySQL as its database:

```bash
DB_USERNAME=root
DB_PASSWORD=your-db-password
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=simple_drive_development
```

## API Usage

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/tokens` | POST | Generate JWT authentication token |
| `/api/v1/blobs` | POST | Store a new blob |
| `/api/v1/blobs/:id` | GET | Retrieve a blob by ID |

### Authentication

<details open>
<summary><strong>Generate Authentication Token</strong></summary>

```http
POST /api/v1/tokens HTTP/1.1
Content-Type: application/json

{
  "username": "your-username",
  "password": "your-password"
}
```

#### Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": true,
  "message": "Token generated successfully",
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

> **Note**: During development, a default token is created when running `rails db:seed` and displayed in the console output.
</details>

### Blob Operations

<details open>
<summary><strong>Store a Blob</strong></summary>

```http
POST /api/v1/blobs HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
Content-Type: application/json

{
  "blob_id": "my-unique-blob-id",
  "data": "base64-encoded-content"
}
```

#### Response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "success": true,
  "message": "Blob created successfully",
  "data": {
    "id": "my-unique-blob-id23232",
    "data": null,
    "size": 44,
    "created_at": "2025-05-07T00:52:22.306Z"
  }
}
```

#### Error Response (Missing Parameters)

```http
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json

{
  "success": false,
  "message": "Missing required parameters",
  "details": "Both blob_id and data are required"
}
```
</details>

<details open>
<summary><strong>Retrieve a Blob</strong></summary>

```http
GET /api/v1/blobs/my-unique-blob-id HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "my-unique-blob-id",
  "data": "base64-encoded-content",
  "size": 1024,
  "created_at": "2025-05-06T00:00:00.000Z"
}
```

#### Error Response (Blob Not Found)

```http
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "success": false,
  "message": "Blob not found",
  "error_code": "storage.not_found"
}
```
</details>

### Error Responses

All errors follow a standardized format:

```json
{
  "error": true,
  "error_code": "error.category.specific_error",
  "message": "Human-readable error message"
}
```

Common HTTP status codes:

- `400 Bad Request`: Invalid input or validation error
- `401 Unauthorized`: Missing or invalid authentication token
- `404 Not Found`: Requested resource not found
- `500 Internal Server Error`: Server-side error

## Architecture

<div align="center">
  <img src="https://mermaid.ink/img/pako:eNqFkk1rwzAMhv9KUE4b7JCjYezQdo4NGrZdeuiMsRrbWVxiB1tZ6Zb8940_ShJa2B5s9Op5kZCs0ERZIR1pYPb8ICxK-KhAgnFXp1shE6HDhM_AqbcU0Fj_5m3QiZdlTLZ4n2A4g7F_aGCG4QbG-RFc0FpiVB-3YKX2OMO0d2jDGd7u3z4e_3iN_uIcXR6lHmmOO8laqPEMW2nwQmkxojkOPsHzHEqn1Ld7sP6V1FcNUQvfEKIlv61wZLHoHJM2Vz6ZRD4CWiVuKrwp3DFdowPt5D6TK4e4KlBpFBYljMfJfVj-ySvzYrp0FhP8Mf-2TtvSYX1Mej8ejzs92SL4c6PZPrFNRVVnrmpJoLPe0KIm75RSt7cO0kp7lytqKSzJIR-cYEpSZ7tJBQXZ7KWDJKK5xYR2eCRNSWKtCUhbF3MsuLNS-5rcTkqlO9rtxDmPdrRzPAfrh3FXx9Fl5W2sMF5f_QDzZdMZ" alt="Architecture Diagram">
</div>

Simple Drive follows a modular architecture where the storage implementations are decoupled from the controllers. Storage providers implement a common interface, allowing easy switching between backends.

### Key Components

- **Controllers**: Handle API requests and responses (`app/controllers/api/v1/`)
- **Models**: Define data structures and validations (`app/models/`)
- **Services**:
  - `TokenService`: JWT token generation and validation 
  - Storage providers: Implementations for different backends (`app/services/storage/`)
- **Error Handling**: Centralized in `ErrorCodes` module with localized messages

## Testing

<div align="center">
  <img src="https://img.shields.io/badge/test_coverage-comprehensive-brightgreen" alt="Test Coverage: Comprehensive">
</div>

Simple Drive includes a comprehensive test suite that covers all major components of the application, ensuring reliability and stability.

### Running Tests

<details open>
<summary><strong>Run All Tests</strong></summary>

```bash
bin/rails test
```
</details>

<details>
<summary><strong>Run Specific Test Categories</strong></summary>

```bash
# Run only model tests
bin/rails test:models

# Run only controller tests
bin/rails test:controllers

# Run a specific test file
bin/rails test test/models/auth_token_test.rb

# Run a specific test
bin/rails test test/models/auth_token_test.rb:42  # Line number of the test
```
</details>

### Test Coverage by Component

| Component | Description | Files |
|-----------|-------------|-------|
| **Models** | Entity validation and behavior | `test/models/*_test.rb` |
| **Controllers** | API endpoints and responses | `test/controllers/api/v1/*_test.rb` |
| **Services** | Storage backends and token service | `test/services/*_test.rb` |
| **Integration** | End-to-end API workflows | `test/integration/*_test.rb` |

## Development

### Project Structure

```
simple_drive/
├── app/
│   ├── controllers/api/v1/     # API endpoints
│   ├── models/                 # Data models
│   ├── services/               # Business logic
│   │   ├── storage/           # Storage backends
│   │   └── token_service.rb   # JWT authentication
│   └── validators/            # Custom validators
├── config/
│   ├── locales/en.yml         # Localized messages
│   └── storage.yml            # Storage configuration
└── test/                      # Comprehensive tests
```

### Key Components

- **Models**: `AuthToken`, `Blob`, `BlobBinaryStorage`
- **Controllers**: `TokensController`, `BlobsController`
- **Services**: `TokenService`, `Storage::BaseStorage` and implementations
- **Configuration**: `.env` for environment variables (not in version control)



## License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <p>Built with ❤️ by Abdulsalam</p>

</div>

