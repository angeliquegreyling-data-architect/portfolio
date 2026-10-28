# Automated Enterprise Snapshot Aggregator & Analytics Framework
## Technical Architecture Specification & Automated Spreadsheet Normalization Pipeline

This infrastructure specification outlines a production-grade automated pipeline designed to ingest daily operational snapshot reporting data, handle multi-source data transformations, and generate structured data models optimized for executive-ready analytical dashboards.

### Inbound Architecture Map
* **Data Source:** Operational data captured via automated form endpoints.
* **Data Extraction Layer:** Proxy scripts monitoring mailboxes and extracting report files.
* **Intermediate Storage Layer:** Google Drive (Raw Snapshots) & SharePoint (Processed Ledger).
* **Automation Processing Layer:** Power Automate Orchestration and TypeScript Table formatters.
* **Analytics Visualization Layer:** Power BI Desktop models and cloud scheduled refreshes.

### 1. Automated Extraction & Repository Management
The pipeline replaces manual extraction loops with an automated scripting proxy. A dedicated script monitors the inbound data inbox, captures incoming spreadsheet attachments, commits the raw snapshot rows directly into an archival folder structure, and clears the processed message container to isolate the transaction and prevent multi-pass file duplication.

### 2. TypeScript Data Normalization Loop (Office Scripts)
Upon repository file drop detection, an automated workflow calls a custom TypeScript compiler script block to standardize the unstructured grid data into clean tables before downstream analytics systems query the row models.

```typescript
function main(workbook: ExcelScript.Workbook) {
  // Access target data sheet layer
  let targetSheet = workbook.getActiveWorksheet();
  let usedRange = targetSheet.getUsedRange();
  
  if (usedRange) {
    let rowCount = usedRange.getRowCount();
    let colCount = usedRange.getColumnCount();
    
    // Unmerge nested layout block headers to clean the table space
    usedRange.unmerge();
    
    // Algorithmic downward text fill to correct missing record identifiers
    for (let col = 0; col < colCount; col++) {
      let firstHeaderValue = targetSheet.getCell(0, col).getValue() as string;
      
      // Clean and normalize column header names to prevent structural schema drift
      if (firstHeaderValue) {
        let sanitizedHeader = firstHeaderValue.trim().toLowerCase().replace(/\s+/g, '_');
        targetSheet.getCell(0, col).setValue(sanitizedHeader);
      }
    }
    
    // Force the sanitized data array into a structured Table Object mapping contract
    let activeTable = workbook.addTable(usedRange.getAddress(), true);
    activeTable.setName("Canonical_Operational_Ledger");
  }
}
```

### 3. Power BI Analytical Modeling Layer
The structural table is published straight into a secure corporate space where Power BI runs incremental refreshes against the workspace records. By handling complex structural data modifications upstream inside the TypeScript loop, the analytical data model remains fast, lightweight, and focused on executing complex DAX calculations for final management review.
