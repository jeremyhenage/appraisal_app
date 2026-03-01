# AppraisalApp — Documentation Index

> **"Operator Terminal"** — Tactical firearm appraisal for dealer decision support.  
> All documentation is grounded in the live codebase. Updated as of commit `9f8c4fb`.

---

## Start Here

| Document                               | Purpose                                                                    |
| -------------------------------------- | -------------------------------------------------------------------------- |
| [Codebase Tour](codebase_tour.md)      | Every file in the repo with a one-liner purpose. Start here if you're new. |
| [Phase 4 Plan](phases/phase_4_plan.md) | What's being built next                                                    |
| [Task Status](phases/task_status.md)   | Current completion state                                                   |

---

## Architecture

> Open `.excalidraw` files in **VS Code** with the [Excalidraw extension](https://marketplace.visualstudio.com/items?itemName=pomdtr.excalidraw-editor), or drag into [excalidraw.com](https://excalidraw.com).

| Document                                                   | Format     | What It Shows                                                            |
| ---------------------------------------------------------- | ---------- | ------------------------------------------------------------------------ |
| [System Overview](architecture/system_overview.excalidraw) | Excalidraw | Full system: Flutter → Firebase → Cloud Function → Gemini → Dashboard    |
| [Auth Flow](architecture/auth_flow.excalidraw)             | Excalidraw | Anonymous sign-in, macOS special case, Cloud Function auth guard         |
| [Data Flow](architecture/data_flow.excalidraw)             | Excalidraw | End-to-end: camera tap → image upload → Gemini analysis → deal dashboard |
| [Security Model](architecture/security_model.md)           | Markdown   | Firestore/Storage rules, auth guard, secrets inventory, threat model     |
| [LLM Usage](architecture/llm_usage.md)                     | Markdown   | Gemini config, prompt design, retry strategy, cost levers                |
| [Frontend Components](architecture/frontend_components.md) | Markdown   | Flutter widget tree, Riverpod dependency chain, all dart files           |
| [Backend Modules](architecture/backend_modules.md)         | Markdown   | Python Cloud Function modules, responsibilities, APIs                    |

---

## Phase Plans

| Document                               | Phase                            | Status         |
| -------------------------------------- | -------------------------------- | -------------- |
| [Phase 2 Plan](phases/phase_2_plan.md) | Backend Logic                    | ✅ Complete    |
| [Phase 3 Plan](phases/phase_3_plan.md) | Firebase Integration + UI        | ✅ Complete    |
| [Phase 4 Plan](phases/phase_4_plan.md) | RSR API, GunBroker, Auth Upgrade | 🔄 In Progress |

---

## Reviews

| Document                                                  | Purpose                               |
| --------------------------------------------------------- | ------------------------------------- |
| [Security & Cost Review](reviews/security_cost_review.md) | Vulnerability and cost audit findings |

---

## Key Facts (Quick Reference)

| Item             | Value                                       |
| ---------------- | ------------------------------------------- |
| GCP Project      | `firearmappraiser`                          |
| Cloud Function   | `appraise_item` (us-central1, 512MB)        |
| LLM Model        | `gemini-2.0-flash-exp` via Vertex AI        |
| Auth             | Anonymous (Firebase Auth)                   |
| Storage path     | `appraisals/{uid}/{timestamp}.jpg`          |
| Firestore        | Fully locked (`allow: false`)               |
| State management | Riverpod (`AsyncNotifier`)                  |
| Backend          | Python 3.11 + Pydantic v2 + tenacity        |
| Valuation        | RSR (mocked) + GunBroker (mocked) — Phase 4 |
