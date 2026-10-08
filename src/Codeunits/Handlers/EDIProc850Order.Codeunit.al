codeunit 72334 "EDI Proc. 850 Order" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        TextHandler: Codeunit "EDI 850 Order - Text";
        XmlHandler: Codeunit "EDI 850 Order - XML";
        JsonHandler: Codeunit "EDI 850 Order - JSON";
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
