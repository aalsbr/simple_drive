# Simple Drive

A Ruby on Rails API application for storing and retrieving binary data (blobs) with multiple storage backend options.

## Features

- Store blobs with POST `/v1/blobs`
- Retrieve blobs with GET `/v1/blobs/:id`
- Metadata stored in database (id, size, created_at, storage_provider, reference_path)
- Multiple storage backends:
  - Local File System
  - Database
  - Amazon S3 (via raw HTTP, no SDK)
- Bearer token authentication
- Base64 validation
- Configurable storage backend via environment variables

## Requirements

- Ruby 2.7.5+
- Rails 7.x
- SQLite (default) or PostgreSQL

## Quick Start

1. Clone the repository
2. Run setup:
   ```bash
   bin/setup
   ```
3. Set up the database:
   ```bash
   # Drop existing database and recreate it with the new schema
   rails db:drop db:create db:schema:load
   ```
4. Seed the database with a test token:
   ```bash
   rails db:seed
   ```
5. Start the server:
   ```bash
   rails server
   ```

## Configuration

### Storage Provider

Configure the storage provider using the `STORAGE_BACKEND` environment variable:

- `file` (default): Local file system
- `database` or `db`: Database storage
- `s3`: Amazon S3 storage

Example:
```bash
STORAGE_BACKEND=database rails server
```

### S3 Configuration

If using the S3 backend, set the following environment variables:

```bash
STORAGE_BACKEND=s3
S3_BUCKET_NAME=your-bucket-name
AWS_REGION=us-east-1 # Optional, defaults to us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

## API Usage

### Authentication

All API requests require a Bearer token for authentication.

Example:
```
Authorization: Bearer test-token-1234567890
```

The default token is created during database seeding and is output to the console.

### Store a Blob

```bash
POST /api/v1/blobs

Headers:
Authorization: Bearer <token>
Content-Type: application/json

Body:
{
  "blob_id": "my-unique-blob-id", # Optional, will generate a UUID if not provided
  "content": "base64-encoded-content"
}
```

Response:
```json
{
  "blob_id": "my-unique-blob-id",
  "size": 1024,
  "created_at": "2025-05-06T00:00:00.000Z",
  "storage_provider": "file"
}
```

### Retrieve a Blob

```bash
GET /api/v1/blobs/:id

Headers:
Authorization: Bearer <token>
```

Response:
```json
{
  "blob_id": "my-unique-blob-id",
  "size": 1024,
  "content": "base64-encoded-content",
  "created_at": "2025-05-06T00:00:00.000Z",
  "storage_provider": "file"
}
```

## Testing

Run the test suite with:

```bash
rails test
```

## License

MIT

