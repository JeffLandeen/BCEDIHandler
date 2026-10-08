page 72325 "EDI Outbound API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'edi';
    APIVersion = 'v1.0';
    EntityName = 'ediOutboundDocument';
    EntitySetName = 'ediOutboundDocuments';
    SourceTable = "EDI Outbound Staging";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    Editable = true;
    Extensible = false;
    Caption = 'EDI Outbound API';

    layout
    {
        area(Content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Editable = false;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Editable = false;
                }
                field(fileFormat; Rec."File Format")
                {
                    Editable = false;
                }
                field(documentType; Rec."Document Type")
                {
                    Editable = false;
                }
                field(ediDocumentId; Rec."EDI Document ID")
                {
                    Editable = false;
                }
                field(tradingPartnerId; Rec."Trading Partner ID")
                {
                    Editable = false;
                }
                field(fileName; Rec."File Name")
                {
                    Editable = false;
                }
                field(status; Rec.Status)
                {
                    // Writable so a consumer can PATCH status to 'Exported'
                    // after picking the document up.
                }
                field(content; ContentText)
                {
                    Editable = false;
                }
                field(fileSizeBytes; Rec."File Size (Bytes)")
                {
                    Editable = false;
                }
                field(createdDateTime; Rec."Created DateTime")
                {
                    Editable = false;
                }
                field(exportedDateTime; Rec."Exported DateTime")
                {
                    Editable = false;
                }
                field(sourceInboundEntryNo; Rec."Source Inbound Entry No.")
                {
                    Editable = false;
                }
                field(errorMessage; Rec."Error Message")
                {
                    Editable = false;
                }
            }
        }
    }

    var
        ContentText: Text;

    trigger OnAfterGetRecord()
    begin
        ContentText := Rec.GetContentAsText();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        // When a consumer marks the document as picked up, stamp the time.
        if (Rec.Status = Rec.Status::Exported) and (Rec."Exported DateTime" = 0DT) then
            Rec."Exported DateTime" := CurrentDateTime();
        exit(true);
    end;
}
