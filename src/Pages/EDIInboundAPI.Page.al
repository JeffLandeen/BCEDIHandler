page 72324 "EDI Inbound API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'edi';
    APIVersion = 'v1.0';
    EntityName = 'ediInboundDocument';
    EntitySetName = 'ediInboundDocuments';
    SourceTable = "EDI Inbound Staging";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = true;
    Extensible = false;
    Caption = 'EDI Inbound API';

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
                }
                field(documentType; Rec."Document Type")
                {
                }
                field(ediDocumentId; Rec."EDI Document ID")
                {
                }
                field(tradingPartnerId; Rec."Trading Partner ID")
                {
                }
                field(inboundProcessingEngine; Rec."Inbound Processing Engine")
                {
                    Editable = false;
                }
                field(fileName; Rec."File Name")
                {
                }
                field(status; Rec.Status)
                {
                    Editable = false;
                }
                field(content; ContentText)
                {
                }
                field(fileSizeBytes; Rec."File Size (Bytes)")
                {
                    Editable = false;
                }
                field(receivedDateTime; Rec."Received DateTime")
                {
                    Editable = false;
                }
                field(importedBy; Rec."Imported By")
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        // Stamp server-controlled fields regardless of payload.
        Rec."Received DateTime" := CurrentDateTime();
        Rec."Imported By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Imported By"));
        Rec.Status := Rec.Status::New;
        if Rec."File Format" = Rec."File Format"::" " then
            Rec."File Format" := Rec."File Format"::Text;

        Rec.Insert(true);

        if ContentText <> '' then begin
            Rec.WriteContentText(ContentText);
            Rec.Modify(true);
        end;

        // We handled the insert ourselves; tell the framework not to repeat it.
        exit(false);
    end;

    trigger OnAfterGetRecord()
    begin
        ContentText := Rec.GetContentAsText();
    end;
}
