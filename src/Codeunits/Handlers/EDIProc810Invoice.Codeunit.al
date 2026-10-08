codeunit 72337 "EDI Proc. 810 Invoice" implements "EDI Inbound Doc. Processor"
{
    Access = Internal;

    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        TextHandler: Codeunit "EDI 810 Invoice - Text";
        XmlHandler: Codeunit "EDI 810 Invoice - XML";
        JsonHandler: Codeunit "EDI 810 Invoice - JSON";
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
