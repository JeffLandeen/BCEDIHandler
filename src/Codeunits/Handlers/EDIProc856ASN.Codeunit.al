codeunit 72336 "EDI Proc. 856 ASN" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        TextHandler: Codeunit "EDI 856 ASN - Text";
        XmlHandler: Codeunit "EDI 856 ASN - XML";
        JsonHandler: Codeunit "EDI 856 ASN - JSON";
        Handler: Interface "EDI Inbound Doc. Processor";
    begin
        case EDIInboundStaging."File Format" of
            EDIInboundStaging."File Format"::XML:
                Handler := XmlHandler;
            EDIInboundStaging."File Format"::JSON:
                Handler := JsonHandler;
            else
                Handler := TextHandler;
        end;
        Handler.ProcessInbound(EDIInboundStaging);
    end;
}
