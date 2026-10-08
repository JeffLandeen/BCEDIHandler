codeunit 72343 "EDI 855 Ack - Text" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        Parser: Codeunit "EDI Payload Parser";
        DocumentLines: List of [Text];
        NotCompleteErr: Label 'Document handler logic is not complete - see developer';
    begin
        // Parse the payload into a Text-appropriate memory structure, then hand
        // off to (not yet implemented) mapping logic for this transaction set.
        DocumentLines := Parser.ParseAsTextLines(EDIInboundStaging.GetContentAsText());
        Error(NotCompleteErr);
    end;
}
