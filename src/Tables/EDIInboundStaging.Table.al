table 72310 "EDI Inbound Staging"
{
    Caption = 'EDI Inbound Staging';
    DataClassification = CustomerContent;
    LookupPageId = "EDI Inbound Staging List";
    DrillDownPageId = "EDI Inbound Staging List";

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
        field(4; Status; Enum "EDI Inbound Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(5; "Received DateTime"; DateTime)
        {
            Caption = 'Received DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Processed DateTime"; DateTime)
        {
            Caption = 'Processed DateTime';
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
        field(11; "Imported By"; Code[50])
        {
            Caption = 'Imported By';
            DataClassification = EndUserIdentifiableInformation;
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
        field(15; "Inbound Processing Engine"; Enum "EDI Inbound Processing Engine")
        {
            Caption = 'Inbound Processing Engine';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Status; Status, "Received DateTime")
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
    /// Creates a new inbound record from an uploaded stream and stores the
    /// raw bytes in the Content blob. File format is inferred from the
    /// file extension and can be overridden afterwards.
    /// </summary>
    procedure CreateFromStream(var SourceInStream: InStream; SourceFileName: Text)
    var
        OutStream: OutStream;
    begin
        Init();
        "File Name" := CopyStr(SourceFileName, 1, MaxStrLen("File Name"));
        "File Format" := DetermineFileFormat(SourceFileName);
        "Received DateTime" := CurrentDateTime();
        "Imported By" := CopyStr(UserId(), 1, MaxStrLen("Imported By"));
        Status := Status::New;
        Insert(true);

        Content.CreateOutStream(OutStream);
        CopyStream(OutStream, SourceInStream);
        Modify(true);

        "File Size (Bytes)" := GetContentLength();
        "Content Preview" := CopyStr(GetContentAsText(), 1, MaxStrLen("Content Preview"));
        Modify(true);
    end;

    /// <summary>
    /// Returns the stored content decoded as UTF-8 text. Suitable for
    /// Text, XML and JSON payloads.
    /// </summary>
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

    /// <summary>
    /// Returns the size in bytes of the stored content.
    /// </summary>
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
    /// Writes a text payload (Text/XML/JSON) into the Content blob and
    /// refreshes the preview and size helpers. Performs no Insert/Modify, so
    /// it is safe to call before the record is committed (e.g. from the API
    /// page insert trigger).
    /// </summary>
    procedure WriteContentText(NewContent: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        BlobOutStream: OutStream;
        TempOutStream: OutStream;
    begin
        Clear(Content);
        Content.CreateOutStream(BlobOutStream, TextEncoding::UTF8);
        BlobOutStream.WriteText(NewContent);

        TempBlob.CreateOutStream(TempOutStream, TextEncoding::UTF8);
        TempOutStream.WriteText(NewContent);
        "File Size (Bytes)" := TempBlob.Length();
        "Content Preview" := CopyStr(NewContent, 1, MaxStrLen("Content Preview"));
    end;

    /// <summary>
    /// Re-downloads the originally imported file to the user's device.
    /// </summary>
    procedure DownloadOriginal()
    var
        InStream: InStream;
        ToFileName: Text;
        NoContentErr: Label 'There is no content stored for entry %1.', Comment = '%1 = Entry No.';
    begin
        CalcFields(Content);
        if not Content.HasValue() then
            Error(NoContentErr, "Entry No.");
        ToFileName := "File Name";
        Content.CreateInStream(InStream);
        DownloadFromStream(InStream, 'Download EDI Document', '', 'All Files (*.*)|*.*', ToFileName);
    end;

    /// <summary>
    /// PoC processing stub: marks the document as processed. Real logic
    /// (mapping into orders, journals, etc.) would replace this body.
    /// </summary>
    procedure MarkProcessed()
    begin
        Status := Status::Processed;
        "Processed DateTime" := CurrentDateTime();
        "Error Message" := '';
        Modify(true);
    end;

    local procedure DetermineFileFormat(FileName: Text): Enum "EDI File Format"
    begin
        case LowerCase(GetFileExtension(FileName)) of
            'xml':
                exit("EDI File Format"::XML);
            'json':
                exit("EDI File Format"::JSON);
            else
                exit("EDI File Format"::Text);
        end;
    end;

    local procedure GetFileExtension(FileName: Text): Text
    var
        i: Integer;
    begin
        for i := StrLen(FileName) downto 1 do
            if FileName[i] = '.' then
                exit(CopyStr(FileName, i + 1));
        exit('');
    end;
}
