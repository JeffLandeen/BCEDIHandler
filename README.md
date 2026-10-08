# EDI Document Management (Proof of Concept)

A Business Central extension that stages **inbound** and **outbound** EDI documents
(Text, XML, JSON) in dedicated tables, with browsable list pages and full
import/export round-trip.

## What's included

### Tables
- **EDI Inbound Staging (72310)** — staging for received files. Stores the raw
  bytes in a `Content` Blob, plus document type, status, audit fields, a text
  preview and the file size.
- **EDI Outbound Staging (72311)** — staging for files to be sent out. Same shape,
  oriented around creation + export, with an optional link back to the inbound
  entry it was copied from.

### Pages
- **EDI Inbound Staging List (72320)** — browse inbound records; import a file,
  download the original, mark processed, copy to outbound.
- **EDI Inbound Staging Card (72321)** — detail view with content preview.
- **EDI Outbound Staging List (72322)** — browse outbound records; create a sample
  (Text/XML/JSON) and export to file.
- **EDI Outbound Staging Card (72323)** — detail view with content preview.

### Codeunits
- **EDI Import Mgt. (72330)** — `UploadIntoStream` → new inbound staging record.
- **EDI Export Mgt. (72331)** — sample-document generation and inbound→outbound copy.

### Enums
- **EDI Document Type (72300)** — Text / XML / JSON.
- **EDI Inbound Status (72301)** — New / Processing / Processed / Error.
- **EDI Outbound Status (72302)** — New / Ready to Export / Exported / Error.

## How the file handling works

- **Import:** `UploadIntoStream` opens the file picker, the resulting `InStream`
  is copied into the `Content` Blob via `CopyStream`. A UTF-8 text preview and the
  byte size are calculated and stored.
- **Export:** the `Content` Blob is opened as an `InStream` and handed to
  `DownloadFromStream`, which streams it back to the user's device.
- Blobs are used so any of the three formats are stored byte-for-byte; the
  preview/`GetContentAsText` helpers decode them as UTF-8 for display.

## Try it

1. Search for **EDI Inbound Documents** → **Import File**, pick a `.txt`, `.xml`
   or `.json` file. The document type is inferred from the extension.
2. Open the card to see the preview, or **Download Original** to verify the
   round-trip.
3. **Copy to Outbound** to push it to the outbound table, or open **EDI Outbound
   Documents** → **Create Sample** to generate one, then **Export File**.

## Build / deploy

1. Open the folder in **VS Code** with the **AL Language** extension installed.
2. Adjust `app.json` if needed:
   - `publisher` — set your name.
   - `application` / `runtime` — currently `24.0.0.0` / `13.0` (BC 2024 wave 1).
     Bump to match your target environment (e.g. runtime `15.0` for BC 2025 wave 1).
3. `AL: Download Symbols`, then `Ctrl+F5` to publish to your sandbox.

> Object IDs use the **72300–72399** range. Change `idRanges` in `app.json` (and the
> object IDs) if that range is taken in your environment.

## Notes / next steps (intentionally out of scope for the PoC)

- `MarkProcessed` is a stub — real processing (mapping to sales orders, journals,
  partner agreements, etc.) would replace its body.
- No automatic pickup (folder/SFTP/API) — import/export are user-triggered.
- No partner/transaction-set metadata, validation, or acknowledgements (997/CONTRL).

---

## External integration (API pages)

Two **API pages** expose the staging tables on Business Central's standard
OData v4 API endpoint, so external systems can push and pull EDI documents
without using the client UI actions.

| Purpose | Object | Entity set | Access |
|---|---|---|---|
| Write inbound docs | EDI Inbound API (72324) | `ediInboundDocuments` | POST (create), GET |
| Read / pick up outbound docs | EDI Outbound API (72325) | `ediOutboundDocuments` | GET, PATCH `status` |

Base URL (SaaS):

```
https://api.businesscentral.dynamics.com/v2.0/{tenant}/{environment}/api/contoso/edi/v1.0/companies({companyId})/{entitySet}
```

Document content is exchanged as the raw document text in the `content` field
(suitable for Text, XML and JSON). The service stamps `entryNo`, `status`,
`receivedDateTime`, `fileSizeBytes` and `importedBy` itself — payload values for
those are ignored.

### Push an inbound document

```http
POST .../ediInboundDocuments
Content-Type: application/json

{
  "documentType": "XML",
  "fileName": "order-123.xml",
  "content": "<?xml version=\"1.0\"?><Order><OrderNo>SO-1001</OrderNo></Order>"
}
```

`documentType` accepts `Text`, `XML` or `JSON`. The record lands in the inbound
table with status `New`, ready for processing.

### Pick up outbound documents

```http
GET .../ediOutboundDocuments?$filter=status eq 'ReadyToExport'&$select=entryNo,fileName,documentType,content
```

After collecting a document, mark it as picked up (optimistic concurrency
requires the row's `@odata.etag` in the `If-Match` header):

```http
PATCH .../ediOutboundDocuments({systemId})
If-Match: {etag}
Content-Type: application/json

{ "status": "Exported" }
```

This sets `exportedDateTime` automatically.

## Security model

Three assignable permission sets ship with the extension so you can give the
right access to each caller:

- **EDI Document Mgt. (72340)** — full RIMD over both tables and all pages.
  For interactive BC users / administrators.
- **EDI Inbound Integration (72341)** — read/insert/modify on the **inbound**
  table and execute on the inbound API only. Assign to the external account
  that submits documents. It has no access to the outbound table.
- **EDI Outbound Integration (72342)** — read/modify on the **outbound** table
  and execute on the outbound API only. Assign to the external account that
  collects documents. It cannot create outbound documents or read inbound ones.

Assign these to the integration user (or its OAuth/S2S app registration) under
**Users → User Permission Sets**. A caller without the relevant set receives a
permission error from the API — i.e. external access is gated by standard BC
permissions, as required.

> The API publisher/group/version are `contoso` / `edi` / `v1.0`. Change the
> `APIPublisher`, `APIGroup` and `APIVersion` properties on both API pages to
> match your own naming before publishing.
