# External Services & Integrations

> This file is loaded on-demand. Referenced from CLAUDE.md.

## API Cost Accounting (REQUIRED)

**Every feature that makes external API calls MUST log usage for cost tracking.**

## Configured Services

### Email (Resend)

**Purpose:** Transactional and notification emails
**Dashboard:** https://resend.com/overview
**Pricing:** Free tier — 3,000 emails/month
**Edge Functions:** `send-email`
**DB Tables:** `email_templates`, `inbound_emails`
**Supabase Secret:** `RESEND_API_KEY` (set)
**Default From:** `onboarding@resend.dev` (verify domain for custom)
**Webhook URL:** `https://cpyfckwfwbqyvwblaftv.supabase.co/functions/v1/resend-inbound-webhook`

#### Domain Verification (optional)
To send from your own domain, add DNS records at https://resend.com/domains:
- SPF record
- DKIM record
This improves deliverability and allows branded from-addresses.
