codeunit 72351 "EDI 810 Invoice - JSON" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        Parser: Codeunit "EDI Payload Parser";
        ParsedJson: JsonToken;
        NotCompleteErr: Label 'Document handler logic is not complete - see developer';
    begin
        // Parse the payload into a JSON-appropriate memory structure, then hand
        // off to (not yet implemented) mapping logic for this transaction set.
        ParsedJson := Parser.ParseAsJson(EDIInboundStaging.GetContentAsText());
        Error(NotCompleteErr);
    end;
}
