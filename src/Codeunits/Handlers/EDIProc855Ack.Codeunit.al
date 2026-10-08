codeunit 72335 "EDI Proc. 855 Ack" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        TextHandler: Codeunit "EDI 855 Ack - Text";
        XmlHandler: Codeunit "EDI 855 Ack - XML";
        JsonHandler: Codeunit "EDI 855 Ack - JSON";
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
