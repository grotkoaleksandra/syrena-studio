# Database Schema Reference

> This file is loaded on-demand. Referenced from CLAUDE.md.

## Core Tables

### app_users
User accounts linked to Supabase Auth. Role: oracle|admin|staff|resident|associate|demo.
Columns: id, auth_user_id, email, display_name, role, avatar_url, person_id, permissions (JSONB), created_at

### people
Contacts, tenants, associates.
Columns: id, first_name, last_name, email, phone, type, notes, created_at

### property_config
Singleton JSONB configuration (name, timezone, features).
Columns: id (always 1), config (JSONB)

### brand_config
Singleton JSONB brand styling (colors, fonts, logos).
Columns: id (always 1), config (JSONB)

### media
All uploaded files (photos, documents, images).
Columns: id, url, filename, mime_type, width, height, caption, category, display_order, created_at

## Email Tables

### email_templates
Customizable email templates with subject/body/category.
Columns: id, name, subject, body, category, created_at, updated_at

### inbound_emails
Log of all received emails via Resend webhook.
Columns: id, from_email, to_email, subject, body_text, body_html, received_at

## Common Patterns

- All tables use UUID primary keys
- RLS is enabled on all tables (public read, authenticated write)
