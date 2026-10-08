codeunit 72347 "EDI 856 ASN - XML" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        Parser: Codeunit "EDI Payload Parser";
        ParsedXml: XmlDocument;
        NotCompleteErr: Label 'Document handler logic is not complete - see developer';
    begin
        // Parse the payload into a XML-appropriate memory structure, then hand
        // off to (not yet implemented) mapping logic for this transaction set.
        ParsedXml := Parser.ParseAsXml(EDIInboundStaging.GetContentAsText());
        Error(NotCompleteErr);
    end;
}
