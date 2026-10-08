table 72311 "EDI Outbound Staging"
{
    Caption = 'EDI Outbound Staging';
    DataClassification = CustomerContent;
    LookupPageId = "EDI Outbound Staging List";
    DrillDownPageId = "EDI Outbound Staging List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "File Format"; Enum "EDI File Format")
        {
            Caption = 'File Format';
            DataClassification = CustomerContent;
        }
        field(3; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(4; Status; Enum "EDI Outbound Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(5; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Exported DateTime"; DateTime)
        {
            Caption = 'Exported DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; Content; Blob)
        {
            Caption = 'Content';
            DataClassification = CustomerContent;
        }
        field(8; "Content Preview"; Text[2048])
        {
            Caption = 'Content Preview';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "File Size (Bytes)"; Integer)
        {
            Caption = 'File Size (Bytes)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(11; "Source Inbound Entry No."; Integer)
        {
            Caption = 'Source Inbound Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "EDI Inbound Staging"."Entry No.";
            Editable = false;
        }
        field(12; "Document Type"; Enum "EDI Document Category")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(13; "EDI Document ID"; Code[10])
        {
            Caption = 'EDI Document ID';
            DataClassification = CustomerContent;
        }
        field(14; "Trading Partner ID"; Code[50])
        {
            Caption = 'Trading Partner ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Status; Status, "Created DateTime")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "File Name", "File Format", Status)
        {
        }
    }

    /// <summary>
    /// Creates a new outbound record from a text payload (Text/XML/JSON)
    /// and stores it UTF-8 encoded in the Content blob.
    /// </summary>
    procedure CreateFromText(NewFileName: Text; NewFileFormat: Enum "EDI File Format"; NewContent: Text)
    begin
        Init();
        "File Name" := CopyStr(NewFileName, 1, MaxStrLen("File Name"));
        "File Format" := NewFileFormat;
        "Created DateTime" := CurrentDateTime();
        Status := Status::ReadyToExport;
        Insert(true);
        SetContentFromText(NewContent);
    end;

    /// <summary>
    /// Writes the supplied text into the Content blob (UTF-8) and refreshes
    /// the preview and size helper fields.
    /// </summary>
    procedure SetContentFromText(NewContent: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Content);
        Content.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewContent);
        Modify(true);

        "File Size (Bytes)" := GetContentLength();
        "Content Preview" := CopyStr(NewContent, 1, MaxStrLen("Content Preview"));
        Modify(true);
    end;

    procedure GetContentAsText() Result: Text
    var
        InStream: InStream;
        Line: Text;
        Builder: TextBuilder;
    begin
        CalcFields(Content);
        if not Content.HasValue() then
            exit('');
        Content.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS() do begin
            InStream.ReadText(Line);
            Builder.AppendLine(Line);
        end;
        Result := Builder.ToText();
    end;

    procedure GetContentLength(): Integer
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        CalcFields(Content);
        if not Content.HasValue() then
            exit(0);
        TempBlob.CreateOutStream(OutStream);
        Content.CreateInStream(InStream);
        CopyStream(OutStream, InStream);
        exit(TempBlob.Length());
    end;

    /// <summary>
    /// Streams the stored content to the user's device as a downloadable
    /// file and flags the record as exported.
    /// </summary>
    procedure ExportToFile(): Boolean
    var
        InStream: InStream;
        ToFileName: Text;
        NoContentErr: Label 'There is no content to export for entry %1.', Comment = '%1 = Entry No.';
    begin
        CalcFields(Content);
        if not Content.HasValue() then
            Error(NoContentErr, "Entry No.");
        ToFileName := "File Name";
        Content.CreateInStream(InStream);
        if DownloadFromStream(InStream, 'Export EDI Document', '', 'All Files (*.*)|*.*', ToFileName) then begin
            Status := Status::Exported;
            "Exported DateTime" := CurrentDateTime();
            "Error Message" := '';
            Modify(true);
            exit(true);
        end;
        exit(false);
    end;
}
