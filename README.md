# AIHOT — self-run AI hot-topics site with a daily digest. Deploy on Railway with one click.

Packages [KKKKhazix/AIHOT](https://github.com/KKKKhazix/AIHOT) (MIT, pinned to commit edfa18f) for Railway:
one app container (migrations + seed, then API, worker and web) plus PostgreSQL 17. Zero deploy-time inputs.

- Admin: `/admin`, password = `ADMIN_PASSWORD` in the service's Variables (auto-generated).
- Add `LLM_API_KEY` (and optionally `LLM_BASE_URL`, `LLM_MODEL`; any OpenAI-compatible API, DeepSeek by default) so the site can score, summarise and write the digest.
- Data: Postgres volume plus `/data` volume for stored files.
