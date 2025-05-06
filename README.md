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

### Storage Backend Configuration

Simple Drive supports multiple storage backends that can be configured through environment variables. Set the main storage type using:

```bash
STORAGE_BACKEND=<type>  # One of: file, database, s3, ftp
```

<details>
<summary><strong>📁 File System Storage (Default)</strong></summary>

```bash
STORAGE_BACKEND=file
STORAGE_PATH=/path/to/storage  # Optional, defaults to tmp/storage
```

Blobs will be stored in the local filesystem. This is the simplest option and works well for development and testing.
</details>

<details>
<summary><strong>💾 Database Storage</strong></summary>

```bash
STORAGE_BACKEND=database  # or db
```

Blobs will be stored directly in the PostgreSQL database in the `blob_binary_storages` table. Good for small files when you want to keep everything in one place.
</details>

<details>
<summary><strong>☁️ Amazon S3 Storage</strong></summary>

```bash
STORAGE_BACKEND=s3
S3_BUCKET_NAME=your-bucket-name
AWS_REGION=us-east-1            # Optional, defaults to us-east-1
AWS_ACCESS_KEY_ID=your-key-id
AWS_SECRET_ACCESS_KEY=your-secret-key
S3_ENDPOINT=custom-endpoint    # Optional, for S3-compatible services
```

Stores blobs in Amazon S3 or any S3-compatible service like MinIO or DigitalOcean Spaces.
</details>

<details>
<summary><strong>📡 FTP Storage</strong></summary>

```bash
STORAGE_BACKEND=ftp
FTP_HOST=ftp.example.com
FTP_USER=username
FTP_PASSWORD=password
FTP_DIRECTORY=/remote/path     # Remote directory to store files
FTP_PASSIVE=true              # Optional, use passive mode
FTP_PORT=21                   # Optional, defaults to 21
```

Stores blobs on a remote FTP server. Useful for integrating with legacy systems.
</details>

### Authentication Configuration

```bash
JWT_SECRET=your-secure-secret-key  # Required for token generation/validation
JWT_EXPIRATION=30                 # Optional: token expiration in days, default: 30
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
  "blob_id": "my-unique-blob-id",  // Optional, auto-generated UUID if omitted
  "content": "base64-encoded-content"
}
```

#### Response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "blob_id": "my-unique-blob-id",
  "size": 1024,
  "created_at": "2025-05-06T00:00:00.000Z",
  "storage_provider": "file"
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
  "blob_id": "my-unique-blob-id",
  "size": 1024,
  "content": "base64-encoded-content",
  "created_at": "2025-05-06T00:00:00.000Z",
  "storage_provider": "file"
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <p>Built with ❤️ by Your Name</p>
  <p>
    <a href="https://github.com/yourusername">GitHub</a> •
    <a href="https://twitter.com/yourusername">Twitter</a>
  </p>
</div>

