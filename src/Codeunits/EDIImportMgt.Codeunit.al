codeunit 72330 "EDI Import Mgt."
{
    /// <summary>
    /// Prompts the user to pick a file and stages it as an inbound EDI
    /// document. Returns true and the created entry number on success.
    /// </summary>
    procedure ImportInboundFile(var CreatedEntryNo: Integer): Boolean
    var
        InboundStaging: Record "EDI Inbound Staging";
        InStream: InStream;
        FileName: Text;
    begin
        if not UploadIntoStream('Select EDI Document', '', 'All Files (*.*)|*.*', FileName, InStream) then
            exit(false);

        InboundStaging.CreateFromStream(InStream, FileName);
        CreatedEntryNo := InboundStaging."Entry No.";
        exit(true);
    end;

    /// <summary>
    /// Convenience overload that does not return the created entry number.
    /// </summary>
    procedure ImportInboundFile(): Boolean
    var
        DummyEntryNo: Integer;
    begin
        exit(ImportInboundFile(DummyEntryNo));
    end;
}
