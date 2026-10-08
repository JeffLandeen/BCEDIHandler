codeunit 72331 "EDI Export Mgt."
{
    /// <summary>
    /// Creates a sample outbound document of the requested file format so the
    /// export round-trip can be demonstrated without external data.
    /// </summary>
    procedure CreateSampleOutbound(FileFormat: Enum "EDI File Format"): Integer
    var
        OutboundStaging: Record "EDI Outbound Staging";
        FileName: Text;
        Payload: Text;
    begin
        Payload := BuildSamplePayload(FileFormat, FileName);
        OutboundStaging.CreateFromText(FileName, FileFormat, Payload);
        exit(OutboundStaging."Entry No.");
    end;

    /// <summary>
    /// Copies an inbound document into the outbound table (for example to
    /// echo or forward a received message). PoC convenience helper.
    /// </summary>
    procedure CreateOutboundFromInbound(InboundStaging: Record "EDI Inbound Staging"): Integer
    var
        OutboundStaging: Record "EDI Outbound Staging";
        OutFileName: Text;
    begin
        OutFileName := 'OUT-' + InboundStaging."File Name";
        OutboundStaging.CreateFromText(OutFileName, InboundStaging."File Format", InboundStaging.GetContentAsText());
        OutboundStaging."Source Inbound Entry No." := InboundStaging."Entry No.";
        OutboundStaging."Document Type" := InboundStaging."Document Type";
        OutboundStaging."EDI Document ID" := InboundStaging."EDI Document ID";
        OutboundStaging."Trading Partner ID" := InboundStaging."Trading Partner ID";
        OutboundStaging.Modify(true);
        exit(OutboundStaging."Entry No.");
    end;

    local procedure BuildSamplePayload(FileFormat: Enum "EDI File Format"; var FileName: Text): Text
    var
        Builder: TextBuilder;
        Stamp: Text;
    begin
        Stamp := Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>-<Hours24,2><Minutes,2><Seconds,2>');
        case FileFormat of
            FileFormat::XML:
                begin
                    FileName := 'SAMPLE-' + Stamp + '.xml';
                    Builder.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
                    Builder.AppendLine('<Order>');
                    Builder.AppendLine('  <OrderNo>SO-1001</OrderNo>');
                    Builder.AppendLine('  <Customer>Contoso Ltd.</Customer>');
                    Builder.AppendLine('  <Lines>');
                    Builder.AppendLine('    <Line item="1000" qty="5" />');
                    Builder.AppendLine('    <Line item="1100" qty="2" />');
                    Builder.AppendLine('  </Lines>');
                    Builder.AppendLine('</Order>');
                end;
            FileFormat::JSON:
                begin
                    FileName := 'SAMPLE-' + Stamp + '.json';
                    Builder.AppendLine('{');
                    Builder.AppendLine('  "orderNo": "SO-1001",');
                    Builder.AppendLine('  "customer": "Contoso Ltd.",');
                    Builder.AppendLine('  "lines": [');
                    Builder.AppendLine('    { "item": "1000", "qty": 5 },');
                    Builder.AppendLine('    { "item": "1100", "qty": 2 }');
                    Builder.AppendLine('  ]');
                    Builder.AppendLine('}');
                end;
            else begin
                FileName := 'SAMPLE-' + Stamp + '.txt';
                Builder.AppendLine('HDR|SO-1001|Contoso Ltd.');
                Builder.AppendLine('LIN|1000|5');
                Builder.AppendLine('LIN|1100|2');
                Builder.AppendLine('TRL|2');
            end;
        end;
        exit(Builder.ToText());
    end;
}
